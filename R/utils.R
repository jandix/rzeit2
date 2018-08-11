##----------------------------------------------------------------------------##
##                                  fetch_article                             ##
##----------------------------------------------------------------------------##

#' Get ZEIT ONLINE article
#'
#' @description Download and process article.
#'
#' @param url character. A ZEIT ONLINE url.
#' @return xml_document. A list of class xml_document returned by \code{xml2::read_html}.
#' @importFrom rvest html_nodes
#' @importFrom httr GET
#' @importFrom httr http_error
#' @importFrom httr status_code
#' @importFrom httr content
#' @importFrom xml2 read_html
#' @keywords internal
#' @noRd

get_article <- function (url, multiple_required = TRUE) {

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

  # check if is zeit plus
  if (is_zeit_plus(article)) {
    return(list(
      article = article,
      zeit_plus = TRUE
    ))
  }

  if(has_multiple_pages(article) & multiple_required) {
    # adjust original url
    url <- paste0(url, "/komplettansicht")
    # refetch article url
    return(get_article(url))
  }

  list(
    article = article,
    zeit_plus = FALSE
  )
}

##----------------------------------------------------------------------------##
##                                  is_zeit_plus                              ##
##----------------------------------------------------------------------------##

#' Is ZEIT PLUS article
#'
#' @description Check if a given article is a ZEIT PLUS article (and not accessible without payment).
#'
#' @param article xml_document. A list of class xml_document returned by \code{xml2::read_html}.
#' @return logical
#' @importFrom rvest html_nodes
#' @keywords internal
#' @noRd

is_zeit_plus <- function (article) {

  # check if zeit plus content by looking for login screen
  nodes <- rvest::html_nodes(article, ".gate")

  # return if ".gate" was found
  length(nodes) > 0
}

##----------------------------------------------------------------------------##
##                                  has_multiple_pages                        ##
##----------------------------------------------------------------------------##

#' Has mutliple pages
#'
#' @description Check if a given article has multiple pages.
#'
#' @param article xml_document. A list of class xml_document returned by \code{xml2::read_html}.
#' @return logical
#' @importFrom rvest html_nodes
#' @keywords internal
#' @noRd

has_multiple_pages <- function (article) {

  # check if multiple pages
  nodes <- rvest::html_nodes(article, "a.article-toc__onesie")

  # return if ".article-toc__onesie" was found
  length(nodes) > 0
}
