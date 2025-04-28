test_that("test calculating available indices for a CICADA json sample",
          {
            # What to expect, a list of NDVI
            expected_table = list(c(0.202269581))
            # Load the XML file with the NDVI index definition
            json_path <- testthat::test_path(
              "data/20250121_003131_Agave_B8861_S4343_018d5378-9186-4336-8511-1d5b14a15144_R0001.json"
            )

            # Step 1: Load Json file and extract data
            # ------------------------------------------------------------------
            # Load the JSON file with the sensor reading
            json_input <- paste(readLines(json_path), collapse = "\n")
            # Setup a decoder that will average the reflectance per LED across sensor channels
            decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
            # Decode the JSON input to get the reflectance values
            data <- decoder$score(json_input)

            # Step 2: Run multi calibration for improved reflectance
            # ------------------------------------------------------------------
            # Setup multi-calibration tool
            calibrator <- CalibrationReflectanceMultipoint$new()
            # Run multi-calibration with sensor provided factors
            calibReflectance <- calibrator$score(data$reflectance, json_input)

            # Step 3: Calculate Indices table from all available data
            # ------------------------------------------------------------------
            index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm)
            print("Table")
            print(index_table)
            write_indices_csv(index_table, "expectedTable.csv", row.names = FALSE)

            # Check if the NDVI value is as expected
            # expect_equal(expected_table, index_table)
          })
