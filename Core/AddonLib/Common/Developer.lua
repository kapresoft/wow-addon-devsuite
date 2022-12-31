--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local geterrorhandler = geterrorhandler

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn, DisableAddOn
local StaticPopupDialogs, ReloadUI = StaticPopupDialogs, ReloadUI
local StaticPopup_Visible, StaticPopup_Show = StaticPopup_Visible, StaticPopup_Show
local str_lower = string.lower

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local addon, ns = ...

local LibStub, M, LogFactory, G = DEVT_LibGlobals:LibPack_NewLibrary()
local reloadUI = addon .. '_CONFIRM_RELOAD_UI'


---@class Developer
local L = LibStub:NewLibrary(M.Developer)
--- This means the library is already loaded in case of multiple libs
if not L then return end

local p = LogFactory(M.Developer)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
StaticPopupDialogs[reloadUI] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function() ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local function ConfirmAndReload()
    if StaticPopup_Visible(reloadUI) == nil then return StaticPopup_Show(reloadUI) end
    return false
end

local function errorhandler(err) return geterrorhandler()(err) end

local function safecall(func, ...)
    if func then
        return xpcall(func, errorhandler, ...)
    end
end

---@class AddOnInfo
local _AddOnInfo = {
    name = '', title = '', notes = '', loadable = true,
    reason = '', security = '', newVersion = false
}
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o Developer
local function Methods(o)

    function o:GetAllAddOns()
        local count = GetNumAddOns()
        ---@type table<string, AddOnInfo>
        local addons = {}
        for i=1,count do
            local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i)
            ---@type AddOnInfo
            local addonInfo = {
                name = name, title = title, loadable = loadable,
                reason = reason, security = security, newVersion = newVersion
            }
            --p:log('%s: %s', name, pformat(o))
            addons[str_lower(name)] = addonInfo
        end
        return addons
    end

    function o:GetAllAddOnsShort()
        local a = self:GetAllAddOns()
        local t = {}
        for k,n in pairs(a) do table.insert(t, n.name) end
        table.sort(t)
        return t
    end

    ---@param addons table<number, string>
    function o:EnableAddOns(addons)
        self:ForEachAddons(addons, function(addonName)
            EnableAddOn(addonName)
            p:log('Addons Enabled: %s', addonName)
        end)
    end

    ---@param addons table<number, string>
    function o:DisableAddOns(addons)
        self:ForEachAddons(addons, function(addonName)
            DisableAddOn(addonName)
            p:log('Addons Disabled: %s', addonName)
        end)
    end

    ---@param addons table<number, string>
    ---@param applyFn fun(addonName:string)
    function o:ForEachAddons(addons, applyFn)
        if #addons <= 0 then return end
        local a = self:GetAllAddOns()
        local overallStatus = true
        for i, n in ipairs(addons) do
            local n_lower = str_lower(n)
            local info = a[n_lower]
            if info then
                local status = safecall(applyFn, info.name)
                if not status then
                    overallStatus = false
                    p:log('Failed to Enable AddOn: %s', info.name)
                end
            else
                p:log('AddOn Not Found: %s', n)
                assert(false, 'AddOn Not Found: ' .. n)
                overallStatus = false
            end
        end
        if overallStatus then ConfirmAndReload() return end
    end

end

Methods(L)

_G[addon .. '_D'] = L
