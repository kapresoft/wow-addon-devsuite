--[[-----------------------------------------------------------------------------
Type: GeneralConfigOptionArgs
-------------------------------------------------------------------------------]]
--- @class GeneralConfigOptionArgs : AceConfigOption
--- @field showFPS AceConfigOption
--- @field addonUsage_AutomaticallyShow AceConfigOption
--- @field specialNoticeText AceConfigOption
--- @field spacer1 AceConfigOption
--- @field enableDebugConsole AceConfigOption
--- @field showEventTraceAtStartup AceConfigOption

--[[-----------------------------------------------------------------------------
Type: DebugConsoleOptionArgs
-------------------------------------------------------------------------------]]
--- @class DebugConsoleOptionArgs

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local L = ns:GetLocale()

local AceConfigDialog, AceDBOptions = ns:AceConfigDialog(), ns:AceDBOptions()
local API, ACU = O.API, ns:AceConfigUtil():New(ns.addon)
local cfmt = ns:ColorFormatter()
local c1 = cfmt:ColorFn(RED_FONT_COLOR)
local c2 = cfmt:ColorFn(YELLOW_FONT_COLOR)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.OptionsDialogMixin()
--- @class OptionsDialogMixin : AceEvent-3.0
local o = ns:AceEvent(); ns:Register(libName, o)

--[[-----------------------------------------------------------------------------
Types: ProfileSelectValues
-------------------------------------------------------------------------------]]

--- Automatically called by CreateAndInitFromMixin(..)
--- @param addon DevSuite
function o:Init(addon)
    self.addon = addon
    self.util = O.OptionsUtil:New(o)
end

--- Usage:  local instance = OptionsDialogMixin:New(addon)
--- @param addon DevSuite
--- @return OptionsDialogMixin
function o:New(addon) return CreateAndInitFromMixin(o, addon) end

function o:CreateOptions()
    self.order = ns.CreateSequence(1)

    local options = {
        name = ns.addon,
        handler = self,
        type = "group",
        args = {
            general = self:CreateGeneralOptions(),
        }
    }

    -- disable in favor of manual tracing with EventTrace
    -- ConfigureDebugging(options)

    return options
end

function o:CreateGeneralOptions()
    local order = self.order

    local aULabel = c2(L['Addon Usage: Automatically Show UI'])
    if not API:IsAddonUsageAvailable() then
        aULabel = L['Addon Usage: Automatically Show UI']
    end

    --- @class GeneralConfigOption : AceConfigOption
    --- @field args GeneralConfigOptionArgs
    local general = {
        type  = "group",
        name  = L['General'],
        desc  = L['General::Desc'],
        order = order:get(),
        args  = {},
    }
    local a = general.args

    -- ShowEventTraceAtStartup
    local function ShowEventTraceAtStartupGetFn() return ns:g().trace.show_at_startup == true end
    local function ShowEventTraceAtStartupSetFn(_, v)
        local val = (v == true)
        ns:g().trace.show_at_startup = val
        if val then return ns:traceUtil():ShowUI() end
        ns:traceUtil():HideUI()
    end
    a.showEventTraceAtStartup = ACU:CreateGlobalOption('Show Event Trace At Startup', {
        type = 'toggle', order = order:next(), width = 'full', descStyle = 'inline',
        get  = ShowEventTraceAtStartupGetFn,
        set  = ShowEventTraceAtStartupSetFn,
    }); a.showEventTraceAtStartup.name = c2(a.showEventTraceAtStartup.name)

    -- DebugConsole
    local function DebugConsoleGetFn() return ns:dbg().enableLogConsole == true end
    local function DebugConsoleSetFn(_, v)
        local val = (v == true)
        ns:dbg().enableLogConsole = val
        if val then return ns:DevConsoleModule():Enable() end
        ns:DevConsoleModule():Disable()
    end
    a.enableDebugConsole = ACU:CreateGlobalOption('Enable Debug Console', {
        type = 'toggle', order = order:next(), width = 'full', descStyle = 'inline',
        get  = DebugConsoleGetFn,
        set  = DebugConsoleSetFn,
    }); a.enableDebugConsole.name = c2(a.enableDebugConsole.name)
    local edc = a.enableDebugConsole
    if not DebugChatFrame then
        --a.enableDebugConsole.name = a.enableDebugConsole.name .. '( Requires DebugChatFrame AddOn Library)'
        --a.enableDebugConsole.descStyle = 'inline'
        ns:dbg().enableLogConsole = false
        edc.desc = "Requires " .. c1('DebugChatFrame') .. ' AddOn'
        edc.disabled = true
    end

    a.showFPS = ACU:CreateGlobalOption('Show Frames-Per-Second (FPS)', {
        type      = 'toggle',
        width     = 'full',
        descStyle = 'inline',
        order     = order:next(),
        get       = self.util:GlobalGet('show_fps', false),
        set       = self.util:GlobalSet('show_fps', GC.M.OnToggleFrameRate)
    }); a.showFPS.name = c2(a.showFPS.name)

    a.addonUsage_AutomaticallyShow = {
        disabled  = not O.API:IsAddonUsageAvailable(),
        order     = order:next(),
        width     = 'full',
        name      = aULabel,
        desc      = ns.LocaleUtil.G('Addon Usage: Automatically Show UI::Desc'),
        descStyle = 'inline',
        type      = 'toggle',
        get       = self.util:GlobalGet('addon_addonUsage_auto_show_ui'),
        set       = self.util:GlobalSet('addon_addonUsage_auto_show_ui')
    }
    a.fontSize = {
        name    = c2(L['Console Font Size']),
        desc    = ns.LocaleUtil.G('Choose a Console Font Size'),
        order   = order:next(),
        type    = 'range',
        min     = 10,
        max     = 18,
        step    = 2,
        get     = self.util:GlobalGet('console_fontSize'),
        set     = self.util:GlobalSet('console_fontSize', nil, function(_, val)
            ns:SetChatFrameFontSize(val)
        end)
    }

    local showSpecialNotice = ns:db().global.show_AddonManagerHasMovedNotice
    if showSpecialNotice then
        a.spacer1 = { type = "description", name = '\n\n  ', width = "full", order = order:next() }
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
  self.options = options

  -- This creates the Profiles Tab/Section in Settings UI
  options.args.profiles = AceDBOptions:GetOptionsTable(ns:db())

  ns:AceConfig():RegisterOptionsTable(ns.addon, options, {
    GC.C.CONSOLE_COMMAND_OPTIONS, GC.C.CONSOLE_COMMAND_OPTIONS_SHORT })
  AceConfigDialog:AddToBlizOptions(ns.addon, ns.addon)
  if API:GetUIScale() > 1.0 then return end

  AceConfigDialog:SetDefaultSize(ns.addon, 950, 600)
end
