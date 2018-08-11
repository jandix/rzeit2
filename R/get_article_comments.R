get_article_comments <- function (url,
                                  timeout = NULL) {

  # test if valid zeit online url
  test_url <- stringr::str_detect(url, "http(s)?://(www.)?zeit.de/.+")
  if (!all(test_url)) {
    stop("Please provide valid ZEIT ONLINE URL(s).", call. = FALSE)
  }

  # define helper function
  get_comments <- function (url, timeout) {

    # get article document
    article <- get_article(url)

    # extract number of comment pages
    n_pages <- rvest::html_nodes(article, ".comment-section__headline small")
    n_pages <- rvest::html_text(n_pages)
    n_pages <- stringr::str_extract(n_pages, "(\\d){1,3}$")
    n_pages <- as.integer(n_pages)
  }
  # apply function to all urls
  sapply(url, try(get_comments), timeout)
}
