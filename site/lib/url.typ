#let url() = {
  let path = sys.inputs.at("path", default : "/index.typ")
  let index = "/index.typ"

  let result = if path.ends-with(index) {
    path.slice(0, -index.len())
  } else if path.ends-with(".typ") {
    path.slice(0, -4)
  } else {
    path
  }

  if not result.starts-with("/") {
    "/" + result
  } else {
    result
  }
}

#let join-url(a, b) = {
  assert(a.starts-with("/"), message: "invalid url")
  assert(b.starts-with("/") or b.starts-with("./"), message: "invalid url")
  
  if b.starts-with("/") {
    b
  } else {
    "/" + a.trim("/", repeat: true) + b.slice(1)
  }
}
