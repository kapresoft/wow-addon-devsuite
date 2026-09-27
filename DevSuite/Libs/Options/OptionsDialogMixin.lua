--[[-----------------------------------------------------------------------------
Type: GeneralConfigOptionArgs
-------------------------------------------------------------------------------]]
--- @class GeneralConfigOptionArgs : AceConfigOption
--- @field showFPS AceConfigOption
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

-- General labels are longer than the Debug Console ones
--- @type Ace3WidgetArg_DevSuite
local GENERAL_ARG = { layout = { label = { width = 210 } } }

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local L = ns:GetLocale()

local C_GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata

local AceConfigDialog, AceDBOptions = ns:AceConfigDialog(), ns:AceDBOptions()
--- @type API, Kapresoft-AceConfigUtil-2-0
local API, ACU = O.API, ns:AceConfigUtil():New(ns.addon)

local Fonts = O.Fonts
local cfmt = ns:ColorFormatter()
local c1 = cfmt:ColorFn(RED_FONT_COLOR)
local c2 = cfmt:ColorFn(YELLOW_FONT_COLOR)

--- @type AceConfigOption, string
local __edc, __edc_desc_dcfEnabled

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.OptionsDialogMixin()
--- @class OptionsDialogMixin : AceEvent-3.0
local o = ns:Register(libName, ns:NewAceEvent())

local p, t, fmt = ns:log(libName)
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return string
local function GetVersionText()
  local version = C_GetAddOnMetadata(ns.addon, 'Version')
  --@debug@
  version = 'v1.0.0.DEV'
  --@end-debug@
  return version
end

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
  local name = ('%s %s'):format(ns.addon, GetVersionText())

  local options = {
    name = name,
    handler = self,
    type = 'group',
    args = {
      general = self:CreateGeneralOptions(),
    },
  }

  -- disable in favor of manual tracing with EventTrace
  -- ConfigureDebugging(options)

  return options
end

--- Refreshes fonts and desc once DebugChatFrame is default
--- @see DevConsoleModuleMixin#EnableDebugChatFrame
function o:OnEnabledDefaultChatFrame()
  Fonts:RefreshFonts()
  if not __edc then return end
  __edc.desc = __edc_desc_dcfEnabled
end

--- @return GeneralConfigOption
function o:CreateGeneralOptions()
  local order = self.order

  --- @class GeneralConfigOption : AceConfigOption
  --- @field args GeneralConfigOptionArgs
  local general = {
    type = 'group',
    name = L['General'],
    desc = L['General::Desc'],
    order = order:get(),
    args = {},
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
    type = 'toggle',
    order = order:next(),
    width = 'full',
    dialogControl = 'DevSuite_SettingsCheckbox',
    arg = GENERAL_ARG,
    get = ShowEventTraceAtStartupGetFn,
    set = ShowEventTraceAtStartupSetFn,
  })
  a.showEventTraceAtStartup.name = c2(a.showEventTraceAtStartup.name)

  -- DebugConsole
  local function DebugConsoleGetFn() return ns:dbg().enableLogConsole == true end
  local function DebugConsoleSetFn(_, v)
    local val = (v == true)
    ns:dbg().enableLogConsole = val
    if val then return ns:DevConsoleModule():Enable() end
    ns:DevConsoleModule():Disable()
  end
  a.enableDebugConsole = ACU:CreateGlobalOption('Enable Debug Console', {
    type = 'toggle',
    order = order:next(),
    width = 'full',
    dialogControl = 'DevSuite_SettingsCheckbox',
    arg = GENERAL_ARG,
    get = DebugConsoleGetFn,
    set = DebugConsoleSetFn,
  })
  a.enableDebugConsole.name = c2(a.enableDebugConsole.name)
  local edc = a.enableDebugConsole
  __edc, __edc_desc_dcfEnabled = edc, edc.desc
  
  if not DebugChatFrame then
    ns:dbg().enableLogConsole = false
    edc.desc = 'Requires ' .. c1('DebugChatFrame') .. ' AddOn'
  end

  a.showFPS = ACU:CreateGlobalOption('Show Frames-Per-Second (FPS)', {
    type = 'toggle',
    width = 'full',
    dialogControl = 'DevSuite_SettingsCheckbox',
    arg = GENERAL_ARG,
    order = order:next(),
    get = self.util:GlobalGet('show_fps', false),
    set = self.util:GlobalSet('show_fps', GC.M.OnToggleFrameRate),
  })
  a.showFPS.name = c2(a.showFPS.name)
  return general
end

function o:InitOptions()
  local options = self:CreateOptions()
  self.options = options

  -- This creates the Profiles Tab/Section in Settings UI
  options.args.profiles = AceDBOptions:GetOptionsTable(ns:db())

  ns:AceConfig():RegisterOptionsTable(ns.addon, options, {
    GC.C.CONSOLE_COMMAND_OPTIONS,
    GC.C.CONSOLE_COMMAND_OPTIONS_SHORT,
  })
  AceConfigDialog:AddToBlizOptions(ns.addon, ns.addon)
  if API:GetUIScale() > 1.0 then return end

  AceConfigDialog:SetDefaultSize(ns.addon, 658, 420)
end

o:RegisterMessage(GC.toMsg('OnEnabledDefaultChatFrame'), 'OnEnabledDefaultChatFrame')
