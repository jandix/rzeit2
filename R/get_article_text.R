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
#' \dontrun{
#' url <- paste0("https://www.zeit.de/kultur/film/2018-04/",
#' "tatort-frankfurt-unter-kriegern-obduktionsbericht")
#' get_article_text(url = url)
#' }
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

  # define helper function
  get_text <- function (url, timeout) {

    # get article document
    article <- get_article(url)

    if (!article$zeit_plus) {
      # extract article text
      nodes <- rvest::html_nodes(article$article, ".article-page p")
      html <- rvest::html_text(nodes)
      text <- paste(html, collapse = " ")
      # define return object
      return(text)
    } else {
      # return placeholder
      return("[ZEIT PLUS CONTENT] You need a ZEIT PLUS account to access this content.")
    }
  }

  # initialize progressbar
  pb <- txtProgressBar(min = 0, max = length(url), style = 3)

  # apply function to all urls
  for (i in 1:length(url)) {
    if (!exists("texts")) {
      texts <- get_text(url[i], timeout = timeout)
    } else {
      texts <- c(texts, get_text(url[i], timeout = timeout))
    }
    setTxtProgressBar(pb, i)
  }
  texts
}
