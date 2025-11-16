#import "url.typ": url

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
  )
)

#let meta(path: url()) = {
  meta-dictionary.at(path, default: (:))
}
