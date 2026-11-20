#| packages:
#|   - testthat
#|   - xml2

library(testthat)
library(xml2)

test_dir <- getwd()
book_dir <- file.path(test_dir, "_book")
index_file <- file.path(book_dir, "index.html")
tables_file <- file.path(book_dir, "01_tables.html")
viz_file <- file.path(book_dir, "02_visualizations.html")

describe("nghiaagent-quarto-theme book output verification", {

  it("produces a valid book structure with all chapters", {
    expect_true(file.exists(index_file), info = "index.html must exist in _book/")
    expect_true(file.exists(tables_file), info = "01_tables.html must exist in _book/")
    expect_true(file.exists(viz_file), info = "02_visualizations.html must exist in _book/")
  })

  html_index <- read_html(index_file)
  html_tables <- read_html(tables_file)
  html_viz <- read_html(viz_file)

  it("renders both TOC columns (left sidebar navigation and right in-page TOC)", {
    sidebar <- xml_find_all(html_index, "//*[@id='quarto-sidebar']")
    expect_gt(length(sidebar), 0, label = "Left sidebar navigation (#quarto-sidebar)")

    toc <- xml_find_all(html_index, "//*[@id='TOC']")
    expect_gt(length(toc), 0, label = "Right in-page TOC (#TOC)")
  })

  # Extract inline styles and linked compiled Bootstrap bundles
  style_nodes <- xml_find_all(html_index, "//style")
  inline_styles <- paste(xml_text(style_nodes), collapse = "\n")

  link_nodes <- xml_find_all(html_index, "//link[@rel='stylesheet']")
  links_href <- xml_attr(link_nodes, "href")
  valid_links <- links_href[file.exists(file.path(book_dir, links_href))]
  linked_css <- vapply(valid_links, function(f) {
    p <- file.path(book_dir, f)
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

  it("contains real rendered gt and reactable tables in 01_tables.html", {
    gt_tables <- xml_find_all(html_tables, ".//table[contains(@class, 'gt_table')]")
    expect_gt(length(gt_tables), 0, label = "gt table elements")

    reactable_nodes <- xml_find_all(html_tables, ".//*[contains(@class, 'reactable') or contains(@class, 'Reactable')]")
    expect_gt(length(reactable_nodes), 0, label = "reactable elements")
  })

  it("contains real rendered ggplot2 and plotly figures in 02_visualizations.html", {
    figures <- xml_find_all(html_viz, ".//img[contains(@class, 'figure-img')]")
    expect_gt(length(figures), 0, label = "ggplot2 figure images")

    plotly_nodes <- xml_find_all(html_viz, ".//*[contains(@class, 'plotly') or contains(@class, 'js-plotly-plot')]")
    expect_gt(length(plotly_nodes), 0, label = "plotly widget elements")
  })
})
