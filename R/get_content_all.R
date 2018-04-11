#' Query content endpoint
#'
#' @param query
#' @param timeout
#' @param begin_date
#' @param end_date
#' @param api_key
#'
#' @examples
#' get_content_all(query = "Merkel")
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
    pb <- txtProgressBar(min = 0, max = to, style = 3)

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
      setTxtProgressBar(pb, offset)

      # sleep to avoid rate limit
      Sys.sleep(timeout)
    }
  }

  # define return object
  initial_response$meta$limit <- initial_response$meta$found
  initial_response
}
