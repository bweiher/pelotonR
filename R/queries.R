#' Makes a request against the \code{api/me} endpoint
#'
#'
#' Returns user metadata, including userid, email, account status, etc.  \code{userid} is particularly useful since you need it for \code{\link{get_workouts_data}}.
#'
#' @export
#' @param dictionary A named list. Maps a data-type to a column name. If \code{NULL} then no parsing is done
#' @param parse_dates Whether to try and guess which columns are dates and convert
#' @param ... Other arguments passed on to methods
#' @examples
#' \dontrun{
#' peloton_auth()
#' get_my_info()
#' }
#'
get_my_info <- function(dictionary = NULL, parse_dates = TRUE, ...) {
  resp <- peloton_api("api/me", ...)$content
  parse_list_to_df(resp, parse_dates = parse_dates, dictionary = dictionary)
}


#' Makes a request against the \code{api/workout/workout_id/performance_graph} endpoint
#'
#'
#' For each workout, returns time series of individual workouts capturing cadence, output, resistance, speed, heart-rate (if applicable), measured at second intervals defined by \code{every_n}. A vectorized function, so accepts multiple \code{workoutIDs} at once.
#'
#' @export
#' @importFrom rlang .data
#' @param workout_ids WorkoutIDs
#' @param every_n How often measurements are reported. If set to 1, there will be 60 data points per minute of a workout
#' @param dictionary A named list. Maps a data-type to a column name. If \code{NULL} then no parsing is done
#' @param parse_dates Whether to try and guess which columns are dates and convert
#' @param ... Other arguments passed on to methods
#' @examples
#' \dontrun{
#' workouts <- get_all_workouts()
#' get_performance_graphs(workouts$id)
#' get_performance_graphs(workouts$id,
#'   dictionary =
#'     list("list" = c("seconds_since_pedaling_start", "segment_list"))
#' )
#' }
#'
get_performance_graphs <- function(workout_ids, every_n = 5, dictionary = list("list" = c("seconds_since_pedaling_start", "segment_list")), parse_dates = TRUE, ...) {
  purrr::map_df(workout_ids, function(workout_id) {
    resp <- peloton_api(
      path = glue::glue("api/workout/{workout_id}/performance_graph"),
      query = list(
        every_n = every_n
      ),
      ...
    )$content

    parse_list_to_df(resp, dictionary = dictionary, parse_dates = parse_dates) %>%
      dplyr::mutate(
        id = workout_id
      )
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
#' @param joins additional joins to make on the data (e.g. `ride` or `ride.instructor`, concatenated as a single string. Results in many additional columns being added to the data.frame)
#' @param dictionary A named list. Maps a data-type to a column name. If \code{NULL} then no parsing is done
#' @param parse_dates Whether to try and guess which columns are dates and convert
#' @param ... Other arguments passed on to methods
#' @examples
#' \dontrun{
#' peloton_auth()
#' get_all_workouts()
#' get_all_workouts(joins = "ride,ride.instructor")
#' # if you run into parsing errors, sometimes helpful to manual override
#' workouts <- get_all_workouts(user_id,
#'   dictionary = list(
#'     "numeric" =
#'       c("v2_total_video_buffering_seconds", "v2_total_video_watch_time_seconds")
#'   )
#' )
#' }
#'
get_all_workouts <- function(userid = Sys.getenv("PELOTON_USERID"), num_workouts = 20, joins = "", dictionary = list("numeric" = c("v2_total_video_buffering_seconds", "v2_total_video_watch_time_seconds")), parse_dates = TRUE, ...) {
  if (userid == "") stop("Provide a userid or set an environmental variable `PELOTON_USERID`", call. = FALSE)
  if (length(joins) > 1 || !is.character(joins)) stop("Provide joins as a length one character vector", call. = FALSE)

  # see if joins is provided, if so, append to request
  if (joins != "") joins <- glue::glue("joins={joins}")

  workouts <- peloton_api(glue::glue("/api/user/{userid}/workouts?{joins}&limit={num_workouts}&page=0"), ...)
  n_workouts <- length(workouts$content$data)
  # v2_total_video_buffering_seconds v2_total_video_watch_time_seconds
  if (n_workouts > 0) {
    workouts <- purrr::map_df(1:n_workouts, ~ parse_list_to_df(workouts$content$data[[.]], dictionary = dictionary, parse_dates = parse_dates))

    # IF JOIN PARAM is specified, get data out for ride list and add it to that row
    if (joins != "") {
      rides <- purrr::map_df(1:n_workouts, function(x) {
        parse_list_to_df(stats::setNames(workouts$ride[[x]], paste0("ride_", names(workouts$ride[[x]]))), dictionary = dictionary, parse_dates = parse_dates, ...)
      })

      dplyr::left_join(
        dplyr::mutate(workouts, rn = dplyr::row_number()),
        dplyr::mutate(rides, rn = dplyr::row_number()),
        by  = "rn"
      ) %>%
        dplyr::select(-.data$rn)
    } else {
      workouts
    }
  }
}



#' Makes a request against the \code{api/workout/workout_id} endpoint
#'
#'
#' Returns data about individual workouts. A vectorized function, so accepts multiple \code{workoutIDs} at once.
#'
#' @export
#' @param workout_ids WorkoutIDs
#' @param dictionary A named list. Maps a data-type to a column name. If \code{NULL} then no parsing is done
#' @param parse_dates Whether to try and guess which columns are dates and convert
#' @param ... Other arguments passed on to methods
#' @examples
#' \dontrun{
#' get_workouts_data(
#'   workout_ids = workout_ids,
#'   dictionary = list(
#'     "numeric" = c(
#'       "v2_total_video_watch_time_seconds", "v2_total_video_buffering_seconds",
#'       "v2_total_video_watch_time_seconds", "leaderboard_rank"
#'     ),
#'     "list" = c("achievement_templates")
#'   )
#' )
#' }
get_workouts_data <- function(workout_ids, dictionary = list(
                                "numeric" = c(
                                  "v2_total_video_watch_time_seconds", "v2_total_video_buffering_seconds", "leaderboard_rank"
                                ),
                                "list" = c("achievement_templates")
                              ), parse_dates = TRUE, ...) {
  purrr::map_df(workout_ids, function(workout_id) {
    resp <- peloton_api(path = glue::glue("api/workout/{workout_id}"), ...)$content
    parse_list_to_df(list = resp, dictionary = dictionary, parse_dates = parse_dates)
  })
}
