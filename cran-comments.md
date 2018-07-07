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
* local ubuntu 18.04, R 3.5.0
* ubuntu 14.04 (on travis-ci), R 3.5.0
* win-builder (devel and release)

## R CMD check results
There were no ERRORs, WARNINGs or NOTEs
