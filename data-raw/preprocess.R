# Generate data files from raw data
#
# Assume working direcory is root directory of the package
#
# Preprocess data:
# 1) If raw data is in one file, just read.table and convert to matrix, e.g. "control", "mutant1" data in the example dataset.
# Data format:
# - Each column is one time-lapse experiment (one sample).
# - The first value is the intensity before the bleach, which is followed by the time-lapse values after the bleach.
# - The first value is used for normalization only and not used in the plotting.
#
# 2) Optional: If raw data is in separate files, use the frapjoin() function, e.g. "mutant2" data in the example dataset.

frapjoin <- function (data_dir) {
  sample_names <- dir(data_dir)
  data <- unname(as.matrix(read.table(paste(data_dir, sample_names[1], sep = "/"))))
  for (i in 2: length(sample_names)) {
    sample_data <- unname(as.matrix(read.table(paste(data_dir, sample_names[i], sep = "/"))))
    data <- cbind(data, sample_data)
  }
  return (data)
}

control <- unname(as.matrix(read.table("data-raw/control.txt")))
mut1 <- unname(as.matrix(read.table("data-raw/mutant1.txt")))
mut2 <- frapjoin("data-raw/mutant2")

example_dataset <- list(control = control, mut1 = mut1, mut2 = mut2)

usethis::use_data(example_dataset, overwrite = TRUE)
