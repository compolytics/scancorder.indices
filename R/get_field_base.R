# base-R version
# pluck_base(x, path) returns NULL if any step is missing
pluck_base <- function(x, path) {
  for (nm in path) {
    if (!is.list(x) || is.null(x[[nm]])) return(NULL)
    x <- x[[nm]]
  }
  x
}

# get_field_base(master, slave, path..., .default = NULL)
get_field_base <- function(master, slave, ..., .default = NULL) {
  path <- c(...)
  # try master
  val1 <- pluck_base(master, path)
  if (!is.null(val1) && length(val1) > 0) return(val1)
  # try slave
  val2 <- pluck_base(slave, path)
  if (!is.null(val2) && length(val2) > 0) return(val2)
  # neither had a value → return default
  .default
}

# Example:
# get_field_base(m, s, "a", "b")         # 1
# get_field_base(m, s, "x")              # 5
# get_field_base(m, s, "z")              # NULL
# get_field_base(m, s, "z", .default=NA) # NA
