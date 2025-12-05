# {prefix: [[path, title, description], ...]};
# $mod: [{"paths": {path: commit}, "commits": [commit, ...], "dates": {commit: date}}]
# $date: date
#    -> "..."
#
# NOTE: $mod is a 1-element array due to slurpfile
{
  "/": "Blog posts on random topics (maybe math and Linux too)",
  "/pt/": "Posts sobre coisas aleatórias (talvez você encontre matemática e Linux aqui também)"
} as $desc | $mod[0] as $mod | 
"
<feed xmlns=\"http://www.w3.org/2005/Atom\">
  <title>goll.cc</title>
  <link href=\"https://goll.cc\($prefix)\" />
  <updated>\($date)</updated>
  <author>
    <name>goll</name>
  </author>
  <id>https://goll.cc\($prefix)</id>
  <generator>jq</generator>
  <link rel=\"self\" href=\"https://goll.cc\($prefix)feed.xml\" />
  <icon>/assets/favicon.png</icon>
  <subtitle>\($desc[$prefix])</subtitle>
  \(.[$prefix] | map(
    "
    <entry>
      <title>\(.[1])</title>
      <link href=\"https://goll.cc\(.[0])\" />
      <id>https://goll.cc\(.[0])</id>
      <summary>\(.[2])</summary>
      <updated>\($mod.dates[$mod.paths[.[0]]])</updated>
    </entry>
    "
  ) | add)
</feed>
" | trim
