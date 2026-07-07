// (str <<page>>: array(str) <<tags>>)
#let tags-init = (:)

#let add-tags(path, tags) = {
  state("tags", tags-init).update(old => {
    let new = (: ..old)
    new.insert(path, tags)
  
    return new
  })
}

#let get-tags(path) = state("tags", tags-init).get().at(path, default: ()) 
