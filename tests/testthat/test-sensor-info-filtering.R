test_that("calculate_indices_table filters indices based on valid_vi in sensor_info", {
  # Load test data
  json_path <- testthat::test_path("data/2025-05-23_ColorChecker_B7696_S3956.json")
  
  # Setup decoder and load data
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  data <- decoder$score(json_path)
  
  # Setup multi-calibration
  calibrator <- CalibrationReflectanceMultipoint$new()
  calibReflectance <- calibrator$score(data$reflectance, json_path)
  
  # Calculate with sensor_info (filtered)
  index_table_filtered <- calculate_indices_table(
    data$wavelength, 
    calibReflectance, 
    data$fwhm, 
    data$meta_table, 
    data$sensor_info
  )
  
  # Calculate without sensor_info (all indices)
  index_table_all <- calculate_indices_table(
    data$wavelength, 
    calibReflectance, 
    data$fwhm, 
    data$meta_table,
    NULL
  )
  
  # The filtered table should have fewer columns than the unfiltered one
  expect_true(ncol(index_table_filtered) <= ncol(index_table_all))
  
  # Check that sensor_info contains valid_vi field
  if (!is.null(data$sensor_info) && !is.null(data$sensor_info$valid_vi)) {
    # All index columns in filtered table should be in valid_vi list
    valid_indices <- unlist(data$sensor_info$valid_vi)
    # Get index column names (excluding meta columns and sample column)
    meta_cols <- colnames(data$meta_table)
    index_cols_filtered <- setdiff(colnames(index_table_filtered), c(meta_cols, "sample"))
    
    # All filtered indices should be in valid_vi
    expect_true(all(index_cols_filtered %in% valid_indices))
  }
})

test_that("calculate_indices_table works without sensor_info (backward compatibility)", {
  # Load test data
  json_path <- testthat::test_path("data/2025-05-23_ColorChecker_B7696_S3956.json")
  
  # Setup decoder and load data
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  data <- decoder$score(json_path)
  
  # Setup multi-calibration
  calibrator <- CalibrationReflectanceMultipoint$new()
  calibReflectance <- calibrator$score(data$reflectance, json_path)
  
  # Calculate without sensor_info parameter (backward compatibility)
  expect_no_error({
    index_table <- calculate_indices_table(
      data$wavelength, 
      calibReflectance, 
      data$fwhm, 
      data$meta_table
    )
  })
  
  # Should return a data frame
  expect_true(is.data.frame(index_table))
  # Should have sample column
  expect_true("sample" %in% colnames(index_table))
})

test_that("DecodeCompolyticsRegularScanner returns sensor_info", {
  json_path <- testthat::test_path("data/2025-05-23_ColorChecker_B7696_S3956.json")
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  data <- decoder$score(json_path)
  
  # Check that sensor_info is in the returned list
  expect_true("sensor_info" %in% names(data))
  
  # If sensor_info exists, it should be a list or NULL
  expect_true(is.list(data$sensor_info) || is.null(data$sensor_info))
})

test_that("DecodeReflectanceList returns sensor_info", {
  # Get path to test CSV file
  csv_path <- system.file("../example/data", "Reflectance_List_S8330_ColorChecker.csv", 
                         package = "scancorder.indices")
  
  # Skip if file doesn't exist
  skip_if_not(file.exists(csv_path), "Test CSV file not found")
  
  decoder <- DecodeReflectanceList$new(sensor_name = "8330", delimiter = ";")
  data <- decoder$score(csv_path)
  
  # Check that sensor_info is in the returned list
  expect_true("sensor_info" %in% names(data))
  
  # If sensor_info exists, it should be a list or NULL
  expect_true(is.list(data$sensor_info) || is.null(data$sensor_info))
})
