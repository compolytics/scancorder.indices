# Load required library
library(xml2)

#' Recursive function to evaluate MathML expressions.
#' This function expects an XML node and a named list 'values' with numeric values.
#'
#' @param node XML node representing a MathML element.
#' @param values Named list of variable identifiers and their numeric values.
#' @return Numeric value resulting from the evaluation of the MathML expression.
#'
#' @export
#' @importFrom xml2 xml_children xml_name xml_text
evaluate_mathml <- function(node, values) {

  # If the node is a <math> element, evaluate its first child.
  if (xml_name(node) == "math") {
    children <- xml_children(node)
    if (length(children) == 0) {
      stop("Empty <math> element encountered.")
    }
    return(evaluate_mathml(children[[1]], values))
  }

  # If the node is a variable identifier, return its value from the list.
  if (xml_name(node) == "ci") {
    varname <- xml_text(node)
    if (!varname %in% names(values)) {
      stop(sprintf("Variable '%s' not found in reflectance values.", varname))
    }
    return(values[[varname]])
  }

  # If the node is a numeric constant, return its numeric value.
  if (xml_name(node) == "cn") {
    return(as.numeric(xml_text(node)))
  }

  # If the node is an <apply> element, process it recursively.
  if (xml_name(node) == "apply") {
    children <- xml_children(node)
    # The first child is the operator.
    operator <- xml_name(children[[1]])
    # Evaluate each argument recursively.
    args <- lapply(children[-1], function(child) evaluate_mathml(child, values))

    # Handle supported operators.
    if (operator == "plus") {
      return(Reduce(`+`, args))
    } else if (operator == "minus") {
      if (length(args) == 1) {
        return(-args[[1]])
      } else if (length(args) == 2) {
        return(args[[1]] - args[[2]])
      } else {
        return(Reduce(function(a, b) a - b, args))
      }
    } else if (operator == "times") {
      return(Reduce(`*`, args))
    } else if (operator == "divide") {
      if (length(args) == 2) {
        return(args[[1]] / args[[2]])
      } else {
        return(Reduce(function(a, b) a / b, args))
      }
    } else if (operator == "power") {
      if (length(args) == 2) {
        return(args[[1]]^args[[2]])
      } else {
        stop("The power operator expects exactly 2 arguments.")
      }
    } else {
      stop(sprintf("Unsupported MathML operator: %s", operator))
    }
  }
  stop("Encountered an unknown MathML element.")
}
