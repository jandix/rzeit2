#' Get article comments
#'
#' Get the article comments for a single url.
#'
#' @param url character. A single character string or character vector.
#' @param timeout integer. Seconds to wait between queries.
#' @details \code{get_article_comments} is the function, which fetches and parses article comments. This function may break in the future due to layout changes on the ZEIT ONLINE website.
#'
#' @section Warning:
#' Please use that function carefully because it uses a lot of HTTP requests. The extensive usage of this function may
#' result in the blocking of IP.
#'
#' @return A list with comments and their respective replies. If the content lies beyond the paywall
#' the function returns "[ZEIT PLUS CONTENT] You need a ZEIT PLUS account to access this content.".
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @examples
#' \dontrun{
#' url <- paste0("https://www.zeit.de/kultur/film/2018-04/",
#' "tatort-frankfurt-unter-kriegern-obduktionsbericht")
#' get_article_comments(url = url)
#' }
#'
#' @export

get_article_comments <- function (url,
                                  timeout = NULL) {

  # test if valid zeit online url
  test_url <- stringr::str_detect(url, "http(s)?://(www.)?zeit.de/.+")
  if (!all(test_url)) {
    stop("Please provide valid ZEIT ONLINE URL(s).", call. = FALSE)
  }

  # define helper function to extract comment information
  extract_comment_details <- function (comment) {
    lapply(comment, function (comment) {
      if (length(comment) <= 0) return(NA)
      # parse comment text
      comment_text <- rvest::html_nodes(comment, ".comment__body p")
      comment_text <- rvest::html_text(comment_text)
      comment_text <- paste(comment_text, collapse = "")
      # parse comment author
      comment_author <- rvest::html_node(comment, ".comment-meta__name")
      comment_author <- rvest::html_text(comment_author)
      comment_author <- stringr::str_replace_all(comment_author, "\\n", "")
      comment_author <- stringr::str_trim(comment_author)
      # parse ids
      comment_parent_id <- rvest::html_attr(comment, "data-ct-row")
      comment_parent_id <- as.integer(comment_parent_id)
      comment_child_id <- rvest::html_attr(comment, "data-ct-column")
      comment_child_id <- as.integer(comment_child_id)
      # parse cid
      comment_cid <- rvest::html_attr(comment, "id")
      comment_cid <- stringr::str_extract(comment_cid, "\\d+")
      # return comment object
      structure(
        list(
          cid = comment_cid,
          parent_id = comment_parent_id,
          child_id = comment_child_id,
          author = comment_author,
          text = comment_text,
          replies = NA
        ),
        class = "zeit_api_comment"
      )
    })
  }

  # define helper function to extract main comments and their replies
  get_replies <- function (comment, page) {
    # paste url
    comment_url <- paste0(url, "/comment-replies")
    comment_url <- httr::parse_url(comment_url)
    query <- list(
      cid = comment$cid,
      page = page,
      local_offset = comment$parent_id - 1
    )
    comment_url$query <- query
    comment_url <- httr::build_url(comment_url)
    # fetch comment replies
    response <- httr::GET(comment_url)
    # parse comment replies
    comment_replies <- httr::content(response, as = "text")
    comment_replies <- xml2::read_html(comment_replies)
    comment_replies <- rvest::html_nodes(comment_replies, "article.comment")
    comment_replies <- extract_comment_details(comment_replies)
    # return comment object
    structure(
      list(
        cid = comment$cid,
        parent_id = comment$parent_id,
        child_id = comment$child_id,
        author = comment$author,
        text = comment$text,
        replies = comment_replies
      ),
      class = "zeit_api_comment"
    )
  }

  # define helper function to fetch comments on each page
  get_comments_per_page <- function (article, page) {
    # get main comments
    comments <- rvest::html_nodes(article$article, "article.comment[data-ct-column=\"0\"]")
    parent_comments <- extract_comment_details(comments)
    # get replies
    complete_comments <- lapply(parent_comments, get_replies, page)
    complete_comments
  }

  # get article document
  article <- get_article(url = url, multiple_required = F)

  # extract number of comment pages
  pages <- rvest::html_nodes(article$article, ".comment-section__headline small")
  pages <- rvest::html_text(pages)
  pages <- stringr::str_extract(pages, "(\\d){1,3}$")
  pages <- as.integer(pages)

  # initialize progressbar
  pb <- txtProgressBar(min = 0, max = pages, style = 3)

  # fetch comments on the first page
  comments <- get_comments_per_page(article, 1)
  setTxtProgressBar(pb, 1)

  # apply function to all comment pages
  for (page in 2:pages) {
    # parse comment page url
    page_url <- httr::parse_url(url)
    query <- list(
      page = page
    )
    page_url$query <- query
    page_url <- httr::build_url(page_url)
    # get article
    article <- get_article(page_url, multiple_required = F)
    # parse comments
    comments <- c(comments, get_comments_per_page(article, page))
    # timeout
    if (!is.null(timeout)) {
      Sys.sleep(timeout)
    }
    # update progress bar
    setTxtProgressBar(pb, page)
  }
  comments

}
