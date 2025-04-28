#' Write indices table to a CSV file
#'
#' Convenience wrapper around `utils::write.csv` for writing the
#' data.frame produced by `calculate_indices()`.
#'
#' @param df Data.frame returned by `calculate_indices()`.
#' @param file Character. Path to the output CSV file.
#' @param row.names Logical. Whether to include row names (default: FALSE).
#' @return Invisibly returns `file`.
#' @export
write_indices_csv <- function(df, file, row.names = FALSE) {
  utils::write.table(df, file = file, sep= ";", dec=".", row.names = row.names)
  invisible(file)
}
