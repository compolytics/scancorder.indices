# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
# * https://testthat.r-lib.org/articles/special-files.html

library(testthat)
library(scancorder.indices)

test_check("scancorder.indices")
# Sample data: a vector of wavelengths and corresponding reflectance values.
wavelengths <- seq(500, 850, by = 10)
set.seed(123)
reflectance <- runif(length(wavelengths))

# Calculate NDVI (using the XML file "ndvi.xml")
ndvi_value <- calculate_index("ndvi.xml", wavelengths, reflectance)
cat("NDVI:", ndvi_value, "\n")

# Calculate NDWI (using the XML file "ndwi.xml")
ndwi_value <- calculate_index("ndwi.xml", wavelengths, reflectance)
cat("NDWI:", ndwi_value, "\n")