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
