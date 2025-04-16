test_that("test CICADA json with sensor set multi point reflectance and sensor average",
          {
            # What to expect, a list of flattened reflectance vectors
            expectedReflectance = list(
              c(
                0.27183583019590901175,
                0.12778142210510917698,
                0.18457823388356783822,
                0.19554861577191423594,
                0.31697108385616384885,
                0.43071404875524871292,
                0.46698097098546453854,
                0.47005589651402440721,
                0.50617128916173614872,
                0.4889325138878333199,
                0.47030773389871982637,
                0.52112279173402409338
              )
            )

            json_path <- testthat::test_path(
              "data/20250303_150545_SA1211_B3009_S5221_08445c21-184a-4082-8597-e11f62e3561e_0001.json"
            )
            # Load the JSON file with the sensor reading
            json_input <- paste(readLines(json_path), collapse = "\n")
            # Setup a decoder that will average the reflectance per LED across sensor channels
            decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
            # Decode the JSON input to get the reflectance values
            loadedReflectance <- decoder$score(json_input)
            # Setup multi-calibration tool
            calibrator <- CalibrationReflectanceMultipoint$new()
            # Run multi-calibration with sensor provided factors
            loadedReflectance <- calibrator$score(loadedReflectance, json_input)
            # Check if the reflectance values are numeric
            expect_equal(loadedReflectance, expectedReflectance)
          })
