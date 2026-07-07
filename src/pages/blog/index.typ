#import "/lib.typ": typ, page
#import "/lib/common/index.typ": page-list

#let paths = (
  "debian-oracle-cloud",
  "linux-weird",
  "restoring-sqrt",
).map(it => "/blog/" + it)

#for path in paths {
  include typ(path)
}

#show: page.with("/blog")

#page-list(..paths)
