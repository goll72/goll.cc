#import "deps.typ": zero

#import "lib/util.typ": content-to-string
#import "lib/common/index.typ": h-rule

#import zero: set-num

#let typ(path) = "/pages" + path + ".typ" 

#let page(path, content, outlined: false) = context {
  let normalized-path = if path.ends-with("/") {
    path.slice(0, -1)
  } else {
    path
  }
  
  let lang-map = (
    "en": [🇺🇸],
    "pt": [🇧🇷]
  )

  let default-lang = "en"
  let langs = lang-map.keys()

  let (current-lang, path-without-lang) = path
    .match(regex("^(?:/(\w{2}))?(/.*)/?$"))
    .captures

  if current-lang == none {
    current-lang = default-lang
  }

  if path-without-lang == none {
    path-without-lang = "/"
  }

  [
    #document(normalized-path + "/index.html", {
      if current-lang == "pt" {
        set-num(decimal-separator: ",")
      }

      set text(lang: current-lang)

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

      // Returns the same path, but without a language prefix
      let remove-lang-prefix(path) = {
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
      let add-lang-prefix(path, lang) = {
        if lang == default-lang {
          remove-lang-prefix(path)
        } else {
          "/" + lang + (if path == "/" { "" } else { path })
        }
      }

      let nav-sections = ("/", "/blog", "/misc")

      set quote(block: true)
      set raw(theme: "themes/fleet-dark.tmTheme")

      show math.equation: set text(font: "STIX Two Math")

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

      counter(heading).update(0)
    
      // (n-backlinks: int, footnotes: array(footnote), backlinks: array(array(int)))
      let footnotes = state("footnotes", (0, (), ()))
      footnotes.update((0, (), ()))

      // XXX: We will need this while Typst doesn't add native support
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
          html.a(href: "#fn" + str(k),
            numbering(it.numbering, k)
          )
        )
      }

      html.html(lang: current-lang, {
        html.head({
          html.meta(charset: "utf-8")
          html.meta(name: "viewport", content: "width=device-width, initial-scale=1")

          if document.description != none {
            html.meta(name: "description", content: content-to-string(document.description))
          }

          html.link(rel: "icon", href: "/assets/favicon.png")
          html.link(rel: "stylesheet", type: "text/css", href: "/styles.css")

          if document.title != none {
            html.title(content-to-string(document.title))
          }

          // XXX: add opengraph attributes
        })

        html.body({
          // Navigation bar
          html.header({
            html.elem("div", attrs: (id: "site-name"), [goll.cc])

            // Sections list
            html.elem("div", attrs: (id: "site-sections"),
              html.ul(
                for section-path in nav-sections {
                  html.li({
                    html.a(
                      href: add-lang-prefix(section-path, current-lang),
                      pretty-path-difference(path-without-lang, section-path)
                    )
                  })
                }
              )
            )

            // Other languages this page is available in
            let alts = lang-map
              .keys()
              .filter(it => it != current-lang)
              .map(it => (it, add-lang-prefix(path-without-lang, it)))
              .filter(((alt-lang, alt-path)) => query(label(alt-path)).len() > 0)
            
            for (alt-lang, alt-path) in alts {
              html.elem("div", attrs: (id: "alt-langs"),
                html.a(href: alt-path, lang-map.at(alt-lang))
              )
            }
          })

          if outlined {
            outline(target: selector(heading).within(here()))
          }

          content

          // Footnotes
          context {
            let (n, footnotes, backlinks) = footnotes.get()

            if n > 0 {
              html.elem("div", attrs: (class: "footnote-rule"), h-rule())
  
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
    }) #label(path)
  ]
}
