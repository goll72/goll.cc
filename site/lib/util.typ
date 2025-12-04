#let content-to-string(it) = {
  if type(it) == str {
    it
  } else if type(it) != content {
    str(it)
  } else if it.has("text") {
    it.text
  } else if it.has("children") {
    it.children.map(content-to-string).join()
  } else if it.has("body") {
    content-to-string(it.body)
  } else if it == [ ] {
    " "
  }
}
 
#let align(alignment, content) = context {
  if target() != "html" {
    return std.align(alignment, content)
  }
  
  if alignment == none {
    return content
  }
  
  let text-align = if alignment == none or alignment.x == left {
    "left"
  } else if alignment.x == center {
    "center"
  } else {
    "right"
  }

  html.elem("div", attrs: (style: "text-align: " + text-align + ";"), content)
}

#let line(length: none) = context {
  assert(
    length == none or type(length) == ratio,
    message: "length must be a ratio"
  )
  
  if target() != "html" {
    return std.line(length: length)
  }

  if length == none {
    html.elem("hr")
  } else {
    // Hack to extract percentage value
    html.elem("hr", attrs: (style: "width: " + str((100pt * length).pt()) + "%;"))
  }
}

#let mono-diagram(content) = context {
  if target() == "html" {
    align(center,
      html.elem("div", attrs: (class: "mono"), html.frame[ #v(1em) #content #v(1em) ])
    )
  } else {
    content
  }
}
