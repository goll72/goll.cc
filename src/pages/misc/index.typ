#import "/lib.typ": typ, page
#import "/lib/common/index.typ": page-list

#let paths = (
  "brachistochrone",
).map(it => "/misc/" + it)

#for path in paths {
  include typ(path)
}

#show: page.with("/misc")

#page-list(..paths)
