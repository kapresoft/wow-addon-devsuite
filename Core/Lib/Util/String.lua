-- ## External -------------------------------------------------
local gsub, len, tinsert, pairs, type, tostring = string.gsub, string.len, table.insert , pairs, type, tostring

-- ## Local ----------------------------------------------------

local LibStub = __K_Core_DevTools:LibPack()
---@class String
local _L = LibStub:NewLibrary('String')

-- ## Functions ------------------------------------------------

function _L.IsEmpty(str) return (str or '') == '' end
function _L.IsNotEmpty(str)
    if str == nil then return true end
    return not _L.IsEmpty(str)
end
function _L.IsBlank(str)
    if str == nil then return true end
    if type(str) ~= 'string' then return false end
    return len(_L.TrimAll(str)) <= 0
end
function _L.IsNotBlank(str) return not _L.IsBlank(str) end
function _L.TrimAll(str)
    if str == nil then return str end
    if type(str) ~= 'string' then error(string.format('expected a string type but got: %s', type(str))) end
    return gsub(str or '', "%s", "")
end

function _L.ToTable(args)
    -- print(string.format("args: %s, type=%s", args, type(args)))
    local rt = {}
    for a in args:gmatch("%S+") do tinsert(rt, a) end
    -- table.foreach(rt, print)
    return rt
end

function _L.ToString(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. _L.ToString(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function _L.EqualsIgnoreCase(str1, str2)
    return string.lower(str1) == string.lower(str2)
end

---@param formatstring string The string format
function _L.format(formatstring, ...)
    return string.format(formatstring, ...)
end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.ltrim(s)
    return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function _L.rtrim(s)
    local n = #s
    while n > 0 and s:find("^%s", n) do n = n - 1 end
    return s:sub(1, n)
end

function _L.replace(str, match, replacement)
    if type(str) ~= 'string' then return nil end
    return str:gsub(match, replacement)
end

---Example: local charCount = Count('hello world', 'l') ; returns 3
---@param str string The string to search
---@param pattern string The pattern to count
function _L.Count(str, pattern)
    return select(2, string.gsub(str, pattern, ""))
end

---@param index number The index to replace
---@param str string The text where we are replacing the index value of
---@param r string The replacement text
function _L.ReplaceChar(index, str, r)
    return str:sub(1, index - 1) .. r .. str:sub(index + 1)
end

---@param str string The text where we are replacing the index value of
---@param r string The replacement text
function _L.ReplaceAllCharButLast(str, r)
    local c = _L.Count(str, r)
    if c == 1 then return str end
    local ret = str
    for _ = 1, c - 1, 1
    do
        local index = ret:find(r)
        if index >= 1 then
            ret = _L.ReplaceChar(index, ret, '')
        end
    end
    return ret
end

---@class BindingDetails
local BindingDetailsTemplate = { action="<CLICK>", buttonName="<buttonName>", buttonPressed="<LeftButton>" }

---@param bindingName string The keybind name (see Bindings.xml) Example: ```'CLICK ActionbarPlusF1Button1:LeftButton'```
---@return BindingDetails
function _L.ParseBindingDetails(bindingName)
    local startIndexMatch, _, a,b,c = string.find(bindingName, "(.+%s)(%w+):(%a+)")
    if not (startIndexMatch or b) then return nil end
    return { action=_L.TrimAll(a), buttonName = _L.TrimAll(b), buttonPressed = _L.TrimAll(c) }
end