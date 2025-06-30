local date = require("filters.date")
local title = require("filters.title")
-- depends on: date, title
local meta = require("filters.meta")
local deps = require("filters.deps")
local sections = require("filters.sections")
-- depends on: <compilation order>
local page_list = require("filters.page-list")
local diagram = require("filters.diagram")

-- FIXME: `.ts` doesn't work in `script` (frontmatter)

-- Filters must be ordered such that each
-- filter is run before its dependents
local filters = {
    date,
    title,
    meta,
    deps,
    sections,
    page_list,
    diagram
}

local flattened = {}

for _, item in ipairs(filters) do
    if #item == 0 then
        table.insert(flattened, item)
    else
        for _, filter in ipairs(item) do
            table.insert(flattened, filter)
        end
    end
end

return flattened
