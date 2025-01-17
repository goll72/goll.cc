local meta = require("filters.meta")
local common = require("filters.common")

local function time(element)
    local str = pandoc.utils.stringify(element)
    return pandoc.RawInline("html",
        string.format([[<time datetime="%s">%s</time>]], str, str)
    )
end

-- Expands a div into a list of pages matching a given path (Lua regex)
-- 
-- Usage:
-- 
-- ::: {.page-list path=...}
-- :::
local function Div(element)
    if not element.attr.classes:includes("page-list") then return end

    local path = element.attributes.path
    if not path then error("page-list used without path attribute") end

    local metadata = {}
    setmetatable(metadata, meta.metatable)

    local chunk = assert(loadfile(meta.path, "t", metadata))
    chunk()

    local flattened = common.flatten(metadata, "index", "/")
    local pages = pandoc.List {}

    for k, v in pairs(flattened) do
        if k:match(path) then
            v.url = k

            for _, key in ipairs(meta.keys) do
                if v[key] then
                    local doc = pandoc.read(v[key], "markdown")
                    v[key] = pandoc.utils.blocks_to_inlines(doc.blocks)
                end
            end

            pages:insert(v)
        end
    end

    local stringify = pandoc.utils.stringify

    pages:sort(function (a, b)
        if a.date == b.date or not a.date or not b.date then
            return a.url > b.url
        else
            return stringify(a.date) > stringify(b.date)
        end
    end)

    pages = pages:map(function (x)
        -- NOTE: x.date and x.updated are `pandoc.Inlines`
        local date = pandoc.Blocks {
            pandoc.Div(x.date and time(x.date[1]) or "No date")
        }

        if x.updated then
            local updated_text = pandoc.Inlines {
                "Updated on ",
                time(x.updated[1])
            }
            
            date:insert(pandoc.Div(updated_text))
        end
        
        local heading = pandoc.Blocks {
            pandoc.Link(x.title, x.url, "Page", { class = "page-list-title" }),
            pandoc.Div(date, { class = "page-list-date" })
        }
        
        return pandoc.Blocks {
            pandoc.Div(heading),
            pandoc.Para(x.description or "No description")
        }
    end)

    return pandoc.Div(#pages ~= 0 and pandoc.BulletList(pages) or {}, { class = "page-list" })
end

return {
    Div = Div
}
