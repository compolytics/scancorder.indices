library(scancorder.indices)

# First rule of programming: clean it
rm(list = ls())

# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Please change this to the path and file name of your CICADA json data file.
#
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

# Step 4: Save
# ------------------------------------------------------------------------------
# Generate an output file name based on the input file name
# Change this file and path to the location where you want to save the indices table
table_file_path <- file.path(current_dir, "example", "data", "Compolytics_R-Package_VI_Test_File_Indices.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

# ------------------------------------------------------------------------------
# The End

