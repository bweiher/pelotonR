# pelotonR

<!-- badges: start -->
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

The goal of `pelotonR` is to provide an `R` interface into the Peloton data API. The package handles authentication, response parsing, and provides helper functions to find and extract data from the most important endpoints.  

## Installation

Currently on [Github](https://github.com/bweiher/pelotonR) only. Install with:

``` r
devtools::install_github("bweiher/pelotonR")
```

## Examples

#### __Authenticating__:

You need to set environmental variables: `PELOTON_LOGIN` and `PELOTON_PASSWORD`, or provide them in this initial step, which must be run before you can issue other queries. 

``` r
library(pelotonR)
peloton_auth()

```

Most useful endpoints already have functions starting with `get_`  that retrieve and parse the API responses, and handle iteration through a list of inputs. You can also query other endpoints using `peloton_api` in case new ones are introduced. You can see how that works in the commented out portions below.

#### __Interacting__:

There are several endpoints where you need to already know some piece of information to get that particular data. 

For example, to list workouts, you will need your `user_id`, which you can get from the `api/me` endpoint. 

Either supply it or set it as an environmental variable, `PELOTON_USERID`:

```r
# get data about yourself
me <- get_my_info() # peloton_api("api/me")
user_id <- me$id
```
It can then be used against the `workouts` endpoint, to fetch your `workout_id`'s:

```r
# get a list of your workouts
workouts <- get_all_workouts(user_id) # peloton_api("api/$USER_ID/workouts")
```

Sometimes the data types returned for certain fields across rides will differ, throwing an error. Since new fields may be introduced, it is possible for you to specify data types if any errors pop up. 

```r
workouts <- get_all_workouts(
userid = user_id,
dictionary = list(
"numeric" = c("v2_total_video_buffering_seconds", "v2_total_video_watch_time_seconds")
)
)


workout_ids <- workouts$id

```

The final two endpoints contain your performance graphs and other workout data. You need to provide `workout_id`'s here, but each function accepts multiple at once:

```r
# get performance graph data
# vectorized function
pg <- get_performance_graphs(workout_ids, dictionary =
 list("list" = c("seconds_since_pedaling_start", "segment_list"))) # peloton_api("api/workout/$WORKOUT_ID/performance_graph")

# get other workout data
# vectorized function

get_workouts_data(workout_ids = workout_ids,
                  dictionary = list(
                    'numeric' =  c("v2_total_video_watch_time_seconds", "v2_total_video_buffering_seconds",
                                   "v2_total_video_watch_time_seconds", "leaderboard_rank"),
                    'list' = c('achievement_templates')
                  ))


```

### 

