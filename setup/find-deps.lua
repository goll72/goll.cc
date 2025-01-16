if #arg ~= 1 then
    error("Usage: " .. arg[0] .. " <modname>")
end

local modname = arg[1]

local before = {}

for k, v in pairs(package.loaded) do
    before[k] = v
end

local mod = require(modname)

for k, v in pairs(package.loaded) do
    if not before[k] then
        local path = package.searchpath(k, package.path, ".")

        print(path)
    end
end
