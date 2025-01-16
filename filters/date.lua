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

        -- If there is only one date in git's output and the metadata already specifies a creation date,
        -- then the date from `git` will be the "updated" date. Otherwise it will be the "created" date.
        if #dates == 1 then
            if metadata.date then
                updated = dates[1]
            else
                created = dates[1]
            end
        else
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
