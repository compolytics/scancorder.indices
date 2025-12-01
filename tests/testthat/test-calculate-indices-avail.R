test_that("test calculating available indices for a CICADA json sample",
          {
            # Load the XML file with the NDVI index definition
            json_path <- testthat::test_path(
              "data/20250121_003131_Agave_B8861_S4343.json"
            )

            # Step 1: Load Json file and extract data
            # ------------------------------------------------------------------
            # Setup a decoder that will average the reflectance per LED across sensor channels
            decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
            # Decode the JSON input to get the reflectance values
            data <- decoder$score(json_path)

            # Step 2: Run multi calibration for improved reflectance
            # ------------------------------------------------------------------
            # Setup multi-calibration tool
            calibrator <- CalibrationReflectanceMultipoint$new()
            # Run multi-calibration with sensor provided factors
            calibReflectance <- calibrator$score(data$reflectance, json_path)

            # Step 3: Calculate Indices table from all available data
            # ------------------------------------------------------------------
            # Pass sensor_info to filter indices based on valid_vi field
            index_table <- calculate_indices_table(data$wavelength, calibReflectance, data$fwhm, data$meta_table, data$sensor_info)
            # ---------------------------------------------------------------------------------------------------------
            # DANGER ZONE: In case we need to write the table to updated expected output
            # ---------------------------------------------------------------------------------------------------------
            # write_indices_csv(index_table, "data/test-calculate-indices-avail_expectedTable.csv", row.names = FALSE)
            # ---------------------------------------------------------------------------------------------------------
            expected_table <- read_indices_csv(testthat::test_path("data/test-calculate-indices-avail_expectedTable.csv"))
            # Check if the table values are as expected
            expect_equal(as.data.frame(index_table), as.data.frame(expected_table))
          })
