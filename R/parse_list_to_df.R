#' Parsing the JSON content of a response and turning result into a tibble. Converts nested lists into list-columns.
#'
#'
#'
#'
#' @export
#' @param list The JSON content of a response (a named list in R)

parse_list_to_df <- function(list) {
  names <- names(list)
  m <- stats::setNames(dplyr::as_tibble(as.data.frame(matrix(nrow = 1L, ncol = length(names)))), names)

  for (column in seq_along(names)) {
    val <- list[[column]]
    if (is.null(val) || length(val) == 0) {
      val <- NA_character_
    } else if (is.list(val) && (!length(val) == 0)) {
      val <- list(val)
    }
    m[[column]] <- val
  }
  m
}
