# pelotonR

<!-- badges: start -->

[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)

<!-- badges: end -->

`pelotonR` provides an `R` interface into the Peloton data API. The package handles authentication, response parsing, and provides helper functions to find and extract data from the most important endpoints.

## Installation

Currently on [Github](https://github.com/bweiher/pelotonR) only. Install with:

``` r
devtools::install_github("bweiher/pelotonR")
```

## Overview

#### **Authentication**

You need to set environmental variables: `PELOTON_LOGIN` and `PELOTON_PASSWORD`, or provide them in this initial step, which must be run before you can issue other queries.

``` r
library(pelotonR)
peloton_auth()
```

#### Data Available

The main endpoints already have their own helper function that helps parse the response into a `tibble` and iterate through multiple inputs if necessary.

You can also query other endpoints using `peloton_api` in case new ones are introduced, or if the automatic parsing fails.

The table below documents each endpoint along with its `R` counterpart, and provides a description of what data is there:

| endpoint                                 | function                   | endpoint description                     |
|------------------------------------------|----------------------------|------------------------------------------|
| api/me                                   | `get_my_info()`            | info about you                           |
| api/workout/workout_id/performance_graph | `get_performance_graphs()` | time series metrics for individual rides |
| api/workout/workout_id                   | `get_workouts_data()`      | data about rides                         |
| api/user/user_id/workouts                | `get_all_workouts()`       | lists **n** workouts                     |

You can show which endpoint (and arguments) are being passed on under the hood by setting the `print_path` to `TRUE` in any of the `get_` functions or in the `peloton_api` function directly.

#### Queries

There are a couple endpoints where you need to already know some piece of information to get that particular data.

For example, to list workouts, you will need your `user_id`, which you can get from the `api/me` endpoint.

Either supply it or set it as an environmental variable, `PELOTON_USERID`:

``` r
# get data about yourself
me <- get_my_info() # peloton_api("api/me")
user_id <- me$id
```

It can then be used against the `workouts` endpoint, to fetch your `workout_id`'s:

``` r
# get a list of your workouts
workouts <- get_all_workouts(user_id) # peloton_api("api/$USER_ID/workouts")
workout_ids <- workouts$id
```

The final two endpoints contain your performance graphs and other workout data. You need to provide `workout_id`'s here, but each function accepts multiple at once:

``` r
# get performance graph data
# vectorized function
pg <- get_performance_graphs(workout_ids) # peloton_api("api/workout/$WORKOUT_ID/performance_graph")

# get other workout data
# vectorized function

wd <- get_workouts_data(workout_ids = workout_ids)
```

------------------------------------------------------------------------

#### :x:***Errors*** :x:

Sometimes the data types returned for particular fields will differ across rides, resulting in an error, like below:

    #> Error: Can't combine `..1$v3_custom_column_name` <integer> and `..10$v3_custom_column_name` <character>.

Each function provides a dictionary of mappings for a few fields that have been identified as being problematic like `v3_custom_column_name` above.

If the defaults fail, you can override (*just be sure to also look at the what the function has set by default).*

In the hypothetical previous error the `v3_custom_column_name` column had an issue:

``` r
# fix for error 
workouts <- get_all_workouts(
userid = user_id,
dictionary = list(
"numeric" = c("v3_custom_column_name")
)
)
```

You can coerce fields to one of (`character`, `numeric`, or `list`) if you see an error pop up.
