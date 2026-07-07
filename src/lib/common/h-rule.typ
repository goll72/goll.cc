#let h-rule(length: none) = context {
  if target() != "html" {
    return std.line(length: length)
  }

  if length == none {
    html.elem("hr")
  } else {
    html.elem("hr", attrs: (style: "width: " + str(int(100 * float(length))) + "%;"))
  }
}

