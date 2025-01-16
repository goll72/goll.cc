local title

-- Sets the title from the first level 1 header
-- iff it isn't already set in the metadata

local function get_metadata_title(metadata)
    title = metadata.title
end

local function Header(element)
    if element.level == 1 and not title then
        title = element.content
        return {}
    end

    return element
end

local function set_metadata_title(metadata)
    metadata.title = title
    return metadata
end

return {
    { Meta = get_metadata_title },
    { Header = Header },
    { Meta = set_metadata_title }
}
