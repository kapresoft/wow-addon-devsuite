--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, G = DEVT_LibGlobals:LibPack()
local Table = G:Lib_Table()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

---@class Mixin
local _L = LibStub:NewLibrary(M.Mixin)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param source table The source table
---@param match string The string to match
local function listContains(source, match)
    for _,v in ipairs(source) do if match == v then return true end end
    return false
end

---@param object any The target object
function _L:Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            object[k] = v
        end
    end

    return object
end

function _L:MixinStandard(object, ...)
    self:MixinExcept(object, { 'GetName', 'mt', 'log' }, Table.pack(...))
end

function _L:MixinExcept(object, skipList, ...)
    print('skipList:', pformat(type(skipList)))
    for i = 1, select("#", ...) do
        local mixin = select(i, ...)
        for k, v in pairs(mixin) do
            if 'string' == type(k) then
                if not listContains(skipList, k) then object[k] = v end
            else
                object[k] = v
            end
        end
    end

    return object
end

