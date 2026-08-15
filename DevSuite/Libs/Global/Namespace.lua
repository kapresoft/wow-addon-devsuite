--- @alias PrinterFunction fun(...:any):void
--- @alias TracerFunction fun(...:any):void

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub
local AceLib = LibStub('Kapresoft-AceLib-2-0')
local DCFM = LibStub('Kapresoft-DebugChatFrameMixin-2-0')
local GVM = LibStub('Kapresoft-GameVersionMixin-2-0')

local strupper = strupper or string.upper

addonName, xns = ...;

--- @class DevSuite_Namespace : Kapresoft-AceLib-2-0, Kapresoft-DebugChatFrameMixin-2-0, Kapresoft-GameVersionMixin-2-0
--- @field GC GlobalConstants
--- @field addon string
--- @field chatFrame ChatFrame
--- @field O Modules
--- @field LocaleUtil LocaleUtil
--- @field fmt LibPrettyPrint_Formatter
--- @field printer LibPrettyPrint_Printer
--- @field eventTraceUtil EventTraceUtil
--- @field logHolder LogHolder
--- @field mountID MountID The displayed Mount ID :: Dump Cursor Info feature
local ns = xns

Mixin(ns, GVM, AceLib, DCFM)

ns.addon = addonName
ns.O = ns.O or {}
ns.nameShort = 'DS'
ns.traceName = strupper(ns.addon)
ns.sformat = string.format

--- @type Kapresoft-ColorFormatter-2-0
local ColorFormatter__

--- Expose globally for devs to use.
--- @param prefix string @The prefix or tag name
--- @param ... any
function tr(prefix, ...)
  local c = CreateColorFromHexString('466EFFff')
  local tag = c:WrapTextInColorCode(ns.traceName)
  if type(prefix) == 'string' then
    tag = c:WrapTextInColorCode(('%s_%s'):format(ns.traceName, strupper(prefix)))
  end
  if not EventTrace then return end; EventTrace:LogEvent(tag, ...)
end

--- @return Kapresoft-ColorFormatter-2-0
local function ColorFormatter()
    if not ColorFormatter__ then ColorFormatter__ = LibStub('Kapresoft-ColorFormatter-2-0') end
    return ColorFormatter__
end

--[[-----------------------------------------------------------------------------
Type: Module
-------------------------------------------------------------------------------]]
--- @class Module
--- @field name Name

--[[-----------------------------------------------------------------------------
Type: Modules
-------------------------------------------------------------------------------]]
--- @class Modules
local M = {
    --- @type AceDbInitializerMixin
    AceDbInitializerMixin = {},
    --- @type API
    API = {},
    --- @type DatabaseSchema
    DatabaseSchema = {},
    --- @type DebugDialog
    DebugDialog = {},
    --- @type DebuggingSettingsGroup
    DebuggingSettingsGroup = {},
    --- @type ConfigDialogController
    ConfigDialogController = {},
    --- @type MainController
    MainController = {},
    --- @type DialogWidgetMixin
    DialogWidgetMixin = {},
    --- @type DevConsoleModuleMixin
    DevConsoleModuleMixin = {},
    --- @type EventTraceUtil
    EventTraceUtil = {},
    --- @type OptionsDialogMixin
    OptionsDialogMixin = {},
    --- @type OptionsDebugConsole
    OptionsDebugConsole = {},
    --- @type OptionsUtil
    OptionsUtil = {},
    --- @type PickupHooks
    PickupHooks = {},
    --- @type PopupDebugDialog
    PopupDebugDialog = {},

    --- Dev Mode Only
    --- @type LibIconPickerUtil
    LibIconPickerUtil = {},
}
local ModuleUtil = LibStub('Kapresoft-ModuleUtil-2-0')
ModuleUtil:EnrichModules(M)

--[[-----------------------------------------------------------------------------
Colors
-------------------------------------------------------------------------------]]
--- @see ColorMixin
--- @see Kapresoft-ColorFormatter-2-0#ColorFn
---
--- @param color colorRGBA|HexRGBA|HexRGB|HexRGBA @ RED_THREAT_COLOR | '565656fc' | '565656' | 'fc565656'
--- @return cfFn        @The color formatter function
--- @return colorRGBA?  @The color object
function ns:ColorFn(color) return ColorFormatter():ColorFn(color) end

--- @type Kapresoft-ColorDefinition-2-0
ns.consoleColors = {
    primary   = CreateColorFromRGBHexString('FF780A'),
    secondary = CreateColorFromRGBHexString('fbeb2d'),
    tertiary  = CreateColorFromRGBHexString('ffffff'),
}

--- Color Formatters: Use these for values
ns.f = {
    val = ns:ColorFn(LIGHTGRAY_FONT_COLOR),
    debug = ns:ColorFn(COMMON_GRAY_COLOR),
}

--[[-----------------------------------------------------------------------------
Settings
-------------------------------------------------------------------------------]]
--[[-----------------------------------------------------------------------------
Type: Settings
Override in DeveloperSetup to enable
-------------------------------------------------------------------------------]]
--- @class DevSuite_Settings
--- @field developer boolean if true: enables developer mode
ns.settings = { developer = false }

--- @return boolean
function ns.IsDev() return ns.settings.developer == true end

--[[-------------------------------------------------------------------
Formatter/Printer
---------------------------------------------------------------------]]
local function predicateFn() return ns.IsDev() end

ns.fmt = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 }); fmt = ns.fmt
ns.printer = LibPrettyPrint:Printer({
  prefix = ns.nameShort, formatter = ns.fmt,
  prefix_color = '466EFF', sub_prefix_color = '9CFF9C',
}, predicateFn)

--- @class LogHolder
--- @field printer fun(moduleName:Name) : PrinterFunction A simple printer
--- @field tracer fun(moduleName:Name) : TracerFunction

ns.logHolder = {}; do
  local h = ns.logHolder; local noop = function(_moduleName) return function() end end
  h.printer = noop; h.tracer = noop
end

--- @type Modules
ns.M = M

-- ###############################################################
-- Loggers/Tracers:: NoOp in Official Releases
-- ###############################################################

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, t, fmt = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return PrinterFunction, TracerFunction, LibPrettyPrint_Formatter
function ns:log(moduleName)
  local h = self.logHolder
  return h.printer(moduleName), h.tracer(moduleName), ns.fmt
end

--- Returns the tracer and formatter
--- ```
--- local p, t, fmt = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return TracerFunction, LibPrettyPrint_Formatter
function ns:trace(moduleName)
  local _, t, fmt = self:log(moduleName)
  return t, fmt
end

local SequenceMixin = LibStub('Kapresoft-SequenceMixin-2-0')

--- @param startingSequence number|nil
--- @return Kapresoft-SequenceMixin-2-0
function ns.CreateSequence(startingSequence)
  return SequenceMixin.New(startingSequence)
end

--- @return EventTraceUtil
function ns:traceUtil() return self.eventTraceUtil end
--- @return EventTrace
function ns:evt() return self:traceUtil().evt end
function ns:InitEventTrace()
  local trace = self:g().trace
  self.eventTraceUtil = self.O.EventTraceUtil:New(self.addon, trace.show_at_startup)
  self:traceUtil():SetEventTraceSearchKeyword(trace.preset_keyword)
end

function ns:Table() return LibStub('Kapresoft-Table-2-0') end
function ns:String() return LibStub('Kapresoft-String-2-0') end
function ns:AceConfigUtil() return LibStub('Kapresoft-AceConfigUtil-2-0') end
function ns:ColorFormatter() return ColorFormatter() end
function ns:AddonUtil() return LibStub('Kapresoft-AddonUtil-2-0') end
function ns:LuaEvaluator() return LibStub('Kapresoft-LuaEvaluator-2-0') end

--- @return table<string, string>
function ns:GetLocale() return ns:AceLocale():GetLocale(self.addon, true) end

--- @param obj table The library object instance
function ns:Register(libName, obj)
  if not (libName or obj) then return end
  self.O[libName] = obj
  return obj
end

--- @generic T
--- @param libName `T`
--- @param ... any? @Mixins
--- @return table|T library
function ns:NewLib2(libName, ...)
  assertsafe(type(libName) == 'string', "ns:NewLibSimple(libName): {libName} should be a string.")
  local newLib = {}
  local len    = select("#", ...)
  if len > 0 then newLib = Mixin({}, ...) end
  newLib.DevSuite_LibName = libName
  self.O[libName] = newLib
  return newLib
end

-- todo next: find out if mt is being used, if not use NewLib2 for NewLib()
--- Simple Library
function ns:NewLib(libName, ...)
  assert(libName, "LibName is required")
  local newLib = {}
  local len    = select("#", ...)
  if len > 0 then newLib = Mixin({}, ...) end
  local mt = { __tostring = function() return 'Lib:' .. libName end }
  setmetatable(newLib, mt)
  self.O[libName] = newLib
  return newLib
end

-- todo next: refactor and use NewLib(libName, 'AceEvent-3.0')
function ns:NewLibWithEvent(libName, ...)
  assert(libName, "LibName is required")

  local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
  local newLib = self:NewAceEvent()
  local len    = select("#", ...)
  if len > 0 then newLib = Mixin(newLib, ...) end
  newLib.mt = { __tostring = function() return string.format(TOSTRING_ADDON_FMT, libName) end }
  setmetatable(newLib, newLib.mt)
  self.O[libName] = newLib

  return newLib
end

--- @param dbfn fun() : AceDBObjectInstance
function ns:SetAddOnFn(dbfn) self.addonDbFn = dbfn end

--- @return AceDBObjectInstance
function ns:db() return self.addonDbFn() end

--- @return DevSuite_Global_Config
function ns:g() return self:db()['global'] end

--- @return DebugSettingsFlag_Config
function ns:dbg() return self:g().debug end

--- @return Profile_Config
function ns:profile()
  local db = self.addonDbFn();
  return db and db.profile
end
--- @return Character_Config
function ns:char() return self:db().char end

--- @return DevSuite
function ns.a() return DevSuite end

--- @return DevConsoleModule
function ns:DevConsoleModule() return self.a():DevConsole() end

--- @param keyword string
function ns:SetEventTraceSearchKeyword(keyword)
  if type(keyword) ~= 'string' then return end
  local s = self:evt().Log.Bar.SearchBox
  if not s then return end
  s:SetText(keyword)
end

function ns.GameTooltip_DefaultAnchor()
  GameTooltip:SetOwner(UIParent, 'ANCHOR_NONE')
  GameTooltip:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -10, 70)
end

---@param chatFrame ChatFrame
function ns:RegisterChatFrame(chatFrame) self.chatFrame = chatFrame end

--InitLocalLibStub()

--[[-----------------------------------------------------------------------------
--- Global Settings
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
DevSuite_NS = ns
