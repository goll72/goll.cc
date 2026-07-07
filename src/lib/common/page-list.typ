#import "/lib/tags.typ": get-tags

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

      #let tags = get-tags(it)
      
      == #link(it, doc.title)
      #doc.description

      #if tags.len() > 0 {
        html.elem("div", attrs: (class: "tag-list"),
          for tag in tags {
            html.elem("div", [\##tag])
          }
        )
      }
    ]
  ))

  list-items.join(h-rule())

  if add-to-feed {
    state("feed-pages", ()).update(old => (..old, ..paths))
  }
}
