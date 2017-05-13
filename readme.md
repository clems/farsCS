---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->




# farsCS 


## Overview

farsCS package gives some function to easily access and manipulate FARS data:

* `fars_summarize_years` returns Returns a month/year table with the number of fatalities for each month of each year.
* `fars_map_state` plots fatalities on a map for a state in a given year

## Installation


```r
# Install the package as usual:
install.packages("dplyr")
```

## Examples


```r
library(farsCS)

fars_summarize_years(2013:2015)
#> # A tibble: 12 × 4
#>   MONTH `2013` `2014` `2015`
#> * <int>  <int>  <int>  <int>
#> 1     1   2230   2168   2368
#> 2     2   1952   1893   1968
#> 3     3   2356   2245   2385
#> 4     4   2300   2308   2430
#> 5     5   2532   2596   2847
#> # ... with 7 more rows
```
```
