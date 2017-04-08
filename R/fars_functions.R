#' Read csv file
#'
#' This function reads a csv file, zipped or unzipped, and stores it in a tibble.
#'
#' @parameter filename A character string indicating the name of the csv file to be read
#'
#' @return This function returns a tibble.
#'
#' @note This functions throws an error if the file does not exist.
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @examples
#' \dontrun{
#' setwd(system.file("extdata", package = "fars"))
#' fars_read("accident_2013.csv.bz2")
#' }
#'
#' @export
fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Make filename
#'
#' This function makes a filename based on a \code{year}.
#'
#' @parameter year A numeric value or character string indicating the year
#'
#' @return This function returns a character string with a filename including the year.
#'
#' @note This functions throws a warning if the input cannot be converted to an integer.
#'       The year can be a string, but all characters must be digits.
#'
#' @examples
#' make_filename(2013)
#' make_filename("2015")
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Extract months and years
#'
#' This function reads csv files for given \code{years}, extracts their months, and adds a column with the years.
#'
#' @parameter years A numeric or character value or vector indicating the year(s)
#'
#' @return This function returns a tibble with the columns MONTH and year.
#'
#' @note This functions throws a warning if a file for the given year does not exist.
#'
#' @importFrom dplyr mutate select
#' @importFrom magrittr "%>%"
#'
#' @examples
#' \dontrun{
#' setwd(system.file("extdata", package = "fars"))
#' fars_read_years(2013:2016)
#' }
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Count months and years
#'
#' This function reads csv files for given \code{years}, extracts the months, and counts them for each year.
#'
#' @inheritParams fars_read_years
#'
#' @return This function returns a tibble with the months in the first column
#'         and the counts for the different years in the remaining columns.
#'
#' @note This functions throws a warning if a file for the given year does not exist.
#'
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#' @importFrom magrittr "%>%"
#'
#' @examples
#' \dontrun{
#' setwd(system.file("extdata", package = "fars"))
#' fars_summarize_years(2013:2016)
#' }
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Map accidents
#'
#' This function maps the point locations of accidents for a given state (\code{state.num}) and \code{year}.
#'
#' @parameter state.num A numeric value indicating the state number
#' @inheritParams make_filename
#'
#' @return This function returns a plot with the state boundaries and the point locations of accidents.
#'
#' @note This functions throws an error if a file for a given year does not exist
#'       or if a state is not contained in the dataset.
#'
#' @importFrom dplyr filter
#' @import maps
#'
#' @examples
#' \dontrun{
#' setwd(system.file("extdata", package = "fars"))
#' fars_map_state(24, 2014)
#' fars_map_state(39, 2013)
#' }
#'
#' @export
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
