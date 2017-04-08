library(testthat)
library(fars)

# devtools::test()

context("Test fars package")

test_that("Test filename", expect_that(make_filename(2013), equals("accident_2013.csv.bz2")))
