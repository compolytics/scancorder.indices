library(R6)
library(jsonlite)

#' DecodeCompolyticsRegularScanner: Decodes Sensor data from Compolytics Regular ScanCorder
#'
#' An R6 class designed to decode and calibrate raw sensor data from Compolytics scanners.
#' It supports JSON input, various calibration modes (two-point and multipoint), and optional sensor value masking and averaging.
#'
#' @docType class
#' @format \code{\link[R6]{R6Class}} object.
#'
#' @field average_sensor_values Logical. Whether to average sensor readings per LED's across sensor elements.
#' @field channel_mask Matrix. A binary mask indicating which channels are valid. If provided it will overwrite potentially sensor supplied info.
#'
#' @section Methods:
#' \describe{
#'   \item{\code{new(average_sensor_values = FALSE, channel_mask = NULL)}}{Creates a new instance of the decoder.}
#'   \item{\code{nested_key_exists(lst, keys)}}{Check if a nested key exists within a list.}
#'   \item{\code{calculate_calibration(calibration_map)}}{Fit quadratic calibration model across multiple reference measurements.}
#'   \item{\code{two_point_calibration(sensor_values, calibration_map)}}{Apply single-reference (two-point) calibration.}
#'   \item{\code{multi_point_calibration(sensor_values, calibration_map)}}{Apply quadratic multipoint calibration from multiple reference measurements.}
#'   \item{\code{convert_json_to_matrix(json_data, type = as.numeric)}}{Convert nested JSON arrays to a numeric matrix.}
#'   \item{\code{score(transform_input)}}{Main method. Decodes a JSON string with sensor data and returns a reflectance vector.}
#' }
#'
#' @examples
#' \dontrun{
#' decoder <- DecodeCompolyticsRegularScanner$new(average_sensor_values = TRUE)
#' json_input <- '{"values": [[100, 200], [300, 400]], "darkCurrent": [[10, 10], [10, 10]]}'
#' output <- decoder$score(json_input)
#' }
#'
#' @export
#' @importFrom xml2 read_xml
#' @importFrom jsonlite fromJSON
DecodeCompolyticsRegularScanner <- R6Class("DecodeCompolyticsRegularScanner",
  public = list(
    average_sensor_values = FALSE,
    channel_mask = NULL,

    initialize = function(average_sensor_values = FALSE, channel_mask = NULL) {
      self$average_sensor_values <- average_sensor_values
      if (!is.null(channel_mask)) {
        self$channel_mask <- as.matrix(channel_mask)
      }
    },

    # Check if a nested key exists in a list
    nested_key_exists = function(lst, keys) {
      current <- lst
      for (k in keys) {
        if (is.list(current) && !is.null(current[[k]])) {
          current <- current[[k]]
        } else {
          return(FALSE)
        }
      }
      return(TRUE)
    },

    # Calculate calibration coefficients using a quadratic model
    calculate_calibration = function(calibration_map) {
      ref_keys <- names(calibration_map)
      num_ref <- length(ref_keys)
      if (num_ref < 2) {
        stop("At least two calibration points are required")
      }

      # Assume each calibration's sensor values is a matrix of dimension (num_orient x num_feat)
      sensor_matrix <- calibration_map[[ref_keys[1]]]$sensorValues
      num_orient <- nrow(sensor_matrix)
      num_feat <- ncol(sensor_matrix)

      # Build arrays for calibration data: add an extra point for dark current assumed at zero.
      xdata <- array(0, dim = c(num_orient, num_feat, num_ref + 1))
      ydata <- array(0, dim = c(1, num_feat, num_ref + 1))

      for (i in seq_along(ref_keys)) {
        key <- ref_keys[i]
        trueFactor <- calibration_map[[key]]$trueFactor
        # For each calibration point assign the same true factor for each feature
        ydata[1, , i] <- as.numeric(trueFactor)
        # Sensor values for this calibration point
        xdata[ , , i] <- calibration_map[[key]]$sensorValues
      }
      # Append a calibration point corresponding to zero dark current
      ydata[1, , num_ref + 1] <- 0
      xdata[ , , num_ref + 1] <- 0

      # Initialize coefficient array: dimensions (num_orient x num_feat x 3)
      b <- array(0, dim = c(num_orient, num_feat, 3))

      # For each sensor location (each row and feature/column), fit:
      #   y = b0 * x^2 + b1 * x + b2
      for (j in 1:num_orient) {
        for (k in 1:num_feat) {
          x_vec <- xdata[j, k, ]
          y_vec <- ydata[1, k, ]
          fit <- tryCatch(
            lm(y_vec ~ I(x_vec^2) + x_vec),
            error = function(e) stop("Curve fitting failed for sensor ", j, " feature ", k)
          )
          coefs <- coef(fit)
          # lm returns: coefficient for I(x_vec^2) (b0), for x_vec (b1) and intercept (b2)
          b[j, k, 1] <- coefs["I(x_vec^2)"]
          b[j, k, 2] <- coefs["x_vec"]
          b[j, k, 3] <- coefs["(Intercept)"]
        }
      }
      return(b)
    },

    # Two–point calibration: expects exactly one calibration measurement
    two_point_calibration = function(sensor_values, calibration_map) {
      if (length(calibration_map) != 1) {
        stop("Two point calibration requires exactly one calibration measurement")
      }
      key <- names(calibration_map)[1]
      # Average calibration sensor values along the measurement dimension:
      calib_vals <- calibration_map[[key]]$sensorValues
      # Get dimensions from first list entry
      rows <- nrow(calib_vals[[1]])
      cols <- ncol(calib_vals[[1]])
      depth <- length(calib_vals)
      # Generate a stack
      array_3d <- array(unlist(calib_vals), dim = c(rows, cols, depth))
      mean_calibration <- apply(array_3d, c(1, 2), mean)
      # Divide sensor values by calibration values (avoiding division by zero)
      calibrated <- sensor_values / ifelse(mean_calibration == 0, 1, mean_calibration)
      calibrated[is.infinite(calibrated) | is.nan(calibrated)] <- 0
      # Multiply by the true factor
      calibrated <- calibrated * calibration_map[[key]]$trueFactor
      return(calibrated)
    },

    # Multipoint calibration: uses several calibration measurements
    multi_point_calibration = function(sensor_values, calibration_map) {
      # For each calibration entry, average the sensor values if multiple measurements exist.
      for (key in names(calibration_map)) {
        calib_vals <- calibration_map[[key]]$sensorValues
        # Get dimensions from first list entry
        rows <- nrow(calib_vals[[1]])
        cols <- ncol(calib_vals[[1]])
        depth <- length(calib_vals)
        # Generate a stack
        array_3d <- array(unlist(calib_vals), dim = c(rows, cols, depth))
        mean_calibration <- apply(array_3d, c(1, 2), mean)
        # Set mean calibration values
        calibration_map[[key]]$sensorValues <- mean_calibration
      }
      b_parameter <- self$calculate_calibration(calibration_map)
      num_orient <- nrow(sensor_values)
      num_feat <- ncol(sensor_values)
      calibrated <- matrix(0, nrow = num_orient, ncol = num_feat)
      # Apply the quadratic calibration for each sensor location.
      for (j in 1:num_orient) {
        for (k in 1:num_feat) {
          b0 <- b_parameter[j, k, 1]
          b1 <- b_parameter[j, k, 2]
          b2 <- b_parameter[j, k, 3]
          calibrated[j, k] <- b0 * sensor_values[j, k]^2 + b1 * sensor_values[j, k] + b2
        }
      }
      return(calibrated)
    },

    convert_json_to_vector  = function(json_data, type = as.numeric) {
      vec <- unlist(json_data, recursive = TRUE, use.names = FALSE)
      vec <- type(vec)
      return(vec)
    },

    # Convert json data frame to numeric matrix
    convert_json_to_matrix = function(json_data, type = as.numeric) {
      df <- do.call(rbind, json_data)
      matrix_data <- apply(df, c(1, 2), type)
      return(matrix_data)
    },

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

    # The main method: given a JSON string with sensor data, generate a reflectance vector.
    score = function(transform_input) {

      # Parse the JSON input (expects either a single object or a list of objects)
      input_json_struct <- fromJSON(transform_input, simplifyVector = FALSE)

      if (!is.list(input_json_struct)) {
        input_json_struct <- list(input_json_struct)
      }

      transform_global_output <- list()
      for (input_json in input_json_struct) {

        # Check if the input JSON contains the required "values" field.
        if (!("values" %in% names(input_json))) {
          stop("Regular Scanner input json needs to contain a 'values' key containing sensor data")
        }

        # Convert the "values" field to a numeric matrix
        sensor_values <- self$convert_json_to_matrix(input_json$values)

        # Try to find sensor external information from package
        keys_to_check <- c("config", "sensorHead", "name")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          external_sensor_info <- find_sensor_metadata(input_json$config$sensorHead$name)
        } else {
          external_sensor_info = NULL
        }

        # Get nested substructure with sensor information
        keys_to_check <- c("config", "sensorHead", "additionalInfo")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          device_sensor_info <- input_json$config$sensorHead$additionalInfo
        } else {
          stop("Cannot find sensor information in sample file.")
        }

        channel_mask <- get_field_base(device_sensor_info, external_sensor_info, "channel_mask")
        if (is.null(channel_mask)) {
          stop("Cannot find valid channel mask")
        }
        channel_mask <- self$convert_json_to_matrix(channel_mask)
        if (!all(dim(channel_mask) == dim(sensor_values))) {
            stop("Channel mask is not of equal size to values field")
        }
        self$channel_mask <- channel_mask

        led_wavelengths <- get_field_base(device_sensor_info, external_sensor_info, "led_wl_real")
        if (is.null(led_wavelengths)) {
          led_wavelengths <- get_field_base(device_sensor_info, external_sensor_info, "led_wl")
        }
        if (is.null(led_wavelengths)) {
          stop("Cannot load center wavelength")
        }
        led_wavelengths <- self$convert_json_to_vector(led_wavelengths)
        print(led_wavelengths)

        led_fwhm <- get_field_base(device_sensor_info, external_sensor_info, "led_fwhm_real")
        if (is.null(led_fwhm)) {
          led_fwhm <- get_field_base(device_sensor_info, external_sensor_info, "led_fwhm_nom")
        }
        if (is.null(led_fwhm)) {
          warning("No FWHM for LEDs found, assuming 0 so wavelength must match range in index exactly")
          led_fwhm = NULL
        } else {
          led_fwhm <- self$convert_json_to_vector(led_fwhm)
        }
        print(led_fwhm)

        # Subtract dark current if provided.
        if (!is.null(input_json$perLEDDarkCurrent)) {
          dark_current <- self$convert_json_to_matrix(input_json$perLEDDarkCurrent)
          sensor_values <- sensor_values - dark_current
        } else if (!is.null(input_json$darkCurrent)) {
          dark_current <- self$convert_json_to_matrix(input_json$darkCurrent)
          sensor_values <- sensor_values - dark_current
        }

        # Process calibration data if available.
        if (!is.null(input_json$calibration)) {

          # Get calibration data field, ensure it is a list
          calibration_values <- self$ensure_list(input_json$calibration)
          # Init calibration map
          calibration_map <- list()
          for (calibration in calibration_values) {

            # Extract approximate true value of calibration
            true_value <- calibration$trueValuePercentage
            # Get sensor values
            this_calibration_data <- self$convert_json_to_matrix(calibration$sensorValue)

            # Adjust calibration data for dark current if present.
            if (!is.null(calibration$perLEDDarkCurrent)) {

              # if we have a dark current per LED, take that first
              dark_current <- self$convert_json_to_matrix(calibration$perLEDDarkCurrent)
              this_calibration_data <- this_calibration_data - dark_current

            } else if (!is.null(calibration$darkCurrent)) {

              # if we have a dark current per Sensor, take that second
              dark_current <- self$convert_json_to_matrix(calibration$darkCurrent)
              this_calibration_data <- this_calibration_data - dark_current

            } else if (!is.null(input_json$shape)) {

              # for legacy, first sensor reading can be dark current
              if ((input_json$shape[1] + 1) == nrow(this_calibration_data)) {
                dark_current <- as.numeric(this_calibration_data[1, ])
                this_calibration_data <- this_calibration_data[-1, , drop = FALSE] -
                  matrix(dark_current, nrow = nrow(this_calibration_data) - 1, ncol = ncol(this_calibration_data), byrow = TRUE)
              }
            }

            key <- as.character(true_value)

            if (!(key %in% names(calibration_map))) {
              calibration_map[[key]] <- list(sensorValues = list(this_calibration_data),
                                             trueFactor = calibration$trueValueFactor)
            } else {
              # Stack additional calibration measurements if present.
              calibration_map[[key]]$sensorValues[[length(calibration_map[[key]]$sensorValues) + 1]] = this_calibration_data
            }
          }
          # Choose between two–point and multipoint calibration.
          if (length(calibration_map) > 0) {
            if (length(calibration_map) == 1) {
              sensor_values <- self$two_point_calibration(sensor_values, calibration_map)
            } else {
              sensor_values <- self$multi_point_calibration(sensor_values, calibration_map)
            }
          }
        }

        # Optionally average sensor values over LED if requested.
        if (self$average_sensor_values) {
          if (!is.null(self$channel_mask)) {
            sensor_values[self$channel_mask == 0] <- NA
          }
          # Average across columns (i.e. LED wavelengths) for each sensor row.
          sensor_values <- matrix(apply(sensor_values, 1, mean, na.rm = TRUE), ncol = 1)
        }

        # Flatten the sensor matrix in column–major order (as.vector does this by default in R)
        reflectance_vector <- as.vector(sensor_values)
        transform_global_output[[length(transform_global_output) + 1]] <- reflectance_vector
      }

      # Return the list of reflectance vectors (one per input structure), the center wavelengths and FHWM of LEDs
      list(reflectance = transform_global_output, wavelength = led_wavelengths, fwhm=led_fwhm)
    }
  )
)
