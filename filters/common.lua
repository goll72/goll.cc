-- Interpolates a list with the result of calling `f`
-- (`f` is called multiple times)
function pandoc.List:interpolate(f)
    local result = pandoc.List {}

    for i = 1, #self do
        result:insert(self[i])

        if i ~= #self then
            result:insert(f())
        end
    end

    return result
end

return {
    -- Escapes a string using the Lua multiline string syntax
    escape = function (s)
        local n = 0

        for w in string.gmatch(s, "]=*%f[%]]") do
            -- -1 to remove the ']'
            n = math.max(n, #w - 1)
        end

        -- produce a string with 'n' plus one equals signs
        local eq = string.rep("=", n + 1)

        -- build quoted string
        return string.format("[%s[%s]%s]", eq, s, eq)
    end,

    -- Flattens a table with some nested key `key` into a table containing
    -- the parent keys concatenated with `key`, e.g. (key="key", sep="/")
    -- table = { a = { key = 1 }, b = { c = { key = {}, other = "#" } } }
    --     -> { a = 1, ["b/c"] = {} }
    flatten = function (table, key, sep)
        local flattened = {}
    
        local function helper(table, path)
            for k, v in pairs(table) do
                if k == key then
                    flattened[path] = v
                elseif type(v) == "table" then
                    helper(v, path .. sep .. k)
                end
            end
        end

        helper(table, "")

        return flattened
    end
}
