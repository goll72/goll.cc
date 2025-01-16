package = "goll.cc"
version = "0.1-1"
source = {
   url = "git://github.com/goll72/goll.cc.git"
}
build = {
   type = "none"
}
dependencies = {
   -- XXX: We need at least one dependency, otherwise luarocks won't create `lua_modules`
   "luafilesystem"
}
