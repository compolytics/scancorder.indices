test_that("Basic splitting functionality works with simple cases", {
  # Test with simple splitting case - manually load helper functions for testing
  simple_splitting_json <- '{
    "values": [[100, 0], [0, 200]],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750],
          "sensor_wl": [655, 755],
          "channel_mask": [
            [1, 0],
            [0, 1]
          ],
          "led_fwhm_nom": [10, 15],
          "sensor_fwhm": [5, 8]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  
  # This should work if the splitting functionality is properly implemented
  # Note: this may fail until helper functions are properly loaded
  expect_error({
    result <- decoder$score(simple_splitting_json)
  }, regexp = NA)  # Expect no error
})

test_that("Traditional backward compatibility mode works", {
  # Test traditional mode - should work without channel mask
  traditional_json <- '{
    "values": [[100], [150], [80]],
    "config": {
      "sensorHead": {
        "name": "Test Sensor 1234",
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "led_fwhm_nom": [10, 15, 12]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  
  # This should work in traditional mode
  expect_error({
    result <- decoder$score(traditional_json)
    
    # Basic checks
    expect_type(result, "list")
    expect_true("reflectance" %in% names(result))
    expect_true("wavelength" %in% names(result))
    
    # Should return 3 features (one per LED) 
    expect_length(result$reflectance, 1)
    expect_length(result$reflectance[[1]], 3)
    expect_equal(result$wavelength, c(650, 750, 850))
  }, regexp = NA)  # Expect no error
})