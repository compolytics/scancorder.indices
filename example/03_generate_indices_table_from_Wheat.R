library(scancorder.indices)

# First rule of programming: clean it
rm(list = ls())
# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Get current directory
current_dir <- getwd()
# Build file
data_file_path <- file.path(current_dir, "example", "data", "S0001_20250219_234134_Target_c3f28a94-fa54-4049-8053-737d770c5a1d_R0001.json")

# For spectral indices we use in this example the broadband sensor only
channel_mask <- matrix(0, nrow = 12, ncol = 10)
channel_mask[, 10] <- 1

# Step 1: Load Json file and extract data
# ------------------------------------------------------------------------------
# Load the JSON file with the sensor reading
json_input <- readChar(data_file_path, nchars = file.info(data_file_path)$size)
# Setup a decoder that will average the reflectance per LED across sensor channels
decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE, channel_mask = channel_mask)
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
index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm)
table_file_path <- file.path(current_dir, "example", "data", "S0001_20250219_234134_Target_c3f28a94-fa54-4049-8053-737d770c5a1d_R0001.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

# ------------------------------------------------------------------------------
# The End

