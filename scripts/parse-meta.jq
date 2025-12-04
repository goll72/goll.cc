# [[path, title, description], ...] -> {"/": [[path, title, description], ...], "/pt/": [[path, title, description], ...], ...}

[ .[] | [.[], (.[0] | split("/") | .[1])] ]
  | group_by(
      if [.[3]] | inside($langs) then
          .[3]
      else
          "/"
      end)
  | map({
      (if [.[0] | .[3]] | inside($langs) then "/" + (.[0] | .[3]) + "/" else "/" end): [ .[] | [.[0, 1, 2]] ]
    })
  | add | . as $meta_by_lang | .
