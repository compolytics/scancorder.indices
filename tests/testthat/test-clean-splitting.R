test_that("Channel mask splitting functionality works correctly", {
  # Test JSON with splitting
  splitting_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 250, 160, 240], 
      [300, 350, 240, 360]
    ],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "sensor_wl": [655, 670, 845, 860],
          "channel_mask": [
            [1, 0, 0, 1],
            [0, 2, 3, 0],
            [0, 0, 0, 1]
          ],
          "led_fwhm_nom": [10, 15, 12],
          "sensor_fwhm": [5, 8, 6, 7]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result <- decoder$score(splitting_json)
  
  # Should return 4 features based on corrected implementation (no binary duplicates):
  # LED1 creates 1 feature (binary avg), LED2 creates 2 features (split), LED3 creates 1 feature (binary)
  expect_length(result$reflectance, 1)
  expect_length(result$reflectance[[1]], 4)
  
  # Check wavelengths: LED1 (binary), LED2 (sensor 2), LED2 (sensor 3), LED3 (binary)
  expected_wavelengths <- c(650, 670, 845, 850)
  expect_equal(result$wavelength, expected_wavelengths)
  
  # Check values based on corrected implementation:
  # Feature 1: LED 1 binary = avg(100,120) = 110 (one feature, not duplicated)
  # Feature 2: LED 2 sensor 2 = 250 (splitting mode)
  # Feature 3: LED 2 sensor 3 = 160 (splitting mode)
  # Feature 4: LED 3 sensor 4 = 360 (binary mode)
  expected_values <- c(110, 250, 160, 360)
  expect_equal(result$reflectance[[1]], expected_values)
})

test_that("Backward compatibility with traditional mode is maintained", {
  # Test JSON without channel_mask (should work as before)
  traditional_json <- '{
    "values": [
      [100], 
      [150], 
      [80]
    ],
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
  result <- decoder$score(traditional_json)
  
  # Should return 3 features (one per LED)
  expect_length(result$reflectance, 1)
  expect_length(result$reflectance[[1]], 3)
  expect_equal(result$reflectance[[1]], c(100, 150, 80))
  expect_equal(result$wavelength, c(650, 750, 850))
})

test_that("Multi-sample processing works with splitting", {
  # Test JSON with one sample containing 2 LEDs and 2 sensors each
  multi_sample_json <- '{
    "values": [
      [100, 150],
      [200, 250]
    ],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750],
          "sensor_wl": [655, 755],
          "channel_mask": [
            [2, 0],
            [0, 3]
          ],
          "led_fwhm_nom": [10, 15],
          "sensor_fwhm": [5, 8]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result <- decoder$score(multi_sample_json)
  
  # Should return 1 sample with 2 features (splitting mode)
  expect_length(result$reflectance, 1)
  expect_length(result$reflectance[[1]], 2)
  
  # Check values based on channel mask:
  # LED 1: channel_mask[1,1]=2 -> use sensor 1 = 100 (splitting)
  # LED 2: channel_mask[2,2]=3 -> use sensor 2 = 250 (splitting)
  expect_equal(result$reflectance[[1]], c(100, 250))
  
  # Wavelengths should be sensor wavelengths (splitting mode)
  expect_equal(result$wavelength, c(655, 755))
})

test_that("Binary-only mode works correctly", {
  # Test JSON with all binary channels (no splitting)
  binary_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 250, 160, 240],
      [300, 350, 240, 360]
    ],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "sensor_wl": [655, 670, 845, 860],
          "channel_mask": [
            [1, 1, 0, 0],
            [0, 0, 1, 1],
            [1, 0, 0, 1]
          ],
          "led_fwhm_nom": [10, 15, 12],
          "sensor_fwhm": [5, 8, 6, 7]
        }
      }
    }
  }'
  
  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result <- decoder$score(binary_json)
  
  # Should return 3 features (one per LED, averaged across sensors)
  expect_length(result$reflectance, 1)
  expect_length(result$reflectance[[1]], 3)
  
  # Check the actual values returned (averaged per LED)
  # LED 1: sensors 1,2 = (100+150)/2 = 125
  # LED 2: sensors 3,4 = (160+240)/2 = 200
  # LED 3: sensors 1,4 = (300+360)/2 = 330
  expected_values <- c(125, 200, 330)
  expect_equal(result$reflectance[[1]], expected_values)
  
  # All wavelengths should be LED wavelengths (binary-only mode)
  expect_equal(result$wavelength, c(650, 750, 850))
})

test_that("Error handling works correctly", {
  # Test with malformed JSON
  expect_error(
    DecodeCompolyticsRegularScanner$new()$score("invalid json"),
    "lexical error|unexpected character"
  )
  
  # Test with missing required fields
  incomplete_json <- '{"values": [[100]]}'
  
  decoder <- DecodeCompolyticsRegularScanner$new()
  expect_error(
    decoder$score(incomplete_json),
    "Cannot find sensor information|config.*not found|subscript out of bounds"
  )
})