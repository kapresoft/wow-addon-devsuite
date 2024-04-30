--[[-----------------------------------------------------------------------------
Type: GeneralConfigOptionArgs
-------------------------------------------------------------------------------]]
--- @class GeneralConfigOptionArgs
--- @field showFPS AceConfigOption
--- @field addonUsage_AutomaticallyShow AceConfigOption
--- @field specialNoticeText AceConfigOption

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub

local ACE, API = ns:AceLibrary(), O.API
local AceConfig, AceConfigDialog, AceDBOptions = ACE.AceConfig, ACE.AceConfigDialog, ACE.AceDBOptions
local DebugSettings = O.DebuggingSettingsGroup
local c1 = ns:K():cf(RED_FONT_COLOR)
local c2 = ns:K():cf(YELLOW_FONT_COLOR)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class OptionsMixin
local libName = M.OptionsMixin()
local S       = LibStub:NewLibrary(libName)
local p       = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Types: ProfileSelectValues
-------------------------------------------------------------------------------]]
---@param o OptionsMixin
local function MethodsAndProps(o)
    local L = ns:AceLocale()

    --- Automatically called by CreateAndInitFromMixin(..)
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        self.util = O.OptionsUtil:New(o)
        self.loc = O.Localization
    end

    --- Usage:  local instance = OptionsMixin:New(addon)
    --- @param addon DevSuite
    --- @return OptionsMixin
    function o:New(addon) return ns:K():CreateAndInitFromMixin(o, addon) end

    ---@param opt AceConfigOption
    local function ConfigureDebugging(opt)
        --@do-not-package@
        if ns.debug:IsDeveloper() then
            opt.args.debugging = DebugSettings:CreateDebuggingGroup()
            p:a(function() return 'Debugging tab in Settings UI is enabled.' end)
            return
        end
        --@end-do-not-package@
        DEVS_LOG_LEVEL = 0
    end

    function o:CreateOptions()
        self.order = ns:CreateSequence(1)

        local options = {
            name = ns.name,
            handler = self,
            type = "group",
            args = {
                general = self:CreateGeneralOptions()
            }
        }; ConfigureDebugging(options)

        return options
    end

    function o:CreateGeneralOptions()
        local order = self.order

        local aULabel = c2(L['Addon Usage: Automatically Show UI'])
        if not O.API:IsAddonUsageAvailable() then
            aULabel = L['Addon Usage: Automatically Show UI']
        end

        --- @class GeneralConfigOption : AceConfigOption
        --- @field args GeneralConfigOptionArgs
        local general = {
            type  = "group",
            name  = L['General'],
            desc  = L['General::Desc'],
            order = order:next(),
            args  = {
                --desc = { name = " General Configuration ", type = "header", order = order:next() },
                showFPS = {
                    type      = 'toggle',
                    width     = 'full',
                    name      = c2(L['Show Frames-Per-Second (FPS)']),
                    desc      = self.loc:G('Show Frames-Per-Second (FPS)::Desc'),
                    descStyle = 'inline',
                    order     = order:next(),
                    get       = self.util:GlobalGet('show_fps', false),
                    set       = self.util:GlobalSet('show_fps', GC.M.OnToggleFrameRate)
                },
                addonUsage_AutomaticallyShow = {
                    disabled  = not O.API:IsAddonUsageAvailable(),
                    order     = order:next(),
                    width     = 'full',
                    name      = aULabel,
                    desc      = self.loc:G('Addon Usage: Automatically Show UI::Desc'),
                    descStyle = 'inline',
                    type      = 'toggle',
                    get       = self.util:GlobalGet('addon_addonUsage_auto_show_ui'),
                    set       = self.util:GlobalSet('addon_addonUsage_auto_show_ui')
                },
            },
        }

        local showSpecialNotice = ns:db().global.show_AddonManagerHasMovedNotice
        if showSpecialNotice then
            local a = general.args
            a.spacer1           = { type = "description", name = '  ', width = "full", order = order:next() }
            a.specialNoticeText = {
                name     = c1(L['Addon Manager Special Notice']),
                type     = "description",
                fontSize = 'medium',
                order    = order:next()
            }
        end

        return general
    end

    function o:InitOptions()
        local options = self:CreateOptions()
        -- This creates the Profiles Tab/Section in Settings UI
        options.args.profiles = AceDBOptions:GetOptionsTable(ns:db())

        AceConfig:RegisterOptionsTable(ns.addon, options, {
            ns.GC.C.CONSOLE_COMMAND_OPTIONS, ns.GC.C.CONSOLE_COMMAND_OPTIONS_SHORT })
        AceConfigDialog:AddToBlizOptions(ns.addon, ns.addon)
        if API:GetUIScale() > 1.0 then return end

        AceConfigDialog:SetDefaultSize(ns.addon, 950, 600)
    end

end

MethodsAndProps(S)
