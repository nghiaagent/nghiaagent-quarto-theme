-- Put each SVG figure into the page itself instead of an <img>. An SVG shown
-- through <img> cannot load anything, so a web font it imports (svglite's
-- web_fonts) never arrives; inline, the figure uses the fonts the page loads.
-- Runs after Quarto has built figures, captions and cross-references.

local function read_file(path)
  local f = io.open(path, "r")
  if f == nil then
    return nil
  end
  local text = f:read("a")
  f:close()
  return text
end

local function escape_attr(text)
  return (text:gsub("&", "&amp;"):gsub('"', "&quot;"):gsub("<", "&lt;"))
end

function Image(img)
  if not quarto.doc.is_format("html") or not img.src:match("%.svg$") then
    return nil
  end
  -- Leave remote images and images that opt out as they are
  if img.src:match("^%a+://") or img.classes:includes("no-inline") then
    return nil
  end

  local dir = pandoc.path.directory(quarto.doc.input_file)
  local svg = read_file(pandoc.path.join({ dir, img.src }))
  if svg == nil then
    return nil
  end

  -- The XML declaration is not valid inside HTML
  svg = svg:gsub("^%s*<%?xml[^>]*>%s*", "")

  -- Keep the image's classes so the theme can style the figure, and its alt
  -- text for screen readers (a Quarto figure is already described by its
  -- caption, so its alt text is usually empty)
  local classes = { "inline-figure" }
  for _, class in ipairs(img.classes) do
    table.insert(classes, class)
  end
  local attrs = string.format('<svg class="%s" role="img" ', table.concat(classes, " "))
  local alt = pandoc.utils.stringify(img.caption)
  if alt ~= "" then
    attrs = attrs .. string.format('aria-label="%s" ', escape_attr(alt))
  end
  svg = svg:gsub("<svg ", function()
    return attrs
  end, 1)

  return pandoc.RawInline("html", svg)
end
