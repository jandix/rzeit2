#' @title Client for the ZEIT ONLINE Content API
#' @description Interface to gather newspaper articles from DIE ZEIT and ZEIT ONLINE,
#' based on a multilevel query. A personal API key is required for usage.
#' @name rzeit2
#' @docType package
#' @references \url{http://developer.zeit.de}
#' @seealso \code{\link{get_content}} to expose a search in the ZEIT online archive,
#' \code{\link{get_content_all}} to get all results using \code{get_content},
#' \code{\link{get_client}} to get client information
#'
#' @importFrom stringr str_detect
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom anytime iso8601
#' @importFrom httr parse_url
#' @importFrom httr build_url
#' @importFrom httr GET
#' @importFrom httr http_type
#' @importFrom httr content
#' @importFrom httr http_error
#' @importFrom httr status_code
#' @importFrom httr parse_url
#' @importFrom httr add_headers
#' @importFrom utils txtProgressBar
#' @importFrom utils setTxtProgressBar
#' @importFrom openssl md5
#' @importFrom jsonlite fromJSON
#' @importFrom utils download.file
#'
#' @aliases rzeit2 rzeit2-package
NULL
