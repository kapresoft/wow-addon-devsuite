local table, tostring, format, pairs, print, ipairs, type, unpack =
    table, tostring, string.format, pairs, print, ipairs, type, unpack

-- #############################################################
local T = {}
DEVT_Table = T
-- ###################### Start Here ###########################

local function Trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

function T.parseSpaceSeparatedVar(text)
    local rt = {}
    for a in text:gmatch("%S+") do table.insert(rt, a) end
    return rt
end

function T.parseCSV(text)
    local rt = {}
    for a,v in text:gmatch("([^,]+)") do
        local a2 = Trim(a)
        table.insert(rt, a2)
    end
    return rt
end

function T.size(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end
function T.isEmpty(t)
    if t == nil then return true end
    return table.size(t) <= 0
end
function T.members()
    print('table members: ')
    for key, _ in pairs(T) do
        print(" " .. key);
    end
end

function T.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function T.append(source, target)
    local t2 = target or {}
    for k,v in pairs(source) do
        if t2[k] == nil then t2[k] = v end
    end
    return t2
end

function T.sliceAndPack(t, startIndex)
    local sliced = T.slice(t, startIndex)
    if type(unpack) ~= 'nil' then
        return T.pack(unpack(sliced))
    end
    return T.pack(table.unpack(sliced))
end

---Fail-safe unpack
---@param t table The table to unpack
function T.unpackIt(t)
    if type(unpack) == 'function' then
        return unpack(t)
    end
    return table.unpack(t)
end

function T.slice (t, startIndex, stopIndex)
    local pos, new = 1, {}
    if not stopIndex then stopIndex = #t end
    for i = startIndex, stopIndex do
        new[pos] = t[i]
        pos = pos + 1
    end
    return new
end

function T.concatkv(t)
    if type(t) ~= 'table' then return tostring(t) end
    local s = '{ '
    for k,v in pairs(t) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. T.concatkv(v) .. ','
    end
    return s .. '} '
end

function T.getSortedKeys(t)
    if type(t) ~= 'table' then return tostring(t) end
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    table.sort(keys)
    return keys
end

function T.concatkvs(t)
    if type(t) ~= 'table' then return tostring(t) end
    local keys = T.getSortedKeys(t)
    local s = '{ \n'
    for _, k in pairs(keys) do
        local ko = k
        if type(k) ~= 'number' then k = '"'..k..'"' end
        if type(t[ko]) ~= 'function' then
            s = s .. '['..k..'] = ' .. T.concatkvs(t[ko]) .. ','
        end
    end
    return s .. '} '
end

function T.toString(t) return T.concatkv(t) end
function T.toStringSorted(t) return T.concatkvs(t) end

function T.toString2(t)
    if type(t) ~= 'table' then return tostring(t) end
    local s = '\n{'
    for k,v in pairs(t) do
        s = string.format("%s\n    %s: %s,", s, tostring(k), T.toString2(v))
    end
    return s .. '\n}'
end

function T.pack(...)
    return { len = select("#", ...), ... }
end

function T.isTable(t) return type(t) == 'table' end
function T.isNotTable(t) return not T.isTable(t) end

function T.print(t) print(T.toString(t)) end
function T.printkv(t) print(T.concatkv(t)) end

function T.printkvs(t)
    local keys = T.getSortedKeys(t)
    for _, k in ipairs(keys) do print(k, t[k]) end
end

function T.println(t)
    if type(t) ~= 'table' then return tostring(t) end
    for k,v in pairs(t) do
        print(format("%s: %s", tostring(k), T.println(v)))
    end
end

function T.printG() T.printkvs(_G) end
function T.printLoaded() T.printkvs(package.loaded) end

-- ### Redirects ---
function T.insert(list, value) table.insert(list, value) end


