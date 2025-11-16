#import "/lib/lib.typ": line
#import "/lib/url.typ": url, join-url
#import "/lib/meta.typ": meta

#let page-list(..pages) = context {
  let c = counter(here())

  show: if target() == "html" {
    it => html.elem("ul", attrs: (class: "page-list"), it)
  } else {
    box
  }
  
  for ref in pages.pos() {
    c.step()
  
    let full-url = join-url(url(), ref)
    let metadata = meta(path: full-url)

    html.li[
      == #link(full-url, metadata.title)
      #metadata.description
    ]

    // No line after the last item in the list
    context if c.get().at(0) != c.final().at(0) {
      line()
    }
  }
}
