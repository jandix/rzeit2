## Resubmission
This is a resubmission. In this version I have:

* excluded readme from build process
* moved ggplot2 from imports to suggested

## Resubmission
This is a resubmission. In this version I have:

* defined new helper functions
* declared a new function to scrape images from articles (get_article_images)
* declared a new function to scrape comments from articles (get_article_comments)
* updated the introduction vignette

## Resubmission
This is a resubmission. In this version I have:

* Added the ZEIT url to the description as suggested by the cran maintainers.

## Resubmission
This is a resubmission. In this version I have:

* Changed the default value for `path` in `set_api_key` as suggested by the cran maintainers.
* Moved the api_key authorization from url query to headers in `get_client` and `get_content`
* Updated the `get_article_text` to highlight paywall articles.
* Added an additional vignette to provide further examples.
* Added an additional example dataset for the mentioned vignette.

## Resubmission
This is a resubmission. In this version I have:

* Moved `set_api_key` into a `dontrun` block to avoid exectution during the checks as suggested by the maintainers.

## Test environments
* local ubuntu 18.04, R 3.5.1
* ubuntu 14.04 (on travis-ci), R 3.5.0
* win-builder (devel and release)

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs
