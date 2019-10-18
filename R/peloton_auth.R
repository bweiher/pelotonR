#' POST's credentials to Pelton's auth/login endpoint to enable further requests
#'
#'
#' User needs to set environmental variables `PELOTON_LOGIN` and `PELOTON_PASSWORD` to authenticate API requests
#'
#' @export
#' @param login Peloton login
#' @param password Peloton password
#' @examples
#' \dontrun{
#' peloton_auth() # need to run each session to authorize any other API requests
#' }
peloton_auth <- function(login = Sys.getenv("PELOTON_LOGIN"), password = Sys.getenv("PELOTON_PASSWORD")) {
  if (login == "" || password == "") {
    stop("Set environmental variables for your login ('PELOTON_LOGIN') and password ('PELOTON_PASSWORD')", call. = FALSE)
  }

  resp <- httr::POST(
    url = "https://api.onepeloton.com/auth/login",
    body = list(
      "username_or_email" = login,
      "password" = password
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
