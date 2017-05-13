
test_that("fars pkg tests", {
  expect_that(fars_summarize_years(2013:2015), is_a("data.frame"))
})
