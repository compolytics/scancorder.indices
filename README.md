<!-- README.md is generated from README.Rmd. Please edit that file -->

# Compolytics (C) Scancorder Indices R-Package

<!-- badges: start -->
<!-- badges: end -->

This package provides an implementation to decode sample files recorded
using CICADA and subsequently calculate well known spectral indices.

## Installation

### From GitLab package registry

You can install compiled platform-specific version of
`scancorder.indices` from
[GitLab](https://gitlab.com/compolytics-public/scancorder.indices/-/packages/).

#### Windows

``` r
# Install dependencies of scancorder.indices
install.packages(c("xml2", "R6", "jsonlite", "pkgload"))

# Define the direct URL to the package
package_url <- "https://gitlab.com/api/v4/projects/70774833/packages/generic/scancorder.indices/1.1.0/windows/scancorder.indices.zip"

# Install the binary package
install.packages(package_url,
                 repos=NULL,
                 type = "win.binary")
```

#### Linux

``` r
# Install dependencies of scancorder.indices
install.packages(c("xml2", "R6", "jsonlite", "pkgload"))

# Define the direct URL to the package
package_url <- "https://gitlab.com/api/v4/projects/70774833/packages/generic/scancorder.indices/1.1.0/linux/scancorder.indices.tar.gz"

# Install the binary package
install.packages(package_url,
                 repos=NULL,
                 type = "binary")
```

#### MacOs

``` r
# Install dependencies of scancorder.indices
install.packages(c("xml2", "R6", "jsonlite", "pkgload"))

# Define the direct URL to the package
package_url <- "https://gitlab.com/api/v4/projects/70774833/packages/generic/scancorder.indices/1.1.0/macos/scancorder.indices.tgz"

# Install the binary package
install.packages(package_url,
                 repos=NULL,
                 type = "mac.binary")
```

### From Github Repository

You can install the development version of `scancorder.indices` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("compolytics/scancorder.indices")
```

For private repository, valid github colaborator credentials are
required.

### From R Package Repository

Install from CRAN package manager (available soon):

``` r
install.packages("scancorder.indices")
```

## Example

This is a basic example to calculate a table of spectral indices from a
CICADA json data file holding Scancorder sensor data.

``` r
library(scancorder.indices)

# First rule of programming: clean it
rm(list = ls())
# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Get current directory
current_dir <- getwd()
# Build file
data_file_path <- file.path(current_dir, "example", "data", "2025-02-20_11-57-59_exampleDataFiles.json")

# Step 1: Load Json file and extract data
# ------------------------------------------------------------------------------
# Load the JSON file with the sensor reading
json_input <- readChar(data_file_path, nchars = file.info(data_file_path)$size)
# Setup a decoder that will average the reflectance per LED across sensor channels
decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
# Decode the JSON input to get the reflectance values
data <- decoder$score(json_input)

# Step 2: Run multi calibration for improved reflectance
# ------------------------------------------------------------------------------
# Setup multi-calibration tool
calibrator <- CalibrationReflectanceMultipoint$new()
# Run multi-calibration with sensor provided factors
calibReflectance <- calibrator$score(data$reflectance, json_input)

# Step 3: Calculate Indices table from all available data
# ------------------------------------------------------------------------------
index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm, data$meta_table)
table_file_path <- file.path(current_dir, "example", "data", "2025-02-20_11-57-59_exampleDataFiles_Indices.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

# ------------------------------------------------------------------------------
# The End
```

| uuid | filename | sampleID | sample | ARI1 | ARI2 | CI | CRI1 | CRI2 | Datt6 | DWSI4 | GI | GM1 | GM2 | LIC1 | NDI | NDVI | NDVI4 | NDVIg | PSNDa1 | PSNDc1 | PSSRa1 | PSSRc1 | RDVI | RGI | RGR | RVI | RVI2 | SAVI | SIPI1 | SR.550.800. | SR.556.750. | SR.605.670. | SR.555.675. | SR.683.510. | SR.694.840. | SR.695.800. | SR.750.705. | SR.752.690. | SR.800.600. | SR.800.960. | SR.810.560. | WBI3 |
|:--|:----|:-|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 6932e54f-85d1-4f31-85a0-8be3cefbd454 | 20250219_234134_Target_c3f28a94-fa54-4049-8053-737d770c5a1d.json | Target | 1 | -3.458221 | -3.179286 | 1.298878 | 3.119617 | -0.3386042 | -2.6567036 | -0.682670 | -0.682670 | -1.9026446 | 1.298878 | 0.1265828 | 0.1265828 | -0.0122657 | 0.1265828 | 3.215711 | 0.1265828 | -0.0108343 | 1.289857 | 0.9785637 | 0.1617137 | -1.4648365 | -0.682670 | 1.289857 | 1.3181120 | 0.1453465 | 1026669.711 | -0.5292604 | -0.5255842 | 1.2804429 | -0.682670 | 0.7586609 | 0.7735897 | 0.7752800 | 1.298878 | 1.298878 | 1.007352 | 1.0094401 | -1.8894290 | 1.0443511 |
| 290a3514-575a-4f53-bc67-2f84886529ca | 20250219_234134_Target_c3f28a94-fa54-4049-8053-737d770c5a1d.json | Target | 2 | -2.610868 | -2.391208 | 1.361998 | 2.216364 | -0.3945040 | -1.5450711 | -1.277647 | -1.277647 | -1.0660203 | 1.361998 | 0.1457918 | 0.1457918 | -0.0148908 | 0.1457918 | 31.293721 | 0.1457918 | -0.0100826 | 1.341349 | 0.9800361 | 0.1843365 | -0.7826887 | -1.277647 | 1.341349 | 1.3686735 | 0.1665860 | 915679.869 | -0.9525088 | -0.9380685 | 1.3227578 | -1.277647 | 0.7306344 | 0.7419078 | 0.7455179 | 1.361998 | 1.361998 | 1.014055 | 1.0170510 | -1.0498590 | 1.0381601 |
| 1fd2acce-e7af-47a1-9ba4-b36be9d166a0 | 20250219_234134_Target_c3f28a94-fa54-4049-8053-737d770c5a1d.json | Target | 3 | -2.571771 | -2.337809 | 1.372820 | 2.162160 | -0.4096117 | -1.4730618 | -1.384593 | -1.384593 | -0.9914975 | 1.372820 | 0.1516180 | 0.1516180 | -0.0123266 | 0.1516180 | -234.224355 | 0.1516180 | -0.0075158 | 1.357428 | 0.9850804 | 0.1905021 | -0.7222339 | -1.384593 | 1.357428 | 1.3779875 | 0.1727227 | 882658.241 | -1.0200117 | -1.0085754 | 1.3340011 | -1.384593 | 0.7256960 | 0.7321450 | 0.7366870 | 1.372820 | 1.372820 | 1.017562 | 1.0138780 | -0.9803809 | 1.0356221 |
| 41ec941d-506d-4406-95da-499388ef5ed0 | 20250219_234417_65_f3d6e601-26dc-4266-9984-c0338e6afd4f.json | 65 | 4 | 10.011793 | 5.439226 | -4.125287 | 7.500076 | 17.5118685 | 2.7362376 | 21.194845 | 21.194845 | -0.1946363 | -4.125287 | 1.4247580 | 1.4247580 | 0.6410276 | 1.4247580 | -1.483350 | 1.4247580 | 0.5837945 | -5.708563 | 3.8053181 | 0.9537499 | 0.0471813 | 21.194845 | -5.708563 | -1.5001539 | 1.0100885 | 6991.253 | -3.7128162 | -5.1377874 | -1.2672815 | 21.194845 | -0.6665983 | -0.1811830 | -0.1751754 | -4.125287 | -4.125287 | 4.504574 | 1.0697564 | -0.2693373 | 0.9811623 |
| 70cee624-1f1f-41d7-97a9-92ff3c9abc58 | 20250219_234417_65_f3d6e601-26dc-4266-9984-c0338e6afd4f.json | 65 | 5 | 10.634579 | 5.413220 | -4.282800 | 11.098259 | 21.7328386 | 2.6102100 | 23.876760 | 23.876760 | -0.1793710 | -4.282800 | 1.4301218 | 1.4301218 | 0.6356522 | 1.4301218 | -1.437155 | 1.4301218 | 0.6881149 | -5.649845 | 5.4126173 | 0.9256391 | 0.0418817 | 23.876760 | -5.649845 | -1.0438287 | 0.9779599 | 5442.702 | -4.2260910 | -5.5750357 | -1.2024157 | 23.876760 | -0.9580116 | -0.1780944 | -0.1769960 | -4.282800 | -4.282800 | 4.698745 | 1.1123385 | -0.2366253 | 1.0140560 |
| 86fb8e54-d491-4d0e-94d0-0a24e2d2d005 | 20250219_234417_65_f3d6e601-26dc-4266-9984-c0338e6afd4f.json | 65 | 6 | 13.851054 | 7.031454 | -5.444666 | 10.475434 | 24.3264880 | 3.3052909 | 31.157980 | 31.157980 | -0.1747439 | -5.444666 | 1.3192538 | 1.3192538 | 0.5806310 | 1.3192538 | -1.423490 | 1.3192538 | 0.6713054 | -7.264608 | 5.0846752 | 0.8728716 | 0.0320945 | 31.157980 | -7.264608 | -1.4287261 | 0.9237793 | 3937.946 | -4.2890103 | -5.7226617 | -1.5797075 | 31.157980 | -0.6999242 | -0.1389539 | -0.1376537 | -5.444666 | -5.444666 | 4.598705 | 1.1950001 | -0.2331540 | 0.9129483 |
| dde222df-873c-44f2-a180-910a55a8e736 | 20250219_234559_42_491ff229-f13a-4ae6-a4be-068547b4e16b.json | 42 | 7 | 7.598013 | 2.929146 | -2.573897 | 11.158867 | 18.7568802 | 1.3337120 | 17.311601 | 17.311601 | -0.1486805 | -2.573897 | 1.9484424 | 1.9484424 | 0.5646673 | 1.9484424 | -1.349294 | 1.9484424 | 0.6095530 | -3.108720 | 4.1223337 | 0.9963840 | 0.0577647 | 17.311601 | -3.108720 | -0.7541167 | 1.0036563 | 5426.120 | -5.5687221 | -6.7258331 | -0.6164052 | 17.311601 | -1.3260548 | -0.3492540 | -0.3216757 | -2.573897 | -2.573897 | 5.043307 | 0.9200127 | -0.1795744 | 1.1524479 |
| a26b3e55-016c-4f7e-88c1-ef9819ac1bec | 20250219_234559_42_491ff229-f13a-4ae6-a4be-068547b4e16b.json | 42 | 8 | 7.555945 | 2.780914 | -2.623991 | 11.688010 | 19.2439553 | 1.2291974 | 17.577078 | 17.577078 | -0.1492848 | -2.623991 | 2.0263406 | 2.0263406 | 0.5683999 | 2.0263406 | -1.350963 | 2.0263406 | 0.6104353 | -2.948671 | 4.1339356 | 0.9993507 | 0.0568923 | 17.577078 | -2.948671 | -0.7132841 | 0.9947031 | 5314.234 | -5.9610174 | -6.6986046 | -0.6275697 | 17.577078 | -1.4019658 | -0.3708166 | -0.3391359 | -2.623991 | -2.623991 | 4.698555 | 0.9242000 | -0.1677566 | 1.1029792 |
| 031017c7-560e-40c5-9ec7-53505a74016a | 20250219_234559_42_491ff229-f13a-4ae6-a4be-068547b4e16b.json | 42 | 9 | 6.967814 | 2.211645 | -2.352071 | 12.345558 | 19.3133716 | 0.9772645 | 16.348018 | 16.348018 | -0.1438750 | -2.352071 | 2.4752041 | 2.4752041 | 0.5280057 | 2.4752041 | -1.336107 | 2.4752041 | 0.5811069 | -2.355745 | 3.7744878 | 1.0579016 | 0.0611695 | 16.348018 | -2.355745 | -0.6241230 | 0.9934812 | 5562.752 | -6.9396396 | -6.9504792 | -0.5110779 | 16.348018 | -1.6022483 | -0.4645496 | -0.4244942 | -2.352071 | -2.352071 | 4.609365 | 0.8171123 | -0.1440997 | 1.1806195 |
| 8c5c3e93-c1f2-460e-b597-f2bc42ac52e3 | 20250219_234747_54_fa1f66f2-1f8e-409d-8a2e-fc9b0b6dc5e6.json | 54 | 10 | 7.053524 | 3.025472 | -2.292242 | 8.684947 | 15.7384712 | 1.5339708 | 16.454829 | 16.454829 | -0.1393051 | -2.292242 | 1.9004002 | 1.9004002 | 0.7401479 | 1.9004002 | -1.323704 | 1.9004002 | 0.5584480 | -3.221234 | 3.5294774 | 1.0335336 | 0.0607724 | 16.454829 | -3.221234 | -0.9126661 | 1.0595123 | 5313.458 | -5.1082372 | -7.1784869 | -0.6192480 | 16.454829 | -1.0956910 | -0.2975259 | -0.3104400 | -2.292242 | -2.292242 | 5.201849 | 1.0136165 | -0.1957623 | 1.0996351 |

Spectral indices calculated from CICADA data.
