#' Get article text
#'
#' Get the article text for a single url or a vector of urls.
#'
#' @param url character. a single character string or character vector.
#' @param timeout integer. Seconds to wait between queries.
#' @details \code{get_article_text} is the function, which fetches and parses an article. This function may break in the future due to layout changes on the ZEIT ONLINE website.
#'
#' @return A named character vector with the respective text.
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @examples
#' get_article_text(url = "http://www.zeit.de/kultur/film/2018-04/tatort-frankfurt-unter-kriegern-obduktionsbericht")
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

  fetch_article <- function (url) {
    # define empty article
    article <- NULL

    # try to download article
    try (
      article <- xml2::read_html(url)
    )

    # set timeout to avoid blocking
    if(!is.null(timeout)) {
      Sys.sleep(timeout)
    }

    # if found article then extract text
    if(!is.null(article)) {

      # extract article text
      nodes <- rvest::html_nodes(article, ".article-page p")
      html <- rvest::html_text(nodes)
      text <- paste(html, collapse = " ")

      # define return object
      return(text)
    } else {
      return(NA)
    }
  }

  # apply function to all urls
  sapply(url, fetch_article)
}
