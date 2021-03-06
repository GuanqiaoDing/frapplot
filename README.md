# Automatic Data Analysis and Visualization for FRAP

[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/frapplot)](https://cran.r-project.org/web/packages/frapplot/index.html)
[![Build Status](https://travis-ci.org/GuanqiaoDing/frapplot.svg?branch=master)](https://travis-ci.org/GuanqiaoDing/frapplot)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)

This R package aims to automatically process Fluorescence Recovery After Photobleaching (FRAP) data and generate consistent, publishable figures. The automation would bring down the hour-long routine work to a few seconds.

Tired of tedious manual quantification of raw images? Check out my [`fraptrack`](https://github.com/GuanqiaoDing/fraptrack) repository :)

## Method

FRAP image courtesy of [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/):

<img src="img/Demo_FRAP.gif" alt="FRAP image" width="200px">

(The top-left puncta is the targeted area.)

<img src="img/Demo_Method.png" alt="Method" width="500px">

## Features

- Batch calculations and regressions for all the groups from the dataset and summarize the results by group names in a dataframe:

<img src="img/Demo_Result.png" alt="Summary result demo" width="700px">

- Access details about the regression of individual groups by simple indexing:

<img src="img/Demo_Detail.png" alt="Access details demo" width="500px">

- Generate figures in a consistent and publishable format:

<img src="img/Demo_Plot.jpg" alt="Output figure demo">

- Compare results of any two groups with a single command.

- Have tested with a real-world dataset from a FRAP experiment.

## Updates in Version 0.1.2

- Exclude certain sample(s) from the dataset (e.g. poor quality due to technical reasons)
```R
# remove sample(column) 1 and 3 from "mut1" data 
modified <- exclude(example_dataset, "mut1", c(1,3))
```

- `frapprocess()` and `frapplot()` now validate the input before execution. Raise Error when input is not valid and provide specific instructions.

View [update history](./NEWS).

## Install

```R
# Install frapplot from CRAN:
install.packages("frapplot")

# Install frapplot from Github:
install.packages("devtools")
devtools::install_github("GuanqiaoDing/frapplot")

# Load frapplot
library(frapplot)

# bring up the manual
?frapprocess
?frapplot
```

## Usage

Example use of frapprocess and frapplot:

```R
# after the preprocessing (refer to ./data-raw/preprocess.R)
load("data/example_dataset.rda")
info <- frapprocess(example_dataset, seq(0, 145, 5))

# view results
info$summary
info$details

# plot any two groups as desired
frapplot ("output_dir", "control", "mut1", info)
frapplot ("output_dir", "control", "mut2", info)
```

Note:

- Raw data can either be in a single file or separate files, refer to [preprocess.R](./data-raw/preprocess.R) for more information.

- Make sure the names (case-sensitive) you provide to `frapplot()` are correct;

- Make sure "info" (the third argument) remains in your global environment and refers to the same experiment before you run `frapplot()`, otherwise re-run `frapprocess()` and get its return value.

## Outputs

`frapplot()` returns a list (if assigned to variable "info"):

- info$time_points: a vector of time points

- info$summary: a dataframe showing the summary of the regression including ymax, ymin, k, halftime, tau, total_recovery, total_recovery_sd.

- info$sample_means: a matrix of sample means, nrow = num of time points, ncol = sample size

- info$sample_sd: a matrix of standard deviations, nrow = num of time points, ncol = sample size

- info$model: a list of models for each group from the non-linear regression

- info$details: details of the regression for each group

`frapplot()` generates a pdf file that compares two groups of choice in the provided directory.

## Test with An Example Dataset

An example dataset can be found [here](./data-raw), which is courtesy of [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/) and should never be used for other purposes.

The [preprocessing](./data-raw/preprocess.R) generates ".rda" file that is ready to be loaded. The code has been tested with the example dataset and generates [expected results](./data-output). Note that only five samples are included in each group of this dataset for demonstration, but larger sample size is highly recommended for statistical robustness.

The code has also passed R CMD check.

## Report Issues

Please report any bugs or issues [here](https://github.com/GuanqiaoDing/frapplot/issues/new). The project also welcomes your contribution.

## License

`frapplot` is licensed under the MIT License - see [LICENSE](./LICENSE) for the details.

## Acknowledgements

I truly appreciate the help and resources provided by [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/) at UT Southwestern Medical Center for this project.
