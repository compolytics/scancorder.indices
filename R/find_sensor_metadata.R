# install.packages("jsonlite")
library(jsonlite)

#' Find sensor metadata by a 4-digit serial embedded in sensor_serial
#'
#' @param serial_number A 4-digit serial (character or numeric)
#' @param directory Path to folder containing .json files.
#'   Defaults to the "sensors" subdirectory of the installed scancorder.indices package.
#' @return Parsed JSON (as an R list) for the first file whose sensor_serial contains that 4-digit code, or NULL
find_sensor_metadata <- function(
    serial_name,
    directory = system.file("sensors", package = "scancorder.indices")
) {
  # pull out all 4-digit substrings from the input
  input_str <- as.character(serial_name)
  codes <- regmatches(input_str, gregexpr("\\d{4}", input_str))[[1]]
  if (length(codes) == 0) {
    stop("No 4-digit code found in serial_name: '", input_str,
         "'. Please include a 4-digit number.")
  }
  # take the first 4-digit match
  serial_code <- codes[1]

  # check that default package folder exists
  if (identical(directory, "") || !dir.exists(directory)) {
    stop("Cannot find sensors directory in scancorder.indices package: ", directory)
  }

  # list JSON files
  files <- list.files(path = directory, pattern = "\\.json$", full.names = TRUE)
  if (length(files) == 0) {
    stop("No JSON files found in directory: ", directory)
  }

  # scan each file
  for (f in files) {
    obj <- tryCatch(fromJSON(f, simplifyVector = FALSE), error = function(e) NULL)
    if (is.null(obj)) next

    if (!is.null(obj[["sensor_serial"]])) {
      txt     <- paste(unlist(obj[["sensor_serial"]]), collapse = " ")
      matches <- regmatches(txt, gregexpr("\\d{4}", txt))[[1]]
      if (serial_code %in% matches) {
        return(obj)
      }
    }
  }

  warning(sprintf("No external metadata found containing serial '%s'", serial_code))
  NULL
}
