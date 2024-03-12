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
local ns = devsuite_ns(...)
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.LibStub
local E, MSG, LL, AceEvent = GC.E, GC.M, ns:AceLocale(), ns:AceEvent()
local Ace = ns.KO().AceLibrary.O
local libName = M.MainController

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class MainController : BaseLibraryObject_WithAceEvent
local L = LibStub:NewLibrary(libName); if not L then return end
Ace.AceEvent:Embed(L)
local p = ns:CreateDefaultLogger(libName)
local pp = ns:CreateDefaultLogger(ns.name)

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

    pp:vv(GC:GetMessageLoadedText())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param addons table<number, AddOnName>
local function AddOnsToString(addons)
    if #addons <=0 then return '' end
    local str = ''
    for i, n in ipairs(addons) do
        str = str .. n .. '\n'
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
        self:RegisterMessage(MSG.OnAddonReady, function() self:OnAddonReady()  end)
    end

    --- @private
    function o:OnAddonReady()
        self:ToggleFramerateIfConfigured()
    end

    function o:ToggleFramerateIfConfigured() self:SendMessage(MSG.OnToggleFrameRate, libName) end

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
            OnAccept = function(self, addonsToEnable)
                O.OptionsMixinEventHandler:ApplyAndRestart()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
        }
    end

    --- @param nameOrIndex string|Index
    --- @return Disabled
    function L:IsAddonDisabled(nameOrIndex)
        local name, title, notes, loadable, reason, security = GetAddOnInfo(nameOrIndex)
        p:f2(function()
            return 'Add-On: %s loadable=%s r=%s s=%s', name, tostring(loadable), tostring(reason), security end)
        return reason and O.String.EqualsIgnoreCase(reason, 'disabled')
    end

    function o:RefreshAutoLoadedAddons()
        local addons = ns:profile().auto_loaded_addons
        if not addons then return end

        local addonsToEnable = {}
        for addonName, autoEnable in pairs(addons) do
            if autoEnable == true then
                local disabled = L:IsAddonDisabled(addonName)
                if disabled == true then table.insert(addonsToEnable, addonName) end
            end
        end

        if true == ns:db().global.prompt_for_reload_to_enable_addons and  #addonsToEnable > 0 then
            p:vv('ActionbarPlus is in Developer mode and needs to restart to load additional addons.')
            local dlg = StaticPopup_Show(DEV_RELOAD_CONFIRM, AddOnsToString(addonsToEnable))
            dlg.data = addonsToEnable
        end

        -- AddonUsage is the "Addon Usage" global var
        C_Timer.After(3, function() self:ApplyInitialStates() end)
    end

    function o:ApplyInitialStates()
        local g = ns:db().global
        self:InitAddonUsage()
        if ToggleFramerate and g.show_fps == true then ToggleFramerate() end
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

    function o:InitializeDevMode()
        self:InitStaticDialog()
        self:RefreshAutoLoadedAddons()
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

AceEvent:RegisterMessage(GC.M.OnAddonReady, function(msg, source, ...)
    p:d(function() return "MSG:R:%s", msg end)
    L:InitializeDevMode()
end)
