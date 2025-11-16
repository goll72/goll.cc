#let icon-links() = {
  let icon-link(path, href: "#", alt: none) = {
    html.elem("a", attrs: (class: "mono", href: href), image(path, alt: alt))
  }

  html.elem("span", attrs: (class: "icon-links"), {
    html.span({
      icon-link("/assets/icons/github.svg",
        href: "https://github.com/goll72"
      )
      icon-link("/assets/icons/gitlab.svg",
        href: "https://gitlab.com/goll72"
      )
    })
    html.span({
      icon-link("/assets/icons/cc.svg",
        href: "https://creativecommons.org",
        alt: "Creative Commons"
      )
      icon-link("/assets/icons/cc-zero.svg",
        href: "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
        alt: "This site is under the CC0"
      )
    })
  })
}
