#' Process FRAP data
#'
#' @description
#' Normalize and analyze FRAP data. Perform non-linear regression and calculate ymax, ymin, k, halftime, tau, total_recovery, total_recovery_sd.
#'
#' Reference: Brian L. Sprague, et al. Analysis of Binding Reactions by Fluorescence Recovery after Photobleaching. Biophys J (2004) <https://doi.org/10.1529/biophysj.103.026765>
#'
#' @param ds A dataset that contains FRAP data for multiple experiment groups
#' @param time_points A vector of time points (in second) that the experiment uses, e.g. 0, 5, 10, ....
#'
#' @return
#' A list of results:
#'   * $time_points: a vector of time points
#'   * $summary: summary of the analysis
#'   * $sample_means: a matrix of sample means, nrow = num of time points, ncol = sample size
#'   * $sample_sd: a matrix of standard deviations, nrow = num of time points, ncol = sample size
#'   * $model: result of non-linear regression model
#'
#' @examples
#' # after load("data/example_dataset.rda")
#' info <- frapprocess(example_dataset, seq(0, 145, 5))
#'
#' @export

frapprocess <- function(ds, time_points) {

  group_names <- names(ds)
  num <- length(group_names)
  result <- data.frame(group_names = group_names,
                         ymax = rep(0, num),
                         ymin = rep(0, num),
                         k = rep(0, num),
                         halftime = rep(0, num),
                         tau = rep(0, num),
                         total_recovery = rep(0, num),
                         total_recovery_sd = rep(0, num))

  # normalize data
  for (i in 1: num) {
    cur <- ds[[i]]
    normalized <- t(t(cur)/cur[1,])
    ds[[i]] <- normalized[-1,]
  }

  # calculate sample mean and standard deviation
  sample_means <- matrix(0, nrow = length(time_points), ncol = num)
  sample_sd <- matrix(0, nrow = length(time_points), ncol = num)

  for (i in 1 : num){
    sample_means[, i] <- rowMeans(ds[[i]])
    for (j in 1 : length(time_points)){
      sample_sd[j, i] <- sd(ds[[i]][j, ])
    }
  }

  # non-linear curve fitting
  mod <- vector("list", num)
  parameter <- vector("list", num)

  for (i in 1 : num){
    cur_dataframe <- data.frame(time = time_points, FR = sample_means[, i])
    c.0 <- max(cur_dataframe$FR) * 1.1
    model.0 <- lm(log(c.0 - FR) ~ time, data = cur_dataframe)
    start <- list(a = exp(coef(model.0)[1]), b=coef(model.0)[2], c=c.0)
    mod[[i]] <- nls(FR ~ c - a * exp(b * time),
                    data = cur_dataframe, start = start)

    # calculate ymax, ymin, k, tau
    # convert to formula: y = ymax+ (ymin-ymax) * exp(-k * t)
    ymax <- coef(mod[[i]])[3]
    ymin <- coef(mod[[i]])[3] - coef(mod[[i]])[1]
    k <- coef(mod[[i]])[2] * (-1)
    halftime <- 1 / k * log(2)
    tau <- 1 / halftime
    total_recovery <- (ymax - ymin) / (1 - ymin)
    a.sd <- summary(mod[[i]])$coefficients[1, 2]
    b.sd <- summary(mod[[i]])$coefficients[1, 2]
    + summary(mod[[i]])$coefficients[3, 2]
    sdtemp <- sqrt((a.sd / (ymax - ymin))^2
                   + (b.sd / (1 - ymin))^2
                   - 2 * a.sd * b.sd / (ymax - ymin) / (1 - ymin))
    total_recovery_sd <- total_recovery * sdtemp

    # copy the results
    result[i, "ymax"] <- ymax
    result[i, "ymin"] <- ymin
    result[i, "k"] <- k
    result[i, "halftime"] <- halftime
    result[i, "tau"] <- tau
    result[i, "total_recovery"] <- total_recovery
    result[i, "total_recovery_sd"] <- total_recovery_sd
  }

  output <- list(time_points = time_points, summary = result, sample_means = sample_means, sample_sd = sample_sd, model = mod)

  return (output)
}
