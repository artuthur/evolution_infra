--- center.lua – filter to center image on their line and div content
---
--- ideas from https://pandoc.org/lua-filters.html#center-images-in-latex-and-html-output
--- TODO : automatize that for images alone on a line (without the need to add a final backslash)

if FORMAT:match 'latex' or FORMAT:match 'beamer' then
  function Image (elem)
    if elem.classes:includes("center", 1) then
      return {
        pandoc.RawInline('latex', '\\centerline{'),
        elem,
        pandoc.RawInline('latex', '}')
      }
    else
      return elem
    end
  end
  function Div (elem)
    if elem.classes:includes("center", 1) then
      return {
        pandoc.RawBlock('latex', '\\begin{center}'),
        elem,
        pandoc.RawBlock('latex', '\\end{center}')
      }
    else
      return elem
    end
  end
end
