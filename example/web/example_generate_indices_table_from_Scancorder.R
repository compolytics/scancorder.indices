library(scancorder.indices)

# First rule of programming: clean what came before.
rm(list = ls())

# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Please change this to the path and file name of your CICADA json data file.
#
# Change this name to the actual file you exported from the CICADA measurement app
cicada_file_name = "2025-02-20_11-57-59_exampleDataFiles.json"
# Get current directory, make sure the R working directory is the one with
# the CICADA data file
current_dir <- getwd()
# We assume the data file is in the current directory
sensor_file_path <- file.path(current_dir, cicada_file_name)

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
# We pass the wavelength, reflectance and FWHM values as well as the meta table
# to the indices calculation, we use the multi-calibrated reflectance values
index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm, data$meta_table)

# Step 4: Save spectral indices in CSV file
# ------------------------------------------------------------------------------
# Generate an output file name based on the input file name
# Change this file and path to the location where you want to save the indices table
table_file_path <- file.path(current_dir, "2025-02-20_11-57-59_exampleDataFiles_Indices.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

# ------------------------------------------------------------------------------
# The End

