--- svg-image-to-pdf.lua – filter to replace svg filename by pdf ones

if FORMAT:match 'latex' or FORMAT:match 'beamer' then
  function Image (elem)
     elem.src = elem.src:gsub("%.svg$", ".pdf")
     return elem
  end
end
