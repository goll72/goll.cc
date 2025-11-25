#import "@preview/zero:0.5.0": set-num

#import "url.typ": url
#import "meta.typ": meta, meta-dictionary


// Utility functions
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



#let page(meta: meta(), content) = context {
  let lang-map = (
    "en": [🇺🇸],
    "pt": [🇧🇷]
  )

  let langs = lang-map.keys()

  // Even though we use `/en/` so this case can be treated without
  // extra conditionals, we always use no prefix for english pages
  let current-lang = langs
    .map(it => "/" + it)
    .filter(it => url() == it or url().starts-with(it + "/"))
    .at(0, default: "/en/")
    .slice(1, 3)

  if current-lang == "pt" {
    set-num(decimal-separator: ",")
  }

  set document(..meta)
  set text(lang: current-lang)

  if target() == "html" {
    // Returns a pretty-printable difference between paths `from` and `target`.
    // Prepends absolute paths with `~`.
    // 
    // Used in the navigation bar site sections list.
    let pretty-path-difference(from, target) = {
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
    
    // (n-backlinks: int, footnotes: array(footnote), backlinks: array(array(int)))
    let footnotes = state("footnotes", (0, (), ()))

    // Returns the same path, but without a language prefix
    let remove-lang(path) = {
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
    let with-lang(path, lang) = {
      if lang == "en" {
        remove-lang(path)
      } else {
        "/" + lang + (if path == "/" { "" } else { path })
      }
    }


    let path = url()
    let path-no-lang = remove-lang(path)

    let nav-sections = ("/", "/blog", "/misc")


    set quote(block: true)
    set math.lr(size: 115%)

    set raw(theme: "themes/fleet-dark.tmTheme")

    // We need to have a numbering function so that `counter(heading)`
    // works, but we don't actually want to display heading numberings
    set heading(numbering: (..) => [])

    // Level 1 headings are only used for the page title
    show heading.where(level: 1): set heading(outlined: false)

    // Adds numbering to headings when they are displayed on
    // the outline and discards the first level of numbering
    show outline.entry: it => context {
      if it.element.func() == heading {
        let c = counter(heading).at(it.element.location())

        link(it.element.location())[
          #numbering("1.", ..c.slice(1))
          #it.body()
        ]
      } else {
        it
      }
    }

    show math.equation: it => context {
      if target() == "html" {
        // Wrap frames of inline equations in a box
        // so they don't interrupt the paragraph
        show: if it.block { it => it } else { box }
        html.elem("span", attrs: (class: "typst-math"), html.frame(it))
      } else {
        it
      }
    }

    // We will need this while Typst doesn't add native support
    // for footnotes when using a custom show-rule with HTML export
    show footnote: it => {
      if type(it.body) == label {
        it = query(it.body).first()
      }
      
      footnotes.update(old => {
        let (n, old-fn, old-backlinks) = old
        let pos = old-fn.position(x => x == it)

        // If this is a new footnote, add it to the array of footnotes
        if pos == none {
          (n + 1, (..old-fn, it), (..old-backlinks, (n + 1,)))
        } else {
          old-backlinks.at(pos).push(n + 1)
          (n + 1, old-fn, old-backlinks)
        }
      })

      // Number of backlinks in total up to this point
      let (n, ..) = footnotes.get()
      // Number of footnotes up to this point 
      let k = counter(footnote).at(it.location()).at(0) 

      html.elem("sup", attrs: (id: "fnref" + str(n + 1)),
        html.a(href: "fn" + str(k),
          numbering(it.numbering, k)
        )
      )
    }


    html.html(lang: current-lang, {
      html.head({
        html.meta(charset: "utf-8")
        html.meta(name: "viewport", content: "width=device-width, initial-scale=1")

        if "description" in meta {
          html.meta(name: "description", content: content-to-string(meta.description))
        }

        html.link(rel: "icon", href: "/assets/favicon.png")
        html.link(rel: "stylesheet", type: "text/css", href: "/styles.css")

        html.title(content-to-string(meta.title))
      })

      html.body({
        // Navigation bar
        html.header({
          html.elem("div", attrs: (id: "site-name"), [goll.cc])

          // Sections list
          html.elem("div", attrs: (id: "site-sections"),
            html.ul(
              for section in nav-sections {
                html.li({
                  html.a(href: with-lang(section, current-lang), pretty-path-difference(path-no-lang, section))
                })
              }
            )
          )

          // Other languages this page is available in
          let alternatives = langs
            .filter(lang => lang != current-lang)
            .map(lang => (lang, with-lang(path-no-lang, lang)))
            .filter(it => {
              let (_, path) = it
              path in meta-dictionary
            })

          if alternatives.len() > 0 {
            html.elem("div", attrs: (id: "alt-langs"),
              for (lang, alt) in alternatives {
                html.a(href: alt, lang-map.at(lang))
              }
            )
          }
        })
    
        content

        // Footnotes
        context {
          let (n, footnotes, backlinks) = footnotes.get()

          if n > 0 {
            line()
  
            html.elem("section", attrs: (class: "footnotes"),
              html.ol({
                for (fn, backlinks) in footnotes.zip(backlinks) {
                  html.li({
                    fn.body

                    for backlink-idx in backlinks {
                      html.a(href: "#fnref" + str(backlink-idx), [↩])
                    }
                  })
                }
              })
            )
          }
        }
      })
    })
  } else {
    content
  }
}

#let article(it) = context {
  if target() == "html" {
    html.article(it)
  } else {
    it
  }
}
