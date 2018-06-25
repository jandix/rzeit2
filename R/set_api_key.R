#'@title Set api key to the .Renviron
#'
#'@description Function to set you API Key to the R environment when starting using \code{rzeit} package. Attention: You should only execute this functions once.
#'
#'@param api_key character. The personal api code. To request an API key see: \url{http://developer.zeit.de/quickstart/}
#'@param path character. Path where the enviornment is stored. Default is the normalized path.
#'
#'@return None.
#'
#'@author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#'@export

set_api_key <- function(api_key,
                        path = paste(normalizePath("~/"), ".Renviron", sep = "/")) {

  # check if an environment file exists
  if (!file.exists(path)) file.create(path)

  # read environment file
  env_file <- readLines(path, encoding = "UTF-8")

  # setup key variable
  key <- paste0("TEST=", api_key)

  # add api key
  env_file <- c(env_file, key)

  # write environment file
  writeLines(env_file, path)
}
