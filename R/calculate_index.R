# Load required library
library(xml2)

#' Main function to calculate the spectral index based on an XML definition.
#' @export
calculate_index <- function(xml_file, wavelengths, reflectance_list, fwhm = NULL) {
  # --- 1. Parse XML once ----------------------------------------------------
  doc           <- read_xml(xml_file)
  index_name    <- xml_text(xml_find_first(doc, "//Name"))
  if (is.na(index_name)) {
    stop("No <Name> element found in XML.")
  }
  # Build a named list of band ranges
  band_nodes    <- xml_find_all(doc, "//Wavelengths/Band")
  bands <- setNames(
    lapply(band_nodes, function(node) {
      list(
        min = as.numeric(xml_attr(node, "min")),
        max = as.numeric(xml_attr(node, "max"))
      )
    }),
    xml_attr(band_nodes, "name")
  )

  # Prepare FWHM margins
  if (is.null(fwhm)) {
    margin <- rep(0, length(wavelengths))
  } else {
    fwhm <- unlist(fwhm)
    if (!is.numeric(fwhm) || length(fwhm) != length(wavelengths)) {
      stop("`fwhm` must be a numeric vector of the same length as `wavelengths`.")
    }
    margin <- 0.5 * fwhm
  }

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

      center <- (rng$min + rng$max) / 2
      idx <- which((wavelengths+margin) >= rng$min & (wavelengths-margin) <= rng$max)
      if (length(idx) == 0) {
        message(sprintf("No reflectance data found in the range [%s, %s] nm with margins applied.",
                        rng$min, rng$max))
        return(NULL)
      }
      # pick the one whose wavelength is closest to the band center
      dists <- abs(wavelengths[idx] - center)
      best <- idx[which.min(dists)]
      return(reflectance[best])
    })

    # if any band is missing data → NA
    if (any(sapply(refl_vals, is.null))) return(NA_real_)
    names(refl_vals) <- names(bands)

    # evaluate the MathML formula with those band means
    result <- tryCatch(
      evaluate_mathml(mathml_node, refl_vals),
      error = function(e) {
        message("MathML evaluation error: ", e$message)
        NA_real_
      }
    )
  }

  # --- 3. Apply to each reflectance vector & return list --------------------
  result <- lapply(reflectance_list, compute_single)
  return(result)
}
