#' Generate reflectance table from calibrated reflectance data
#'
#' This function creates a data frame containing calibrated reflectance values
#' for each sample and wavelength. Each wavelength becomes a column in the output.
#'
#' @param wavelengths Numeric vector of wavelengths (same length as each reflectance vector).
#' @param reflectance_list List of numeric reflectance vectors (calibrated or raw).
#' @param meta_table Optional data frame containing metadata for each sample.
#' @return A data.frame with columns:
#'   - `sample`: integer sample number (1 to length of `reflectance_list`)
#'   - one column per wavelength (named by wavelength, e.g. `R550`, `R700`)
#'   - metadata columns (if meta_table is provided)
#' @export
generate_reflectance_table <- function(wavelengths, reflectance_list, meta_table = NULL) {
  
  # Validate inputs
  if (length(wavelengths) == 0) {
    stop("wavelengths vector is empty")
  }
  
  if (length(reflectance_list) == 0) {
    stop("reflectance_list is empty")
  }
  
  # Check that all reflectance vectors have the same length as wavelengths
  reflectance_lengths <- vapply(reflectance_list, length, integer(1))
  if (!all(reflectance_lengths == length(wavelengths))) {
    stop("All reflectance vectors must have the same length as wavelengths")
  }
  
  # Convert reflectance list to matrix (samples x wavelengths)
  reflectance_matrix <- do.call(rbind, reflectance_list)
  
  # Create column names from wavelengths (e.g., "R550", "R700")
  wavelength_cols <- paste0("R", wavelengths)
  
  # Create the data frame
  df <- data.frame(
    sample = seq_along(reflectance_list),
    reflectance_matrix,
    row.names = NULL,
    check.names = FALSE
  )
  
  # Set proper column names
  colnames(df) <- c("sample", wavelength_cols)
  
  # If meta_table is provided, bind it to the results
  if (!is.null(meta_table) && is.data.frame(meta_table)) {
    if (nrow(meta_table) != nrow(df)) {
      stop("meta_table must have the same number of rows as reflectance_list.")
    }
    df <- cbind(meta_table, df)
  }
  
  return(df)
}
