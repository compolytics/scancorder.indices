#' Find the file path to a spectral-index XML by name from the scancorder.indices package
#'
#' This function locates XML files shipped in the `inst/indices/` folder of the
#' `scancorder.indices` package and returns the full file path of the XML whose
#' <Name> element matches `index_name`.
#'
#' @param index_name Character. Name of the index to find (e.g. "NDVI").
#' @return Character. Full file path to the matching XML.
#' @importFrom pkgload pkg_path
#' @importFrom xml2 read_xml xml_find_first xml_text
#' @export
get_index_xml <- function(index_name) {
  # Locate the package source path
  pkg_root   <- pkgload::pkg_path()
  indices_dir <- file.path(pkg_root, "indices")
  if (!dir.exists(indices_dir)) {
    stop("Indices directory not found in package source: ", indices_dir)
  }

  # List available XML files
  xml_files <- list.files(indices_dir,
                          pattern = "\\.xml$",
                          full.names = TRUE)
  if (length(xml_files) == 0) {
    stop("No XML index definitions found in: ", indices_dir)
  }

  # Extract <Name> from each XML to find matches
  index_names <- vapply(xml_files, function(f) {
    doc <- xml2::read_xml(f)
    nm  <- xml2::xml_text(xml2::xml_find_first(doc, "//Name"))
    if (nzchar(nm)) nm else NA_character_
  }, character(1), USE.NAMES = FALSE)

  # Perform case-insensitive matching
  hits <- which(tolower(index_names) == tolower(index_name))
  if (length(hits) == 0) {
    stop("No index named '", index_name,
         "' found in scancorder.indices\nAvailable: ",
         paste(na.omit(index_names), collapse = ", "))
  }
  if (length(hits) > 1) {
    warning("Multiple definitions for '", index_name,
            "' found; returning the first match.")
  }

  # Return the file path of the first match
  xml_files[hits[1]]
}
