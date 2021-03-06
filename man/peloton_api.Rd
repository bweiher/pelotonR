% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/peloton_api.R
\name{peloton_api}
\alias{peloton_api}
\title{Makes a \code{GET} request against one of Peloton's API endpoints}
\usage{
peloton_api(path, print_path = FALSE, ...)
}
\arguments{
\item{path}{API endpoint to query}

\item{print_path}{Show path/endpoint queried}

\item{...}{Additional parameters passed onto methods}
}
\description{
Users need not invoke this method directly and may instead use one of the wrappers around specific endpoints that also vectorizes inputs and processes the data returned, such as \code{\link{get_my_info}},  \code{\link{get_performance_graphs}}, \code{\link{get_all_workouts}}, \code{\link{get_workouts_data}}
}
\examples{
\dontrun{
peloton_auth()
peloton_api("api/me")
}

}
