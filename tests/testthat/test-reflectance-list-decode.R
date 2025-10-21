test_that("DecodeReflectanceList loads CSV and sensor metadata correctly", {
  # Get path to test CSV file
  csv_path <- system.file("../example/data", "Reflectance_List_S8330_ColorChecker.csv", 
                         package = "scancorder.indices")
  
  # Skip if file doesn't exist
  skip_if_not(file.exists(csv_path), "Test CSV file not found")
  
  # Create decoder
  decoder <- DecodeReflectanceList$new(sensor_name = "8330", delimiter = ";")
  
  # Load data
  data <- decoder$score(csv_path)
  
  # Check structure
  expect_true(is.list(data))
  expect_true("meta_table" %in% names(data))
  expect_true("reflectance" %in% names(data))
  expect_true("wavelength" %in% names(data))
  expect_true("fwhm" %in% names(data))
  
  # Check metadata table
  expect_true(is.data.frame(data$meta_table))
  expect_true("LabelName" %in% names(data$meta_table))
  expect_equal(nrow(data$meta_table), 24)  # 24 ColorChecker samples
  
  # Check reflectance list
  expect_true(is.list(data$reflectance))
  expect_equal(length(data$reflectance), 24)  # 24 samples
  expect_true(is.numeric(data$reflectance[[1]]))
  
  # Check wavelengths
  expect_true(is.numeric(data$wavelength))
  expect_equal(length(data$wavelength), 12)  # S8330 has 12 LEDs
  
  # Check FWHM
  expect_true(is.numeric(data$fwhm) || is.null(data$fwhm))
  if (!is.null(data$fwhm)) {
    expect_equal(length(data$fwhm), 12)
  }
})

test_that("DecodeReflectanceList handles missing file gracefully", {
  decoder <- DecodeReflectanceList$new(sensor_name = "8330")
  expect_error(decoder$score("nonexistent_file.csv"), "CSV file not found")
})

test_that("DecodeReflectanceList requires sensor_name parameter", {
  expect_error(DecodeReflectanceList$new(), "sensor_name is required")
})

test_that("DecodeReflectanceList uses CSV wavelengths as fallback when sensor not found", {
  # Get path to test CSV file
  csv_path <- system.file("../example/data", "Reflectance_List_S8330_ColorChecker.csv", 
                         package = "scancorder.indices")
  
  # Skip if file doesn't exist
  skip_if_not(file.exists(csv_path), "Test CSV file not found")
  
  # Create decoder with non-existent sensor
  decoder <- DecodeReflectanceList$new(sensor_name = "9999")
  
  # Should produce warning but still work
  expect_warning(
    data <- decoder$score(csv_path),
    "Sensor metadata not found"
  )
  
  # Check that wavelengths from CSV are used
  expect_true(is.numeric(data$wavelength))
  expect_equal(length(data$wavelength), 12)  # 12 wavelength columns in CSV
  
  # Check that FWHM is set to 1nm
  expect_true(is.numeric(data$fwhm))
  expect_equal(length(data$fwhm), 12)
  expect_true(all(data$fwhm == 1))
})
