# Using DecodeReflectanceList

The `DecodeReflectanceList` class provides an alternative way to load reflectance data from CSV files instead of ScanCorder JSON files.

## Features

- Loads reflectance data from CSV files where each row is a separate sample
- Automatically extracts wavelengths from column headers
- Retrieves FWHM information from sensor metadata in the package
- **Fallback behavior**: If sensor metadata is not found, uses wavelengths from CSV column headers and assumes FWHM = 1nm
- Preserves metadata from CSV (e.g., LabelName, LabelNumber)
- Produces the same output structure as `DecodeCompolyticsRegularScanner`

## CSV Format Requirements

The CSV file should have:
- **Metadata columns** at the beginning (e.g., `LabelName`, `LabelNumber`)
- **Wavelength columns** with numeric headers representing wavelengths in nm (e.g., `394`, `445`, `490`)
- **One row per sample** with reflectance values

Example CSV structure:
```csv
LabelName;LabelNumber;394;445;459;490;517;590;680;700;750;770;800;850
Sample_01;1;0.071;0.075;0.072;0.078;0.085;0.140;0.166;0.164;0.169;0.171;0.166;0.159
Sample_02;2;0.213;0.254;0.249;0.328;0.350;0.471;0.659;0.667;0.729;0.723;0.739;0.739
```

## Usage Example

```r
library(scancorder.indices)

# Create decoder for sensor S8330
decoder <- DecodeReflectanceList$new(sensor_name = "8330", delimiter = ";")

# Load reflectance data from CSV file
data <- decoder$score("path/to/reflectance_data.csv")

# The output contains:
# - meta_table: Data frame with metadata (LabelName, LabelNumber, etc.)
# - reflectance: List of numeric vectors (one per sample)
# - wavelength: Numeric vector of wavelengths
# - fwhm: Numeric vector of FWHM values

# Calculate vegetation indices
index_table <- calculate_indices_table(
  data$wavelength, 
  data$reflectance, 
  data$fwhm, 
  data$meta_table
)

# Save results
write_indices_csv(index_table, "output_indices.csv")
```

## Sensor Metadata

The class tries to load sensor metadata from the package using `find_sensor_metadata()`. This includes:
- Real or nominal LED wavelengths
- Real or nominal FWHM values

If the sensor is not found in the package:
- A warning is issued
- Wavelengths are taken from CSV column headers
- FWHM is assumed to be 1nm for all wavelengths

## Comparison with DecodeCompolyticsRegularScanner

| Feature | DecodeCompolyticsRegularScanner | DecodeReflectanceList |
|---------|--------------------------------|----------------------|
| Input Format | ScanCorder JSON file | CSV file |
| Calibration | Supports two-point and multi-point | Pre-calibrated data expected |
| Dark Current | Automatic subtraction | Not applicable |
| Sensor Info | From JSON file | From package or CSV headers |
| Output Structure | Same | Same |

## See Also

- Example script: `example/02_generate_indices_table_from_reflectance_list.R`
- Example data: `example/data/Reflectance_List_S8330_ColorChecker.csv`
- Regular ScanCorder example: `example/01_generate_indices_table_from_Scancorder.R`
