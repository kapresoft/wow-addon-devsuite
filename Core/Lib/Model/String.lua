-- String Utils

local __def = function(tinsert, pairs, type, tostring)
    local S = {}

    function S.IsEmpty(str) return (str or '') == '' end
    function S.IsNotEmpty(str) return not S.IsEmpty(str) end
    function S.IsBlank(str) return S.len(S.TrimAll(str)) <= 0 end
    function S.IsNotBlank(str) return not S.IsEmpty(str) end
    function S.TrimAll(str) return S.gsub(str or '', "%s", "") end

    function S.ToTable(args)
        -- print(string.format("args: %s, type=%s", args, type(args)))
        local rt = {}
        for a in args:gmatch("%S+") do tinsert(rt, a) end
        -- table.foreach(rt, print)
        return rt
    end

    function S.ToString(o)
        if type(o) == 'table' then
            local s = '{ '
            for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. S.ToString(v) .. ','
            end
            return s .. '} '
        else
            return tostring(o)
        end
    end

    function S.EqualsIgnoreCase(str1, str2)
        return S.lower(str1) == S.lower(str2)
    end

    -- remove trailing and leading whitespace from string.
    -- http://en.wikipedia.org/wiki/Trim_(programming)
    function S.trim(s)
        -- from PiL2 20.4
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end

    -- remove leading whitespace from string.
    -- http://en.wikipedia.org/wiki/Trim_(programming)
    function S.ltrim(s)
        return (s:gsub("^%s*", ""))
    end

    -- remove trailing whitespace from string.
    -- http://en.wikipedia.org/wiki/Trim_(programming)
    function S.rtrim(s)
        local n = #s
        while n > 0 and s:find("^%s", n) do n = n - 1 end
        return s:sub(1, n)
    end

    function S.replace(str, match, replacement)
        if type(str) ~= 'string' then return nil end
        return str:gsub("%" .. match, replacement)
    end

    return S
end

DEVT_String = __def(table.insert , pairs, type, tostring)
