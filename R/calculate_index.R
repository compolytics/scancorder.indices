# Load required library
library(xml2)

#' Main function to calculate the spectral index based on an XML definition.
#' @export
calculate_index <- function(xml_file, wavelengths, reflectance) {

  # Parse the XML file.
  doc <- read_xml(xml_file)

  # Get the index name (e.g., NDVI, NDWI).
  index_name <- xml_text(xml_find_first(doc, "//Name"))

  # Retrieve band definitions (wavelength ranges).
  band_nodes <- xml_find_all(doc, "//Wavelengths/Band")
  bands <- list()
  for (node in band_nodes) {
    band_name <- xml_attr(node, "name")
    band_min <- as.numeric(xml_attr(node, "min"))
    band_max <- as.numeric(xml_attr(node, "max"))
    bands[[band_name]] <- list(min = band_min, max = band_max)
  }

  # For each required band, select the reflectance values that fall within the defined wavelength range.
  reflectance_values <- list()
  for (band in names(bands)) {
    band_range <- bands[[band]]
    indices <- which(wavelengths >= band_range$min & wavelengths <= band_range$max)

    # If no data falls within the specified band, do not calculate the index.
    if (length(indices) == 0) {
      message(sprintf("No reflectance data found in the %s band range [%s, %s] nm.",
                      band, band_range$min, band_range$max))
      return(NA)
    }
    # Use the mean reflectance value for the band.
    reflectance_values[[band]] <- mean(reflectance[indices])
  }

  # Parse the MathML expression.
  # Use an XPath that ignores namespaces by matching local names.
  mathml_node <- xml_find_first(doc, "//*[local-name()='MathML']/*[local-name()='math']")
  if (is.na(xml_name(mathml_node))) {
    message("No MathML expression found in the XML. Cannot calculate index.")
    return(NA)
  }

  # Evaluate the MathML expression using the reflectance values.
  message(sprintf("Index %s", mathml_node))
  index_value <- tryCatch({
    evaluate_mathml(mathml_node, reflectance_values)
  }, error = function(e) {
    message("Error evaluating MathML: ", e$message)
    return(NA)
  })

  message(sprintf("Calculated %s: %s", index_name, index_value))
  return(index_value)
}
