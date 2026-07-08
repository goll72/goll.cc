#import "tags.typ": get-tags
#import "util.typ": xml-escape, content-to-string
#import "lang.typ": langs, extract-lang, add-lang-prefix

// Generates a feed for all feed pages matching the path passed in (and having the same language)
// If `updated` is not set, the updated date will be the maximum over all feed entries
#let generate-feed(host: none, location: none, updated: none, path, subtitle: none) = {
  if location == none {
    location = "https://" + host
  }

  let normalized-path = if path.ends-with("/") {
    path.slice(0, -1)
  } else {
    path
  }

  let entries = {
    let all-entries = state("feed-pages").get()

    if path == "/" {
      all-entries.filter(it => it.match(regex("^/\w{2}(/.*)?$")) == none)
    } else {
      all-entries.filter(it => it.starts-with(normalized-path + "/"))
    }    
  }

  let entries = entries.map(it => {
    let doc = query(label(it)).first()

    let summary = if doc.description == none {
      ""
    } else {
      "<summary>" + xml-escape(content-to-string(doc.description)) + "</summary>"
    }

    let published = {
      let date = state("published").at(label(it))

      if date == none {
        ""
      } else {
        "<published>" + date.display("[year]-[month]-[day]") + "</published>"
      }
    }

    let updated-date = state("updated").at(label(it))
    assert.ne(updated-date, none, message: "`updated` needs to be set for pages on a feed: " + it)

    let updated = updated-date.display("[year]-[month]-[day]")

    let categories = get-tags(it)
      .map(it => "<category term=\"" + it + "\" />")

    return (updated-date, "
  <entry>
    <title>" + xml-escape(content-to-string(doc.title)) + "</title>
    <link href=\"" + location + it + "\" />
    <id>" + location + it + "</id>
    " + summary + "
    " + published + "
    <updated>" + updated + "</updated>
    " + categories.join("\n" + 4 * " ") + "
  </entry>
")
  })

  let xml-entries = entries.map(((_, entry)) => entry)

  if updated == none {
    updated = calc.max(..entries.map(((date, _)) => date))
  }

  let updated = updated.display("[year]-[month]-[day]")

  let subtitle = if subtitle == none {
    ""
  } else {
    "<subtitle>" + xml-escape(subtitle) + "</subtitle>"
  }

  // NOTE: this assumes that for each path, either there are
  // no feeds or there are feeds for all possible languages
  //
  // i.e. this could be improved to check if a
  // feed actually exists before linking to it
  let (current-lang, path-without-lang) = extract-lang(path)

  let alternates = langs
    .filter(it => it != current-lang)
    .map(it => {
      let path = add-lang-prefix(path-without-lang, it)

      let normalized-path = if path.ends-with("/") {
        path.slice(0, -1)
      } else {
        path
      }
      
      ("<link rel=\"alternate\" hreflang=\"" + it
        + "\" href=\"" + location + normalized-path + "/feed.xml" + "\"/>")
    })
  
  let feed = "
<feed xmlns=\"http://www.w3.org/2005/Atom\" xml:lang=\"" + text.lang + "\">
  <title>" + host + "</title>
  <link href=\"" + location + normalized-path + "/" + "\" />
  <updated>" + updated + "</updated>
  <author>
    <name>goll</name>
  </author>
  <id>" + location + normalized-path + "/" + "</id>
  <generator>Typst</generator>
  <link rel=\"self\" href=\"" + location + normalized-path + "/feed.xml" + "\" />
  " + alternates.join("\n" + 2 * " ") + "
  <icon>/assets/favicon.png</icon>
  " + subtitle + "
  " + xml-entries.join("") + "
</feed>
"

  return feed
}
