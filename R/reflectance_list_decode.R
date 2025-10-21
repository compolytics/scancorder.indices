library(R6)

#' DecodeReflectanceList: Decodes Reflectance data from CSV files
#'
#' An R6 class designed to load reflectance data from CSV files where each row
#' represents a separate sample. The CSV should have wavelengths as column headers
#' (after metadata columns) and reflectance values in the data rows.
#'
#' If the sensor metadata is found in the package, wavelengths and FWHM values are
#' loaded from the sensor configuration. If the sensor is not found, the class will
#' use wavelengths from the CSV column headers and assume a FWHM of 1nm for each wavelength.
#'
#' @docType class
#' @export
#' @format \code{\link[R6]{R6Class}} object.
#' @field sensor_name Character. The sensor name/serial to look up wavelength and FWHM information.
#' @field delimiter Character. The delimiter used in the CSV file (default: ";").
#'
DecodeReflectanceList <- R6Class("DecodeReflectanceList",
  public = list(
    sensor_name = NULL,
    delimiter = ";",

    #' Create a new instance of the reflectance list decoder.
    #'
    #' This method initializes the decoder with the sensor name to retrieve
    #' wavelength and FWHM information from the package's sensor metadata.
    #' @param sensor_name Character. The sensor name/serial (e.g., "8330" or "S8330").
    #' @param delimiter Character. The delimiter used in the CSV file (default: ";").
    #' @return A new instance of DecodeReflectanceList.
    initialize = function(sensor_name, delimiter = ";") {
      if (missing(sensor_name)) {
        stop("sensor_name is required to load sensor metadata")
      }
      self$sensor_name <- as.character(sensor_name)
      self$delimiter <- delimiter
    },

    #' Parse wavelength column names from CSV header
    #' @param column_names Character vector of column names from CSV
    #' @param metadata_columns Character vector of column names that are metadata (not wavelengths)
    #' @return Numeric vector of wavelengths extracted from column names
    parse_wavelengths = function(column_names, metadata_columns) {
      # Filter out metadata columns
      wavelength_cols <- setdiff(column_names, metadata_columns)
      # Convert to numeric (assuming column names are wavelength values)
      wavelengths <- as.numeric(wavelength_cols)
      if (any(is.na(wavelengths))) {
        stop("Could not parse all wavelength column names as numeric values")
      }
      return(wavelengths)
    },

    #' Load sensor metadata to get wavelengths and FWHM
    #' @param csv_wavelengths Numeric vector of wavelengths from CSV (optional, used as fallback)
    #' @return A list containing wavelength and fwhm vectors
    load_sensor_metadata = function(csv_wavelengths = NULL) {
      sensor_info <- find_sensor_metadata(self$sensor_name)
      
      if (is.null(sensor_info)) {
        # If sensor metadata not found, use CSV wavelengths and assume 1nm FWHM
        if (is.null(csv_wavelengths)) {
          stop(paste("Cannot find sensor metadata for sensor:", self$sensor_name, 
                    "and no CSV wavelengths provided as fallback"))
        }
        warning(paste("Sensor metadata not found for sensor:", self$sensor_name, 
                     ". Using wavelengths from CSV columns and assuming FWHM = 1nm"))
        led_wavelengths <- csv_wavelengths
        led_fwhm <- rep(1, length(csv_wavelengths))
      } else {
        # Extract wavelengths - prefer real over nominal
        led_wavelengths <- sensor_info[["led_wl_real"]]
        if (is.null(led_wavelengths)) {
          led_wavelengths <- sensor_info[["led_wl_nom"]]
        }
        if (is.null(led_wavelengths)) {
          # Fallback to CSV wavelengths if sensor metadata incomplete
          if (!is.null(csv_wavelengths)) {
            warning("Cannot load center wavelength from sensor metadata. Using CSV column headers.")
            led_wavelengths <- csv_wavelengths
          } else {
            stop("Cannot load center wavelength from sensor metadata")
          }
        } else {
          led_wavelengths <- unlist(led_wavelengths)
        }

        # Extract FWHM - prefer real over nominal
        led_fwhm <- sensor_info[["led_fwhm_real"]]
        if (is.null(led_fwhm)) {
          led_fwhm <- sensor_info[["led_fwhm_nom"]]
        }
        if (is.null(led_fwhm)) {
          # If FWHM not available in sensor metadata, assume 1nm
          warning("FWHM not found in sensor metadata. Assuming FWHM = 1nm")
          led_fwhm <- rep(1, length(led_wavelengths))
        } else {
          led_fwhm <- unlist(led_fwhm)
        }
      }

      list(wavelength = led_wavelengths, fwhm = led_fwhm)
    },

    #' Sanitize field names by replacing problematic characters
    #' @param field_name A character string representing a field name to sanitize
    #' @return A sanitized field name safe for use in R
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

    #' The main method: read CSV file and generate reflectance output
    #' @param csv_file_path Character. Path to the CSV file containing reflectance data
    #' @return A list containing metadata table, reflectance data, wavelengths, and FWHM values
    score = function(csv_file_path) {
      # Check if file exists
      if (!file.exists(csv_file_path)) {
        stop(paste("CSV file not found:", csv_file_path))
      }

      # Read the CSV file
      data <- read.csv(csv_file_path, sep = self$delimiter, header = TRUE, 
                      stringsAsFactors = FALSE, check.names = FALSE)

      if (nrow(data) == 0) {
        stop("CSV file is empty or could not be read")
      }

      # Get column names
      column_names <- colnames(data)

      # Identify metadata columns (typically LabelName, LabelNumber, etc.)
      # These are columns that are not numeric wavelength values
      metadata_columns <- c()
      for (col in column_names) {
        # If column name cannot be converted to numeric, it's metadata
        if (is.na(suppressWarnings(as.numeric(col)))) {
          metadata_columns <- c(metadata_columns, col)
        }
      }

      # Extract wavelengths from column names
      csv_wavelengths <- self$parse_wavelengths(column_names, metadata_columns)

      # Load sensor metadata for FWHM information (pass CSV wavelengths as fallback)
      sensor_meta <- self$load_sensor_metadata(csv_wavelengths)

      # Verify that CSV wavelengths match sensor wavelengths (if sensor was found)
      if (length(csv_wavelengths) != length(sensor_meta$wavelength)) {
        warning(paste("Number of wavelengths in CSV (", length(csv_wavelengths), 
                     ") does not match sensor metadata (", length(sensor_meta$wavelength), ").",
                     " Using sensor metadata wavelengths."))
      }

      # Build metadata table
      sample_meta_table <- data.frame()
      if (length(metadata_columns) > 0) {
        sample_meta_table <- data[, metadata_columns, drop = FALSE]
        # Sanitize column names
        colnames(sample_meta_table) <- sapply(colnames(sample_meta_table), self$sanitize_field_name)
      }

      # Extract reflectance data (all non-metadata columns)
      reflectance_columns <- setdiff(column_names, metadata_columns)
      reflectance_data <- data[, reflectance_columns, drop = FALSE]

      # Convert to list of numeric vectors (one per sample/row)
      reflectance_list <- list()
      for (i in seq_len(nrow(reflectance_data))) {
        reflectance_vector <- as.numeric(reflectance_data[i, ])
        reflectance_list[[i]] <- reflectance_vector
      }

      # Return structure matching DecodeCompolyticsRegularScanner output
      list(
        meta_table = sample_meta_table,
        reflectance = reflectance_list,
        wavelength = sensor_meta$wavelength,
        fwhm = sensor_meta$fwhm
      )
    }
  )
)
