library(scancorder.indices)

# First rule of programming: clean it
rm(list = ls())

# Step 0: What data file to process
# ------------------------------------------------------------------------------
# Please change this to the path and file name of your reflectance CSV file.
#
# Change this name to the actual file containing reflectance data
reflectance_csv_file_name = "Reflectance_List_S8330_ColorChecker.csv"
# Get current directory
current_dir <- getwd()
# Build full path + file name to the data file, changes this location to the
# location of your actual file
reflectance_file_path <- file.path(current_dir, "example", "data", reflectance_csv_file_name)

# Step 1: Load CSV file and extract data
# ------------------------------------------------------------------------------
# Setup a decoder that will load reflectance from CSV and sensor metadata
# Specify the sensor name/serial to load wavelength and FWHM information
decoder <- DecodeReflectanceList$new(sensor_name = "8330", delimiter = ";")
# Decode the reflectance data from CSV file
data <- decoder$score(reflectance_file_path)

# Step 2: Inspect the loaded data
# ------------------------------------------------------------------------------
cat("Number of samples loaded:", length(data$reflectance), "\n")
cat("Wavelengths:", data$wavelength, "\n")
cat("FWHM:", data$fwhm, "\n")
cat("\nMetadata table (first 5 rows):\n")
print(head(data$meta_table, 5))

# Step 3: Calculate Indices table from all available data
# ------------------------------------------------------------------------------
# Note: Since reflectance was loaded from CSV, no additional calibration is needed
index_table <- calculate_indices_table(data$wavelength, data$reflectance, data$fwhm, data$meta_table)

# Step 4: Save
# ------------------------------------------------------------------------------
# Generate an output file name based on the input file name
# Change this file and path to the location where you want to save the indices table
table_file_path <- file.path(current_dir, "example", "data", "Reflectance_List_S8330_ColorChecker_Indices.csv")
write_indices_csv(index_table, table_file_path, row.names = FALSE)

cat("\nIndices calculated and saved to:", table_file_path, "\n")

# ------------------------------------------------------------------------------
# The End
