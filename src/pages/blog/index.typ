#import "/lib.typ": typ, page
#import "/lib/common/index.typ": page-list

#let paths = (
  "restoring-sqrt",
  "linux-weird",
  "debian-oracle-cloud"
).map(it => "/blog/" + it)

#for path in paths {
  include typ(path)
}

#show: page.with("/blog")

#page-list(..paths)
