test_that("Basic decoder functionality works", {
  # Simple test without any advanced features - proper LED×SENSOR matrix format
  simple_json <- '{
    "values": [[100], [150], [80]],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "led_fwhm_nom": [10, 15, 12]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  
  # This should work with traditional mode (no channel mask)
  result <- decoder$score(simple_json)
  
  expect_type(result, "list")
  expect_true("reflectance" %in% names(result))
  expect_true("wavelength" %in% names(result))
  
  # Should return 3 features (one per LED)
  expect_length(result$reflectance, 1)
  expect_length(result$reflectance[[1]], 3)
  expect_equal(result$reflectance[[1]], c(100, 150, 80))
  expect_equal(result$wavelength, c(650, 750, 850))
})