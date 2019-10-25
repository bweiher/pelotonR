# pelotonR

<!-- badges: start -->
<!-- badges: end -->

The goal of `pelotonR` is to provide an `R` interface into the Peloton data API. The package handles authentication, response parsing, and provides helper functions to find and extract data from the most important endpoints.  

## Installation

Currently on [Github](https://github.com/bweiher/pelotonR) only. Install with:

``` r
devtools::install_github("bweiher/pelotonR")
```

## Examples

#### __Authenticating__:

You need to set environmental variables or `PELOTON_LOGIN` and `PELOTON_PASSWORD` or provide them in this initial step, which must be run before you can issue other queries. 

``` r
library(pelotonR)
peloton_auth()

```

Making queries -- most useful endpoints already have `get_` functions to retrieve and parse the responses. You can also query other endpoints using `peloton_api` in case new ones are introduced, as in the commented out sections below. 

#### __Interacting__:

To get your `user_id`, which also either needs to be supplied or read from an environmental variable, `PELOTON_USERID`.

```r
# get data about yourself
me <- get_my_info() # peloton_api("api/me")
user_id <- me$id
```

It can then be used against the `workouts` endpoint, to fetch your workout ids:

```r
# get a list of your workouts
workouts <- get_all_workouts(user_id) # peloton_api("api/user_id/workouts")
workout_ids <- workouts$id

```

The final two endpoints contain your performance graphs and other workout data:

```r
# get performance graph data
# vectorized function
get_performance_graphs(workout_ids) # peloton_api(api/workout/workout_id/performance_graph")

# get other workout data
# vectorized function
get_workouts_data(workout_ids) # peloton_api(api/workout/workout_id/")

```
#### __Future__

A fancy Shiny dashboard and some algorithm to help optimize your fitness
