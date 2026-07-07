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

// Returns a pretty-printable difference between paths `from` and `target`.
// Prepends absolute paths with `~`.
// 
// Used in the navigation bar site sections list.
#let pretty-path-difference(from, target) = {
  if from == target {
    return "."
  }

  if target == "/" {
    return "~"
  }

  let path = if from.starts-with(target) {
    let dotdot-count = from.slice(target.len()).matches(regex("[^/]+/?")).len()

    let path = ""

    for _ in range(0, dotdot-count) {
      path = path + "../"
    }

    path
  } else {
    "~" + target
  }

  if path.ends-with("/") {
    path.slice(0, -1)
  } else {
    path
  }
}

#let xml-escape(s) = {
  s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
}
