#' Query content endpoint
#'
#' @param query
#' @param limit
#' @param offset
#' @param sort
#' @param begin_date
#' @param end_date
#' @param api_key
#'
#' @examples
#' get_content(query = "Merkel")
#'
#' @export

## define helper function to fetch meta data
get_content <- function (query,
                         limit = 10,
                         offset = 0,
                         sort = "release_date asc",
                         begin_date = NULL,
                         end_date = NULL,
                         api_key = Sys.getenv("ZEIT_ONLINE_KEY")) {

  # define base_url
  base_url <- "http://api.zeit.de/content"

  # stop if larger than limit
  if (limit > 1000) {
    stop("Cannot fetch more than 1000 articles. Please use rzeit2::get_content_all().", call. = FALSE)
  }

  # parse date
  if (!is.null(begin_date) && !is.null(end_date)) {
    begin_date <- as.Date(begin_date, format="%Y%m%d")
    begin <- anytime::iso8601(begin_date)
    begin <- paste0(begin, "T00:00:00Z")

    end_date <- as.Date(end_date, format="%Y%m%d")
    end <- anytime::iso8601(end_date)
    end <- paste0(end_date, "T23:59:59.999Z")

    query = paste0("\"", query ,"\" AND release_date:[", begin ," TO ", end, "]")
  }

  # define query
  query <- list(
    api_key = api_key,
    q = query,
    sort = sort,
    limit = limit,
    offset = offset
  )

  # build final url
  url <- httr::parse_url(base_url)
  url$query <- query
  url <- httr::build_url(url)

  # get data
  response <- httr::GET(url)

  # check if successful
  if (httr::http_type(response) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  # parse result
  parsed <- jsonlite::fromJSON(httr::content(response, "text"))

  # check if http error
  if (httr::http_error(response)) {
    stop(
      sprintf(
        "ZEIT ONLINE API request failed [%s]\n%s",
        httr::status_code(response),
        parsed$description
      ),
      call. = FALSE
    )
  }

  # define url without key
  url <- httr::parse_url(url)
  url$query$api_key <- NULL
  url <- httr::build_url(url)

  # define return object
  structure(
    list(
      content = parsed$matches,
      meta = list(
        found = parsed$found,
        limit = parsed$limit,
        offset = parsed$offset,
        url = url,
        begin_date = begin_date,
        end_date = end_date
      )
    ),
    class="zeit_api_content"
  )
}
