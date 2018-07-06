#'@title Set api key to the .Renviron
#'
#'@description Function to set you API Key to the R environment when starting using \code{rzeit} package. Attention: You should only execute this functions once.
#'
#'@param api_key character. The personal api code. To request an API key see: \url{http://developer.zeit.de/quickstart/}
#'@param path character. Path where the environment is stored. Default is the normalized path.
#'
#'@return None.
#'
#'@examples
#'\dontrun{
#'# this is not an actual api key
#'api_key <- "5t5yno5qqkufxis5q2vzx26vxq2hqej9"
#'set_api_key(api_key, tempdir())
#'}
#'@author Jan Dix <\email{jan.dix@@uni-konstanz.de}>
#'
#'@export

set_api_key <- function(api_key,
                        path = stop("Please specify a path.")) {

  # check if an environment file exists
  if (!file.exists(path)) file.create(path)

  # read environment file
  env_file <- readLines(path, encoding = "UTF-8")

  # setup key variable
  key <- paste0("ZEIT_ONLINE_KEY=", api_key)

  # add api key
  env_file <- c(env_file, key)

  # write environment file
  writeLines(env_file, path)

  # send success message
  message <- paste("Your api key was successfully appended to your .Renviron.",
                   "Please restart the session to automatically load the key.",
                   sep = "\n")
  message(message)
}
