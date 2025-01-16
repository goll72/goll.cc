local sections = pandoc.List {
    "/",
    "/blog",
    "/resources"
}

-- Generates navbar links for the pages specified in `sections`,
-- storing the links in the `site-sections` metadata attribute
local function Meta(metadata)    
    local items = sections:map(function (x)
        if metadata.url == x then
            return pandoc.Str "."
        else
            local parent = ""
            local url = metadata.url

            while url ~= "" do
                if url == x then break end

                local last_component = url:match("/[^/]*$")

                url = url:sub(0, -last_component:len() - 1)
                parent = parent .. "../"
            end

            -- The url for the current page is not a child of `x`
            if url == "" then
                return pandoc.Link("~" .. x:match("^(.-)/?$"), x)
            else
                return pandoc.Link(parent:match("^(.-)/?$"), x)
            end
        end
    end)

    metadata["site-sections"] = pandoc.BulletList(items)

    return metadata
end

return {
    Meta = Meta
}
