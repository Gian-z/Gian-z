-- Monkey-patches on standard Lua tables, isolated to a single file so they are
-- easy to find and remove. Loaded once from core/init.lua.

-- Looks for the last match of `pattern` in `s`. Returns start, finish.
-- WARN: this function does poorly with unicode characters.
---@param s string
---@param pattern string
---@param last integer?
---@param plain boolean?
---@return integer | nil, integer | nil
string.findlast = function(s, pattern, last, plain)
    local reverse = string.reverse(s)
    if last == nil then
        last = #s
    end
    local start, finish = string.find(reverse, string.reverse(pattern), #s + 1 - last, plain)
    if start == nil then
        return nil
    else
        return #s + 1 - finish, #s + 1 - start
    end
end

-- Finds the first occurrence of `target` in table `t`. Returns the key/index
-- or nil.
---@param t table
---@param target any
---@return any
table.find = function(t, target)
    for key, value in pairs(t) do
        if value == target then
            return key
        end
    end
    return nil
end
