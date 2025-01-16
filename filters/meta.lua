local meta_path = "meta.lua"
local meta_keys = { "title", "date", "description", "updated" }

local metatable = {}

metatable.__index = function (table, key)
    local default = {}
    setmetatable(default, metatable)
        
    table[key] = default

    return default
end

local common = require("filters.common")

-- Save metadata to a file, in a format that can be read by Lua later (Lua code)
local function Meta(metadata)
    local meta_file = io.open(meta_path, "a")

    meta_file:write("_ENV")

    local components = pandoc.path.split(metadata.url)

    -- The first component will always be '/'
    for i = 2, #components do
        meta_file:write("[", string.format("%q", components[i]), "]")
    end

    meta_file:write("[\"index\"] = {")

    for _, key in ipairs(meta_keys) do
        local content = metadata[key]

        if content then
            -- Inline content has to be wrapped in a paragraph for
            -- it to be rendered properly to Markdown by Pandoc
            if pandoc.utils.type(content) == "Inlines" then
                content = pandoc.Para(content)
            end
                
            local rendered = pandoc.write(pandoc.Pandoc(content, metadata), "markdown", {})
            meta_file:write(" ", key, " = ", common.escape(rendered), ", ")
        end
    end

    meta_file:write("}\n")

    meta_file:close()
end

return {
    Meta = Meta,
    path = meta_path,
    metatable = metatable,
    keys = meta_keys
}
