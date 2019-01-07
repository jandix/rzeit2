#' Content endpoint (all)
#'
#' Exposes a search in the ZEIT online archive on the content endpoint and returns results for the given query. Performs multiple queries if limit exceeds 1000 rows.
#'
#' @param query character. Search query term.
#' @param timeout integer. Seconds to wait between queries.
#' @param begin_date begin_date character. Begin date - Restricts responses to results with publication dates of the date specified or later. In the form YYYYMMDD.
#' @param end_date character. End date - Restricts responses to results with publication dates of the date specified or earlier. In the form YYYYMMDD.
#' @param api_key api_key character. The personal api code. To request an API key see: \url{http://developer.zeit.de/quickstart/} This parameter is by default set to the R Environment.
#'
#' @details \code{get_content} is the function, which interacts directly with the ZEIT Online API. I only used the content endpoint for this package. There are further endpoints (e.g. /author, /product) not included into this package to further specify the search if needed. The whole list of possible endpoints can be accessed here \url{http://developer.zeit.de/docs/}.
#'
#' @return A list including articles and meta information about the query.
#'
#' @references \url{http://developer.zeit.de}
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @seealso \code{\link{get_content}}
#'
#' @examples
#' \dontrun{
#' get_content(query = "Merkel")
#'  }
#'
#' @export


# fetch all articles
get_content_all <- function(query,
                            timeout = 2,
                            begin_date = NULL,
                            end_date = NULL,
                            api_key = Sys.getenv("ZEIT_ONLINE_KEY")) {

  # set limit to default
  limit <- 1000

  # fetch first block
  initial_response <- get_content(query = query,
                                  begin_date = begin_date,
                                  end_date = end_date,
                                  api_key = api_key,
                                  limit = limit,
                                  offset = 0)

  # if more than 1000 articles exist define loop
  if (initial_response$meta$found > 1000) {

    # check if response is a thousands
    if (initial_response$meta$found %% limit == 0) {
      to <- limit * round(initial_response$meta$found / limit + 1)
    } else {
      to <- initial_response$meta$found
    }

    # define offsets
    offsets <- seq(from = limit, to = to, by = limit)

    # set progress bar
    pb <- utils::txtProgressBar(min = 0, max = to, style = 3)

    for (offset in offsets) {

      try (
        # get reponse with offset
        response <- get_content(query = query,
                                begin_date = begin_date,
                                end_date = end_date,
                                api_key = api_key,
                                limit = limit,
                                offset = offset)
      )

      # join new conent and initial response data
      initial_response$content <- rbind(initial_response$content, response$content)

      # update progress bar
      utils::setTxtProgressBar(pb, offset)

      # sleep to avoid rate limit
      Sys.sleep(timeout)
    }
  }

  # define return object
  initial_response$meta$limit <- initial_response$meta$found
  initial_response
}
