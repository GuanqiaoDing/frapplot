#' Process FRAP data
#'
#' @description Takes time-lapse data from ImageJ after the intensity quantification, perform normalization, calculations and non-linear curve fitting. The results are written to output files and returned to be used for [frapplot()].
#'    The raw data is organized as below, which is complied with the regular practice when processing imageJ time-lapse data by hand:
#'  * There is a main folder for the experiment (rawdata direcotry)
#'  * Each group (e.g. control, mutant1, mutant2, etc.) is in a subfolder
#'  * In each subfolder, there are multiple ".txt" files for individual samples where the number equals to the sample size (the function uses ".txt" as a pattern to read all relavant files)
#'  * In each file, the first value is the fluorecent intensity before the bleach, followed by the time-lapse values, one value per line
#' @param rawdata_dir  Absolute or relative path of the rawdata directory.
#' @param time_points A vector of time points (in second) that match raw data.
#' @return Results used for the plot as a list.
#'     It also generates output files:
#'  * One file for each group that contains normalized data.
#'  * One summary file of the sample means.
#'  * One summary file of the sample standard deviations.
#'  * One summary file of the parameters/results: ymax, ymin, k, halftime, tau, total_recovery, total_recovery_sd.
#' @examples
#' \dontrun{
#' info <- frapprocess("~/experiment/rawdata")
#' frapplot("name1", "name2", info)
#' }
#' @export

frapprocess <- function(rawdata_dir, time_points = seq(0, 145, 5)) {
  #set working directory
  setwd(rawdata_dir)

  #(sub)folder_names means group names, e.g. control, mutant1, mutant2
  folder_names <- dir()
  folder_num <- length(folder_names)
  file_numvec <- rep(0, folder_num)

  #initiate data
  x <- time_points;
  y <- vector("list", folder_num)
  FRAPdata <- data.frame(sample_names = folder_names,
                         ymax = rep(0, folder_num),
                         ymin = rep(0, folder_num),
                         k = rep(0, folder_num),
                         halftime = rep(0, folder_num),
                         tau = rep(0, folder_num),
                         total_recovery = rep(0, folder_num),
                         total_recovery_sd = rep(0, folder_num))

  #read files from each subfolder and merge data into matrices
  for(i in 1 : folder_num){
    file_names <- list.files(folder_names[i], pattern = ".txt")
    file_numvec[i] <- length(file_names)

    y[[i]] <- matrix(0, nrow = 31, ncol = file_numvec[i])

    for (j in 1: file_numvec[i]){
      cur_path <- paste(getwd(), "/", folder_names[i],
                        "/", file_names[j], sep = "")
      cur_data <- read.table(cur_path, header = FALSE)
      normalized <- cur_data/cur_data[1, ]
      #normalize to data at t0
      y[[i]][, j] <- as.vector(normalized[, 1])
    }
    #remove the first datapoint at t0
    y[[i]] <- y[[i]][-1, ]
  }

  #calculate mean and standard deviation
  sample_means <- matrix(0, nrow = 30, ncol = folder_num)
  sample_sd <- matrix(0, nrow = 30, ncol = folder_num)

  for (i in 1 : folder_num){
    sample_means[, i] <- rowMeans(y[[i]])
    for (j in 1 : 30){
      sample_sd[j, i] <- sd(y[[i]][j, ])
    }
  }

  #Non-linear curve fitting
  mod <- vector("list", folder_num)
  parameter <- vector("list", folder_num)

  for (i in 1 : folder_num){
    cur_dataframe <- data.frame(time = x, FR = sample_means[, i])
    c.0 <- max(cur_dataframe$FR) * 1.1
    model.0 <- lm(log(c.0 - FR) ~ time, data = cur_dataframe)
    start <- list(a = exp(coef(model.0)[1]), b=coef(model.0)[2], c=c.0)
    mod[[i]] <- nls(FR ~ c - a * exp(b * time),
                    data = cur_dataframe, start = start)

    #calculate ymax, ymin, k, tau
    #convert to formula: y = ymax+ (ymin-ymax) * exp(-k * t)
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

    #copy the results in FRAPdata
    FRAPdata[i, "ymax"] <- ymax
    FRAPdata[i, "ymin"] <- ymin
    FRAPdata[i, "k"] <- k
    FRAPdata[i, "halftime"] <- halftime
    FRAPdata[i, "tau"] <- tau
    FRAPdata[i, "total_recovery"] <- total_recovery
    FRAPdata[i, "total_recovery_sd"] <- total_recovery_sd
  }

  #Output all results
  setwd("../")
  dir.create("output")
  output_dir <- paste(getwd(), "/", "output", sep = "")

  for (i in 1 : folder_num){
    write.table(y[[i]],
                file = paste(output_dir, "/", folder_names[i], ".txt", sep = ""),
                quote = FALSE, row.names = FALSE, col.names = FALSE)
  }
  write.table(sample_means, file = paste(output_dir, "/sample_means.txt", sep = ""),
              quote = FALSE, col.names = folder_names, row.names = FALSE)
  write.table(sample_sd, file = paste(output_dir, "/sample_sd.txt", sep = ""),
              quote = FALSE, col.names = folder_names, row.names = FALSE)

  write.table(FRAPdata, file = paste(output_dir, "/FRAPsummary.txt", sep = ""),
              quote = FALSE, row.names = FALSE, col.names = TRUE)

  #return info used for frapplot()
  return (list(x, FRAPdata, sample_means, sample_sd, mod, output_dir))
}
