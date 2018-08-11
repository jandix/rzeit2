#' Get article text
#'
#' Get the article text for a single url or a vector of urls.
#'
#' @param url character. A single character string or character vector.
#' @param timeout integer. Seconds to wait between queries.
#' @details \code{get_article_text} is the function, which fetches and parses an article. This function may break in the future due to layout changes on the ZEIT ONLINE website.
#'
#' @return A named character vector with the respective text. If the content lies beyond the paywall
#' the function returns "[ZEIT PLUS CONTENT] You need a ZEIT PLUS account to access this content.".
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @examples
#' url <- paste0("https://www.zeit.de/kultur/film/2018-04/",
#' "tatort-frankfurt-unter-kriegern-obduktionsbericht")
#' get_article_text(url = url)
#'
#' @export

## define helper function to fetch meta data
get_article_text <- function (url,
                              timeout = NULL) {

  # test if valid zeit online url
  test_url <- stringr::str_detect(url, "http(s)?://(www.)?zeit.de/.+")
  if (!all(test_url)) {
    stop("Please provide valid ZEIT ONLINE URL(s).", call. = FALSE)
  }

  fetch_article <- function (url, timeout) {
    # define empty article
    article <- NULL

    # try to download article
    response <- httr::GET(url)

    # check if http error
    if (httr::http_error(response)) {
      stop(
        sprintf(
          "Article parse failed [%s]",
          httr::status_code(response)
        ),
        call. = FALSE
      )
    }

    # parse article
    article <- xml2::read_html(httr::content(response, "text"))

    if (has_multiple_pages(article)) {
      # adjust original url
      url <- paste0(url, "/komplettansicht")
      return(fetch_article(url, timeout = timeout))
    }

    # set timeout to avoid blocking
    if(!is.null(timeout)) {
      Sys.sleep(timeout)
    }

    # if found article then extract text
    if(!is.null(article)) {

      if (is_zeit_plus(article)) {
        # return ZEIT PLUS placeholder
        text <- "[ZEIT PLUS CONTENT] You need a ZEIT PLUS account to access this content."
      }
      else {
        # extract article text
        nodes <- rvest::html_nodes(article, ".article-page p")
        html <- rvest::html_text(nodes)
        text <- paste(html, collapse = " ")
      }

      # define return object
      return(text)
    } else {
      return(NA)
    }
  }

  # apply function to all urls
  sapply(url, try(fetch_article), timeout)
}
