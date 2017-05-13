#' Read a fars file and return a data frame tbl
#'
#' A function to read comma separated values fars files.
#'
#' @param filename the name of the file to read (character)
#'
#' @return a data frame tbl
#'
#' @examples
#' \dontrun{fars_read("accident_2013.csv.bz2")
#' fars_read(make_filename(2013))}
#'
# #' @import dplyr
# #' @import readr
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

#' Fars file name for a given year
#'
#' \code{make_filename()} takes a year number and returns the name of the file containing
#' the fars data for this year.
#'
#' @param year the year of the fars data file (coerced to integer)
#'
#' @return a string
#'
#' @examples
#' make_filename(2013)
#'
#' @export
make_filename <- function(year) {
        year <- as.integer(year)
        system.file("extdata", sprintf("accident_%d.csv.bz2", year), package = "farsCS")
}

#' A helper function for \code{\link{fars_summarize_years}}
#'
#' Extracts month/year couples from each year in \code{years} and stores it in a list. Return
#' an error if year in \code{years} does not exist in the data.
#'
#' @param years a vector of integer specifying the years to extract
#'
#' @return a list of data frames
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' make_filename(2013)
#'
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

#' Number of fatalities by year and month
#'
#' Returns a month/year table with the number of fatalities for each month of each year.
#'
#' @param years a vector of integer specifying the years to tabulate.
#'
#' @return a data frame
#'
#' @examples
#' fars_summarize_years(2013:2015)
#'
#' @importFrom magrittr %>%
#'
#' @export
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}


#' Plot fatalities on a map
#'
#' \code{fars_map_state} plots fatalities on a map for a state in a given year
#'
#' @param state.num the number of the state to plot (coerced to integer).
#' @param year an integer representing the year to plot .
#'
#' @return None
#'
#' @examples
#' \dontrun{fars_map_state(2, 2015)}
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
