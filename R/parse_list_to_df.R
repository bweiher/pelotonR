#' Parsing the JSON content of a response and turning result into a tibble. Converts nested lists into list-columns.
#'
#'
#'
#'
#' @export
#' @param list The JSON content of a response (a named list in R)
#' @param parse_dates Whether to turn timestamps into datetimes
#' @examples
#' \dontrun{
#' parse_list_to_df(peloton_api("api/me")$content)
#' }
#'
parse_list_to_df <- function(list, parse_dates = TRUE) {
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
  if(parse_dates) m <- parse_dates(m)

}


#' Helper function to infer which columns are dates (UNIX epoch) and parse them as such.
#'
#'
#' Automatically converts timezone to America/Los_Angeles
#'
#' @export
#' @param dataframe A dataframe containing some columns that may be dates
#' @param tz Timezone to convert datestamp to
#' @examples
#' \dontrun{
#' parse_dates(data.frame(a = 1570914652, b = "adad", c = 123L))
#' }
#'
parse_dates <- function(dataframe, tz = "America/Los_Angeles"){
  fn <- function(x, ...) {
    as.POSIXct(x, origin = '1970-01-01', tz)
  }
  names <- names(dataframe)
  true <- logical(length = length(names))
  for(i in seq_along(names)){
    name <- names[i]
    # TODO parse inner list too
    true[[i]] <- grepl(pattern = "[0-9]{10}", x = dataframe[[name]]) && !is.list(dataframe[[name]])
  }
  vars <- names[true]
  dplyr::mutate_at(dataframe, vars, fn)
}
