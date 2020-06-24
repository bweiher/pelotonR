#' Requests complete Rider, Instructor, and Workout Information
#'
#' @param userid userID
#' @param num_workouts  Number of workouts requested
#' @param tz Timezone to convert times into
#'
#' @return A tibble of all rider, instructor, and workout information
#' @example
#' \dontrun{
#' get_rider_information(userID = "ID", num_workouts = 20, tz = "America/New_York)
#' }
#'
#' @examples
get_rider_information <- function(userid = Sys.getenv("PELOTON_USERID"), num_workouts = 20, tz = "America/New_York"){
  if (userid == "") stop("Provide a userid or set an environmental variable `PELOTON_USERID`", call. = FALSE)
  workouts <- peloton_api(path = glue::glue("/api/user/{userid}/workouts?joins=ride,ride.instructor&limit={num_workouts}&page=0"))
  n_workouts <- length(workouts$content$data)

  workout_df <- function(workout_number, all_my_workouts = workouts$content){
    ride_info <-
      tibble(
        created_at = purrr::pluck(all_my_workouts$data, workout_number, "created_at"),
        device_type = purrr::pluck(all_my_workouts$data, workout_number, "device_type"),
        end_time = purrr::pluck(all_my_workouts$data, workout_number, "end_time"),
        fitness_discipline = purrr::pluck(all_my_workouts$data, workout_number, "fitness_discipline"),
        is_total_work_personal_record = purrr::pluck(all_my_workouts$data, workout_number, "is_total_work_personal_record"),
        id = purrr::pluck(all_my_workouts$data, workout_number, "id"),
        name = purrr::pluck(all_my_workouts$data, workout_number, "name"),
        start_time = purrr::pluck(all_my_workouts$data, workout_number, "start_time"),
        ride_description = purrr::pluck(all_my_workouts$data, workout_number, "ride", "description"),
        ride_difficulty_rating_avg = purrr::pluck(all_my_workouts$data, workout_number, "ride", "difficulty_rating_avg"),
        ride_difficulty_rating_count = purrr::pluck(all_my_workouts$data, workout_number, "ride", "difficulty_rating_count"),
        ride_duration = purrr::pluck(all_my_workouts$data, workout_number, "ride", "duration"),
        ride_fitness_discipline = purrr::pluck(all_my_workouts$data, workout_number, "ride", "fitness_discipline"),
        ride_id = purrr::pluck(all_my_workouts$data, workout_number, "ride", "id"),
        ride_is_explicit = purrr::pluck(all_my_workouts$data, workout_number, "ride", "is_explicit"),
        ride_is_live_in_studio_only = purrr::pluck(all_my_workouts$data, workout_number, "ride", "is_live_in_studio_only"),
        ride_location = purrr::pluck(all_my_workouts$data, workout_number, "ride", "location"),
        ride_overall_rating_avg = purrr::pluck(all_my_workouts$data, workout_number, "ride", "overall_rating_avg"),
        ride_overall_rating_count = purrr::pluck(all_my_workouts$data, workout_number, "ride", "overall_rating_count"),
        # ride_rating = purrr::pluck(all_my_workouts$data, workout_number, "ride", "rating"),
        ride_title = purrr::pluck(all_my_workouts$data, workout_number, "ride", "title"),
        # ride_total_ratings = purrr::pluck(all_my_workouts$data, workout_number, "ride", "total_ratings"),
        ride_total_in_progress_workouts = purrr::pluck(all_my_workouts$data, workout_number, "ride", "total_in_progress_workouts"),
        ride_total_workouts = purrr::pluck(all_my_workouts$data, workout_number, "ride", "total_workouts"),
        ride_difficulty_estimate = purrr::pluck(all_my_workouts$data, workout_number, "ride", "difficulty_estimate"),
        ride_overall_estimate = purrr::pluck(all_my_workouts$data, workout_number, "ride", "overall_estimate")
      )

    if(!is.null(purrr::pluck(all_my_workouts$data, workout_number, "ride", "instructor_id"))){
      instructor_info <-
        tibble::tibble(
          ride_instructor_id = purrr::pluck(all_my_workouts$data, workout_number, "ride", "instructor_id"),
          instructor_bio = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor","bio"),
          instructor_short_bio = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "short_bio"),
          instructor_coach_type = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "coach_type"),
          instructor_background = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "background"),
          instructor_twitter_profile = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "twitter_profile"),
          instructor_name = purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "name"),
          instructor_fitness_disciplines =   purrr::pluck(all_my_workouts$data, workout_number,"ride","instructor", "fitness_disciplines") %>% str_c(collapse = "\n")
        )

      ride_info <- bind_cols(ride_info,instructor_info)
    }
    return(ride_info)
  }

  df <-
    purrr::map(1:n_workouts,~workout_df(workout_number = .x, all_my_workouts = workouts$content)) %>%
    dplyr::bind_rows()

  output <-
    df %>%
    mutate::mutate(dplyr::across(.cols = c(tidyselect::contains("time"),tidyselect::contains("created")), .fns = ~as.POSIXct(.x, origin = "1970-01-01", tz)))

  return(output)
}
