#' POST's credentials to Pelton's auth/login endpoint to enable further requests
#'
#'
#'
#'
#' @export
#'
auth_peloton <- function() {

  login <- Sys.getenv("PELOTON_LOGIN")
  pass <- Sys.getenv("PELOTON_PASSWORD")

  if (login == "" || pass == "") {
    stop("Set environmental variables for your login ('PELOTON_LOGIN') and password ('PELOTON_PASSWORD')", call. = FALSE)
  }

  resp <- httr::POST(
    url = "https://api.onepeloton.com/auth/login",
    body = list(
      "username_or_email" = Sys.getenv("PELOTON_LOGIN"),
      "password" = Sys.getenv("PELOTON_PASSWORD")
    ),
    encode = "json"
  )


  if (httr::http_error(resp)) {
    stop(
      glue::glue("Peloton Login failed ({httr::status_code(resp)})"),
      call. = FALSE
    )
  } else {
    print("Logged in")
  }
}
