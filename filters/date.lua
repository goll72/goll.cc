-- Get a date from git if no date was specified, get an `updated` date
-- from git that will be set in the metadata iff it is different from
-- `date` and normalize the date(s) using `pandoc.utils.normalize_date`
local function Meta(metadata)
    local dirname, basename = PANDOC_STATE.input_files[1]:match("^(.*)/(.-)$")
    
    if not metadata.date or not metadata.updated then
        -- `git` must be run inside the git repository,
        -- and the builddir may be outside the repository
        local output = pandoc.pipe("git", {
            "-C",
            dirname,
            "--no-pager",
            "log",
            "--diff-filter=AM",
            "--follow",
            "--format=%ad",
            "--date=short",
            "--",
            basename
        }, "")

        local dates = pandoc.List {}

        for date in output:gmatch("([^\n]+)") do
            dates:insert(date)
        end

        local created, updated

        if #dates == 1 then
            created = dates[1]
        elseif #dates > 1 then
            updated = dates[1]
            created = dates[#dates]
        end            

        if created then
            metadata.date = metadata.date or created
        end

        if updated then
            metadata.updated = metadata.updated or updated
        end
    end

    if metadata.date then
        metadata.date = pandoc.utils.normalize_date(pandoc.utils.stringify(metadata.date))
    end

    if metadata.updated then
        metadata.updated = pandoc.utils.normalize_date(pandoc.utils.stringify(metadata.updated))
    end

    if metadata.updated == metadata.date then
        metadata.updated = nil
    end
    
    return metadata
end

return {
    Meta = Meta
}
