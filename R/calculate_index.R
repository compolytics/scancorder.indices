# Load required library
library(xml2)

#' Main function to calculate the spectral index based on an XML definition.
#' @export
calculate_index <- function(xml_file, wavelengths, reflectance_list) {
  # --- 1. Parse XML once ----------------------------------------------------
  doc           <- read_xml(xml_file)
  index_name    <- xml_text(xml_find_first(doc, "//Name"))
  band_nodes    <- xml_find_all(doc, "//Wavelengths/Band")

  # Build a named list of band ranges
  bands <- setNames(
    lapply(band_nodes, function(node) {
      list(
        min = as.numeric(xml_attr(node, "min")),
        max = as.numeric(xml_attr(node, "max"))
      )
    }),
    xml_attr(band_nodes, "name")
  )

  # Grab the MathML <math> node (ignoring namespaces)
  mathml_node <- xml_find_first(
    doc,
    "//*[local-name()='MathML']/*[local-name()='math']"
  )
  if (is.na(xml_name(mathml_node))) {
    stop("No MathML expression found in XML.")
  }

  # --- 2. Define single‐vector computation --------------------------------
  compute_single <- function(reflectance) {
    # ensure it's a numeric vector
    reflectance <- unlist(reflectance)

    # for each band, find indices & mean‐aggregate
    refl_vals <- lapply(bands, function(rng) {
      idx <- which(wavelengths >= rng$min & wavelengths <= rng$max)
      if (length(idx) == 0) {
        message(sprintf("No reflectance data found in the range [%s, %s] nm.",
                        rng$min, rng$max))
        return(NULL)
      }
      mean(reflectance[idx])
    })

    # if any band is missing data → NA
    if (any(sapply(refl_vals, is.null))) return(NA_real_)
    names(refl_vals) <- names(bands)

    # evaluate the MathML formula with those band means
    tryCatch(
      evaluate_mathml(mathml_node, refl_vals),
      error = function(e) NA_real_
    )
  }

  # --- 3. Apply to each reflectance vector & return list --------------------
  result <- lapply(reflectance_list, compute_single)
  return(result)
}
