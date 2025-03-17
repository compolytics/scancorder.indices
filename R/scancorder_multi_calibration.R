library(R6)
library(jsonlite)

TransformIOCalibrationReflectanceMultipoint <- R6Class("TransformIOCalibrationReflectanceMultipoint",
  public = list(
    calibration_factors = NULL,
    sample_order = NULL,
    
    initialize = function(calibration_factors = NULL, sample_order = "SCORE_ND_ARRAY_TYPE_BC") {
      # If calibration_factors is provided, store it as an array.
      if (!is.null(calibration_factors)) {
        # Ensure calibration_factors is numeric and preserve its dimensions.
        self$calibration_factors <- as.array(calibration_factors)
      }
      self$sample_order <- sample_order
    },
    
    # Stub for get_onnx_model to mirror Python functionality.
    get_onnx_model = function(inputs, uuid) {
      # In R, you might not generate an ONNX node.
      # This stub simply returns a list with calibration factor information.
      list(
        inputs = inputs,
        uuid = uuid,
        calibration_factors = if (!is.null(self$calibration_factors)) as.vector(self$calibration_factors) else NULL,
        calibration_factors_shape = if (!is.null(self$calibration_factors)) dim(self$calibration_factors) else NULL
      )
    },
    
    # Applies the multipoint calibration to sensor reflectance.
    multi_point_calibration = function(sensor_values) {
      if (is.null(self$calibration_factors)) {
        stop("Calibration factors are not defined.")
      }
      # sensor_values is assumed to be a numeric matrix.
      # calibration_factors should be a 3D array with dimensions (nrow, ncol, 3)
      dims_sensor <- dim(sensor_values)
      dims_cal <- dim(self$calibration_factors)
      
      if (length(dims_cal) != 3 || !all(dims_sensor == dims_cal[1:2]) || dims_cal[3] != 3) {
        stop("Calibration data not of correct size for this sensor.")
      }
      
      # Apply the quadratic calibration:
      # calibrated = b0 * sensor^2 + b1 * sensor + b2
      b0 <- self$calibration_factors[ , , 1]
      b1 <- self$calibration_factors[ , , 2]
      b2 <- self$calibration_factors[ , , 3]
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
    
    # Stub for convert_to_bc. In the Python code this comes from the base class.
    # Here we simply return the reflectance input unchanged.
    convert_to_bc = function(reflectance_input, sample_order) {
      # Implement any necessary reordering based on sample_order.
      return(reflectance_input)
    },
    
    # The score method expects two inputs:
    #   1. A reflectance input (matrix or array)
    #   2. A JSON string representing the sensor configuration.
    score = function(...) {
      args <- list(...)
      if (length(args) == 1) {
        args <- args[[1]]
      }
      if (length(args) != 2) {
        stop("Scanner selector scoring needs to contain two inputs (scoring vector, configuration).")
      }
      
      # First input: reflectance data (numeric matrix).
      reflectance_input <- args[[1]]
      
      # Second input: sensor reading configuration as a JSON string.
      config_json <- args[[2]]
      input_json_struct <- fromJSON(config_json, simplifyVector = FALSE)
      
      # If the JSON is a single object, wrap it into a list.
      if (is.null(names(input_json_struct)) || !is.null(input_json_struct$values)) {
        input_json_struct <- list(input_json_struct)
      }
      
      # Check for calibration factors within the JSON.
      keys_to_check <- c("config", "sensorHead", "additionalInfo", "multi_calibration")
      if (self$nested_key_exists(input_json_struct[[1]], keys_to_check)) {
        # Extract the calibration factors from the JSON structure.
        calibration_factors <- input_json_struct[[1]]$config$sensorHead$additionalInfo$multi_calibration
        # Convert to a 3D array using simplify2array (assuming the nested list structure is regular).
        calibration_factors_arr <- simplify2array(calibration_factors)
        dims_sensor <- dim(reflectance_input)
        dims_cal <- dim(calibration_factors_arr)
        if (length(dims_cal) != 3 || !all(dims_sensor == dims_cal[1:2]) || dims_cal[3] != 3) {
          stop("Calibration data not of correct size for this sensor.")
        }
        self$calibration_factors <- calibration_factors_arr
      }
      
      # Ensure calibration factors are now defined.
      if (is.null(self$calibration_factors)) {
        stop("Calibration factors are not defined.")
      }
      
      # Ensure the reflectance input is in the proper order (using convert_to_bc).
      reflectance_input <- self$convert_to_bc(reflectance_input, self$sample_order)
      
      # Run the calibration.
      transform_output <- self$multi_point_calibration(reflectance_input)
      return(transform_output)
    }
  )
)
