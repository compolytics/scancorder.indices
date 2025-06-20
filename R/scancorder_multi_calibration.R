library(R6)
library(jsonlite)

#' CalibrationReflectanceMultipoint R6 Class
#'
#' Performs multi-point reflectance calibration based on a 3D array of
#' calibration factors, typically loaded from JSON data from CICADA sensor
#' reading.
#'
#' @export
#' @docType class
#' @name CalibrationReflectanceMultipoint
#' @section Methods:
#' \describe{
#'   \item{\code{initialize(calibration_factors = NULL)}}{
#'     Initialize the object with optional calibration factors (3D array).
#'   }
#'   \item{\code{multi_point_calibration(sensor_values)}}{
#'     Apply the calibration formula using quadratic coefficients.
#'   }
#'   \item{\code{slice_keep_first(x, k)}}{
#'     Helper function to extract the k-th slice from a 3D array while preserving dimensions.
#'   }
#'   \item{\code{nested_key_exists(dictionary, keys)}}{
#'     Check whether a nested sequence of keys exists in a list.
#'   }
#'   \item{\code{convert_json_to_matrix(json_data, type = as.numeric)}}{
#'     Convert a nested JSON list to a numeric matrix.
#'   }
#'   \item{\code{convert_json_to_3d_array(json_data, type = as.numeric)}}{
#'     Convert nested JSON structures to a 3D numeric array.
#'   }
#'   \item{\code{ensure_list(x)}}{
#'     Ensure the input is an unnamed list (wraps if necessary).
#'   }
#'   \item{\code{flatten_sample_json(input_json)}}{
#'     Flatten JSON input by extracting "data" fields if present.
#'   }
#'   \item{\code{score(reflectance, json_input)}}{
#'     Perform full calibration pipeline:
#'     flatten JSON input, extract calibration, apply multi-point transformation,
#'     and return the calibrated reflectance as a list.
#'   }
#' }
#'
#' @importFrom jsonlite fromJSON
#' @importFrom R6 R6Class
CalibrationReflectanceMultipoint <- R6Class("CalibrationReflectanceMultipoint",

  public = list(

    calibration_factors = NULL,

    # Initialize the CalibrationReflectanceMultipoint object.
    initialize = function(calibration_factors = NULL) {

      # If calibration_factors is provided, store it as an array.
      if (!is.null(calibration_factors)) {
        # Ensure calibration_factors is numeric and preserve its dimensions.
        self$calibration_factors <- as.array(calibration_factors)
      }
    },

    # Helper function to slice the last dimension of a 3D array
    slice_keep_first = function(x, k) {
      # 1) slice, keeping even singleton dims
      y <- x[,, k, drop = FALSE]
      # 2) drop *only* the last dimension
      d <- dim(y)
      dim(y) <- d[-length(d)]
      y
    },

    # Applies the multi-point calibration to sensor reading
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

    # Helper: Check if a nested key exists in a list.
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

    # Convert json data frame to numeric matrix
    convert_json_to_matrix = function(json_data, type = as.numeric) {
      df <- do.call(rbind, json_data)
      matrix_data <- apply(df, c(1, 2), type)
      return(matrix_data)
    },

    # Convert json data frame to 3D array
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

    # Ensure input is a list, wrapping if necessary
    ensure_list = function(x) {
      # if it's not a list, or it's a named list (i.e. a JSON object),
      # then wrap it in a one-element list
      if (!is.list(x) || !is.null(names(x))) {
        list(x)
      } else {
        # otherwise it's an unnamed list (JSON array), leave as is
        x
      }
    },

    # Flatten JSON input, extracting 'data' field if it exists
    flatten_sample_json = function(input_json) {
      flat_list <- list()
      for (entry in input_json) {
        if ("data" %in% names(entry)) {
          # If 'data' field exists, append all entries inside 'data'
          flat_list <- c(flat_list, entry$data)
        } else {
          # Otherwise, append the entry itself
          flat_list <- c(flat_list, list(entry))
        }
      }
      return(flat_list)
    },

    # Perform multi-point calibration on reflectance data.
    score = function(reflectance, json_input) {

      # First input: reflectance data (as matrix).
      reflectance_input <- do.call(rbind, reflectance)

      # Second input: sensor reading configuration as a JSON string.
      config_json <- json_input
      input_json_struct <- fromJSON(config_json, simplifyVector = FALSE)

      # If the JSON is a single object, wrap it into a list.
      input_json_struct <- self$ensure_list(input_json_struct)

      # Flatten the input JSON if it contains a 'data' field
      input_json_struct <- self$flatten_sample_json(input_json_struct)

      # Get nested substructure with sensor information
      keys_to_check <- c("config", "sensorHead", "additionalInfo")
      if (self$nested_key_exists(input_json_struct[[1]], keys_to_check)) {
        device_sensor_info <- input_json_struct[[1]]$config$sensorHead$additionalInfo
      } else {
        stop("Cannot find sensor information in sample file.")
      }

      # Try to find sensor external information from package
      keys_to_check <- c("config", "sensorHead", "name")
      if (self$nested_key_exists(input_json_struct[[1]], keys_to_check)) {
        external_sensor_info <- find_sensor_metadata(input_json_struct[[1]]$config$sensorHead$name)
      } else {
        external_sensor_info = NULL
      }

      multi_calibration <- get_field_base(device_sensor_info, external_sensor_info, "multi_calibration")
      if (is.null(multi_calibration)) {
        stop("Calibration factors are not defined.")
      }

      # Extract the calibration factors from the JSON structure.
      calibration_factors <- self$convert_json_to_3d_array(multi_calibration)
      # Get the dimensions of the reflectance input and calibration factors.
      dims_sensor <- dim(reflectance_input)
      dims_cal <- dim(calibration_factors)
      # Ensure the calibration factors are of the correct size.
      if (length(dims_cal) != 3 || dims_sensor[2] != dims_cal[2] || dims_cal[3] != 3) {
        stop("Calibration data not of correct size for this sensor.")
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
