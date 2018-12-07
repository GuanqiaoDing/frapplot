# Automatic Data Processing and Visualization for FRAP
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/GuanqiaoDing/frapplot.svg?branch=master)](https://travis-ci.org/GuanqiaoDing/frapplot)

This R package aims to automatically process Fluorescence Recovery After Photobleaching (FRAP) data and generate consistent, publishable figures. The automation would bring down the hour-long routine work to a few seconds for researchers that often do FRAP experiments. Note: this package does not replace ['ImageJ'](https://imagej.nih.gov/ij/) (or other image quantification tools) in raw image quantification.

FRAP image courtesy of [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/): <br/>
![FRAP image](./img/Demo_FRAP.gif) <br/>
(The top-left puncta is the targeted area.)

Generates figures in a consistent and publishable format: <br/>
![Output figure demo](./img/Demo_Plot.jpg) <br/>

## Installation
In the R or Rstudio console,
```
\# if "devtools" has not been installed
install.packages("devtools")

\# install and load frapplot
devtools::install_github("GuanqiaoDing/frapplot")
library(frapplot)

\# bring up the manual
?frapprocess				
?frapplot
```

## Usage
In the R or Rstudio console:
```
\# example use of frapprocess and frapplot
\# after the preprocessing (refer to ./data-raw/preprocess.R)
load("data/example_dataset.rda")
info <- frapprocess(example_dataset, seq(0, 145, 5))

\# plot any combinations of groups as desired
frapplot ("Control", "Mutant1", info)
frapplot ("Control", "Mutant2", info)
```

Note:
- Raw data can either be in a single file or separate files, refer to [preprocess.R](./data-raw/preprocess.R) for more information.
- Make sure the names (case-sensitive) you provide to `frapplot()` are correct;
- Make sure "info" (the third argument) remains in your global environment and refers to the same experiment before you run `frapplot()`, otherwise re-run `frapprocess()` and get its return value.

## Outputs
`frapplot()` returns a list, its item can be acessed with '$' sign, e.g. info$summary:
- $time_points: a vector of time points
- $summary: summary of the analysis
- $sample_means: a matrix of sample means, nrow = num of time points, ncol = sample size
- $sample_sd: a matrix of standard deviations, nrow = num of time points, ncol = sample size
- $model: result of non-linear regression model

`frapplot()` generates a pdf file that compares two groups of choice.

## Test with Example Dataset
An example dataset can be found [here](./data-raw), which is courtesy of [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/) and should never be used for other purposes.

The [preprocessing](./data-raw/preprocess.R) generates ".rda" file that is ready to be loaded. The code has been tested with the example dataset and generates expected results. Note that only five samples are included in each group of this dataset for demonstration, but larger sample size is highly recommended for statistical robustness.

The code has also passed R CMD check.

## Report Issues
Please report any bugs or issues [here](https://github.com/GuanqiaoDing/frapplot/issues/new). The project also welcomes your contribution.

## License
`frapplot` is licensed under the MIT License - see [LICENSE](./LICENSE) for the details.

## Acknowledgements
I truly appreciate the help and resources provided by [Dr. Michael Rosen's Lab](https://www.utsouthwestern.edu/labs/rosen/) at UT Southwestern Medical Center for this project.
