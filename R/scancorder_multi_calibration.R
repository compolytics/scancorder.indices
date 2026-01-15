library(R6)
library(jsonlite)

#' CalibrationReflectanceMultipoint R6 Class
#'
#' Performs multi-point reflectance calibration based on a 3D array of
#' calibration factors, typically loaded from JSON data from CICADA sensor
#' reading.
#'
#' @docType class
#' @export
#' @name CalibrationReflectanceMultipoint
#' @field calibration_factors A 3D array containing calibration factors, initialized to NULL.
#'
CalibrationReflectanceMultipoint <- R6Class("CalibrationReflectanceMultipoint",

  public = list(

    # Calibration factors as a 3D array, initialized to NULL.
    calibration_factors = NULL,
    helpers = NULL,

    #' Initialize the CalibrationReflectanceMultipoint object
    #' @param calibration_factors A 3D array of calibration factors. If provided, it will be stored as an array.
    initialize = function(calibration_factors = NULL) {

      # If calibration_factors is provided, store it as an array.
      if (!is.null(calibration_factors)) {
        # Ensure calibration_factors is numeric and preserve its dimensions.
        self$calibration_factors <- as.array(calibration_factors)
      }
      # Initialize the helpers instance
      self$helpers <- ScanCorderHelpers$new()
    },

    #' Helper function to slice the last dimension of a 3D array
    #' @param x A 3D array to slice
    #' @param k The index for the last dimension to slice
    #' @return A 2D matrix with the last dimension sliced
    slice_keep_first = function(x, k) {
      # 1) slice, keeping even singleton dims
      y <- x[,, k, drop = FALSE]
      # 2) drop *only* the last dimension
      d <- dim(y)
      dim(y) <- d[-length(d)]
      y
    },

    #' Applies the multi-point calibration to sensor reading
    #' @param sensor_values A numeric matrix containing sensor values to calibrate
    #' @return A calibrated numeric matrix
    multi_point_calibration = function(sensor_values) {

      if (is.null(self$calibration_factors)) {
        stop("Calibration factors are not defined.")
      }
      # sensor_values is assumed to be a numeric matrix.
      # calibration_factors should be a 3D array with dimensions (nrow, ncol, 3)
      dims_sensor <- dim(sensor_values)
      dims_cal <- dim(self$calibration_factors)

      # Ensure the calibration factors are of the correct size.
      if (length(dims_cal) != 3 || dims_sensor[2] != dims_cal[2] || dims_cal[3] != 3) {
        stop("Calibration data not of correct size for this sensor.")
      }
      # Apply the quadratic calibration:
      # calibrated = b0 * sensor^2 + b1 * sensor + b2
      b0 <- self$slice_keep_first(self$calibration_factors,1)
      b1 <- self$slice_keep_first(self$calibration_factors,2)
      b2 <- self$slice_keep_first(self$calibration_factors,3)

      b0 <- b0[ rep(1L, dims_sensor[1]), , drop = FALSE ]
      b1 <- b1[ rep(1L, dims_sensor[1]), , drop = FALSE ]
      b2 <- b2[ rep(1L, dims_sensor[1]), , drop = FALSE ]

      calibrated <- b0 * sensor_values^2 + b1 * sensor_values + b2
      return(calibrated)
    },

    #' Check if a nested key exists in a list
    #' @param dictionary A list or nested list structure to check
    #' @param keys A vector of keys representing the nested path to check
    #' @return Logical value indicating whether the nested key path exists
    nested_key_exists = function(dictionary, keys) {
      current <- dictionary
      for (key in keys) {
        if (is.list(current) && !is.null(current[[key]])) {
          current <- current[[key]]
        } else {
          return(FALSE)
        }
      }
      return(TRUE)
    },

    #' Convert JSON data frame to numeric matrix
    #' @param json_data A list or data frame structure from JSON
    #' @param type Function to convert data type (default: as.numeric)
    #' @return A numeric matrix
    convert_json_to_matrix = function(json_data, type = as.numeric) {
      df <- do.call(rbind, json_data)
      matrix_data <- apply(df, c(1, 2), type)
      return(matrix_data)
    },

    #' Convert JSON data frame to 3D array
    #' @param json_data A list structure from JSON to convert to 3D array
    #' @param type Function to convert data type (default: as.numeric)
    #' @return A 3D numeric array
    convert_json_to_3d_array = function(json_data, type = as.numeric) {
      matrix_list <- lapply(json_data, function(mat) {
        mat_df <- do.call(rbind, lapply(mat, unlist))  # ensures 2D shape
        mat_clean <- apply(mat_df, c(1, 2), type)
        return(mat_clean)
      })

      # Check that all matrices are the same size
      dims_list <- lapply(matrix_list, dim)
      if (!all(vapply(dims_list, function(d) all(d == dims_list[[1]]), logical(1)))) {
        stop("Not all matrices have the same dimensions")
      }

      dims <- dims_list[[1]]
      depth <- length(matrix_list)

      array_data <- array(unlist(matrix_list), dim = c(depth, dims[1], dims[2]))
      return(array_data)
    },


    #' Perform multi-point calibration on reflectance data
    #' @param reflectance A list or matrix of reflectance data
    #' @param json_input A JSON string containing sensor configuration and calibration data
    #' @param multi_calibration Optional multi-point calibration data. If provided, overrides calibration from json_input. Default is NULL.
    #' @return A list of calibrated reflectance values
    score = function(reflectance, json_input, multi_calibration = NULL) {

      # First input: reflectance data (as matrix).
      reflectance_input <- do.call(rbind, reflectance)

      # If multi_calibration is not provided, extract it from json_input
      if (is.null(multi_calibration)) {
        # Second input: sensor reading configuration as a JSON string.
        config_json <- json_input
        input_json_struct <- jsonlite::fromJSON(config_json, simplifyVector = FALSE)

        # If the JSON is a single object, wrap it into a list.
        input_json_struct <- self$helpers$ensure_list(input_json_struct)

        # Flatten the input JSON if it contains a 'data' field
        input_json_struct <- self$helpers$flatten_sample_json(input_json_struct)

        # Extract sensor configuration using helper function
        sensor_config <- self$helpers$extract_sensor_configuration(input_json_struct[[1]])
        device_sensor_info <- sensor_config$device_sensor_info
        external_sensor_info <- sensor_config$external_sensor_info

        multi_calibration <- self$helpers$get_field_base(device_sensor_info, external_sensor_info, "multi_calibration")
        if (is.null(multi_calibration)) {
          stop("Calibration factors are not defined.")
        }
        # Extract the calibration factors from the JSON structure.
        calibration_factors <- self$convert_json_to_3d_array(multi_calibration)
      } else {
        calibration_factors <- multi_calibration
      }

      # Get the dimensions of the reflectance input and calibration factors.
      dims_sensor <- dim(reflectance_input)
      dims_cal <- dim(calibration_factors)
      # Ensure the calibration factors are of the correct size.
      if (length(dims_cal) != 3 || dims_sensor[2] != dims_cal[2] || dims_cal[3] != 3) {
        stop(sprintf("Calibration data not of correct size for this sensor. Sensor bands: %d, Expected calibration: (depth, %d, 3), Got: (%s)",
                     dims_sensor[2], dims_sensor[2], paste(dims_cal, collapse = ", ")))
      }
      self$calibration_factors <- calibration_factors
      # Run the calibration.
      transform_output <- self$multi_point_calibration(reflectance_input)
      # We convert back to a list of samples (row vectors)
      transform_output <- lapply(seq_len(nrow(transform_output)), function(i) as.numeric(transform_output[i, ]))
      return(transform_output)
    }
  )
)
