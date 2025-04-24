#' Calculate all available spectral indices for a list of reflectance vectors
#'
#' This function discovers all index XML definitions in the
#' `inst/indices/` folder of the `scancorder.indices` package, then
#' uses `calculate_indices_table()` to compute each index for each reflectance
#' vector in `reflectance_list`.
#'
#' @param wavelengths Numeric vector of wavelengths (same length as each reflectance vector).
#' @param reflectance_list List of numeric reflectance vectors.
#' @return A data.frame with columns:
#'   - `sample`: integer sample number (1 to length of `reflectance_list`)
#'   - one column per index (named by the index, e.g. `NDVI`, `NDWI`)
#' @importFrom pkgload pkg_path
#' @importFrom xml2 read_xml xml_find_first xml_text
#' @export
calculate_indices_table <- function(wavelengths, reflectance_list) {
  # Locate the indices directory in the package source
  pkg_root    <- pkgload::pkg_path()
  indices_dir <- file.path(pkg_root, "indices")
  if (!dir.exists(indices_dir)) {
    stop("Indices directory not found in package source: ", indices_dir)
  }

  # Discover all XML files
  xml_files <- list.files(indices_dir,
                          pattern = "\\.xml$",
                          full.names = TRUE)
  if (length(xml_files) == 0) {
    stop("No XML index definitions found in: ", indices_dir)
  }

  # Extract index names from each XML
  index_names <- vapply(xml_files, function(f) {
    doc <- xml2::read_xml(f)
    xml2::xml_text(xml2::xml_find_first(doc, "//Name"))
  }, character(1), USE.NAMES = FALSE)

  # For each XML, compute index values for all reflectance vectors
  results <- lapply(seq_along(xml_files), function(i) {
    xml_file <- xml_files[i]
    vals <- calculate_index(xml_file, wavelengths, reflectance_list)
    # ensure a numeric vector
    unlist(vals, use.names = FALSE)
  })
  names(results) <- index_names

  # Combine into data.frame
  df <- data.frame(
    sample = seq_along(reflectance_list),
    as.data.frame(results, check.names = FALSE),
    row.names = NULL
  )
  df
}
