#' Sentiment scores for 103 ZEIT ONLINE articles
#'
#' The dataset contains 103 articles returned by a query using the keyword "Merkel" between
#' 01st May and 31st May 2018. The sentiment scores are calculated using the Sentiment Worschatz
#' dictionary.
#'
#' @format A data frame with 103 rows and 3 variables:
#' \describe{
#'   \item{url}{the url of the article}
#'   \item{date}{the release date of the article}
#'   \item{score}{the calculated sentiment score}
#' }
#'
#' @seealso \code{\link{senti_ws}}
"sentiment_example"
