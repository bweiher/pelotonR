library(glue)
library(dplyr)
library(lubridate)
library(httr)
library(purrr)

#  ---- function to query API endpoint(s) -----

peloton_api <- function(path){
  
  ua <- httr::user_agent("https://github.com/bweiher/pelotonR")
  login <- Sys.getenv("PELOTON_LOGIN")
  pass <-  Sys.getenv("POLOTON_PASSWORD")
  
  if(login == '' || pass == ''){
    stop("Set environmental variables for your login ('PELOTON_LOGIN') and password ('POLOTON_PASSWORD')", call. = FALSE)
  } else {
    auth <- httr::authenticate(login, pass)  
  }
  
  url <-  glue::glue("https://api.onepeloton.com/api/{path}")
  
  print(url)
  
  resp <- httr::GET(url = url, auth, ua)
  
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }
  
  parsed <- jsonlite::fromJSON(content(resp, "text", encoding = "UTF-8"), simplifyVector = FALSE)
  
  
  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "Peloton API request failed [%s]\n%s\n<%s>", 
        httr::status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
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
  str(x$content)
  invisible(x)
}



 # ----- ENDPOINTS  -----
 

#  ------ ME ------
res <- peloton_api("me")


me <- tibble(
  username = res$content$username,
  user_id = res$content$id,
  email =  res$content$email,
  total_workouts = res$content$total_workouts ,
  created_at = lubridate::as_datetime(res$content$created_at)
)


id <- me$user_id

# ---- GET ALL WORKOUTS ------


workouts <- peloton_api(path = glue::glue("user/{id}/workouts"))

# loop through workouts and grab data associated with each one ... 
workouts_parsed <- map_df(1:length(workouts$content$data), function(workout){
  
  this_workout <- workouts$content$data[[workout]]
  m <- as.data.frame(matrix(nrow=1L,ncol = length(names(this_workout)))) 
  m <- setNames(m, names(this_workout))
  
  for(column in 1:ncol(m)){
    val <- this_workout[[column]]
    if(is.null(val)) val <- NA_character_
    m[column] <- val
  }
  
  as_tibble(m) %>% 
    mutate(
      device_time_created_at = as_datetime(device_time_created_at, tz =timezone),
      start_time =  as_datetime(start_time,tz=timezone),
      created = as_datetime(created,tz=timezone),
      created_at = as_datetime(created_at,tz=timezone),
      end_time = as_datetime(end_time,tz=timezone)
    )
  
})


# ----- GET A SPECIFIC WORKOUT ------
# granular ride data ismissing..
workout_id <- slice(workouts_parsed,1)$id

workout <- peloton_api(path = glue::glue("workout/{workout_id}"))
content(workout$content)
workout <- peloton_api(path = glue::glue("user/{id}/workouts?joins=ride&limit=10&page=0"))


workout <- peloton_api(path = glue::glue("workout/{workout_id}/performance_graph?every_n=5"))




