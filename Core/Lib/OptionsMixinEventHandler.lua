--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = devsuite_ns(...)
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local reloadUI = ns.name .. '_CONFIRM_RELOAD_UI'
local API = O.API

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function ConfirmAndReload()
    if StaticPopup_Visible(reloadUI) == nil then return StaticPopup_Show(reloadUI, true) end
    return false
end

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @return OptionsMixinEventHandler, Kapresoft_CategoryLogger
local function CreateLib()
    local libName = M.OptionsMixinEventHandler or 'OptionsMixinEventHandler'
    --- @class OptionsMixinEventHandler : BaseLibraryObject
    local newLib = LibStub:NewLibrary(libName); if not newLib then return nil end
    local logger = ns:LC().OPTIONS:NewLogger(libName)
    return newLib, logger
end; local L, p = CreateLib(); if not L then return end
local pm = ns:LC().MESSAGE:NewLogger(L.name)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param addons table<number, AddOnName>
local function EnableAddOns(addons)
    if #addons <= 0 then return end
    local charSpecific = ns:db().global.auto_loaded_addons_characterSpecific
    local charName
    if charSpecific == true then charName = UnitName("player") end
    for i, name in ipairs(addons) do
        EnableAddOn(name, charName)
    end
end

---@param o OptionsMixinEventHandler
local function PropsAndMethods(o)
    ---@param val boolean The config value
    function o:ShowFPS(val)
        if true == FramerateText:IsShown() then
            return val == false and ToggleFramerate()
        end
        return val == true and ToggleFramerate()
    end
    --- What needs to be enabled and disabled
    function o:SyncAddOnEnabledState()
        local charSpecific = ns:db().global.auto_loaded_addons_characterSpecific
        local charName
        if charSpecific == true then charName = UnitName("player") end
        p:d(function() return "CharSpecific=%s CharName=%s", tostring(charSpecific), charName end)
        --- @table<string,boolean>
        local addons = ns:db().profile.auto_loaded_addons

        local enabled = {}
        local disabled = {}
        API:ForEachAddOn(function(addOn)
            local shouldLoad = addons[addOn.name]
            local name = addOn.name
            if name ~= ns.name then
                if shouldLoad and shouldLoad == true then
                    EnableAddOn(name, charName)
                    table.insert(enabled, name)
                else
                    DisableAddOn(name, charName)
                    table.insert(disabled, name)
                end
            end
        end)

        EnableAddOn(ns.name, charName)
        p:f1(function() return "Updating Add-On States:" end)
        p:f1(function() return "%s (this): enabled=true", ns.name end)
        p:f1(function() return "Enabled: %s", pformat(enabled) end)
        p:f1(function() return "Disabled: %s", pformat(disabled) end)

    end
    function o:ApplyAndRestart()
        self:SyncAddOnEnabledState()
        ReloadUI()
    end
end; PropsAndMethods(L)

ns.event:RegisterMessage(GC.M.OnAddonReady, function(msg, source, ...)
    pm:f1(function() return "Msg received: %s", msg end)
end)
ns.event:RegisterMessage(GC.M.OnToggleFrameRate, function(msg, source, ...)
    --- @type boolean
    local checkedVal = ...
    pm:f1(function() return '%s: source=%s val=%s',
                            GC.M.OnToggleFrameRate, source, tostring(checkedVal) end)
    L:ShowFPS(checkedVal)
end)
ns.event:RegisterMessage(GC.M.OnApplyAndRestart, function(msg, source, ...)
    pm:d(function() return '%s: source=%s', GC.M.OnApplyAndRestart, source end)
    L:ApplyAndRestart()
end)
ns.event:RegisterMessage(GC.M.OnSyncAddOnEnabledState, function(msg, source, ...)
    pm:d(function() return '%s: source=%s', GC.M.OnSyncAddOnEnabledState, source end)
    L:SyncAddOnEnabledState()
end)
