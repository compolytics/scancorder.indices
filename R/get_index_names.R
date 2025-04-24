#' Extract the <Name> element from one or more spectral-index XML files
#'
#' @param xml_files  Character vector with paths to the XML files **or**
#'                   a single directory that contains only index XMLs.
#' @return           A character vector of index names.
#' @examples
#' files <- list.files("indices", pattern = "\\.xml$", full.names = TRUE)
#' get_index_names(files)
#' #> [1] "NDVI" "NDWI"
get_index_names <- function() {
  
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
  if (length(xml_files) == 1L && dir.exists(xml_files)) {
    xml_files <- list.files(xml_files, pattern = "\\.xml$", full.names = TRUE)
  }
  if (!length(xml_files)) stop("No XML files supplied or found.")

  # Read each file, pull the first <Name> element, strip whitespace
  vapply(xml_files, function(f) {
    doc <- xml2::read_xml(f)
    name_node <- xml2::xml_find_first(doc, ".//Name")
    trimws(xml2::xml_text(name_node))
  }, character(1L), USE.NAMES = FALSE)
}