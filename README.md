# nghiaagent-quarto-theme

A clean, modern, and accessible Quarto HTML theme extension featuring Satoshi and JetBrains Mono typography, automatic light/dark mode switching (`flatly` / `darkly`), comprehensive table theming (`gt` and `reactable`), Positron-style figure inversion, and solid wide-column layout backgrounds.

---

## Features

- **Light & Dark Mode Switching**: Paired with `flatly` (light) and `darkly` (dark) themes, honoring system preferences (`respect-user-color-scheme: true`) with an interactive toggle switch.
- **Modern Typography**:
  - Display & Headings: [Satoshi](https://www.fontshare.com/fonts/satoshi) with refined tracking (`-0.015em`).
  - Body: Satoshi for crisp readability.
  - Code & Monospace: [JetBrains Mono](https://www.jetbrains.com/lp/mono/) across code blocks, inline snippets, tables, and widgets.
  - Pill styling for inline code in headings, breadcrumbs, TOC, and sidebars.
- **Table Theming**:
  - **`gt`**: Harmonized fonts, seamless dark mode with `#2d3238` header spanners, subtle row striping/hover, stubs, summary rows, and footnotes.
  - **`reactable`**: Full dark mode styling for containers, search inputs, column filters, pagination buttons, expanders, and selection controls.
- **Positron-Style Plot Inversion**:
  - Automatically inverts static plots, figures, tabset images, and Plotly widgets in dark mode with smooth CSS transitions (`invert(0.9) hue-rotate(180deg)`).
  - Use class `.no-invert` to exempt specific figures, microscopy images, or diagrams.
- **Solid Wide-Column Backgrounds**:
  - Prevents margin content and Table of Contents (TOC) bleed-through on wide sections (`.column-page`, `.column-page-inset`, `.column-screen`).
- **Additional Polish**:
  - Consistent callout blocks (`.callout-note`, `.callout-tip`, etc.).
  - Dark mode webkit scrollbars.
  - Text selection highlight accent.
  - Print styles disabling dark inversion and forcing high-contrast output.

---

## Installation

Inside any existing Quarto book, website, or document project:

```bash
quarto add nghiaagent/nghiaagent-quarto-theme
```

This will download the extension into your project's `_extensions/` folder without touching your existing documents or project configurations.

---

## Configuration

In your project's `_quarto.yml` (for books/websites) or document frontmatter:

```yaml
format:
  html:
    theme:
      light:
        - flatly
        - nghiaagent-quarto-theme
      dark:
        - darkly
        - nghiaagent-quarto-theme
    respect-user-color-scheme: true
    monofont: "JetBrains Mono"
    code-fold: true
```

Alternatively, you can use the contributed format name directly:

```yaml
format:
  nghiaagent-quarto-theme-html: default
```

---

## Updating

To pull the latest style improvements or bug fixes:

```bash
quarto update nghiaagent/nghiaagent-quarto-theme
```

---

## Usage Tips

### 1. Exempting Plots from Dark Mode Inversion
If you have a plot (e.g., heatmaps, histology, photography) that should look identical in light and dark modes, add the `.no-invert` class:

````markdown
::: {.no-invert}
```{r}
#| label: fig-microscopy
plot(image)
```
:::
````

### 2. Wide Tables and Tabsets
Use Quarto's column classes without worrying about transparent background overlap:

````markdown
::: {.column-page}
::: {.panel-tabset}

### Tab 1
```{r}
my_data |> gt()
```

### Tab 2
```{r}
my_data |> reactable()
```

:::
:::
````

---

## License

MIT License.
