library(R6)
library(jsonlite)

#' DecodeCompolyticsRegularScanner: Decodes Sensor data from Compolytics Regular ScanCorder
#'
#' An R6 class designed to decode and calibrate raw sensor data from Compolytics scanners.
#' It supports JSON input, various calibration modes (two-point and multipoint), and optional sensor value masking and averaging.
#'
#' @docType class
#' @export
#' @format \code{\link[R6]{R6Class}} object.
#'
DecodeCompolyticsRegularScanner <- R6Class("DecodeCompolyticsRegularScanner",
  public = list(
    average_sensor_values = FALSE,
    channel_mask = NULL,
    helpers = NULL,

    #' Create a new instance of the decoder.
    #'
    #' This method initializes the decoder with optional parameters for averaging sensor values and a channel mask.
    #' @param average_sensor_values Logical. Whether to average sensor readings per LED's across sensor elements.
    #' @param channel_mask Matrix. A binary mask indicating which channels are valid. If provided it will overwrite potentially sensor supplied info.
    #' @return A new instance of DecodeCompolyticsRegularScanner.
    initialize = function(average_sensor_values = FALSE, channel_mask = NULL) {
      self$average_sensor_values <- average_sensor_values
      if (!is.null(channel_mask)) {
        self$channel_mask <- as.matrix(channel_mask)
      }
      # Initialize the helpers instance
      self$helpers <- ScanCorderHelpers$new()
    },

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
      calibrated <- sensor_values / mean_calibration
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

    # Ensure the input is a list, wrapping it if necessary
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

    # Sanitize field names by replacing problematic characters
    sanitize_field_name = function(field_name) {
      # First trim leading and trailing whitespace
      sanitized <- trimws(field_name)
      # Replace hyphens with underscores and remove other problematic characters
      sanitized <- gsub("-", "_", sanitized)
      # Replace dots with underscores (R converts dots to column names)
      sanitized <- gsub("\\.", "_", sanitized)
      # Remove any other special characters except letters, numbers, and underscores
      sanitized <- gsub("[^A-Za-z0-9_]", "_", sanitized)
      # Ensure it doesn't start with a number
      if (grepl("^[0-9]", sanitized)) {
        sanitized <- paste0("X", sanitized)
      }
      return(sanitized)
    },

    # Filter info fields to keep only numeric or single string values
    filter_info_fields = function(info) {
      if (is.null(info) || !is.list(info)) {
        return(info)
      }

      # Create a new info list with only valid fields
      filtered_info <- list()
      for (field_name in names(info)) {
        field_value <- info[[field_name]]
        # Check if field is numeric (including vectors of numbers)
        if (is.numeric(field_value)) {
          # Sanitize the field name and add to filtered info
          sanitized_name <- self$sanitize_field_name(field_name)
          filtered_info[[sanitized_name]] <- field_value
        } else if (is.character(field_value) && length(field_value) == 1) {
          # Check if field is a single character string (length 1)
          # Sanitize the field name and add to filtered info
          sanitized_name <- self$sanitize_field_name(field_name)
          filtered_info[[sanitized_name]] <- field_value
        }
        # Skip all other types (lists, multi-element vectors, etc.)
      }
      return(filtered_info)
    },

    # Flatten a JSON structure containing multiple sample data,
    # extracting metadata if available
    flatten_sample_json = function(input_json) {
      flat_list <- list()
      for (entry in input_json) {
        if ("data" %in% names(entry)) {
          # Extract metadata if available
          info <- tryCatch(entry$store$meta$meta$info, error = function(e) NULL)
          # Filter info to keep only numeric or single string fields
          info <- self$filter_info_fields(info)
          filename <- tryCatch(entry$filename, error = function(e) NULL)
          # Loop over each data element
          for (d in entry$data) {
            # Add metadata into the data entry
            combined <- c(d, list(info = info, filename = filename))
            # Add entry to flat list
            flat_list <- c(flat_list, list(combined))
          }
        } else {
          # Otherwise, append the entry itself
          flat_list <- c(flat_list, list(entry))
        }
      }
      return(flat_list)
    },

    # Add a new row to a data frame using key-value pairs
    add_row_by_kv = function(df, kv_list) {

      all_cols <- union(names(df), names(kv_list))

      # Ensure missing columns in df are added with the right number of NAs
      for (col in setdiff(all_cols, names(df))) {
        df[[col]] <- rep(NA, nrow(df))
      }

      # Ensure missing columns in kv_list are filled with NA
      for (col in setdiff(all_cols, names(kv_list))) {
        kv_list[[col]] <- NA
      }

      # Create new row and bind
      new_row <- as.data.frame(kv_list, stringsAsFactors = FALSE)
      df <- rbind(df[all_cols], new_row[all_cols])
      rownames(df) <- NULL
      return(df)
    },

    # Trim white space from names in a list
    trim_list_names = function(x) {
      if (is.list(x)) {
        names(x) <- trimws(names(x))
        x <- lapply(x, self$trim_list_names)
      }
      return(x)
    },

    # The main method: given a JSON string with sensor data, generate a reflectance vector.
    score = function(transform_input) {

      # Parse the JSON input (expects either a single object or a list of objects)
      input_json_struct <- jsonlite::fromJSON(transform_input, simplifyVector = FALSE)
      # Ensure we do have a list
      input_json_struct <- self$ensure_list(input_json_struct)
      # Flatten the input JSON if it contains a 'data' field
      input_json_struct <- self$flatten_sample_json(input_json_struct)

      transform_global_output <- list()
      sample_meta_table <- data.frame()
      for (input_json in input_json_struct) {

        # Check if the input JSON contains the required "values" field.
        if (!("values" %in% names(input_json))) {
          stop("Regular Scanner input json needs to contain a 'values' key containing sensor data")
        }

        # Extract metadata if available
        kv_list <- list()
        keys_to_check <- c("uuid")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          kv_list$uuid <- input_json$uuid
        }

        keys_to_check <- c("filename")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          kv_list$filename <- input_json$filename
        }

        keys_to_check <- c("info")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          # Trim away any white spaces from names
          info <- self$trim_list_names(input_json$info)
          kv_list <- c(kv_list, info)
        }

        # Add key-value pairs to the metadata data frame
        sample_meta_table <- self$add_row_by_kv(sample_meta_table, kv_list)

        # Convert the "values" field to a numeric matrix
        sensor_values <- self$convert_json_to_matrix(input_json$values)

        # Extract sensor configuration using helper function
        sensor_config <- self$helpers$extract_sensor_configuration(input_json)
        device_sensor_info <- sensor_config$device_sensor_info
        external_sensor_info <- sensor_config$external_sensor_info

        # Extract and validate channel mask using helper function
        self$channel_mask <- self$helpers$extract_channel_mask(input_json, device_sensor_info, external_sensor_info, 
                                                               sensor_values, self$channel_mask)

        # Extract LED wavelengths for flattened mode
        led_wavelengths <- self$helpers$extract_led_wavelengths(input_json, device_sensor_info, external_sensor_info)
        
        # Extract feature wavelengths and FWHM considering splitting
        feature_info <- self$helpers$extract_feature_wavelengths(input_json, device_sensor_info, external_sensor_info, self$channel_mask, self$average_sensor_values)
        feature_wavelengths <- feature_info$wavelengths
        feature_fwhm <- self$helpers$extract_feature_fwhm(input_json, device_sensor_info, external_sensor_info, 
                                                         self$channel_mask, feature_info)

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

        # Process sensor values with splitting support
        processing_result <- self$helpers$process_sensor_values_with_splitting(
          sensor_values, self$channel_mask, feature_info, self$average_sensor_values, led_wavelengths
        )
        
        # Update wavelengths if we got them from flattened processing
        if (!is.null(processing_result$wavelengths)) {
          feature_wavelengths <- processing_result$wavelengths
          # Also need to update FWHM for flattened case - use LED FWHM
          led_fwhm <- self$helpers$extract_led_fwhm(input_json, device_sensor_info, external_sensor_info)
          if (!is.null(led_fwhm) && !self$average_sensor_values) {
            if (is.null(self$channel_mask)) {
              # No channel mask: repeat LED FWHM for each sensor
              feature_fwhm <- rep(led_fwhm, each = ncol(sensor_values))
            } else {
              # Channel mask exists: LED FWHM for each mask > 0 entry  
              flattened_fwhm <- c()
              for (led_idx in seq_len(nrow(self$channel_mask))) {
                for (sensor_idx in seq_len(ncol(self$channel_mask))) {
                  if (self$channel_mask[led_idx, sensor_idx] > 0) {
                    flattened_fwhm <- c(flattened_fwhm, led_fwhm[led_idx])
                  }
                }
              }
              feature_fwhm <- flattened_fwhm
            }
          }
        }
        
        # Extract reflectance values
        reflectance_values <- processing_result$values
        
        # Handle the result - could be a single matrix or list of matrices
        if (is.list(reflectance_values) && !is.data.frame(reflectance_values)) {
          # Multiple samples - add each one separately (convert matrices to vectors)
          for (sample_matrix in reflectance_values) {
            transform_global_output[[length(transform_global_output) + 1]] <- as.vector(sample_matrix)
          }
        } else {
          # Single sample - add it directly (convert matrix to vector)
          transform_global_output[[length(transform_global_output) + 1]] <- as.vector(reflectance_values)
        }
      }

      # Return the list of reflectance vectors, feature wavelengths, and FWHM
      list(meta_table = sample_meta_table, reflectance = transform_global_output, 
           wavelength = feature_wavelengths, fwhm = feature_fwhm)
    }
  )
)
