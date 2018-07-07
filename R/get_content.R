#' Content endpoint
#'
#' Exposes a search in the ZEIT online archive on the content endpoint and returns results for the given query.
#'
#' @param query character. Search query term.
#' @param limit integer. The number of results given back. Please use \code{\link{get_content_all}} if the limit exceeds 1000 rows.
#' @param offset integer. Offset for the list of matches.
#' @param sort character. Sort search result by various fields. For example: \code{sort=release_date asc, uuid desc}.
#' @param begin_date character. Begin date - Restricts responses to results with publication dates of the date specified or later. In the form YYYYMMDD.
#' @param end_date character. End date - Restricts responses to results with publication dates of the date specified or earlier. In the form YYYYMMDD.
#' @param api_key character. The personal api code. To request an API key see: \url{http://developer.zeit.de/quickstart/} This parameter is by default set to the R Environment.
#'
#' @details \code{get_content} is the function, which interacts directly with the ZEIT Online API. I only used the content endpoint for this package. There are further endpoints (e.g. /author, /product) not included into this package to further specify the search if needed. The whole list of possible endpoints can be accessed here \url{http://developer.zeit.de/docs/}.
#'
#' @return A list including articles and meta information about the query.
#'
#' @references \url{http://developer.zeit.de}
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @seealso \code{\link{get_content_all}}
#'
#' @examples
#' \dontrun{
#' get_content(query = "Merkel")
#' }
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

    query = paste0(query ," AND release_date:[", begin ," TO ", end, "]")
  }

  # define query
  query <- list(
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
  response <- httr::GET(url, httr::add_headers("X-Authorization" = api_key))

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

is.zeit_api_content <- function(x) inherits(x, "zeit_api_content")

print.zeit_api_content <- function(x) {
  cat(format("ZEIT ONLINE CONTENT ENDPOINT\n\n"))
  cat(format(paste("Number of Articles", "\n")))
  cat(format(paste("  Found:", x$meta$found, "\n")))
  cat(format(paste("  Limit:", x$meta$limit, "\n")))
  cat(format(paste("  Offset:", x$meta$offset, "\n")))
  cat(format(paste("Time Period:", min(x$content$release_date), "-", max(x$content$release_date), "\n")))
  cat(format(paste("URL:", x$meta$url, "\n")))
}
