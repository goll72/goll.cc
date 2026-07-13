#let icon-links(path: none) = {
  if path == none {
    path = state("path").get()
  }
  
  let normalized-path = if path.ends-with("/") {
    path.slice(0, -1)
  } else {
    path
  }
  
  let icon-link(path, href: "#", alt: none) = {
    html.elem("a", attrs: (class: "mono", href: href),
      html.elem("svg", attrs: (width: "32", height: "32"),
        html.elem("use", attrs: (href: path))
      )
    )
  }

  html.elem("span", attrs: (class: "icon-links"), {
    html.span({
      icon-link("/assets/icons/github.svg#icon",
        href: "https://github.com/goll72"
      )
      icon-link("/assets/icons/gitlab.svg#icon",
        href: "https://gitlab.com/goll72"
      )
    })
    
    html.span({
      icon-link("/assets/icons/cc.svg#icon",
        href: "https://creativecommons.org",
        alt: "Creative Commons"
      )
      icon-link("/assets/icons/cc-zero.svg#icon",
        href: "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
        alt: "This site is under the CC0"
      )
    })

    html.span({
      
      icon-link("/assets/icons/rss.svg#icon",
        href: normalized-path + "/feed.xml"
      )

    })
  })
}
