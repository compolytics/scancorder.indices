test_that("Channel mask splitting functionality works correctly", {

  # Test 1: Splitting mode with mixed binary/split features
  splitting_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 250, 160, 170],
      [300, 320, 330, 360]
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
          "sensor_fwhm_nom": [5, 8, 6, 7]
        }
      }
    }
  }'

  decoder_split <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result_split <- decoder_split$score(splitting_json)

  # Assertions for splitting mode
  expect_type(result_split, "list")
  expect_named(result_split, c("meta_table", "reflectance", "wavelength", "fwhm"))

  # Check feature wavelengths (should include both LED and sensor wavelengths, no duplicates)
  expected_wavelengths <- c(650, 670, 845, 850)
  expect_equal(result_split$wavelength, expected_wavelengths)

  # Check feature FWHM (should include both LED and sensor FWHM, no duplicates)
  expected_fwhm <- c(10, 8, 6, 12)
  expect_equal(result_split$fwhm, expected_fwhm)

  # Check number of samples and features
  expect_length(result_split$reflectance, 1)
  expect_length(result_split$reflectance[[1]], 4)

  # Check reflectance values based on new matrix (no duplicates)
  # Feature 1: LED 1 binary (sensors 1,4) = avg(100,120) = 110
  # Feature 2: LED 2 split (sensor 2) = 250
  # Feature 3: LED 2 split (sensor 3) = 160
  # Feature 4: LED 3 binary (sensor 4) = 360
  expected_reflectance <- c(110, 250, 160, 360)
  expect_equal(result_split$reflectance[[1]], expected_reflectance)
})

test_that("Backward compatibility with traditional mode (no channel mask)", {
  # Test traditional mode without channel mask
  traditional_json <- '{
    "values": [[100], [200], [300]],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "led_fwhm_nom": [10, 15, 12]
        }
      }
    }
  }'

  decoder_trad <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result_trad <- decoder_trad$score(traditional_json)

  # Assertions for traditional mode
  expect_type(result_trad, "list")
  expect_named(result_trad, c("meta_table", "reflectance", "wavelength", "fwhm"))

  # Should return LED wavelengths (not feature wavelengths)
  expected_wavelengths <- c(650, 750, 850)
  expect_equal(result_trad$wavelength, expected_wavelengths)

  # Should return LED FWHM
  expected_fwhm <- c(10, 15, 12)
  expect_equal(result_trad$fwhm, expected_fwhm)

  # Check number of samples and features
  expect_length(result_trad$reflectance, 1)
  expect_length(result_trad$reflectance[[1]], 3)

  # Should return original sensor values
  expected_reflectance <- c(100, 200, 300)
  expect_equal(result_trad$reflectance[[1]], expected_reflectance)
})

test_that("Multi-sample splitting processing works correctly", {
  # Test with multiple samples
  multi_json <- '[
  {
    "values": [
      [100, 150, 80, 120],
      [200, 300, 160, 240],
      [180, 270, 144, 216]
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
          "sensor_fwhm_nom": [5, 8, 6, 7]
        }
      }
    }
  },
  {
    "values": [
      [150, 100, 120,  80],
      [300, 200, 240, 160],
      [270, 180, 216, 144]
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
          "sensor_fwhm_nom": [5, 8, 6, 7]
        }
      }
    }
  }]'

  decoder_multi <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result_multi <- decoder_multi$score(multi_json)

  # This should be treated as single sample with 3 LEDs × 4 sensors
  expect_type(result_multi, "list")

  # Check single sample was processed
  expect_length(result_multi$reflectance, 2)

  # Sample should have 4 features (based on channel mask, no duplicates)
  expect_length(result_multi$reflectance[[1]], 4)

  # Calculate expected values based on channel mask (fixed logic - no duplicates):
  # LED 1: mask [1,0,0,1] -> avg sensors 1,4 -> avg(100,120) = 110 (one binary feature)
  # LED 2: mask [0,2,3,0] -> sensor 2 = 300, sensor 3 = 160 (two splitting features)
  # LED 3: mask [0,0,0,1] -> sensor 4 = 216 (one binary feature)
  expected_values <- c(110, 300, 160, 216)
  expect_equal(result_multi$reflectance[[1]], expected_values)

  # Calculate expected values based on channel mask (fixed logic - no duplicates):
  # LED 1: mask [1,0,0,1] -> avg sensors 1,4 -> avg(150,80) = 115 (one binary feature)
  # LED 2: mask [0,2,3,0] -> sensor 2 = 200, sensor 3 = 240 (two splitting features)
  # LED 3: mask [0,0,0,1] -> sensor 4 = 144 (one binary feature)
  expected_values <- c(115, 200, 240, 144)
  expect_equal(result_multi$reflectance[[2]], expected_values)
})

test_that("Binary-only mode (channel mask with only 0s and 1s) works correctly", {
  # Test binary-only mode (no splitting values > 1)
  binary_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 250, 160, 170],
      [300, 320, 330, 360]
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
          "sensor_fwhm_nom": [5, 8, 6, 7]
        }
      }
    }
  }'

  decoder_bin <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
  result_bin <- decoder_bin$score(binary_json)

  # Assertions for binary-only mode
  expect_type(result_bin, "list")

  # Should return LED wavelengths (no splitting)
  expected_wavelengths <- c(650, 750, 850)
  expect_equal(result_bin$wavelength, expected_wavelengths)

  # Should return LED FWHM
  expected_fwhm <- c(10, 15, 12)
  expect_equal(result_bin$fwhm, expected_fwhm)

  # Check number of samples and features
  expect_length(result_bin$reflectance, 1)
  expect_length(result_bin$reflectance[[1]], 3)

  # Each LED should be averaged across its active sensors
  # LED 1: mask [1,1,0,0] -> avg(100,150) = 125
  # LED 2: mask [0,0,1,1] -> avg(160,170) = 165
  # LED 3: mask [1,0,0,1] -> avg(300,360) = 330
  expected_reflectance <- c(125, 165, 330)
  expect_equal(result_bin$reflectance[[1]], expected_reflectance)
})

test_that("Shared helper functions work correctly", {
  # Test JSON input - LED x SENSOR format (3 LEDs x 4 Sensors)
  test_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 175, 90, 130],
      [180, 160, 85, 125]
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
          "sensor_fwhm_nom": [5, 8, 6, 7]
        }
      }
    }
  }'

  input_json <- jsonlite::fromJSON(test_json, simplifyVector = FALSE)

  # Test sensor configuration extraction using helpers
  helpers <- ScanCorderHelpers$new()
  sensor_config <- helpers$extract_sensor_configuration(input_json)
  expect_type(sensor_config, "list")
  expect_named(sensor_config, c("device_sensor_info", "external_sensor_info"))
  expect_false(is.null(sensor_config$device_sensor_info))

  # Test wavelength extraction
  device_info <- sensor_config$device_sensor_info
  external_info <- sensor_config$external_sensor_info

  led_wl <- helpers$extract_led_wavelengths(input_json, device_info, external_info)
  expect_equal(led_wl, c(650, 750, 850))

  sensor_wl <- helpers$extract_sensor_wavelengths(input_json, device_info, external_info)
  expect_equal(sensor_wl, c(655, 670, 845, 860))

  # Test channel mask extraction
  sensor_values <- helpers$convert_json_to_matrix(input_json$values)
  channel_mask <- helpers$extract_channel_mask(input_json, device_info, external_info, sensor_values)
  expect_equal(dim(channel_mask), c(3, 4))
  expect_true(helpers$has_splitting(channel_mask))

  # Test feature wavelength extraction (with averaging to get mixed_mode behavior)
  feature_info <- helpers$extract_feature_wavelengths(input_json, device_info, external_info, channel_mask, average_sensor_values = TRUE)
  expect_type(feature_info, "list")
  expect_named(feature_info, c("wavelengths", "led_indices", "sensor_indices", "mixed_mode", "flattened_mode"))
  expect_true(feature_info$mixed_mode)
  expect_equal(feature_info$wavelengths, c(650, 670, 845, 850))

  # Test FWHM extraction
  feature_fwhm <- helpers$extract_feature_fwhm(input_json, device_info, external_info, channel_mask, feature_info)
  expect_equal(feature_fwhm, c(10, 8, 6, 12))
})

test_that("Error handling works correctly", {
  # Test with missing sensor wavelengths for splitting
  invalid_json <- '{
    "values": [
      [100, 150, 80, 120],
      [200, 250, 160, 170],
      [300, 320, 330, 360]
    ],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "channel_mask": [
            [1, 0, 0, 1],
            [0, 2, 3, 0],
            [0, 0, 0, 1]
          ],
          "led_fwhm_nom": [10, 15, 12]
        }
      }
    }
  }'

  decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)

  # Should throw error about missing sensor wavelengths
  expect_error(
    decoder$score(invalid_json),
    "Channel mask splitting requires sensor wavelengths"
  )

  # Test with mismatched dimensions
  mismatch_json <- '{
    "values": [[100], [150], [80]],
    "config": {
      "sensorHead": {
        "additionalInfo": {
          "led_wl": [650, 750, 850],
          "sensor_wl": [655, 670, 845, 860],
          "channel_mask": [
            [1, 0, 0, 1],
            [0, 2, 3, 0],
            [0, 0, 0, 1]
          ]
        }
      }
    }
  }'

  # Should throw error about dimension mismatch
  expect_error(
    decoder$score(mismatch_json),
    "Channel mask number of sensors.*does not match sensor values number of sensors"
  )
})
