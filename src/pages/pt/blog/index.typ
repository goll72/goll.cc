#import "/lib.typ": typ, page
#import "/lib/common/index.typ": page-list

#let paths = (
  "restoring-sqrt",
).map(it => "/pt/blog/" + it)

#for path in paths {
  include typ(path)
}

#show: page.with("/pt/blog")

#page-list(..paths)
