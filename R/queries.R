utils::globalVariables(c("."))


#' Makes a request against the \code{api/me} endpoint
#'
#'
#' Returns user metadata, including userid, email, account status, etc..
#'
#' @export
#' @examples
#' \dontrun{
#' peloton_auth() ; get_my_info()
#' }
#'
get_my_info <- function(){
  peloton_api("api/me") %>%
    .$content %>%
    parse_list_to_df()
}


#' Makes a request against the \code{api/workout/workout_id/performance_graph} endpoint
#'
#'
#' Returns time series of individual workouts capturing cadence, output, resistance and speed measured at many intervals.
#'
#' @export
#' @param workout_ids WorkoutIDs
#' @param every_n Everywhat?
#' @examples
#' \dontrun{
#' workouts <- get_all_workouts()
#' get_perfomance_graphs(workouts$id)
#' }
#'
get_perfomance_graphs <- function(workout_ids, every_n = 5){
  purrr::map_df(workout_ids, function(workout_id){
    peloton_api(
      path = glue::glue("api/workout/{workout_id}/performance_graph"),
      query = list(
        every_n = every_n # wat does this mean
      )
    ) %>%
      .$content %>%
      parse_list_to_df() %>%
      mutate(id = workout_id)
  })

}


#' Makes a request against the \code{api/user_id/workouts/} endpoint
#'
#'
#' Lists (all?) workouts for a user
#'
#' @export
#' @param userid userID
#' @examples
#' \dontrun{
#' peloton_auth() ; get_all_workouts()
#' }
#'
get_all_workouts <- function(userid = Sys.getenv("PELOTON_USERID")){
  # TODO pagination  in API ?
  if(userid == '') stop("Provide a userid or set an environmental variable `PELOTON_USERID`", call. = FALSE)
  workouts <- peloton_api(path = glue::glue("api/user/{userid}/workouts"))
  n_workouts <- length(workouts$content$data)
  if(n_workouts > 0) purrr::map_df(1:length(workouts$content$data), ~parse_list_to_df(workouts$content$data[[.]]))
}




#' Makes a request against the \code{api/workout/workout_id} endpoint
#'
#'
#' Returns data about an individual workout.
#'
#' @export
#' @param workout_ids WorkoutIDs
#' @examples
#' \dontrun{
#' peloton_auth() ; get_all_workouts()
#' }
#'
get_workouts_data <- function(workout_ids){
  purrr::map_df(workout_ids, function(workout_id){
  peloton_api(path = glue::glue("api/workout/{workout_id}")) %>%
    .$content %>%
    parse_list_to_df()
})
}
