--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetNumAddOns = GetNumAddOns or C_AddOns.GetNumAddOns
local GetAddOnInfo = GetAddOnInfo or C_AddOns.GetAddOnInfo
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = devsuite_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return API, LoggerV2
local function CreateLib()
    local libName = M.API
    --- @class API : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:CreateDefaultLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o API
local function PropsAndMethods(o)

    ---@param indexOrName IndexOrName The index from 1 to GetNumAddOns() or The name of the addon (as in TOC/folder filename), case insensitive.
    function o:GetAddOnInfo(indexOrName)
        assert(indexOrName, "The index parameter is required.")
        local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(indexOrName)
        --- @type AddOnInfo
        local info = {
            name = name, title = title, loadable = loadable, notes = notes,
            reason = reason, security = security, newVersion = newVersion
        }
        return info
    end

    ---@param callbackFn AddOnCallbackFn
    function o:ForEachAddOn(callbackFn)
        local addOnCount = GetNumAddOns()
        if addOnCount <= 0 then return end

        for i = 1, addOnCount do
            callbackFn(self:GetAddOnInfo(i))
        end
    end

end; PropsAndMethods(L)

