#' Read indices table from a CSV file
#'
#' Convenience wrapper around `utils::read.table` for reading the
#' CSV written by `write_indices_csv()`.
#'
#' @param file Character. Path to the input CSV file.
#' @param row.names Logical. Whether the CSV includes row names (default: FALSE).
#' @return A data.frame containing the index values.
#' @export
read_indices_csv <- function(file, row.names = FALSE) {
  if (row.names) {
    df <- utils::read.table(file, sep = ";", dec = ".", header = TRUE, row.names = 1)
  } else {
    df <- utils::read.table(file, sep = ";", dec = ".", header = TRUE)
  }
  return(df)
}
