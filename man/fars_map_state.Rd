% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fars_functions.R
\name{fars_map_state}
\alias{fars_map_state}
\title{Map accidents}
\usage{
fars_map_state(state.num, year)
}
\value{
This function returns a plot with the state boundaries and the point locations of accidents.
}
\description{
This function maps the point locations of accidents for a given state (\code{state.num}) and \code{year}.
}
\note{
This functions throws an error if a file for a given year does not exist
      or if a state is not contained in the dataset.
}
\examples{
\dontrun{
setwd(system.file("extdata", package = "fars"))
fars_map_state(24, 2014)
fars_map_state(39, 2013)
}

}
