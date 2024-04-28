--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub, KO = ns.O, ns.GC, ns.M, ns.LibStub, ns:KO()
local E, MSG, LL, AceEvent = GC.E, GC.M, ns:AceLocale(), ns:AceEvent()
local API, Ace, IsAddonSuiteEnabled = O.API, KO.AceLibrary.O, O.API.IsAddonSuiteEnabled
local libName = M.MainController

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class MainController : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end
Ace.AceEvent:Embed(L)
local p = ns:CreateDefaultLogger(libName)
local pp = ns:CreateDefaultLogger(ns.name)
local pm = ns:LC().MESSAGE:NewLogger(L.name)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---Other modules can listen to message
---```Usage:
---AceEvent:RegisterMessage(MSG.OnAddonReady, function(evt, ...) end
---```

---@param frame MainControllerFrame
---@param event string The event name
local function OnPlayerEnteringWorld(frame, event, ...)
    local isLogin, isReload = ...

    local addon = frame.ctx.addon
    addon:SendMessage(MSG.OnAddonReady)
    if not addon.PopupDialog then
        addon.PopupDialog = O.PopupDebugDialog()
    end

    --@debug@
    isLogin = true
    --@end-debug@

    if not isLogin then return end

    pp:a(GC:GetMessageLoadedText())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param addons table<number, AddOnName>
---@param action string
local function AddOnsToString(action, addons)
    if #addons <=0 then return '' end
    local str = ''
    for _, n in ipairs(addons) do
        str = sformat('%s%s (%s)\n', str, n, action)
    end
    return str
end
---@param o MainController
local function PropsAndMethods(o)
    local DEV_RELOAD_CONFIRM = 'DEV_RELOAD_CONFIRM'

    ---Init Method: Called by DevSuite.lua
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        self:RegisterMessage(MSG.OnAfterInitialize, function(evt, ...) self:OnAfterInitialize() end)
    end

    function o:OnAfterInitialize() self:RegisterEvents() end

    --- @private
    function o:RegisterEvents()
        p:f1("RegisterEvents called...")
        self:RegisterOnPlayerEnteringWorld()
        self:RegisterMessage(MSG.OnAddonReady, function(msg) self:OnAddonReady(msg)  end)
    end

    --- @private
    function o:OnAddonReady(msg)
        p:d(function() return "MSG:R:%s", msg end)
        self:InitializeState()
    end

    function o:InitializeState()
        self:InitStaticDialog()
        self:RefreshAutoLoadedAddons()

        -- AddonUsage is the "Addon Usage" global var
        C_Timer.After(3, function()
            self:OnToggleFrameRate()
            self:InitAddonUsage()
        end)
    end

    function o:OnToggleFrameRate() L:ShowFPS(ns:db().global.show_fps) end

    --- @private
    function o:RegisterOnPlayerEnteringWorld()
        local f = self:CreateEventFrame()
        f:SetScript(E.OnEvent, OnPlayerEnteringWorld)
        RegisterFrameForEvents(f, { E.PLAYER_ENTERING_WORLD })
    end

    --- #### See Also:
    --- - [Creating_simple_pop-up_dialog_boxes](https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes)
    function o:InitStaticDialog()
        if StaticPopupDialogs[DEV_RELOAD_CONFIRM] then return end
        StaticPopupDialogs[DEV_RELOAD_CONFIRM] = {
            text =  sformat(':: %s ::\n\n', ns.name) .. LL['REQUIRES_RELOAD'] .. '\n%s\n',
            button1 = YES,
            button2 = NO,
            OnAccept = function() L:OnApplyAndRestart() end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
        }
    end

    --- @param callbackFn fun(info:AddOnInfo) | "function(info) end"
    function o:ForEachCheckedAndLoadableAddon(callbackFn)
        local addons = ns:profile().auto_loaded_addons
        if not addons then return end
        for name, checked in pairs(addons) do
            if checked == true then
                local info = API:GetAddOnInfo(name)
                if info:CanBeEnabled() then callbackFn(info) end
            end
        end
    end

    function o:OnSyncAddOnEnabledState()
        if IsAddonSuiteEnabled() then return end

        local charName = UnitName("player")
        p:d(function() return "CharName=%s", tostring(charName) end)
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
    function o:OnApplyAndRestart()
        self:OnSyncAddOnEnabledState()
        ReloadUI()
    end

    function o:RefreshAutoLoadedAddons()
        if IsAddonSuiteEnabled() then return end

        local addons = ns:profile().auto_loaded_addons
        if not addons then return end

        local addonsToEnable = {}
        local addonsToDisable = {}
        self:ForEachCheckedAndLoadableAddon(function(info)
            table.insert(addonsToEnable, info.name)
        end)

        API:ForEachAddOnThatCanBeDisabled(function(info)
            p:d(function() return 'Addon should be disabled: %s', info.name end)
            table.insert(addonsToDisable, info.name)
        end)

        if true == ns:db().global.prompt_for_reload_to_enable_addons
                and (#addonsToEnable > 0 or #addonsToDisable > 0) then
            local prompt = ns:db().global.prompt_for_reload_to_enable_addons
            p:d(function() return 'prompt-for-reload=%s addons to enable=%s disable=%s',
            tostring(prompt), pformat(addonsToEnable), pformat(addonsToDisable) end)

            local msg = ''
            if #addonsToEnable > 0 then
                msg = AddOnsToString('Enable', addonsToEnable)
            end
            if #addonsToDisable > 0 then
                msg = msg .. AddOnsToString('Disable', addonsToDisable)
            end

            StaticPopup_Show(DEV_RELOAD_CONFIRM, msg)
        end
    end

    ---@param val boolean The config value
    function o:ShowFPS(val)
        local frameShown = (FramerateText and FramerateText:IsShown()) or
                (FramerateFrame and FramerateFrame:IsShown())
        local toggleFn = function() ToggleFramerate()  end
        --- @type _Frame
        local f = FramerateFrame
        if f then
            toggleFn = function()
                if f:IsShown() then f:Hide()
                else f:Show() end
            end
        end
        if true == frameShown then return val == false and toggleFn() end
        return val == true and toggleFn()
    end

    function o:InitAddonUsage()
        local g = ns:db().global
        --- @type _Frame
        local au = AddonUsage
        local autoShowUI = au and g.addon_addonUsage_auto_show_ui == true
        if not autoShowUI then return end

        -- TODO: Add "compact" option
        au:SetSize(385, 200)
        if ChatFrame1Tab then
            -- TODO: Add "align" option
            au:ClearAllPoints()
            au:SetPoint("BOTTOM", ChatFrame1Tab, "TOP", 155, 0)
        end
        au:Show();
    end

    --- @param eventFrame MainControllerFrame
    --- @return MainEventContext
    function o:CreateEventContext(eventFrame)
        --- @class MainEventContext
        --- @field frame MainControllerFrame
        --- @field addon AddOnSecurity
        local ctx = {
            frame = eventFrame,
            addon = self.addon,
        }
        return ctx
    end

    --- @return MainControllerFrame
    function o:CreateEventFrame()
        --- @class MainControllerFrame : _Frame
        --- @field ctx MainEventContext
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.ctx = self:CreateEventContext(f)
        return f
    end

end; PropsAndMethods(L)

AceEvent:RegisterMessage(GC.M.OnApplyAndRestart, function(msg, source, ...)
    pm:d(function() return '%s: source=%s', GC.M.OnApplyAndRestart, source end)
    L:OnApplyAndRestart()
end)
AceEvent:RegisterMessage(GC.M.OnSyncAddOnEnabledState, function(msg, source, ...)
    pm:d(function() return '%s: source=%s', GC.M.OnSyncAddOnEnabledState, source end)
    L:OnSyncAddOnEnabledState()
end)
AceEvent:RegisterMessage(GC.M.OnToggleFrameRate, function(msg, source, ...)
    pm:f1(function() return '%s: source=%s', GC.M.OnToggleFrameRate, source end)
    L:OnToggleFrameRate()
end)
