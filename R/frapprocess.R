#' Process FRAP data
#'
#' @importFrom stats coef lm nls predict sd
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
#'   * $summary: summary of the regression
#'   * $sample_means: a matrix of sample means, nrow = num of time points, ncol = sample size
#'   * $sample_sd: a matrix of standard deviations, nrow = num of time points, ncol = sample size
#'   * $model: a list of models for each group from the non-linear regression
#'   * $details: details of the regression for each group
#'
#' @examples
#' # after load("data/example_dataset.rda")
#' info <- frapprocess(example_dataset, seq(0, 145, 5))
#'
#' @export

frapprocess <- function(ds, time_points) {
  
  # validate input
  if(!is.list(ds) || is.null(names(ds))) {
    stop("Dataset should be a list of matrices containing data of each group. 
         Each item in the list has a name that identifies the group.")
  } 
  else {
    len.x <- length(time_points)
    for (i in 1: length(ds)) {
      name <- names(ds)[i]
      len <- length(ds[[i]])
      
      if(!is.matrix(ds[[i]])) {
        stop(sprintf("Each item in the list is a matrix. 
            Each column contains data from one cell/sample.
            The %dth item of the list named %s is not a matrix.", i, name))
      }
      else if(len %% (len.x+1) != 0) {
        stop(sprintf("The number of rows in the %dth item of the list named %s
            does not match the length of the time_points provided.
            The matrix needs %d rows which is 1 + length(time_points).", i, name, len.x+1))
      }
    }
  }
  
  group_names <- names(ds)
  num <- length(group_names)

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
  result <- data.frame(group_names = group_names,
                       ymax = rep(0, num),
                       ymin = rep(0, num),
                       k = rep(0, num),
                       halftime = rep(0, num),
                       tau = rep(0, num),
                       total_recovery = rep(0, num),
                       total_recovery_sd = rep(0, num))

  mod <- vector("list", num)
  parameter <- vector("list", num)
  details <- vector("list", num)

  for (i in 1 : num){
    cur_dataframe <- data.frame(time = time_points, FR = sample_means[, i])

    c.0 <- max(cur_dataframe$FR) * 1.1
    model.0 <- lm(log(c.0 - FR) ~ time, data = cur_dataframe)
    start <- list(a = exp(coef(model.0)[1]), b=coef(model.0)[2], c=c.0)

    mod[[i]] <- nls(FR ~ c - a * exp(b * time),
                    data = cur_dataframe, start = start)
    details[[i]] <- summary(mod[[i]])

    # calculate ymax, ymin, k, tau
    # convert to formula: y = ymax+ (ymin-ymax) * exp(-k * t)
    ymax <- coef(mod[[i]])[3]
    ymin <- coef(mod[[i]])[3] - coef(mod[[i]])[1]
    k <- coef(mod[[i]])[2] * (-1)

    halftime <- 1 / k * log(2)
    tau <- 1 / halftime

    total_recovery <- (ymax - ymin) / (1 - ymin)

    a.sd <- details[[i]]$coefficients[1, 2]
    b.sd <- details[[i]]$coefficients[1, 2] + details[[i]]$coefficients[3, 2]

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

  output <- list(time_points = time_points, summary = result,
                 sample_means = sample_means, sample_sd = sample_sd, model = mod, details = details)

  return (output)
}
