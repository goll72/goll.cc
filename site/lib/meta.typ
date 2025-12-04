#import "url.typ": url
#import "util.typ": content-to-string

#let meta-dictionary = (
  "/": (
    title: [goll.cc]
  ),
  "/blog": (
    title: [Blog]
  ),
  "/blog/restoring-sqrt": (
    title: [Restoring Square Root Explained],
    description: [This algorithm, although a bit niche, is still quite useful. But how (and why) does it work?]
  ),
  "/blog/linux-weird": (
    title: [Linux Oddities],
    description: [A log of weird stuff that has happened to me on Linux]
  ),
  "/misc": (
    title: [Misc.]
  ),
  "/misc/brachistochrone": (
    title: [Brachistochrone],
    description: [A physics simulation/demo]
  ),
  "/pt": (
    title: [goll.cc]
  ),
  "/pt/blog": (
    title: [Blog]
  ),
  "/pt/blog/restoring-sqrt": (
    title: [Raiz quadrada por restauração],
    description: [Veja como esse algoritmo funciona em binário]
  ),
  "/pt/misc": (
    title: [Misc.]
  ),
  "/pt/misc/brachistochrone": (
    title: [Curva braquistócrona],
    description: [Uma demonstração/simulação]
  )
)

#let meta(path: url()) = {
  meta-dictionary.at(path, default: (:))
}

#if sys.inputs.at("meta-export", default: none) != none [
  #metadata(meta-dictionary.pairs().filter(
    ((_, info)) => info.at("description", default: none) != none
  ).map(((link, (title, description))) => (link, content-to-string(title), content-to-string(description)))) <meta>
]
