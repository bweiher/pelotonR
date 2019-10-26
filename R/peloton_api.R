#' Makes a \code{GET} request against one of Peloton's API endpoints
#'
#'
#' Users need not invoke this method directly and may instead use one of the wrappers around specific endpoints that also vectorizes inputs and processes the data returned, such as \code{\link{get_my_info}},  \code{\link{get_perfomance_graphs}}, \code{\link{get_all_workouts}}, \code{\link{get_workouts_data}}
#'
#' @export
#' @param path API endpoint to query
#' @param ... Additional parameters passed onto methods
#' @examples
#' \dontrun{
#' peloton_auth()
#' peloton_api("api/me")
#' }
#'
peloton_api <- function(path, ...) {
  path <- glue::glue("{path}")
  url <- httr::modify_url("https://api.onepeloton.com/", path = path, ...)
  resp <- httr::GET(url = url)

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)

  if (httr::http_error(resp)) {
    msg <- glue::glue(
      "Peloton API request failed ({httr::status_code(resp)})
        {parsed$message}
        "
    )
    stop(
      msg,
      call. = FALSE
    )
  }

  structure(
    list(
      path = path,
      response = resp,
      content = parsed
    ),
    class = "peloton_api"
  )
}


print.peloton_api <- function(x, ...) {
  cat("<Peloton ", x$path, ">\n", sep = "")
  utils::str(x$content)
}
