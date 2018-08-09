##----------------------------------------------------------------------------##
##                                  is_zeit_plus                              ##
##----------------------------------------------------------------------------##

#' Is ZEIT PLUS article
#'
#' @description Check if a given article is a ZEIT PLUS article (and not accessible without payment).
#'
#' @param article
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
#' @param article
#' @return logical
#' @importFrom rvest html_nodes
#' @keywords internal
#' @noRd

has_multiple_pages <- function () {

  # check if multiple pages
  nodes <- rvest::html_nodes(article, "a.article-toc__onesie")

  # return if ".article-toc__onesie" was found
  length(nodes) > 0
}
