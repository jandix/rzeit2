#'@title Client status and API usage
#'
#'@description \code{get_cleint} returns API access status and usage.
#'
#'@param api character. The personal api code. To request an API key see: \url{http://developer.zeit.de/quickstart/} This parameter is by default set to the R Environment.
#'
#'@return a list of information about the client and API usage
#'@author Jan Dix (\email{jan.dix@@uni-konstanz.de})
#'
#'@export
#'
#'@examples get_client()

# catch client data
get_client <- function(api_key = Sys.getenv("ZEIT_ONLINE_KEY")) {

  # define base_url
  base_url <- "http://api.zeit.de/client"

  # define query
  query <- list(
    api_key = api_key
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

  # return
  parsed
}
