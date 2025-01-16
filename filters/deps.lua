-- Writes dependencies of the current file
-- to a dyndep file, to be processed by Ninja

local dyndeps = pandoc.List {}
local deps = pandoc.List {}

-- NOTE: if the output format is HTML, we will assume the --embed-resources 
-- flag is active (it seems this flag can't be checked in Lua). In that case, 
-- if the data-external attribute is present, then we will add a dependency 
-- on the output file. Otherwise, we will add a dependency on the input file.
--
-- NOTE: this filter assumes that the resource path is set to sitedir only, 
-- as a path relative to the build directory.
local function Image(element)
    -- Very rudimentary way of filtering out stuff like `https://...`
    if element.src:find("://") then return end

    local path = pandoc.path.normalize(element.src)
    local sitedir = PANDOC_STATE.resource_path[1]
    
    if FORMAT == "html" and element.attr.attributes["data-external"] then
        deps:insert(pandoc.path.join { "dist", path })
    else
        deps:insert(pandoc.path.join { sitedir, path })
    end
end

-- NOTE: `script` and `css` are metadata keys added by the user
local function Meta(metadata)
    local output = PANDOC_STATE.output_file:match("^temp/(.-)/out")

    local path = PANDOC_STATE.output_file:gsub("out$", "dep")
    local dyndep = io.open(path, "w")

    dyndep:write("ninja_dyndep_version = 1", "\n")
    dyndep:write("build ", output, ": dyndep | ")

    if metadata.script then
        dyndeps:extend(
            metadata.script:map(function (script)
                script = pandoc.utils.stringify(script)
                script = script:gsub("[.]ts$", ".js")

                local url = pandoc.path.join { metadata.url, script }
                
                return "dist" .. url
            end)
        )
    end

    if metadata.css then
        dyndeps:extend(
            metadata.css:map(function (css)
                css = pandoc.utils.stringify(css)

                local url = pandoc.path.join { metadata.url, css }

                return "dist" .. url
            end)
        )
    end

    for _, dep in ipairs(dyndeps) do
        dyndep:write(dep, " ")
    end

    dyndep:write("\n")
    dyndep:close()


    local depfile = io.open(PANDOC_STATE.output_file .. ".d", "w")

    depfile:write(output, ": ")

    for _, dep in ipairs(deps) do
        depfile:write(dep, " ")
    end

    depfile:write("\n")
    depfile:close()
end

return {
    Image = Image,
    Meta = Meta
}
