#import "lib.typ"

#include "pages/index.typ"
#include "pages/blog/index.typ"
#include "pages/misc/index.typ"

#include "pages/pt/index.typ"
#include "pages/pt/blog/index.typ"
#include "pages/pt/misc/index.typ"

#asset("styles.css", read("styles.css", encoding: none))
#asset("fonts.css", read("fonts.css", encoding: none))

#let assets = json(bytes(sys.inputs.at("assets")))

#for path in assets {
  asset(path, read(path, encoding: none))
}

// XXX: generate RSS feed

// XXX: generate sitemap
