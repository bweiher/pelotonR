utils::globalVariables(c("."))


#' Makes a request against the \code{api/me} endpoint
#'
#'
#' Returns user metadata, including userid, email, account status, etc.  \code{userid} is particularly useful since you need it for \code{\link{get_workouts_data}}.
#'
#' @export
#' @examples
#' \dontrun{
#' peloton_auth()
#' get_my_info()
#' }
#'
get_my_info <- function() {
  peloton_api("api/me") %>%
    .$content %>%
    parse_list_to_df()
}


#' Makes a request against the \code{api/workout/workout_id/performance_graph} endpoint
#'
#'
#' For each workout, returns time series of individual workouts capturing cadence, output, resistance, speed, heart-rate (if applicable), measured at second intervals defined by \code{every_n}. A vectorized function, so accepts multiple \code{workoutIDs} at once.
#'
#' @export
#' @param workout_ids WorkoutIDs
#' @param every_n How often measurements are reported. If set to 1, there will be 60 data points per minute of a workout.
#' @examples
#' \dontrun{
#' workouts <- get_all_workouts()
#' get_perfomance_graphs(workouts$id)
#' }
#'
get_perfomance_graphs <- function(workout_ids, every_n = 5) {
  purrr::map_df(workout_ids, function(workout_id) {
    peloton_api(
      path = glue::glue("api/workout/{workout_id}/performance_graph"),
      query = list(
        every_n = every_n # wat does this mean
      )
    ) %>%
      .$content %>%
      parse_list_to_df() %>%
      dplyr::mutate(id = workout_id)
  })
}


#' Makes a request against the \code{api/user_id/workouts/} endpoint
#'
#'
#' Lists requested number of workouts for a user, along with some metadata.
#'
#' @export
#' @param userid userID
#' @param num_workouts num_workouts
#' @examples
#' \dontrun{
#' peloton_auth()
#' get_all_workouts()
#' }
#'
get_all_workouts <- function(userid = Sys.getenv("PELOTON_USERID"), num_workouts = 20) {
  if (userid == "") stop("Provide a userid or set an environmental variable `PELOTON_USERID`", call. = FALSE)
  workouts <- peloton_api(path = glue::glue("api/user/{userid}/workouts?&limit={num_workouts}"))
  n_workouts <- length(workouts$content$data)
  if (n_workouts > 0) purrr::map_df(1:length(workouts$content$data), ~ parse_list_to_df(workouts$content$data[[.]]))
}




#' Makes a request against the \code{api/workout/workout_id} endpoint
#'
#'
#' Returns data about individual workouts. A vectorized function, so accepts multiple \code{workoutIDs} at once.
#'
#' @export
#' @param workout_ids WorkoutIDs
#' @examples
#' \dontrun{
#' peloton_auth()
#' get_all_workouts()
#' }
#'
get_workouts_data <- function(workout_ids) {
  purrr::map_df(workout_ids, function(workout_id) {
    peloton_api(path = glue::glue("api/workout/{workout_id}")) %>%
      .$content %>%
      parse_list_to_df()
  })
}
