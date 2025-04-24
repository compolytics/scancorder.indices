test_that("test CICADA json with single point reflectance and sensor average",
          {
            # What to expect, a list of flattened reflectance vectors
            expectedReflectance = list(
              c(
                0.27145945207973060098,
                0.14883863233347485733,
                0.22945771871391168473,
                0.21311535920599539162,
                0.33350373518300396869,
                0.43729383415162503823,
                0.45909600805682160285,
                0.46451358205843712446,
                0.53620244890137458427,
                0.55389701018604053928,
                0.5006713015862638283,
                0.53368890808155600158
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
            data <- decoder$score(json_input)
            # Check if the reflectance values are numeric
            expect_equal(data$reflectance, expectedReflectance)
          })
