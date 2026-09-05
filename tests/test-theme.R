#| packages:
#|   - testthat
#|   - xml2

library(testthat)
library(xml2)

test_dir <- getwd()
html_file <- file.path(test_dir, "example.html")

describe("nghiaagent-quarto-theme output verification", {

  it("produces a valid non-empty HTML document", {
    expect_true(file.exists(html_file), info = "example.html must exist")
    expect_gt(file.info(html_file)$size, 1000)
  })

  html <- read_html(html_file)

  # Extract inline styles
  style_nodes <- xml_find_all(html, "//style")
  inline_styles <- paste(xml_text(style_nodes), collapse = "\n")

  # Extract linked styles (Bootstrap bundles where Quarto compiles theme SCSS)
  link_nodes <- xml_find_all(html, "//link[@rel='stylesheet']")
  links_href <- xml_attr(link_nodes, "href")
  valid_links <- links_href[file.exists(file.path(test_dir, links_href))]
  linked_css <- vapply(valid_links, function(f) {
    p <- file.path(test_dir, f)
    readChar(p, file.info(p)$size)
  }, character(1))

  all_styles <- paste(c(inline_styles, linked_css), collapse = "\n")

  it("loads the Satoshi font family", {
    has_satoshi <- grepl("satoshi", all_styles, ignore.case = TRUE) ||
                   any(grepl("satoshi", links_href, ignore.case = TRUE))
    expect_true(has_satoshi, info = "Satoshi font definition or import must be present")
  })

  it("configures JetBrains Mono for monospace typography", {
    expect_match(all_styles, "JetBrains Mono", fixed = TRUE, info = "JetBrains Mono should be defined in styles")
  })

  it("defines dark mode styling for gt tables", {
    expect_match(all_styles, "body.quarto-dark .gt_table", fixed = TRUE, info = "gt table dark mode styling must exist")
  })

  it("defines dark mode styling for reactable tables", {
    expect_match(all_styles, "body.quarto-dark .Reactable", fixed = TRUE, info = "reactable dark mode styling must exist")
  })

  it("applies Positron-style figure inversion in dark mode", {
    expect_match(all_styles, "hue-rotate(180deg)", fixed = TRUE, info = "Figure inversion filter must exist")
  })

  it("applies shaded pill backgrounds to inline code", {
    expect_match(all_styles, "code:not(pre code)", fixed = TRUE, info = "Inline code pill styling must exist")
  })

  it("contains real rendered gt, reactable, ggplot2, and plotly elements", {
    gt_tables <- xml_find_all(html, ".//table[contains(@class, 'gt_table')]")
    expect_gt(length(gt_tables), 0, label = "gt table elements")

    reactable_nodes <- xml_find_all(html, ".//*[contains(@class, 'reactable') or contains(@class, 'Reactable')]")
    expect_gt(length(reactable_nodes), 0, label = "reactable elements")

    figures <- xml_find_all(html, ".//img[contains(@class, 'figure-img')]")
    expect_gt(length(figures), 0, label = "ggplot2 figure images")

    plotly_nodes <- xml_find_all(html, ".//*[contains(@class, 'plotly') or contains(@class, 'js-plotly-plot')]")
    expect_gt(length(plotly_nodes), 0, label = "plotly widget elements")
  })
})
