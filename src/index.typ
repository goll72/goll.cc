#import "lib.typ": host
#import "lib/feed.typ": generate-feed
#import "lib/tags.typ": tags-init

#include "pages/index.typ"
#include "pages/blog/index.typ"
#include "pages/misc/index.typ"

#include "pages/pt/index.typ"
#include "pages/pt/blog/index.typ"
#include "pages/pt/misc/index.typ"

#let serve(..args) = {
  let files = args.pos()

  for file in files {
    asset(file, read(file, encoding: none))

    if file.ends-with(".js") {
      asset(file + ".map", read(file + ".map", encoding: none))
    }
  }
}

#let assets = json(bytes(sys.inputs.at("assets")))
#serve("styles.css", "fonts.css", "scripts/page-list.js", ..assets)

// Write Atom feed for each language
#context for path in ("/", "/pt") {
  let feed = generate-feed(host: host, path)
  asset(path + "/feed.xml", bytes(feed))
}

// Write tag information for all pages
#context {
  let tags = state("tags", tags-init).get()
  asset("/tags.json", bytes(json.encode(tags, pretty: false)))
}
