
<!-- README.md is generated from README.Rmd. Please edit that file -->
rzeit2
======

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active) [![Build Status](https://travis-ci.org/jandix/rzeit2.svg?branch=master)](https://travis-ci.org/jandix/rzeit2)

Purpose / Description
---------------------

Client for the ZEIT ONLINE Content API - Interface to gather newspaper articles from *DIE ZEIT* and *ZEIT ONLINE*, based on a multilevel query.

This package is a lightweight successor of the [rzeit](https://github.com/jandix/rzeit) package. The main functions are completly rewritten using `httr`. Additionally the package provides a new functionality to directly download article texts using web scraping. Old grouping and visualisation functions are removed and will probably also rewritten in the future.

Status
------

The package is under development and will be extended with additional features in the future.

Installation
------------

``` r
devtools::install_github("jandix/rzeit2")
```

Authors
-------

Jan Dix <jan.dix@uni-konstanz.de>

Acknowledgements
----------------

Special thanks to [Simon Munzert](http://simonmunzert.github.io/), who helped me entering the world of R and GitHub. Additionally, I would like to thank **Peter Meißner** and **Christian Graul** who helped with the first version of this package. Lastly, I would like to thank **Jana Blahak** who wrote the documentation for the first package which is widely reused.
