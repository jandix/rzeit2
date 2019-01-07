## ----install github, warning = FALSE, results = "hide", message = FALSE, eval = FALSE----
#  devtools::install_github("jandix/rzeit2")

## ----loading rzeit, warning = FALSE, results = "hide", message = FALSE, eval = FALSE----
#  library(rzeit2)

## ----set key, warning = FALSE, message = FALSE, eval = FALSE-------------
#  set_api_key(api_key = "set_your_api_key_here",
#              path = tempdir())

## ----get content, warning = FALSE, message = FALSE, eval = FALSE---------
#  articles_merkel <- get_content("Merkel",
#                                 limit = 100,
#                                 begin_date = "20180101",
#                                 end_date = "20180520")

## ----get content all, warning = FALSE, message = FALSE, eval = FALSE-----
#  articles_merkel <- get_content_all("Merkel",
#                                     timeout = 1,
#                                     begin_date = "20150101",
#                                     end_date = "20180520")

## ----get client, warning = FALSE, message = FALSE, eval = FALSE----------
#  get_client()

