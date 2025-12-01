library(jsonlite)
library(R6)

#' ScanCorderHelpers R6 Class
#'
#' A helper class containing static methods for parsing JSON input data, extracting
#' wavelengths, FWHM values, and processing channel masks with splitting support.
#' These methods are shared across decoder, meta, and calibration classes.
#'
#' Channel Mask Splitting:
#' - Value 0: Ignore sensor for this LED
#' - Value 1: Use sensor with LED wavelength (binary behavior)
#' - Value >1: Split sensor reading into separate feature with sensor wavelength
#'
#' @docType class
#' @export
#' @format \code{\link[R6]{R6Class}} object.
#'
ScanCorderHelpers <- R6Class("ScanCorderHelpers",
  public = list(
    #' Initialize the helper class (not needed for static methods)
    initialize = function() {
      # Nothing to initialize for static helper methods
    },

    #' Check if a nested key exists in a list
    #' @param dictionary A list or nested list structure to check
    #' @param keys A vector of keys representing the nested path to check
    #' @return Logical value indicating whether the nested key path exists
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

    #' Get a field value from device or external sensor info with fallback
    #' @param device_info Device sensor info from JSON
    #' @param external_info External sensor info (package metadata)
    #' @param field_name Name of the field to retrieve
    #' @return Field value or NULL if not found
    get_field_base = function(device_info, external_info, field_name) {
      # First try device info
      if (!is.null(device_info) && field_name %in% names(device_info) && !is.null(device_info[[field_name]])) {
        return(device_info[[field_name]])
      }
      # Then try external info
      if (!is.null(external_info) && field_name %in% names(external_info) && !is.null(external_info[[field_name]])) {
        return(external_info[[field_name]])
      }
      return(NULL)
    },

    #' Convert JSON data to numeric vector
    #' @param json_data JSON data structure
    #' @param type Conversion function (default: as.numeric)
    #' @return Numeric vector
    convert_json_to_vector = function(json_data, type = as.numeric) {
      vec <- unlist(json_data, recursive = TRUE, use.names = FALSE)
      vec <- type(vec)
      return(vec)
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

    #' Extract LED wavelengths from JSON input
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @return Numeric vector of LED wavelengths
    extract_led_wavelengths = function(input_json, device_sensor_info, external_sensor_info) {
      led_wavelengths <- self$get_field_base(device_sensor_info, external_sensor_info, "led_wl_real")
      if (is.null(led_wavelengths)) {
        led_wavelengths <- self$get_field_base(device_sensor_info, external_sensor_info, "led_wl")
      }
      if (is.null(led_wavelengths)) {
        return(NULL)
      }
      return(self$convert_json_to_vector(led_wavelengths))
    },

    #' Extract sensor wavelengths from JSON input
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @return Numeric vector of sensor wavelengths
    extract_sensor_wavelengths = function(input_json, device_sensor_info, external_sensor_info) {
      sensor_wavelengths <- self$get_field_base(device_sensor_info, external_sensor_info, "sensor_wl")
      if (is.null(sensor_wavelengths)) {
        return(NULL)
      }
      return(self$convert_json_to_vector(sensor_wavelengths))
    },

    #' Extract LED FWHM values from JSON input
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @return Numeric vector of LED FWHM values or NULL
    extract_led_fwhm = function(input_json, device_sensor_info, external_sensor_info) {
      led_fwhm <- self$get_field_base(device_sensor_info, external_sensor_info, "led_fwhm_real")
      if (is.null(led_fwhm)) {
        led_fwhm <- self$get_field_base(device_sensor_info, external_sensor_info, "led_fwhm_nom")
      }
      if (is.null(led_fwhm)) {
        return(NULL)
      }
      return(self$convert_json_to_vector(led_fwhm))
    },

    #' Extract sensor FWHM values from JSON input
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @return Numeric vector of sensor FWHM values or NULL
    extract_sensor_fwhm = function(input_json, device_sensor_info, external_sensor_info) {
      sensor_fwhm <- self$get_field_base(device_sensor_info, external_sensor_info, "sensor_fwhm_nom")
      if (is.null(sensor_fwhm)) {
        return(NULL)
      }
      return(self$convert_json_to_vector(sensor_fwhm))
    },

    #' Extract and validate channel mask from JSON input
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @param sensor_values Sensor values matrix for dimension checking
    #' @param provided_mask Optional externally provided channel mask
    #' @return Channel mask matrix
    extract_channel_mask = function(input_json, device_sensor_info, external_sensor_info,
                                   sensor_values, provided_mask = NULL) {
      if (!is.null(provided_mask)) {
        channel_mask <- as.matrix(provided_mask)
      } else {
        channel_mask <- self$get_field_base(device_sensor_info, external_sensor_info, "channel_mask")
        if (is.null(channel_mask)) {
          # Create default channel mask for backward compatibility (all sensors active for each LED)
          led_wl <- self$get_field_base(device_sensor_info, external_sensor_info, "led_wl")
          num_leds <- if (!is.null(led_wl)) length(led_wl) else ncol(sensor_values)
          num_sensors <- ncol(sensor_values)
          channel_mask <- matrix(1, nrow = num_leds, ncol = num_sensors)
        } else {
          channel_mask <- self$convert_json_to_matrix(channel_mask)
        }
      }

      if (ncol(channel_mask) != ncol(sensor_values)) {
        stop("Channel mask number of sensors (", ncol(channel_mask),
             ") does not match sensor values number of sensors (", ncol(sensor_values), ")")
      }

      return(channel_mask)
    },

    #' Check if channel mask contains splitting values (values > 1)
    #' @param channel_mask Channel mask matrix
    #' @return Logical indicating if splitting is enabled
    has_splitting = function(channel_mask) {
      return(any(channel_mask > 1))
    },

    #' Extract feature wavelengths considering channel mask splitting
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @param channel_mask Channel mask matrix
    #' @return List with wavelengths and indices for output features
    extract_feature_wavelengths = function(input_json, device_sensor_info, external_sensor_info, channel_mask, average_sensor_values = FALSE) {
      led_wavelengths <- self$extract_led_wavelengths(input_json, device_sensor_info, external_sensor_info)
      sensor_wavelengths <- self$extract_sensor_wavelengths(input_json, device_sensor_info, external_sensor_info)

      if (!average_sensor_values) {
        # Flattened mode - wavelengths are always LED wavelengths for flattened vector
        if (is.null(channel_mask)) {
          # No channel mask: will be handled in process_sensor_values_with_splitting
          # Return placeholder that will be corrected when we have sensor_values matrix
          return(list(
            wavelengths = NULL,  # Will be set in main processing
            led_indices = NULL,
            sensor_indices = NULL,
            mixed_mode = FALSE,
            flattened_mode = TRUE
          ))
        } else {
          # Channel mask exists: LED wavelength for each mask > 0 entry
          flattened_wavelengths <- c()
          for (led_idx in seq_len(nrow(channel_mask))) {
            for (sensor_idx in seq_len(ncol(channel_mask))) {
              if (channel_mask[led_idx, sensor_idx] > 0) {
                flattened_wavelengths <- c(flattened_wavelengths, led_wavelengths[led_idx])
              }
            }
          }
          return(list(
            wavelengths = flattened_wavelengths,
            led_indices = NULL,
            sensor_indices = NULL,
            mixed_mode = FALSE,
            flattened_mode = TRUE
          ))
        }
      }

      if (!self$has_splitting(channel_mask)) {
        # No splitting - return LED wavelengths only
        return(list(
          wavelengths = led_wavelengths,
          led_indices = seq_along(led_wavelengths),
          sensor_indices = NULL,
          mixed_mode = FALSE,
          flattened_mode = FALSE
        ))
      }

      # Splitting mode - combine LED and sensor wavelengths
      if (is.null(sensor_wavelengths)) {
        stop("Channel mask splitting requires sensor wavelengths")
      }

      feature_wavelengths <- c()
      led_indices <- c()
      sensor_indices <- c()

      binary_leds_processed <- c()  # Track which LEDs already have binary features

      for (led_idx in seq_len(nrow(channel_mask))) {
        # Check if this LED has any binary sensors (mask == 1)
        binary_sensors <- which(channel_mask[led_idx, ] == 1)
        if (length(binary_sensors) > 0 && !(led_idx %in% binary_leds_processed)) {
          # Create one binary feature for this LED (averages all binary sensors)
          feature_wavelengths <- c(feature_wavelengths, led_wavelengths[led_idx])
          led_indices <- c(led_indices, led_idx)
          sensor_indices <- c(sensor_indices, NA)
          binary_leds_processed <- c(binary_leds_processed, led_idx)
        }

        # Process splitting sensors (mask > 1) for this LED
        for (sensor_idx in seq_len(ncol(channel_mask))) {
          mask_value <- channel_mask[led_idx, sensor_idx]

          if (mask_value > 1) {
            # Splitting mode - use sensor wavelength
            feature_wavelengths <- c(feature_wavelengths, sensor_wavelengths[sensor_idx])
            led_indices <- c(led_indices, led_idx)
            sensor_indices <- c(sensor_indices, sensor_idx)
          }
          # mask_value == 0: ignore (skip)
          # mask_value == 1: already handled above for the entire LED
        }
      }

      # Sort by wavelength
      sort_order <- order(feature_wavelengths)

      return(list(
        wavelengths = feature_wavelengths[sort_order],
        led_indices = led_indices[sort_order],
        sensor_indices = sensor_indices[sort_order],
        mixed_mode = TRUE,
        flattened_mode = FALSE
      ))
    },

    #' Extract feature FWHM values considering channel mask splitting
    #' @param input_json JSON input structure
    #' @param device_sensor_info Device sensor information
    #' @param external_sensor_info External sensor information
    #' @param channel_mask Channel mask matrix
    #' @param feature_info Feature information from extract_feature_wavelengths
    #' @return Numeric vector of FWHM values corresponding to features
    extract_feature_fwhm = function(input_json, device_sensor_info, external_sensor_info,
                                   channel_mask, feature_info) {
      led_fwhm <- self$extract_led_fwhm(input_json, device_sensor_info, external_sensor_info)
      sensor_fwhm <- self$extract_sensor_fwhm(input_json, device_sensor_info, external_sensor_info)

      if (!feature_info$mixed_mode) {
        # No splitting - return LED FWHM
        return(led_fwhm)
      }

      # Splitting mode - combine LED and sensor FWHM
      feature_fwhm <- c()

      for (i in seq_along(feature_info$led_indices)) {
        led_idx <- feature_info$led_indices[i]
        sensor_idx <- feature_info$sensor_indices[i]

        if (is.na(sensor_idx)) {
          # Binary mode - use LED FWHM
          if (!is.null(led_fwhm)) {
            feature_fwhm <- c(feature_fwhm, led_fwhm[led_idx])
          } else {
            feature_fwhm <- c(feature_fwhm, NA)
          }
        } else {
          # Splitting mode - use sensor FWHM
          if (!is.null(sensor_fwhm)) {
            feature_fwhm <- c(feature_fwhm, sensor_fwhm[sensor_idx])
          } else {
            feature_fwhm <- c(feature_fwhm, NA)
          }
        }
      }

      return(feature_fwhm)
    },

    #' Process sensor values with channel mask (including splitting support)
    #' @param sensor_values LED×sensor matrix (rows=LEDs, cols=sensors)
    #' @param channel_mask Channel mask matrix (rows=LEDs, cols=sensors)
    #' @param feature_info Feature information from extract_feature_wavelengths
    #' @param average_sensor_values Whether to average across sensors per LED for binary channels
    #' @return Processed feature values vector for one sample
    process_sensor_values_with_splitting = function(sensor_values, channel_mask, feature_info, average_sensor_values = FALSE, led_wavelengths = NULL) {

      # Always expect LED × SENSOR matrix format (N_LEDs × N_SENSORS)

      if (!average_sensor_values) {
        # No averaging: return flattened matrix (F-style, column-major order)
        if (is.null(channel_mask)) {
          # No channel mask: return all values flattened
          flattened_values <- as.vector(sensor_values)
          # Create corresponding wavelengths: LED wavelength for each sensor reading
          if (!is.null(led_wavelengths)) {
            flattened_wavelengths <- rep(led_wavelengths, each = ncol(sensor_values))
          } else {
            flattened_wavelengths <- NULL
          }
          return(list(
            values = matrix(flattened_values, nrow = 1),
            wavelengths = flattened_wavelengths
          ))
        } else {
          # Channel mask exists: only include entries where mask > 0
          flattened_values <- c()
          flattened_wavelengths <- c()
          for (led_idx in seq_len(nrow(sensor_values))) {
            for (sensor_idx in seq_len(ncol(sensor_values))) {
              if (channel_mask[led_idx, sensor_idx] > 0) {
                flattened_values <- c(flattened_values, sensor_values[led_idx, sensor_idx])
                if (!is.null(led_wavelengths)) {
                  flattened_wavelengths <- c(flattened_wavelengths, led_wavelengths[led_idx])
                }
              }
            }
          }
          return(list(
            values = matrix(flattened_values, nrow = 1),
            wavelengths = flattened_wavelengths
          ))
        }
      }

      # Averaging mode: process according to channel mask and feature info
      if (is.null(channel_mask)) {
        # No channel mask: average all sensors per LED
        feature_values <- numeric(nrow(sensor_values))
        for (led_idx in seq_len(nrow(sensor_values))) {
          feature_values[led_idx] <- mean(sensor_values[led_idx, ], na.rm = TRUE)
        }
        return(matrix(feature_values, nrow = 1))
      }

      # Channel mask exists: use splitting/binary logic
      n_features <- length(feature_info$led_indices)
      feature_values <- numeric(n_features)

      if (!feature_info$mixed_mode) {
        # Binary-only mode - process each LED according to channel mask
        for (i in seq_along(feature_info$led_indices)) {
          led_idx <- feature_info$led_indices[i]
          # Find active sensors for this LED (where mask > 0)
          active_sensors <- which(channel_mask[led_idx, ] > 0)

          if (length(active_sensors) > 0) {
            if (length(active_sensors) > 1) {
              # Average across active sensors for this LED
              feature_values[i] <- mean(sensor_values[led_idx, active_sensors], na.rm = TRUE)
            } else {
              # Single active sensor
              feature_values[i] <- sensor_values[led_idx, active_sensors[1]]
            }
          }
        }
      } else {
        # Splitting mode - process features according to LED/sensor mapping
        for (i in seq_along(feature_info$led_indices)) {
          led_idx <- feature_info$led_indices[i]
          sensor_idx <- feature_info$sensor_indices[i]

          if (is.na(sensor_idx)) {
            # Binary mode within splitting - use active sensors for this LED
            active_sensors <- which(channel_mask[led_idx, ] == 1)
            if (length(active_sensors) > 0) {
              if (length(active_sensors) > 1) {
                # Average across active sensors for this LED
                feature_values[i] <- mean(sensor_values[led_idx, active_sensors], na.rm = TRUE)
              } else {
                # Single active sensor
                feature_values[i] <- sensor_values[led_idx, active_sensors[1]]
              }
            }
          } else {
            # Splitting mode - use specific sensor value from specific LED
            feature_values[i] <- sensor_values[led_idx, sensor_idx]
          }
        }
      }

      # Return as 1×N matrix (averaging mode uses original feature_info wavelengths)
      return(list(
        values = matrix(feature_values, nrow = 1),
        wavelengths = feature_info$wavelengths
      ))
    },

    #' Extract sensor configuration from JSON input
    #' @param input_json JSON input structure
    #' @return List with device_sensor_info and external_sensor_info
    extract_sensor_configuration = function(input_json) {
      # Try to find sensor external information from package
      external_sensor_info <- NULL
      keys_to_check <- c("config", "sensorHead", "name")
      if (self$nested_key_exists(input_json, keys_to_check)) {
        external_sensor_info <- find_sensor_metadata(input_json$config$sensorHead$name)
      }

      # Get nested substructure with sensor information
      keys_to_check <- c("config", "sensorHead", "additionalInfo")
      if (self$nested_key_exists(input_json, keys_to_check)) {
        device_sensor_info <- input_json$config$sensorHead$additionalInfo
      } else {
        stop("Cannot find sensor information in sample file.")
      }

      return(list(
        device_sensor_info = device_sensor_info,
        external_sensor_info = external_sensor_info
      ))
    },

    #' Ensure input is a list, wrapping if necessary
    #' @param x Input object to ensure is a list
    #' @return A list, either the original if already a list, or wrapped in a list
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

    #' Sanitize field names by replacing problematic characters
    #' @param field_name Field name to sanitize
    #' @return Sanitized field name
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

    #' Filter info fields to keep only numeric or single string values
    #' @param info Info object to filter
    #' @return Filtered info object with sanitized field names
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

    #' Flatten JSON input, extracting 'data' field if it exists
    #' @param input_json A list structure from parsed JSON
    #' @return A flattened list with data fields extracted
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
    }
  )
)
