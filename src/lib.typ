#import "deps.typ": zero

#import "lib/util.typ": content-to-string, pretty-path-difference,
#import "lib/lang.typ": lang-map, langs, default-lang, add-lang-prefix, remove-lang-prefix, extract-lang
#import "lib/foot.typ": track-footnote, show-footnotes, footnote-init
#import "lib/tags.typ": add-tags

#import zero: set-num

#let host = "goll.cc"

#let typ(path) = "/pages" + path + ".typ" 

#let page(path, content, outlined: false, published: none, updated: none, tags: ()) = context {
  let normalized-path = if path.ends-with("/") {
    path.slice(0, -1)
  } else {
    path
  }

  let (current-lang, path-without-lang) = extract-lang(path)
  
  let date-regex = regex("(\d{4})-(\d{2})-(\d{2})")
  let date-parse = ((y, m, d)) => datetime(year: int(y), month: int(m), day: int(d))
  
  let to-datetime = it => if type(it) == str {
    date-parse(it.match(date-regex).captures)
  } else {
    it
  }

  let published = to-datetime(published)
  let updated = to-datetime(updated)

  if published != none and updated != none and published > updated {
    panic("`updated` date cannot be lower than `published` date: " + path)
  }

  let tags = if type(tags) == str {
    (tags,)
  } else {
    tags
  }

  [
    #state("published").update(published)
    #state("updated").update(updated)

    #add-tags(path, tags)

    #document(normalized-path + "/index.html", {
      if current-lang == "pt" {
        set-num(decimal-separator: ",")
      }

      set text(lang: current-lang)

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
      state("footnotes").update(footnote-init)

      // XXX: We will need this while Typst doesn't add native support
      // for footnotes when using a custom show-rule with HTML export
      show footnote: track-footnote

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

            html.elem("meta", attrs: (property: "og:title", content: content-to-string(document.title)))
            html.elem("meta", attrs: (property: "og:type", content: "website"))
            html.elem("meta", attrs: (property: "og:url", content: "https://" + host + path))
            html.elem("meta", attrs: (property: "og:image", content: "https://" + host + "/assets/favicon.png"))
          }
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

          html.article(content)

          context show-footnotes()
        })
      })
    }) #label(path)
  ]
}
