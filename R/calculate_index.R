# Load required library
library(xml2)

#' Calculate the spectral index based on an XML definition.
#'
#' This function reads an XML file containing the index definition,
#' extracts the band ranges and MathML expression,
#' and computes the index for each reflectance vector.
#' @param xml_file Path to the XML file defining the index.
#' @param wavelengths Numeric vector of wavelengths corresponding to the reflectance data.
#' @param reflectance_list List of numeric vectors, each representing reflectance values for a sample.
#' @param fwhm Optional numeric vector of full width at half maximum (FWHM) values for each wavelength.
#' @return A list of computed index values for each reflectance vector.
#'
#' @export
#' @importFrom xml2 xml_attr xml_text xml_name xml_find_first xml_find_all
#' @importFrom stats na.omit setNames
calculate_index <- function(xml_file, wavelengths, reflectance_list, fwhm = NULL) {
  # --- 1. Parse XML once ----------------------------------------------------
  doc           <- read_xml(xml_file)
  index_name    <- xml_text(xml_find_first(doc, "//Name"))
  if (is.na(index_name)) {
    stop("No <Name> element found in XML.")
  }
  # Build a named list of band ranges with their selection strategy
  band_nodes    <- xml_find_all(doc, "//Wavelengths/Band")
  bands <- setNames(
    lapply(band_nodes, function(node) {
      sel <- xml_attr(node, "select")
      # Default selection strategy is "min-distance"
      if (is.null(sel) || is.na(sel) || sel == "") sel <- "min-distance"
      list(
        min = as.numeric(xml_attr(node, "min")),
        max = as.numeric(xml_attr(node, "max")),
        select = sel
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
    # store the indices of the selected bands to assure no repetitions
    selected_indices <- vector("integer", length(bands))
    refl_vals <- vector("double", length(bands))
    band_names <- names(bands)
    for (i in seq_along(bands)) {
      rng <- bands[[i]]
      center <- (rng$min + rng$max) / 2
      idx <- which((wavelengths+margin) >= rng$min & (wavelengths-margin) <= rng$max)
      if (length(idx) == 0) {
        selected_indices[i] <- NA_integer_
        refl_vals[i] <- NA
        next
      }
      if (rng$select == "min-distance") {
        dists <- abs(wavelengths[idx] - center)
        best <- idx[which.min(dists)]
        selected_indices[i] <- best
        refl_vals[i] <- reflectance[best]
      } else if (rng$select == "min-reflectance") {
        best <- idx[which.min(reflectance[idx])]
        selected_indices[i] <- best
        refl_vals[i] <- reflectance[best]
      } else {
        stop(paste0('Unknown select attribute value: ', rng$select))
      }
    }
    names(refl_vals) <- band_names

    # if any band is missing data → NA
    if (any(sapply(refl_vals, is.na))) return(NA_real_)
    # if any band is duplicated (same wavelength selected for two bands) → NA
    if (any(duplicated(selected_indices))) return(NA_real_)
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
