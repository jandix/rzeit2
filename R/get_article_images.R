#' Get article images
#'
#' Get the article images for a single url or a vector of urls.
#'
#' @param url character. A single character string or character vector.
#' @param timeout integer. Seconds to wait between queries.
#' @param download character. Path to download folder. If path is set to \code{NULL} images are not downloaded.
#' @details \code{get_article_images} is the function, which fetches and parses meta information for each image of an article and downloads the images. This function may break in the future due to layout changes on the ZEIT ONLINE website.
#'
#' @return A data frame including meta information for each image.
#'
#' @author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#' @examples
#' \dontrun{
#' url <- paste0("https://www.zeit.de/kultur/film/2018-04/",
#' "tatort-frankfurt-unter-kriegern-obduktionsbericht")
#' get_article_images(url = url, timeout = 0)
#' }
#'
#' @export


get_article_images <- function (url,
                                timeout = 0,
                                download = NULL) {

  # test if valid zeit online url
  test_url <- stringr::str_detect(url, "http(s)?://(www.)?zeit.de/.+")
  if (!all(test_url)) {
    stop("Please provide valid ZEIT ONLINE URL(s).", call. = FALSE)
  }

  # define helper function
  get_images <- function (url,
                          timeout,
                          download) {

    # get article document
    article <- get_article(url)

    # get all articles images
    img <- rvest::html_nodes(article$article, "img.article__media-item")
    # parse article image text
    img_alt <- rvest::html_attr(img, "alt")
    # parse article image source url
    img_src <- rvest::html_attr(img, "src")

    # parse caption
    caption_text <- rvest::html_nodes(article$article, ".figure__caption .figure__text")
    caption_text <- rvest::html_text(caption_text)

    # parse copyright
    caption_copyright <- rvest::html_nodes(article$article, ".figure__caption .figure__copyright")
    caption_copyright <- rvest::html_text(caption_copyright)

    # hash source url
    md5 <- openssl::md5(img_src)

    if (length(img) > 0) {
      # paste images data frame
      images <- data.frame(
        article_url = url,
        image_url = img_src,
        image_alt = img_alt,
        image_caption = caption_text,
        image_copyright = caption_copyright,
        image_path = paste0(md5, ".jpeg"),
        zeit_plus = article$zeit_plus,
        stringsAsFactors = F
      )

      # download images if a path is provided
      if (!is.null(download)) {
        for (i in 1:nrow(images)) {
          # reuse source url hash as file name
          file_name <- paste(download, images$image_path[i], sep = "/")
          # download and save image
          download.file(images$image_url[i], file_name, mode = "wb", quiet = T)
        }
      }
    } else {
      # paste images data frame
      images <- data.frame(
        article_url = url,
        image_url = NA,
        image_alt = NA,
        image_caption = NA,
        image_copyright = NA,
        image_path = NA,
        zeit_plus = article$zeit_plus,
        stringsAsFactors = F
      )
    }

    # timeout if provided
    Sys.sleep(timeout)

    # return images data frame
    images
  }

  # initialize progressbar
  pb <- txtProgressBar(min = 0, max = length(url), style = 3)

  # apply function to all urls
  for (i in 1:length(url)) {
    if (!exists("images")) {
      images <- get_images(url[i], timeout, download)
    } else {
      images <- rbind(images, get_images(url[i], timeout, download))
    }
    setTxtProgressBar(pb, i)
  }
  images
}
