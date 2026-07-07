#import "common/index.typ": h-rule

// (n-backlinks: int, footnotes: array(footnote), backlinks: array(array(int)))
#let footnote-init = (0, (), ())

#let track-footnote = it => {
  if type(it.body) == label {
    it = query(it.body).first()
  }

  let footnotes = state("footnotes", footnote-init)

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

#let show-footnotes() = {
  let footnotes = state("footnotes", footnote-init)
  let (n, footnotes, backlinks) = footnotes.get()

  if n == 0 {
    return
  }

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
