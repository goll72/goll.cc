#let lang-map = (
  "en": [🇺🇸],
  "pt": [🇧🇷]
)

#let default-lang = "en"

#let langs = lang-map.keys()

// Returns the same path, but without a language prefix
#let remove-lang-prefix(path) = {
  assert(path.at(0) == "/", message: "invalid path")

  if path.len() < 3 {
    return path
  }

  let valid-lang-root = path.slice(1, 3) in lang-map

  if valid-lang-root and path.len() == 3 {
    "/"
  } else if valid-lang-root and path.at(3, default: none) == "/" {
    path.slice(3)
  } else {
    path
  }
}

// Returns a path with the appropriate prefix for the given language 
#let add-lang-prefix(path, lang) = {
  if lang == default-lang {
    remove-lang-prefix(path)
  } else {
    "/" + lang + (if path == "/" { "" } else { path })
  }
}

#let date-fmt = (
  en: "[year]-[month]-[day]",
  pt: "[day]/[month]/[year]"
)
