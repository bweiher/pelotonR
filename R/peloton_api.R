#' Makes a GET request against one of Peloton's APIs
#'
#'
#'
#'
#' @export
#' @param path API endpoint to query
#' @param ... Additional parameters passed onto methods

peloton_api <- function(path, ...) {
  # ua <- httr::user_agent("https://github.com/bweiher/pelotonR")

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
      content = parsed,
      path = path,
      response = resp
    ),
    class = "peloton_api"
  )
}


print.peloton_api <- function(x, ...) {
  cat("<Peloton ", x$path, ">\n", sep = "")
  utils::str(x$content)
  invisible(x)
}
