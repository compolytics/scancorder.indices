#' Extract the <Name> element from one or more spectral-index XML files
#'
#' @param xml_files  Character vector with paths to the XML files **or**
#'                   a single directory that contains only index XMLs.
#' @return           A character vector of index names.
#'
#' @importFrom pkgload pkg_path
#' @importFrom xml2 read_xml xml_find_first xml_text
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

  # Read each file, pull the first <Name> element, strip white space
  vapply(xml_files, function(f) {
    doc <- read_xml(f)
    name_node <- xml_find_first(doc, ".//Name")
    trimws(xml_text(name_node))
  }, character(1L), USE.NAMES = FALSE)
}
