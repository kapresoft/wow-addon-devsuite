--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local E, MSG, AceEvent = GC.E, GC.M, ns:AceEvent()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MainController()
--- @class MainController
local L = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)
local pp = ns:CreateDefaultLogger(ns.addon)

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

    --@do-not-package@
    if ns.debug:IsDeveloper() then
        isLogin = true
        p:vv(function()
            return "IsLogin=%s IsReload=%s LogLevel=%s",
                    ns.f.val(isLogin), ns.f.val(isReload), ns.f.val(DEVS_LOG_LEVEL)
        end)
    end
    --@end-do-not-package@

    if not isLogin then return end

    pp:a(GC:GetMessageLoadedText())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o MainController | AceEvent
local function PropsAndMethods(o)

    --- Init Method: Called by DevSuite.lua
    --- @private
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        self:RegisterMessage(MSG.OnAfterInitialize, function(evt, ...) self:OnAfterInitialize() end)
    end

    --- @private
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

    --- @private
    function o:InitializeState()
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
        f:RegisterEvent(E.PLAYER_ENTERING_WORLD)
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
        --- @class _MainControllerFrame
        --- @field ctx MainEventContext
        local f = CreateFrame("Frame", nil, self.addon.frame)
        f.ctx = self:CreateEventContext(f)
        --- @alias MainControllerFrame _MainControllerFrame | Frame
        return f
    end

end; PropsAndMethods(L)

AceEvent:RegisterMessage(GC.M.OnToggleFrameRate, function(msg, source, ...)
    pm:f1(function() return '%s: source=%s', GC.M.OnToggleFrameRate, source end)
    L:OnToggleFrameRate()
end)
