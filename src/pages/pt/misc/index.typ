#import "/lib.typ": typ, page
#import "/lib/common/index.typ": page-list

#let paths = (
  "brachistochrone",
).map(it => "/pt/misc/" + it)

#for path in paths {
  include typ(path)
}

#show: page.with("/pt/misc")

#page-list(..paths)
