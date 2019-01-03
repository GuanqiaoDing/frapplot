#' Exclude samples from the dataset
#'
#' @description If certain samples are of poor quality, use this function to exclude them from the dataset.
#'
#' @param ds Name of the dataset.
#' @param group Name of the group from which to exclude certain samples.
#' @param cols A vector of numbers specifying the column(s) to exclude.
#'
#' @return Modified dataset in the same format.
#'
#' @examples
#' ds <- exclude(example_dataset, group = "mut1", cols = c(1,3))
#'
#' @export

exclude <- function (ds, group, cols) {
  index <- which(names(ds) == group)
  ma <- ds[[index]]
  ds[[index]] <- ma[,-cols]
  return (ds)
}
