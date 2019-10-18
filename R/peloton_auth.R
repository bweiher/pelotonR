#' \code{POST} credentials to Peloton's auth/login endpoint
#'
#'
#' Users needs to run this each session in order to authenticate any requests made against other Pelton endpoints. Set environmental variables \code{`PELOTON_LOGIN`} and \code{`PELOTON_PASSWORD`}, or provide them yourself.
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
