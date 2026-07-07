#import "h-rule.typ": h-rule

#let page-list(..args) = context {
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
      
      == #link(it, doc.title)
      #doc.description
    ]
  ))

  list-items.join(h-rule())
}
