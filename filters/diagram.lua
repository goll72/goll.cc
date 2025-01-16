-- NOTE: A RawBlock might've been more appropriate,
-- but it doesn't allow us to specify attributes
--
-- Usage:
-- ```{.pikchr caption="abc" width="50%"}
-- 
-- ```    
local function CodeBlock(element)
    if element.classes[1] ~= "pikchr" then
        return
    end

    local attrs = element.attr.attributes
    local caption = attrs.caption or attrs.alt

    attrs.caption = nil
    attrs.alt = nil

    local hash = pandoc.sha1(element.text)

    -- Allow for CSS color references
    if FORMAT == "html" then
        element.text = "color = ok\n" .. element.text
    end

    local output = pandoc.pipe("./pikchr", { "--svg-only", "-" }, element.text)
    local path = hash .. ".svg"

    pandoc.mediabag.insert(path, "image/svg+xml", output) 

    return pandoc.Image({ pandoc.Str(caption) }, path, "Diagram", element.attr)
end

return {
    CodeBlock = CodeBlock
}
