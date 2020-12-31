#' Parse the \code{JSON} content of a response and turn the result into a \code{tibble} .
#'
#'
#' A helper, agnostic function to parse the content of API responses made to Peloton's API. Leaves most datatypes alone, but converts nested lists into list-columns.
#'
#' @export
#' @param list The JSON content of a response (aka a named list in R)
#' @param parse_dates Whether to turn epoch timestamps into datetimes
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
    } else {
      m[[column]] <- val
    }
    m[[column]] <- val
  }
  if (parse_dates) m <- parse_dates(m)
  m
}


#' Convert UNIX epoch timestamps to datetime
#'
#'
#' Helper function convert UNIX timestamps to datestamps. By default converts to \code{America/Los_Angeles} timezone.
#'
#' @export
#' @param dataframe A dataframe containing some columns that may be dates
#' @param tz Timezone to convert datestamp to
#' @examples
#' \dontrun{
#' parse_dates(data.frame(a = 1570914652, b = "adad", c = 123L))
#' }
#'
parse_dates <- function(dataframe, tz = base::Sys.timezone()) {
  exclude_ <- c("peloton_id", "id", "facebook_id", "home_peloton_id")
  fn <- function(x, ...) {
    as.POSIXct(x, origin = "1970-01-01", tz)
  }
  names <- names(dataframe)
  true <- logical(length = length(names))
  for (i in seq_along(names)) {
    name <- names[i]
    # TODO parse inner list too
    true[[i]] <- grepl(pattern = "^1[0-9]{9}", x = dataframe[[name]]) && !is.list(dataframe[[name]]) && !name %in% exclude_
  }
  vars <- names[true]
  dplyr::mutate_at(dataframe, vars, fn)
}
