# `git last-modified -r site` [-R -n] -> {"paths": {path: commit}, "commits": [commit, ...]}
[
  inputs
    | split("\t")
    | select(.[1] | endswith(".typ") and (startswith("site/lib/") | not))
    | [
        .[0],
        "/" + (.[1] | ltrimstr("site/") | rtrimstr("index.typ") | rtrimstr(".typ") | rtrimstr("/"))
      ]
]
  | map({ (.[1]): .[0] })
  | add
  | { "paths": ., "commits": [.[]] | unique }
