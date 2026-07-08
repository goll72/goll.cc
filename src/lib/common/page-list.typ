#import "/lib/tags.typ": get-tags
#import "/lib/lang.typ": date-fmt

#import "h-rule.typ": h-rule

#let page-list(..args, add-to-feed: true) = context {
  show: if target() == "html" {
    it => html.elem("ul", attrs: (class: "page-list"), it)
  } else {
    box
  }

  let paths = args.pos()

  let list-items = paths.map(it => html.li(
    context [
      #let doc = query(label(it)).first(default: (
        title: [Untitled],
        description: [No description]
      ))

      #let published = state("published").at(label(it))
      #let updated = state("updated").at(label(it))

      #let date-fmt = date-fmt.at(text.lang)
      
      #let tags = get-tags(it)

      #html.elem("div", attrs: (class: "main-info"), {
        html.div[
          == #link(it, doc.title)
          #doc.description
        ]

        if published != none or updated != none {
          html.elem("div", attrs: (class: "date-info"), {
            if updated != none and updated != published {
              html.div[\+ #updated.display(date-fmt)]
            }

            if published != none {
              html.div[\* #published.display(date-fmt)]
            }
          })
        }
      })

      #if tags.len() > 0 {
        html.elem("div", attrs: (class: "tag-list"),
          for tag in tags {
            html.elem("div", [\##tag])
          }
        )
      }
    ]
  ))

  html.script(src: "/scripts/page-list.js", type: "module", async: true)

  list-items.join(h-rule())

  if add-to-feed {
    state("feed-pages", ()).update(old => (..old, ..paths))
  }
}
