#' Write reflectance table to a CSV file
#'
#' Convenience wrapper around `utils::write.table` for writing the
#' data.frame produced by `generate_reflectance_table()`.
#'
#' @param df Data.frame returned by `generate_reflectance_table()`.
#' @param file Character. Path to the output CSV file.
#' @param row.names Logical. Whether to include row names (default: FALSE).
#' @return Invisibly returns `file`.
#' @export
write_reflectance_csv <- function(df, file, row.names = FALSE) {
  utils::write.table(df, file = file, sep = ";", dec = ".", row.names = row.names)
  invisible(file)
}
