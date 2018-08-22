#' Get article comments
#'
#' Get the article comments for a single url.
#'
#' @param url character. A single character string or character vector.
#' @param timeout integer. Seconds to wait between queries.
#' @param simplify logical. If true the function returns a data frame else it returns a nested list.
#' @param id character. You can provide your own id for each article. If is null the function uses the md5
#' hash of the url to create one.
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
                                  id = NULL,
                                  simplify = FALSE,
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
      # parse stars
      comment_stars <- rvest::html_node(comment, ".js-comment-recommendations")
      if (length(comment_stars) > 0) {
        comment_stars <- rvest::html_text(comment_stars)
        comment_stars <- stringr::str_trim(comment_stars)
        comment_stars <- as.integer(comment_stars)
      } else {
        comment_stars <- 0
      }
      # parse date


      # parse ids
      comment_parent_id <- rvest::html_attr(comment, "data-ct-row")
      comment_parent_id <- as.integer(comment_parent_id)
      comment_child_id <- rvest::html_attr(comment, "data-ct-column")
      comment_child_id <- as.integer(comment_child_id)
      # parse cid
      comment_cid <- rvest::html_attr(comment, "id")
      comment_cid <- stringr::str_extract(comment_cid, "\\d+")
      comment_cid <- as.integer(comment_cid)

      # return comment object
      structure(
        list(
          cid = comment_cid,
          parent_id = comment_parent_id,
          child_id = comment_child_id,
          author = comment_author,
          text = comment_text,
          stars = comment_stars,
          replies = NA
        ),
        class = "zeit_api_comment"
      )
    })
  }

  # define helper function to extract main comments and their replies
  get_replies <- function (comment, page, article) {
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
    comment_replies <- httr::content(response, "text")
    comment_replies <- paste("<html>", comment_replies, "</html>")
    comment_replies <- xml2::read_html(comment_replies)
    comment_replies <- rvest::html_nodes(comment_replies, "article.comment")
    comment_replies <- extract_comment_details(comment_replies)
    # get first comment
    query <- paste0("article.comment[data-ct-column=\"1\"][data-ct-row=\"", comment$parent_id ,"\"]")
    first_comment <- rvest::html_nodes(article$article, query)
    if (length(first_comment) > 0) {
      first_comment <- extract_comment_details(first_comment)
      # join replies
      comment_replies <- c(first_comment, comment_replies)
    }
    # return comment object
    structure(
      list(
        cid = comment$cid,
        parent_id = comment$parent_id,
        child_id = comment$child_id,
        author = comment$author,
        text = comment$text,
        stars = comment$stars,
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
    complete_comments <- lapply(parent_comments, get_replies, page, article)
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

  # return data frame
  if (simplify) {

    # create id
    if (is.null(id)) {
      id <- openssl::md5(url)
      id <- paste0("", id)
    }

    # create empty data frame
    comments_df <- data.frame(
      article_url = as.character(),
      article_id = as.character(),
      cid = as.integer(),
      parent_id = as.integer(),
      child_id = as.integer(),
      author = as.character(),
      text = as.character(),
      stars = as.integer(),
      stringsAsFactors = F
    )

    # helper function to add rows to the data frame
    add_row <- function (comment, df, url, id) {
      rbind(df, data.frame(
        article_url = url,
        article_id = id,
        cid = comment$cid,
        parent_id = comment$parent_id,
        child_id = comment$child_id,
        author = comment$author,
        text = comment$text,
        stars = comment$stars,
        stringsAsFactors = F
      ))
    }

    # add all comments to the data frame
    for (comment in comments) {
      comments_df <- add_row(comment, comments_df, url, id)
      for (subcomment in comment$replies) {
        comments_df <- add_row(subcomment, comments_df, url, id)
      }
    }

    return(comments_df)
  }

  # return nested list
  comments
}
