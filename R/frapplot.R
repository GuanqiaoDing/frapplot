#' Plot FRAP data of two samples
#'
#' @description Takes in group names (e.g. control, mutant, etc.) and plot their data. Note: [frapprocess()] needs to run and process the data first.
#' @param control Name of the control.
#' @param mutant Name of the mutant.
#' @return The function has no return value. Instead, it outputs the plot as a pdf file.
#' @seealso Find more about FRAP, input data formats and methods used for the processing at the [Github page](https://github.com/GuanqiaoDing).
#' @export

frapplot <- function(control, mutant){

  setwd(output_dir)
  filename <- paste(control, "_", mutant, ".pdf", sep = "")
  pdf(filename, width = 8, height = 6)

  index1 <- which(FRAPdata$sample_names == control)
  index2 <- which(FRAPdata$sample_names == mutant)
  y1 <- sample_means[, index1]
  y2 <- sample_means[, index2]

  par(mar=c(5, 5, 3, 3))

  #plot data points and axis label
  plot(x, y1,
       pch = 21, bg = 'black', col = 'black',
       axes = FALSE, xlab = "Time (s)", ylab = "Fractional Recovery",
       cex.lab = 1.5, xlim = c(0, 150), ylim = c(0, 1),
       mgp = c(2, 1, 0), cex.axis = 1.2)
  points(x, y2, pch = 21, bg = 'blue', col = 'blue')

  #plot axes
  axis(1, seq(0, 150, 25), tck = -0.02,
       cex.axis = 1.2, mgp = c(2, 1, 0), pos = 0)
  axis(2, seq(0, 1, 0.2), c("0", "0.2", "0.4", "0.6", "0.8", "1.0"),
       tck = -0.02, cex.axis = 1.2,
       mgp = c(2, 1, 0), pos = 0, las = 1)

  #plot error bars
  upper <- sample_means + sample_sd
  lower <- sample_means - sample_sd
  arrows(x, upper[, index1], x, lower[, index1],
         length = 0.05, angle = 90, code = 3, lwd = 1.5, col = 'black')
  arrows(x, upper[, index2], x, lower[, index2],
         length = 0.05, angle = 90, code = 3, lwd = 1.5, col = 'blue')

  #plot fitted curves
  lines(x, predict(mod[[index1]], list(x)), lwd = 2, col = 'black')
  lines(x, predict(mod[[index2]], list(x)), lwd = 2, col = 'blue')

  #plot legend
  legend(x = 5, y = 1.05, legend = c(control, mutant),
         lty = c(1,1), lwd = 2, pch = c(20, 20), col = c('black', 'blue'),
         bty = 'n', cex = 1.5)

  dev.off()

}
