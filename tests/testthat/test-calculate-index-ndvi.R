test_that("test calculating NDVI from CICADA json with single point reflectance and sensor average",
          {
            # What to expect, a list of NDVI
            expectedNDVI = list(c(0.202269581))

            json_path <- testthat::test_path(
              "data/20250303_150545_SA1211_B3009_S5221_08445c21-184a-4082-8597-e11f62e3561e_0001.json"
            )
            # Load the JSON file with the sensor reading
            json_input <- paste(readLines(json_path), collapse = "\n")
            # Setup a decoder that will average the reflectance per LED across sensor channels
            decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
            # Decode the JSON input to get the reflectance values
            data <- decoder$score(json_input)
            # Calculate Index
            ndvi_value <- calculate_index(get_index_xml("NDVI"), data$wavelength, data$reflectance)
            # Check if the NDVI value is as expected
            expect_equal(ndvi_value, expectedNDVI)
          })
