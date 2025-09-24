<!-- README.md is generated from README.Rmd. Please edit that file -->

# COMPOLYTICS® ScanCorder Vegetation Indices R Package

<!-- badges: start -->
<!-- badges: end -->

This package provides tools to process spectral data from plant samples
recorded with the ScanCorder using CICADA, and to calculate a wide range
of vegetation indices.

## Installation

### From GitLab package registry

You can install the source package from
[GitLab](https://gitlab.com/compolytics-public/scancorder.indices/-/packages/).

#### Windows/Linux

``` r
options(repos = c(
  gitlab = "https://gitlab.com/api/v4/projects/70774833/packages/generic/scancorder.indices/1.1.6/",
  CRAN   = "https://cloud.r-project.org"
))
install.packages("scancorder.indices")
```

### From GitHub Repository

You can install the development version of `scancorder.indices` from
[GitHub](https://github.com/) with (available soon):

``` r
# install.packages("pak")
pak::pak("compolytics/scancorder.indices")
```

For private repository, valid GitHub colaborator credentials are
required.

### From R Package Repository

Install from CRAN package manager (available soon):

``` r
install.packages("scancorder.indices")
```

## Example

This basic example demonstrates how to calculate a table of spectral
indices from a CICADA json file containing ScanCorder sensor data.

``` r
# include scancorder.indices package
library(scancorder.indices)

# First rule of programming: clean it
rm(list = ls())
# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Please change this to the path and file name of your CICADA json data file.
# ------------------------------------------------------------------------------
# Change this name to the actual file you exported from the CICADA measurement app
# This file is also available from the Compolytics website (https://compolytics.com/vi-ppda)
cicada_file_name = "Compolytics_R-Package_VI_Test_File.json"
# Get current directory
current_dir <- getwd()
# Build full path + file name to the data file, change this location to the
# location of your actual file
sensor_file_path <- file.path(current_dir, "example", "data", cicada_file_name)

# Step 1: Load the json file and extract data
# ------------------------------------------------------------------------------
# Setup a decoder that will average the reflectance per LED across sensor channels
decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
# Decode the sensor data file reflectance values
data <- decoder$score(sensor_file_path)

# Step 2: Run multi calibration for improved reflectance
# ------------------------------------------------------------------------------
# Setup multi-calibration tool
calibrator <- CalibrationReflectanceMultipoint$new()
# Run multi-calibration with sensor provided factors
calibReflectance <- calibrator$score(data$reflectance, sensor_file_path)

# Step 3: Calculate Indices table from all available data
# ------------------------------------------------------------------------------
index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm, data$meta_table)
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Variable 'R2800' not found in reflectance values.
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: abs
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: root
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln
#> MathML evaluation error: Unsupported MathML operator: ln

# Step 4: Save spectral indices in CSV file
# ------------------------------------------------------------------------------
# Generate an output file name based on the input file name
# ------------------------------------------------------------------------------
# Change this file and path to the location where you want to save the indices table
# ------------------------------------------------------------------------------
table_file_path <- file.path(current_dir, "example", "data", "Compolytics_R-Package_VI_Test_File_Indices.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

# ------------------------------------------------------------------------------
# The End
```

| uuid | filename | sample_id | sample | AI | ARI1 | ARI2 | BGI1 | BGI2 | BRI1 | BRI2 | CAR | CARgreen | CARrededge | CCI | CI | CLSI | CRI1 | CRI2 | Ctr2 | Ctr3 | Ctr4 | Ctr5 | CUR | D1 | Datt2 | Datt3 | Datt4 | Datt5 | Datt6 | DD | DDI | DDIn | DI | DRIpri | DVI | DWSI4 | EG | EVI | EVI2 | FD_VI1 | FR | FR2 | GCC | GI | GLI | GM1 | GM2 | GNDVI | GR | GRVI | LCI | Lic1 | Lic2 | Lic3 | MCARI.OSAVI | MCARI.OSAVI750 | MCARI | MCARI1 | MCARI705 | MCARI710 | MGRVI | mNDI | mSRI1 | MTCI | MTVI | NBNDVI | NDI | NDRE | NDVI | NDVI1 | NDVI2 | NDVI3 | NDVI4 | NDVIg | NGRDI | NVI1 | NVI2 | OSAVI | PMI | PRI | PRI515 | PRI570 | PRIm1 | PRIm2 | PRIm3 | PRIm4 | PSND1 | PSND2 | PSNDa1 | PSNDc1 | PSRI | PSSRa | PSSRa1 | PSSRb | PSSRc1 | PSSRc2 | R.M | RARS | RDVI | reNDVI | REP | RGBVI | RGI | RGR | RGR2 | RVI | RVI1 | RVI2 | RVSI | SAVI | SBRI | SIPI1 | SIPI2 | SR.520.670. | SR.520.760. | SR.542.750. | SR.550.670. | SR.550.760. | SR.550.800. | SR.556.750. | SR.560.658. | SR.570.670. | SR.605.670. | SR.672.708. | SR.674.553. | SR.675.555. | SR.675.700. | SR.675.705. | SR.678.750. | SR.683.510. | SR.685.735. | SR.694.840. | SR.695.800. | SR.700.670. | SR.700. | SR.705.722. | SR.706.750. | SR.710.670. | SR.735.700.710. | SR.750.705. | SR.750.755. | SR.752.690. | SR.760.695. | SR.774.677. | SR.787.765. | SR.800.550. | SR.800.600. | SR.801.550. | SR.810.560. | SR.833.658. | SR.860.550. | SR.860.708. | TCARI.OSAVI | TCARI | TGI1 | TGI2 | TVI | VARI | VARIgreen | VIopt1 | Vog1 | Vog2 | Vog3.SR.715.705. | Vog3 | WDRVIa | WDRVIa.1 | WDRVIb | WDRVIc |
|:-|:-|:-|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 398cac85-1fac-4d30-98a9-313de2fd436e | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 1 | 1.0414810 | 1.455141 | 0.7046968 | 0.5227698 | 0.7125362 | 0.5470802 | 0.7456713 | 1.1386722 | -0.5088607 | 0.1711054 | 0.0648403 | 3.392523 | -0.0449964 | -1.0889722 | 0.3661691 | 0.2858437 | 0.2393271 | 0.2858437 | 1 | 1 | 1 | 3.571881 | 3.392523 | 7.153998 | 0.9555634 | 31.93912 | 11.966228 | 0.3195706 | -0.9345706 | 0.3724466 | -0.0178838 | 0.3774161 | 1.0465030 | 0.0754871 | 0.2985987 | 0.4777407 | 0.6410548 | 0.8000604 | 0.2358305 | 0.3716633 | 1.0465030 | 0.0885331 | 4.051907 | 3.392523 | 0.6247902 | 0.9533712 | 3.746580 | 0.9278671 | 1.3410735 | 0.7456713 | 0.1758521 | -0.0083121 | 1.717352 | -0.0043473 | 0.4711135 | 0.8525719 | 0.8525719 | 0.8684267 | 0.7478132 | 1.751204 | 11.966228 | 0.4711135 | 0.6340022 | 0.6384491 | 0.5625433 | 0.6137790 | 0.5553990 | 0.6247902 | 0.6137790 | 0.5676287 | 0.6041099 | 0.5453099 | 8.613022 | 0.5948795 | 0.5230097 | 0.1984109 | 0.0648403 | 0 | -0.0648403 | 0 | -0.0648403 | 0.0238709 | -0.3999465 | 0.6247902 | 0.7112512 | 0.6384491 | 0.6837402 | 0.0350912 | 4.531725 | 4.531725 | 4.330351 | 5.323914 | 5.926436 | 2.392523 | 5.137077 | 0.4461761 | 0.5446808 | 0.3004279 | 0.1953979 | 0.9555634 | 0.9533712 | 1.026040 | 3.625654 | 3.625654 | 0.8512018 | 0.1597853 | 0.4706039 | 0.0019449 | 1.153645 | 1.0720126 | 0.9533712 | 0.2725151 | 0.2467974 | 0.8372657 | 0.2393271 | 0.2309282 | 0.2467974 | 0.8372657 | 0.8372657 | 0.8372657 | 0.8000604 | 0.9555634 | 0.9555634 | 0.8000604 | 0.8000604 | 0.2358305 | 0.8391909 | 0.8000604 | 0.2799645 | 0.2758123 | 1 | 7.486680 | 1 | 0.2947659 | 1 | 1 | 3.392523 | 1 | 4.240333 | 3.498416 | 4.372689 | 1 | 4.330351 | 4.330351 | 4.330351 | 4.330351 | 3.571881 | 4.266126 | 3.571881 | -0.0249363 | -0.0130419 | 2.621833 | 0.0266415 | 18.30477 | 0.0389049 | -0.0343670 | 3.498416 | 3.392523 | -1.196261 | 1 | -1.196261 | -0.6969371 | -0.6969371 | -0.4736351 | -0.1666051 |
| f3694b9b-5958-4905-936e-6e7f48276258 | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 2 | 0.7678306 | 1.767805 | 0.8193834 | 0.4136873 | 0.7252288 | 0.4637544 | 0.8130007 | 0.9845969 | 0.0626436 | 0.8404416 | -0.0077613 | 3.161953 | -0.0287969 | 0.1423784 | 1.9101835 | 0.3099332 | 0.2497316 | 0.3099332 | 1 | 1 | 1 | 3.323159 | 3.161953 | 6.541594 | 0.8920396 | 30.24442 | 7.687471 | 0.2948131 | -0.8799590 | 0.3536265 | 0.0022834 | 0.3654888 | 1.1210264 | 0.0820494 | 0.2760518 | 0.4448294 | 0.6242832 | 0.7187692 | 0.2273181 | 0.3049354 | 1.1210264 | 0.0007368 | 3.924191 | 3.161953 | 0.6167401 | 0.7933481 | 4.188778 | 0.8920166 | 1.2300112 | 0.8130007 | 0.1848098 | -0.0106076 | 1.550884 | -0.0052975 | 0.4297596 | 0.7289979 | 0.7289979 | 0.8333376 | 0.7222802 | 1.626899 | 7.687471 | 0.4297596 | 0.6443434 | 0.6508946 | 0.5373753 | 0.6003437 | 0.5267954 | 0.6167401 | 0.6003437 | 0.5453521 | 0.5938419 | 0.4662573 | 8.888048 | 0.6440038 | 0.4994045 | 0.1286029 | -0.0077613 | 0 | 0.0077613 | 0 | 0.0077613 | 0.1152325 | -0.3799723 | 0.6167401 | 0.6157467 | 0.6508946 | 0.7202355 | 0.0524939 | 4.728929 | 4.728929 | 4.218392 | 6.148869 | 4.204901 | 2.161953 | 5.836801 | 0.4223812 | 0.5194564 | 0.2881719 | -0.1244610 | 0.8920396 | 0.7933481 | 1.129230 | 3.399008 | 3.399008 | 0.7690729 | 0.1474066 | 0.4461523 | 0.0759435 | 1.173255 | 1.0501483 | 0.7933481 | 0.2458849 | 0.2548296 | 0.8057593 | 0.2497316 | 0.2370572 | 0.2548296 | 0.8057593 | 0.8057593 | 0.8057593 | 0.7187692 | 0.8920396 | 0.8920396 | 0.7187692 | 0.7187692 | 0.2273181 | 0.9059948 | 0.7187692 | 0.3009185 | 0.2942035 | 1 | 7.333300 | 1 | 0.3162602 | 1 | 1 | 3.161953 | 1 | 4.399122 | 3.226502 | 4.488926 | 1 | 4.218392 | 4.218392 | 4.218392 | 4.218392 | 3.323159 | 4.124257 | 3.323159 | -0.0318229 | -0.0158925 | 4.191930 | 0.0063939 | 16.62929 | 0.0895197 | -0.1709296 | 3.226502 | 3.161953 | -1.080977 | 1 | -1.080977 | -0.7150336 | -0.7150336 | -0.5011455 | -0.2014669 |
| 1a7dbcc7-aab2-44a5-9f8e-7e377574510f | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 3 | 0.9999159 | 1.727309 | 0.8178471 | 0.5347179 | 0.7200641 | 0.5925920 | 0.7979987 | 1.0727217 | -0.2817352 | 0.5039606 | 0.0350851 | 3.282283 | -0.0305711 | -0.6193795 | 1.1079299 | 0.2967185 | 0.2406221 | 0.2967185 | 1 | 1 | 1 | 3.508185 | 3.282283 | 6.685595 | 0.9023374 | 32.05255 | 8.507896 | 0.3080338 | -0.9097337 | 0.3640293 | -0.0100011 | 0.3747186 | 1.1082329 | 0.0700056 | 0.2944311 | 0.4708479 | 0.6369040 | 0.7317453 | 0.2229379 | 0.3453855 | 1.1082329 | 0.0469055 | 4.047483 | 3.282283 | 0.6244806 | 0.8699174 | 4.032779 | 0.9033818 | 1.2531349 | 0.7979987 | 0.1779042 | -0.0099869 | 1.635903 | -0.0051033 | 0.4476531 | 0.7920930 | 0.7920930 | 0.8595960 | 0.7328117 | 1.703578 | 8.507896 | 0.4476531 | 0.6548314 | 0.6548253 | 0.5563624 | 0.6120944 | 0.5423548 | 0.6244806 | 0.6120944 | 0.5563550 | 0.6037629 | 0.5223249 | 9.091252 | 0.6165713 | 0.5109977 | 0.1700525 | 0.0350851 | 0 | -0.0350851 | 0 | -0.0350851 | 0.0695660 | -0.3950123 | 0.6244806 | 0.6878580 | 0.6548253 | 0.6988497 | 0.0334745 | 4.794167 | 4.794167 | 4.325956 | 5.641203 | 5.407340 | 2.282283 | 5.419436 | 0.4339739 | 0.5329594 | 0.2949171 | 0.0768313 | 0.9023374 | 0.8699174 | 1.077390 | 3.508109 | 3.508109 | 0.8498483 | 0.1540169 | 0.4580906 | 0.0323986 | 1.165889 | 1.0532400 | 0.8699174 | 0.2581206 | 0.2470671 | 0.8109442 | 0.2406221 | 0.2311628 | 0.2470671 | 0.8109442 | 0.8109442 | 0.8109442 | 0.7317453 | 0.9023374 | 0.9023374 | 0.7317453 | 0.7317453 | 0.2229379 | 0.8411664 | 0.7317453 | 0.2850477 | 0.2850539 | 1 | 7.409196 | 1 | 0.3046660 | 1 | 1 | 3.282283 | 1 | 4.485554 | 3.370198 | 4.605698 | 1 | 4.325956 | 4.325956 | 4.325956 | 4.325956 | 3.508185 | 4.326049 | 3.508185 | -0.0299606 | -0.0153098 | 3.189783 | 0.0166980 | 17.46137 | 0.0860094 | -0.1011540 | 3.370198 | 3.282283 | -1.141142 | 1 | -1.141142 | -0.7015351 | -0.7015351 | -0.4805839 | -0.1753389 |
| 9b131730-ea16-46cb-9d70-46272e23d036 | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 4 | 0.9728537 | 1.699768 | 0.8415079 | 0.5223610 | 0.7641411 | 0.5801405 | 0.8486643 | 1.1222013 | -0.4782250 | 0.3343609 | 0.0575823 | 3.443152 | -0.0316240 | -1.0003516 | 0.6994164 | 0.2794030 | 0.2277051 | 0.2794030 | 1 | 1 | 1 | 3.625853 | 3.443152 | 6.741040 | 0.9004044 | 33.30871 | 9.177972 | 0.3263331 | -0.9561140 | 0.3862162 | -0.0155357 | 0.3970578 | 1.1106120 | 0.0763018 | 0.3013626 | 0.4858181 | 0.6444984 | 0.7338027 | 0.2131195 | 0.3556875 | 1.1106120 | 0.0597846 | 4.224881 | 3.443152 | 0.6395068 | 0.9145604 | 3.964586 | 0.9079555 | 1.1783223 | 0.8486643 | 0.1808669 | -0.0092960 | 1.755315 | -0.0049429 | 0.4820076 | 0.8818724 | 0.8818724 | 0.8733020 | 0.7640466 | 1.738035 | 9.177972 | 0.4820076 | 0.6633667 | 0.6694768 | 0.5676473 | 0.6290557 | 0.5632291 | 0.6395068 | 0.6290557 | 0.5750510 | 0.6172162 | 0.5419933 | 9.569618 | 0.6154691 | 0.5317261 | 0.1911529 | 0.0575823 | 0 | -0.0575823 | 0 | -0.0575823 | 0.0446262 | -0.4028496 | 0.6395068 | 0.6989838 | 0.6694768 | 0.7115009 | 0.0316645 | 5.051013 | 5.051013 | 4.547955 | 5.932431 | 5.644161 | 2.443152 | 5.728539 | 0.4559406 | 0.5498691 | 0.3058138 | 0.1203757 | 0.9004044 | 0.9145604 | 1.049400 | 3.706447 | 3.706447 | 0.8514238 | 0.1631666 | 0.4804465 | 0.0092029 | 1.139389 | 1.0373575 | 0.9145604 | 0.2555309 | 0.2366930 | 0.8149700 | 0.2277051 | 0.2198791 | 0.2366930 | 0.8149700 | 0.8149700 | 0.8149700 | 0.7338027 | 0.9004044 | 0.9004044 | 0.7338027 | 0.7338027 | 0.2131195 | 0.8023556 | 0.7338027 | 0.2757972 | 0.2698002 | 1 | 7.486680 | 1 | 0.2904316 | 1 | 1 | 3.443152 | 1 | 4.692204 | 3.579060 | 4.877414 | 1 | 4.547955 | 4.547955 | 4.547955 | 4.547955 | 3.625853 | 4.449063 | 3.625853 | -0.0278879 | -0.0148287 | 3.165178 | 0.0193252 | 18.59141 | 0.0878439 | -0.0661395 | 3.579060 | 3.443152 | -1.221576 | 1 | -1.221576 | -0.6930605 | -0.6930605 | -0.4677980 | -0.1593056 |
| d9976327-4180-4785-8034-b88c27df300c | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 5 | 1.0839529 | 1.875598 | 0.9083156 | 0.4679776 | 0.7148075 | 0.5143931 | 0.7857045 | 1.1019081 | -0.3970604 | 0.4809324 | 0.0484836 | 3.299921 | -0.0231655 | -0.8482137 | 1.0273840 | 0.2927979 | 0.2329201 | 0.2927979 | 1 | 1 | 1 | 3.438097 | 3.299921 | 6.637594 | 0.9097664 | 31.53261 | 8.324517 | 0.3152333 | -0.9362272 | 0.3752476 | -0.0137220 | 0.3850860 | 1.0991832 | 0.0682817 | 0.2902671 | 0.4640802 | 0.6322243 | 0.7237172 | 0.2193135 | 0.3508818 | 1.0991832 | 0.0555438 | 4.148246 | 3.299921 | 0.6324607 | 0.8765655 | 3.922236 | 0.8982151 | 1.2727432 | 0.7857045 | 0.1723156 | -0.0108750 | 1.667486 | -0.0056059 | 0.4562676 | 0.8136967 | 0.8136967 | 0.8672070 | 0.7272097 | 1.741199 | 8.324517 | 0.4562676 | 0.6522107 | 0.6599869 | 0.5493564 | 0.6221651 | 0.5470322 | 0.6324607 | 0.6221651 | 0.5588182 | 0.6115182 | 0.5321745 | 9.278825 | 0.6223416 | 0.5154876 | 0.1855463 | 0.0484836 | 0 | -0.0484836 | 0 | -0.0484836 | 0.0657768 | -0.4045816 | 0.6324607 | 0.7007801 | 0.6599869 | 0.7068512 | 0.0354199 | 4.882126 | 4.882126 | 4.441594 | 5.822475 | 5.684047 | 2.299921 | 5.628100 | 0.4404903 | 0.5348751 | 0.3025881 | 0.1055799 | 0.9097664 | 0.8765655 | 1.073822 | 3.533279 | 3.533279 | 0.8384967 | 0.1576166 | 0.4644670 | 0.0200477 | 1.170282 | 1.0552006 | 0.8765655 | 0.2566565 | 0.2410658 | 0.7954978 | 0.2329201 | 0.2251444 | 0.2410658 | 0.7954978 | 0.7954978 | 0.7954978 | 0.7237172 | 0.9097664 | 0.9097664 | 0.7237172 | 0.7237172 | 0.2193135 | 0.8256282 | 0.7237172 | 0.2908586 | 0.2830232 | 1 | 7.295932 | 1 | 0.3030376 | 1 | 1 | 3.299921 | 1 | 4.559682 | 3.415325 | 4.719143 | 1 | 4.441594 | 4.441594 | 4.441594 | 4.441594 | 3.438097 | 4.321944 | 3.438097 | -0.0326250 | -0.0168178 | 3.264901 | 0.0191480 | 17.79281 | 0.0786740 | -0.0943733 | 3.415325 | 3.299921 | -1.149960 | 1 | -1.149960 | -0.7066232 | -0.7066232 | -0.4883060 | -0.1851013 |
| eef00541-a703-45df-b2ab-46f6698897d8 | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 6 | 1.4771745 | 1.351382 | 0.6757587 | 0.6978782 | 1.0168552 | 0.7293760 | 1.0627496 | 1.1668344 | -0.6034698 | 0.0246537 | 0.0769945 | 3.508938 | -0.0489871 | -1.2983410 | 0.0530414 | 0.2783558 | 0.2369304 | 0.2783558 | 1 | 1 | 1 | 3.923951 | 3.508938 | 7.395391 | 0.9568154 | 35.63165 | 13.519490 | 0.3246064 | -0.9296014 | 0.3899245 | -0.0199211 | 0.3946803 | 1.0451337 | 0.1011511 | 0.3027546 | 0.5201603 | 0.6623875 | 0.8144206 | 0.2320989 | 0.3570275 | 1.0451337 | 0.0313724 | 4.122447 | 3.508938 | 0.6390368 | 0.9931843 | 3.950879 | 0.9403192 | 0.9409554 | 1.0627496 | 0.2466630 | -0.0070702 | 1.772238 | -0.0038509 | 0.5037278 | 0.8977063 | 0.8977063 | 0.8802781 | 0.9031820 | 1.416981 | 13.519490 | 0.5037278 | 0.6562445 | 0.6519118 | 0.5938221 | 0.6169058 | 0.5645097 | 0.6390368 | 0.6169058 | 0.5888980 | 0.6095616 | 0.5763683 | 8.719650 | 0.5712879 | 0.5446680 | 0.2063745 | 0.0769945 | 0 | -0.0769945 | 0 | -0.0769945 | 0.0034195 | -0.4014980 | 0.6390368 | 0.6610668 | 0.6519118 | 0.6748146 | 0.0182362 | 4.745671 | 4.745671 | 4.540731 | 5.150337 | 4.900867 | 2.508938 | 4.787282 | 0.4672118 | 0.5564366 | 0.2970903 | 0.1114252 | 0.9568154 | 0.9931843 | 1.003695 | 3.864972 | 3.864972 | 0.9214292 | 0.1623032 | 0.4922882 | -0.0123046 | 1.046938 | 0.9832474 | 0.9931843 | 0.2764586 | 0.2425744 | 0.8511784 | 0.2369304 | 0.2202289 | 0.2425744 | 0.8511784 | 0.8511784 | 0.8511784 | 0.8144206 | 0.9568154 | 0.9568154 | 0.8144206 | 0.8144206 | 0.2320989 | 0.8200096 | 0.8144206 | 0.2548452 | 0.2587341 | 1 | 7.729172 | 1 | 0.2849865 | 1 | 1 | 3.508938 | 1 | 4.308509 | 3.592525 | 4.411142 | 1 | 4.540731 | 4.540731 | 4.540731 | 4.540731 | 3.923951 | 4.610022 | 3.923951 | -0.0212106 | -0.0115527 | 1.722635 | 0.0097312 | 18.70620 | 0.0401651 | -0.0060441 | 3.592525 | 3.508938 | -1.254469 | 1 | -1.254469 | -0.6719646 | -0.6719646 | -0.4363739 | -0.1205799 |
| 81a11240-b895-428c-9170-5b77f7eff350 | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 7 | 1.6194536 | 1.716445 | 0.8169823 | 0.5211501 | 0.7607257 | 0.4854687 | 0.7086414 | 1.1929050 | -0.6885051 | 0.1021937 | 0.0879678 | 3.403994 | -0.0305109 | -1.4946034 | 0.2218416 | 0.2884381 | 0.2348715 | 0.2884381 | 1 | 1 | 1 | 3.509158 | 3.403994 | 8.079188 | 1.0734989 | 32.43332 | 19.100017 | 0.3194238 | -0.9213215 | 0.3677774 | -0.0245570 | 0.3598251 | 0.9315334 | 0.0918055 | 0.2893260 | 0.4669003 | 0.6369681 | 0.8741365 | 0.2567973 | 0.3609781 | 0.9315334 | 0.0907549 | 4.180335 | 3.403994 | 0.6295730 | 0.9713674 | 3.612596 | 0.9522344 | 1.4111510 | 0.7086414 | 0.1819772 | -0.0095338 | 1.715558 | -0.0049352 | 0.4555714 | 0.8530540 | 0.8530540 | 0.8793338 | 0.7595329 | 1.719439 | 19.100017 | 0.4555714 | 0.6011509 | 0.6076876 | 0.5564582 | 0.6196017 | 0.5522670 | 0.6295730 | 0.6196017 | 0.5635277 | 0.6139246 | 0.5706351 | 7.860262 | 0.5883698 | 0.5176561 | 0.2208399 | 0.0879678 | 0 | -0.0879678 | 0 | -0.0879678 | 0.0145242 | -0.4153709 | 0.6295730 | 0.6654557 | 0.6076876 | 0.6732166 | 0.0512707 | 4.097978 | 4.097978 | 4.399175 | 5.120261 | 4.978282 | 2.403994 | 4.955535 | 0.4397126 | 0.5458668 | 0.2967664 | 0.1346811 | 1.0734989 | 0.9713674 | 1.016035 | 3.582192 | 3.582192 | 0.8003455 | 0.1597119 | 0.4641332 | -0.0215317 | 1.147375 | 1.0940480 | 0.9713674 | 0.2801794 | 0.2392153 | 0.8142874 | 0.2348715 | 0.2273154 | 0.2392153 | 0.8142874 | 0.8142874 | 0.8142874 | 0.8741365 | 1.0734989 | 1.0734989 | 0.8741365 | 0.8741365 | 0.2567973 | 0.8999031 | 0.8741365 | 0.2849686 | 0.2791587 | 1 | 7.526033 | 1 | 0.2937725 | 1 | 1 | 3.403994 | 1 | 3.894122 | 3.466948 | 3.966140 | 1 | 4.399175 | 4.399175 | 4.399175 | 4.399175 | 3.509158 | 4.309484 | 3.509158 | -0.0286013 | -0.0148056 | 2.046239 | 0.0270399 | 18.17839 | -0.0605263 | -0.0211792 | 3.466948 | 3.403994 | -1.201997 | 1 | -1.201997 | -0.7014646 | -0.7014646 | -0.4804772 | -0.1752044 |
| 845567d7-4573-4557-ac81-d0b64903598e | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 8 | 1.3076662 | 2.276122 | 1.1041719 | 0.4843794 | 0.7348054 | 0.4394557 | 0.6666561 | 1.1304546 | -0.5150876 | 0.5503960 | 0.0612332 | 3.301597 | -0.0022293 | -1.1003474 | 1.1757745 | 0.2942899 | 0.2240397 | 0.2942899 | 1 | 1 | 1 | 3.384622 | 3.301597 | 8.000993 | 1.1022256 | 32.27260 | 14.305634 | 0.3170705 | -0.9362272 | 0.3802350 | -0.0173889 | 0.3695140 | 0.9072553 | 0.0647392 | 0.2860760 | 0.4570496 | 0.6285719 | 0.8391126 | 0.2541536 | 0.3484310 | 0.9072553 | 0.0493221 | 4.336849 | 3.301597 | 0.6444802 | 0.8606030 | 3.932850 | 0.9367956 | 1.5000238 | 0.6666561 | 0.1694330 | -0.0127789 | 1.669193 | -0.0065770 | 0.4488833 | 0.8157564 | 0.8157564 | 0.8761269 | 0.7231363 | 1.758495 | 14.305634 | 0.4488833 | 0.6026680 | 0.6151307 | 0.5438604 | 0.6339339 | 0.5452489 | 0.6444802 | 0.6339339 | 0.5576585 | 0.6252470 | 0.5447517 | 7.984157 | 0.6334156 | 0.5146766 | 0.1989943 | 0.0612332 | 0 | -0.0612332 | 0 | -0.0612332 | 0.0749203 | -0.4192825 | 0.6444802 | 0.7049745 | 0.6151307 | 0.7176961 | 0.0788619 | 4.196569 | 4.196569 | 4.625566 | 6.084563 | 5.779075 | 2.301597 | 5.871371 | 0.4401166 | 0.5350564 | 0.3029373 | 0.0972629 | 1.1022256 | 0.8606030 | 1.085947 | 3.521394 | 3.521394 | 0.6897075 | 0.1585352 | 0.4640109 | 0.0076473 | 1.174745 | 1.1042818 | 0.8606030 | 0.2532668 | 0.2305822 | 0.7612893 | 0.2240397 | 0.2161898 | 0.2305822 | 0.7612893 | 0.7612893 | 0.7612893 | 0.8391126 | 1.1022256 | 1.1022256 | 0.8391126 | 0.8391126 | 0.2541536 | 0.9750287 | 0.8391126 | 0.2954539 | 0.2839785 | 1 | 7.258943 | 1 | 0.3028838 | 1 | 1 | 3.301597 | 1 | 3.934629 | 3.398010 | 4.049528 | 1 | 4.625566 | 4.625566 | 4.625566 | 4.625566 | 3.384622 | 4.445908 | 3.384622 | -0.0383367 | -0.0197310 | 3.259543 | 0.0178221 | 17.70883 | -0.0761734 | -0.1071293 | 3.398010 | 3.301597 | -1.150798 | 1 | -1.150798 | -0.7105258 | -0.7105258 | -0.4942521 | -0.1926595 |
| 41f49fff-47ea-470d-bad6-176dc2129b72 | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 9 | 0.6474729 | 1.268001 | 0.6024811 | 0.4953303 | 0.7129260 | 0.5019172 | 0.7224065 | 1.0517892 | -0.1953673 | 0.3793058 | 0.0252410 | 3.322933 | -0.0554982 | -0.4310728 | 0.8369281 | 0.2947199 | 0.2520335 | 0.2947199 | 1 | 1 | 1 | 3.541495 | 3.322933 | 7.388429 | 0.9868765 | 31.00466 | 14.884909 | 0.3102755 | -0.9064238 | 0.3609179 | -0.0070957 | 0.3624169 | 1.0132980 | 0.0749448 | 0.2941452 | 0.4731647 | 0.6390866 | 0.8439404 | 0.2539745 | 0.3511989 | 1.0132980 | 0.0555173 | 3.885730 | 3.322933 | 0.6123821 | 0.8994513 | 3.937395 | 0.9421477 | 1.3842622 | 0.7224065 | 0.1834728 | -0.0075066 | 1.663579 | -0.0038692 | 0.4616840 | 0.8119627 | 0.8119627 | 0.8415816 | 0.7484648 | 1.685606 | 14.884909 | 0.4616840 | 0.6151167 | 0.6164936 | 0.5596164 | 0.5974013 | 0.5447357 | 0.6123821 | 0.5974013 | 0.5611379 | 0.5906446 | 0.4910732 | 7.957891 | 0.6129451 | 0.5154374 | 0.1588115 | 0.0252410 | 0 | -0.0252410 | 0 | -0.0252410 | 0.0529357 | -0.3791050 | 0.6123821 | 0.6863447 | 0.6164936 | 0.6984906 | 0.0639414 | 4.215037 | 4.215037 | 4.159721 | 5.633292 | 5.376426 | 2.322933 | 5.373283 | 0.4378001 | 0.5373512 | 0.2933912 | 0.1002115 | 0.9868765 | 0.8994513 | 1.057305 | 3.557240 | 3.557240 | 0.7482370 | 0.1551377 | 0.4621195 | 0.0415443 | 1.152638 | 1.0863422 | 0.8994513 | 0.2650862 | 0.2573519 | 0.8551631 | 0.2520335 | 0.2404007 | 0.2573519 | 0.8551631 | 0.8551631 | 0.8551631 | 0.8439404 | 0.9868765 | 0.9868765 | 0.8439404 | 0.8439404 | 0.2539745 | 0.9382836 | 0.8439404 | 0.2823666 | 0.2811168 | 1 | 7.486680 | 1 | 0.3009389 | 1 | 1 | 3.322933 | 1 | 3.937403 | 3.393053 | 4.020488 | 1 | 4.159721 | 4.159721 | 4.159721 | 4.159721 | 3.541495 | 4.141310 | 3.541495 | -0.0225198 | -0.0116076 | 3.576897 | 0.0183731 | 17.84269 | 0.0105117 | -0.0779578 | 3.393053 | 3.322933 | -1.161467 | 1 | -1.161467 | -0.6991274 | -0.6991274 | -0.4769418 | -0.1707552 |
| cf4660c5-5e96-47f3-ad3d-9aa078a533de | 20250911_133200_Lime_4bb7735b-aeb4-45d1-b33f-a34b9965fac0.json | Lime | 10 | 0.8884015 | 1.509658 | 0.7135385 | 0.5454734 | 0.7429258 | 0.5289901 | 0.7204758 | 1.1469078 | -0.5491374 | 0.1450528 | 0.0684276 | 3.454804 | -0.0398882 | -1.1942108 | 0.3154468 | 0.2783252 | 0.2332574 | 0.2783252 | 1 | 1 | 1 | 3.586723 | 3.454804 | 8.057001 | 1.0311600 | 33.43970 | 18.075195 | 0.3141734 | -0.9196658 | 0.3653898 | -0.0185287 | 0.3620476 | 0.9697816 | 0.0822983 | 0.2930140 | 0.4686006 | 0.6420084 | 0.8641894 | 0.2501414 | 0.3636702 | 0.9697816 | 0.0845587 | 4.122309 | 3.454804 | 0.6300816 | 0.9611948 | 3.731526 | 0.9501161 | 1.3879716 | 0.7204758 | 0.1802208 | -0.0078852 | 1.710960 | -0.0041447 | 0.4639903 | 0.8540066 | 0.8540066 | 0.8699792 | 0.7648439 | 1.745426 | 18.075195 | 0.4639903 | 0.6116799 | 0.6207408 | 0.5639589 | 0.6217215 | 0.5645471 | 0.6300816 | 0.6217215 | 0.5738388 | 0.6095510 | 0.5407307 | 8.155299 | 0.6039342 | 0.5256320 | 0.1964107 | 0.0684276 | 0 | -0.0684276 | 0 | -0.0684276 | 0.0197865 | -0.4012188 | 0.6300816 | 0.6882926 | 0.6207408 | 0.6984000 | 0.0603160 | 4.273438 | 4.273438 | 4.406598 | 5.631301 | 5.416273 | 2.454804 | 5.478603 | 0.4447278 | 0.5510464 | 0.2939080 | 0.1507405 | 1.0311600 | 0.9611948 | 1.021567 | 3.693060 | 3.693060 | 0.7588724 | 0.1570867 | 0.4697293 | -0.0044361 | 1.140128 | 1.0853916 | 0.9611948 | 0.2675247 | 0.2425825 | 0.8380750 | 0.2332574 | 0.2269324 | 0.2425825 | 0.8380750 | 0.8380750 | 0.8380750 | 0.8641894 | 1.0311600 | 1.0311600 | 0.8641894 | 0.8641894 | 0.2501414 | 0.8990783 | 0.8641894 | 0.2788060 | 0.2707782 | 1 | 7.813532 | 1 | 0.2894520 | 1 | 1 | 3.454804 | 1 | 3.997739 | 3.592919 | 4.157560 | 1 | 4.406598 | 4.406598 | 4.406598 | 4.406598 | 3.586723 | 4.279716 | 3.586723 | -0.0236557 | -0.0124342 | 2.876815 | 0.0244949 | 18.02146 | -0.0249551 | -0.0289901 | 3.592919 | 3.454804 | -1.227402 | 1 | -1.227402 | -0.6958693 | -0.6958693 | -0.4720253 | -0.1645886 |

Spectral indices calculated from CICADA data.
