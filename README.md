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

#### Windows/Linux

``` r
options(repos = c(
  gitlab = "https://gitlab.com/api/v4/projects/70774833/packages/generic/scancorder.indices/__VERSION__/",
  CRAN   = "https://cloud.r-project.org"
))
install.packages("scancorder.indices")
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
# Please change this to the path and file name of your CICADA json data file.
# ------------------------------------------------------------------------------
# Change this name to the actual file you exported from the CICADA measurement app
cicada_file_name = "Compolytics_R-Package_VI_Test_File.json"
# Get current directory
current_dir <- getwd()
# Build full path + file name to the data file, changes this location to the
# location of your actual file
sensor_file_path <- file.path(current_dir, "example", "data", cicada_file_name)

# Step 1: Load Json file and extract data
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

| uuid | filename | sample_id | sample | ARI1 | ARI2 | CI | CRI1 | CRI2 | Datt6 | DWSI4 | GI | GM1 | GM2 | LIC1 | NDI | NDVI | NDVI4 | NDVIg | PSNDa1 | PSNDc1 | PSSRa1 | PSSRc1 | RDVI | RGI | RGR | RVI | RVI2 | SAVI | SIPI1 | SR.550.800. | SR.556.750. | SR.605.670. | SR.675.555. | SR.683.510. | SR.694.840. | SR.695.800. | SR.750.705. | SR.752.690. | SR.800.600. | SR.810.560. |
|:---|:----|:-|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|-:|
| 398cac85-1fac-4d30-98a9-313de2fd436e | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 1 | 1.455141 | 0.7046968 | 3.392523 | -1.0889722 | 0.3661691 | 31.93912 | 1.0465030 | 1.0465030 | 4.051907 | 3.392523 | 0.6384491 | 0.6384491 | 0.6137790 | 0.5676287 | 0.6041099 | 0.6384491 | 0.6837402 | 4.531725 | 5.323914 | 0.4461761 | 0.9555634 | 0.9533712 | 3.625654 | 0.8512018 | 0.4706039 | 1.153645 | 0.2309282 | 0.2467974 | 0.8372657 | 0.9555634 | 0.8391909 | 0.2799645 | 0.2758123 | 3.392523 | 4.240333 | 4.330351 | 4.330351 |
| f3694b9b-5958-4905-936e-6e7f48276258 | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 2 | 1.767805 | 0.8193834 | 3.161953 | 0.1423784 | 1.9101835 | 30.24442 | 1.1210264 | 1.1210264 | 3.924191 | 3.161953 | 0.6508946 | 0.6508946 | 0.6003437 | 0.5453521 | 0.5938419 | 0.6508946 | 0.7202355 | 4.728929 | 6.148869 | 0.4223812 | 0.8920396 | 0.7933481 | 3.399008 | 0.7690729 | 0.4461523 | 1.173255 | 0.2370572 | 0.2548296 | 0.8057593 | 0.8920396 | 0.9059948 | 0.3009185 | 0.2942035 | 3.161953 | 4.399122 | 4.218392 | 4.218392 |
| 1a7dbcc7-aab2-44a5-9f8e-7e377574510f | 20250911_133609_Lime_8a24381d-b1f2-476f-8abb-d384af3d92d6.json | Lime | 3 | 1.727309 | 0.8178471 | 3.282283 | -0.6193795 | 1.1079299 | 32.05255 | 1.1082329 | 1.1082329 | 4.047483 | 3.282283 | 0.6548253 | 0.6548253 | 0.6120944 | 0.5563550 | 0.6037629 | 0.6548253 | 0.6988497 | 4.794167 | 5.641203 | 0.4339739 | 0.9023374 | 0.8699174 | 3.508109 | 0.8498483 | 0.4580906 | 1.165889 | 0.2311628 | 0.2470671 | 0.8109442 | 0.9023374 | 0.8411664 | 0.2850477 | 0.2850539 | 3.282283 | 4.485554 | 4.325956 | 4.325956 |
| 9b131730-ea16-46cb-9d70-46272e23d036 | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 4 | 1.699768 | 0.8415079 | 3.443152 | -1.0003516 | 0.6994164 | 33.30871 | 1.1106120 | 1.1106120 | 4.224881 | 3.443152 | 0.6694768 | 0.6694768 | 0.6290557 | 0.5750510 | 0.6172162 | 0.6694768 | 0.7115009 | 5.051013 | 5.932431 | 0.4559406 | 0.9004044 | 0.9145604 | 3.706447 | 0.8514238 | 0.4804465 | 1.139389 | 0.2198791 | 0.2366930 | 0.8149700 | 0.9004044 | 0.8023556 | 0.2757972 | 0.2698002 | 3.443152 | 4.692204 | 4.547955 | 4.547955 |
| d9976327-4180-4785-8034-b88c27df300c | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 5 | 1.875598 | 0.9083156 | 3.299921 | -0.8482137 | 1.0273840 | 31.53261 | 1.0991832 | 1.0991832 | 4.148246 | 3.299921 | 0.6599869 | 0.6599869 | 0.6221651 | 0.5588182 | 0.6115182 | 0.6599869 | 0.7068512 | 4.882126 | 5.822475 | 0.4404903 | 0.9097664 | 0.8765655 | 3.533279 | 0.8384967 | 0.4644670 | 1.170282 | 0.2251444 | 0.2410658 | 0.7954978 | 0.9097664 | 0.8256282 | 0.2908586 | 0.2830232 | 3.299921 | 4.559682 | 4.441594 | 4.441594 |
| eef00541-a703-45df-b2ab-46f6698897d8 | 20250911_133447_Lime_ff05a1c2-91d6-41cd-903f-0390cdf04fea.json | Lime | 6 | 1.351382 | 0.6757587 | 3.508938 | -1.2983410 | 0.0530414 | 35.63165 | 1.0451337 | 1.0451337 | 4.122447 | 3.508938 | 0.6519118 | 0.6519118 | 0.6169058 | 0.5888980 | 0.6095616 | 0.6519118 | 0.6748146 | 4.745671 | 5.150337 | 0.4672118 | 0.9568154 | 0.9931843 | 3.864972 | 0.9214292 | 0.4922882 | 1.046938 | 0.2202289 | 0.2425744 | 0.8511784 | 0.9568154 | 0.8200096 | 0.2548452 | 0.2587341 | 3.508938 | 4.308509 | 4.540731 | 4.540731 |
| 81a11240-b895-428c-9170-5b77f7eff350 | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 7 | 1.716445 | 0.8169823 | 3.403994 | -1.4946034 | 0.2218416 | 32.43332 | 0.9315334 | 0.9315334 | 4.180335 | 3.403994 | 0.6076876 | 0.6076876 | 0.6196017 | 0.5635277 | 0.6139246 | 0.6076876 | 0.6732166 | 4.097978 | 5.120261 | 0.4397126 | 1.0734989 | 0.9713674 | 3.582192 | 0.8003455 | 0.4641332 | 1.147375 | 0.2273154 | 0.2392153 | 0.8142874 | 1.0734989 | 0.8999031 | 0.2849686 | 0.2791587 | 3.403994 | 3.894122 | 4.399175 | 4.399175 |
| 845567d7-4573-4557-ac81-d0b64903598e | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 8 | 2.276122 | 1.1041719 | 3.301597 | -1.1003474 | 1.1757745 | 32.27260 | 0.9072553 | 0.9072553 | 4.336849 | 3.301597 | 0.6151307 | 0.6151307 | 0.6339339 | 0.5576585 | 0.6252470 | 0.6151307 | 0.7176961 | 4.196569 | 6.084563 | 0.4401166 | 1.1022256 | 0.8606030 | 3.521394 | 0.6897075 | 0.4640109 | 1.174745 | 0.2161898 | 0.2305822 | 0.7612893 | 1.1022256 | 0.9750287 | 0.2954539 | 0.2839785 | 3.301597 | 3.934629 | 4.625566 | 4.625566 |
| 41f49fff-47ea-470d-bad6-176dc2129b72 | 20250911_133329_Lime_7094830a-7194-4cae-9aa8-0c26f0b7ad50.json | Lime | 9 | 1.268001 | 0.6024811 | 3.322933 | -0.4310728 | 0.8369281 | 31.00466 | 1.0132980 | 1.0132980 | 3.885730 | 3.322933 | 0.6164936 | 0.6164936 | 0.5974013 | 0.5611379 | 0.5906446 | 0.6164936 | 0.6984906 | 4.215037 | 5.633292 | 0.4378001 | 0.9868765 | 0.8994513 | 3.557240 | 0.7482370 | 0.4621195 | 1.152638 | 0.2404007 | 0.2573519 | 0.8551631 | 0.9868765 | 0.9382836 | 0.2823666 | 0.2811168 | 3.322933 | 3.937403 | 4.159721 | 4.159721 |
| cf4660c5-5e96-47f3-ad3d-9aa078a533de | 20250911_133200_Lime_4bb7735b-aeb4-45d1-b33f-a34b9965fac0.json | Lime | 10 | 1.509658 | 0.7135385 | 3.454804 | -1.1942108 | 0.3154468 | 33.43970 | 0.9697816 | 0.9697816 | 4.122309 | 3.454804 | 0.6207408 | 0.6207408 | 0.6217215 | 0.5738388 | 0.6095510 | 0.6207408 | 0.6984000 | 4.273438 | 5.631301 | 0.4447278 | 1.0311600 | 0.9611948 | 3.693060 | 0.7588724 | 0.4697293 | 1.140128 | 0.2269324 | 0.2425825 | 0.8380750 | 1.0311600 | 0.8990783 | 0.2788060 | 0.2707782 | 3.454804 | 3.997739 | 4.406598 | 4.406598 |

Spectral indices calculated from CICADA data.
