library(R6)
library(jsonlite)

TransformIODecodeCompolyticsRegularScanner <- R6Class("TransformIODecodeCompolyticsRegularScanner",
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
      
      # Assume each calibration's sensorValues is a matrix of dimension (num_orient x num_feat)
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
      calib_vals <- colMeans(calibration_map[[key]]$sensorValues)
      # Divide sensor values by calibration values (avoiding division by zero)
      calibrated <- sensor_values / ifelse(calib_vals == 0, 1, calib_vals)
      calibrated[is.infinite(calibrated) | is.nan(calibrated)] <- 0
      # Multiply by the true factor
      calibrated <- calibrated * calibration_map[[key]]$trueFactor
      return(calibrated)
    },
    
    # Multipoint calibration: uses several calibration measurements
    multi_point_calibration = function(sensor_values, calibration_map) {
      # For each calibration entry, average the sensorValues if multiple measurements exist.
      for (key in names(calibration_map)) {
        mat <- calibration_map[[key]]$sensorValues
        if (nrow(mat) > 1) {
          calibration_map[[key]]$sensorValues <- matrix(colMeans(mat), nrow = nrow(mat), ncol = ncol(mat), byrow = TRUE)
          # Alternatively, if you want a single averaged row, use:
          # calibration_map[[key]]$sensorValues <- matrix(colMeans(mat), nrow = 1)
        }
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
    
    # The main method: given a JSON string with sensor data, generate a reflectance vector.
    score = function(transform_input) {
      # Parse the JSON input (expects either a single object or a list of objects)
      input_json_struct <- fromJSON(transform_input, simplifyVector = FALSE)
      if (!("values" %in% names(input_json_struct))) {
        # Wrap single sensor reading into a list if necessary
        input_json_struct <- list(input_json_struct)
      }
      
      transform_global_output <- list()
      
      for (input_json in input_json_struct) {
        if (!is.list(input_json)) {
          stop("Regular Scanner input json needs to be a dictionary")
        }
        if (is.null(input_json$values)) {
          stop("Regular Scanner input json needs to contain a 'values' key containing sensor data")
        }
        
        # Convert the "values" field to a numeric matrix.
        sensor_values <- as.matrix(as.data.frame(input_json$values))
        sensor_values <- apply(sensor_values, 2, as.numeric)
        
        # If a channel mask is provided in the nested sensor config, use it.
        keys_to_check <- c("config", "sensorHead", "additionalInfo", "channel_mask")
        if (self$nested_key_exists(input_json, keys_to_check)) {
          channel_mask <- as.matrix(as.data.frame(input_json$config$sensorHead$additionalInfo$channel_mask))
          if (!all(dim(channel_mask) == dim(sensor_values))) {
            stop("Channel mask is not of equal size to values field")
          }
          self$channel_mask <- channel_mask
        }
        
        # Subtract dark current if provided.
        if (!is.null(input_json$perLEDDarkCurrent)) {
          dark_current <- as.matrix(as.data.frame(input_json$perLEDDarkCurrent))
          sensor_values <- sensor_values - dark_current
        } else if (!is.null(input_json$darkCurrent)) {
          dark_current <- as.matrix(as.data.frame(input_json$darkCurrent))
          sensor_values <- sensor_values - dark_current
        }
        
        # Process calibration data if available.
        if (!is.null(input_json$calibration)) {
          calibration_values <- input_json$calibration
          calibration_map <- list()
          for (calibration in calibration_values) {
            true_value <- calibration$trueValuePercentage
            this_calibration_data <- as.matrix(as.data.frame(calibration$sensorValue))
            
            # Adjust calibration data for dark current if present.
            if (!is.null(calibration$perLEDDarkCurrent)) {
              dark_current <- as.matrix(as.data.frame(calibration$perLEDDarkCurrent))
              this_calibration_data <- this_calibration_data - dark_current
            } else if (!is.null(calibration$darkCurrent)) {
              dark_current <- as.matrix(as.data.frame(calibration$darkCurrent))
              this_calibration_data <- this_calibration_data - dark_current
            } else if (!is.null(input_json$shape)) {
              if ((input_json$shape[1] + 1) == nrow(this_calibration_data)) {
                dark_current <- as.numeric(this_calibration_data[1, ])
                this_calibration_data <- this_calibration_data[-1, , drop = FALSE] - 
                  matrix(dark_current, nrow = nrow(this_calibration_data) - 1, ncol = ncol(this_calibration_data), byrow = TRUE)
              }
            }
            calibration$sensorValue <- this_calibration_data
            key <- as.character(true_value)
            if (!(key %in% names(calibration_map))) {
              calibration_map[[key]] <- list(sensorValues = this_calibration_data,
                                             trueFactor = calibration$trueValueFactor)
            } else {
              # Stack additional calibration measurements if present.
              existing <- calibration_map[[key]]$sensorValues
              calibration_map[[key]]$sensorValues <- rbind(existing, this_calibration_data)
              calibration_map[[key]]$trueFactor <- calibration$trueValueFactor
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
        
        # Optionally average sensor values over LEDs if requested.
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
      
      # Return the list of reflectance vectors (one per input structure)
      return(transform_global_output)
    }
  )
)
