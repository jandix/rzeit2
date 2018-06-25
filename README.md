# rzeit2

[![Build Status](https://travis-ci.org/jandix/rzeit2.svg?branch=master)](https://travis-ci.org/jandix/rzeit2)

## Purpose / Description

Client for the ZEIT ONLINE Content API - Interface to gather newspaper articles from *DIE ZEIT* and *ZEIT ONLINE*, based on a multilevel query.

This package is a lightweight successor of the [rzeit](https://github.com/jandix/rzeit) package. The main functions are completly rewritten using `httr`. Additionally the package provides a new functionality to directly download article texts using web scraping. Old grouping and visualisation functions are removed and will probably rewritten in the future, too. 

## Status

The package is under development and will be extended with additional features in the future.

## Installation

```{r, eval=FALSE}
devtools::install_github("jandix/rzeit2")
```

## Authors

Jan Dix
[jan.dix@uni-konstanz.de](mailto:jan.dix@uni-konstanz.de)


Special thanks to [Simon Munzert](http://simonmunzert.github.io/), who helped me entering the world of R and GitHub.
