--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub = LibStub

--- @type PreNamespace
local kns = select(2, ...)

--- @type string
local addonName = kns.addon

--- @type Kapresoft_LibUtil
local K = kns.Kapresoft_LibUtil
--- @type Kapresoft_LibUtil_Modules
local KO = K.Objects

--[[-----------------------------------------------------------------------------
Log Categories
todo: remove LogCategories
-------------------------------------------------------------------------------]]
--- @class LogCategories
local LogCategories = {
    --- @type Kapresoft_LogCategory
    DEFAULT = 'DEFAULT',
    --- @type Kapresoft_LogCategory
    API = "AP",
    --- @type Kapresoft_LogCategory
    OPTIONS = "OP",
    --- @type Kapresoft_LogCategory
    EVENT = "EV",
    --- @type Kapresoft_LogCategory
    FRAME = "FR",
    --- @type Kapresoft_LogCategory
    MESSAGE = "MS",
    --- @type Kapresoft_LogCategory
    PROFILE = "PR",
    --- @type Kapresoft_LogCategory
    DB = "DB",
    --- @type Kapresoft_LogCategory
    DEV = "DV",
}

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
    --- @type CategoryLoggerMixin
    CategoryLoggerMixin = {},
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
    --- @type OptionsMixin
    OptionsMixin = {},
    --- @type OptionsDebugConsole
    OptionsDebugConsole = {},
    --- @type OptionsUtil
    OptionsUtil = {},
    --- @type PopupDebugDialog
    PopupDebugDialog = {},
    
    --- Dev Mode Only
    --- @type LibIconPickerUtil
    LibIconPickerUtil = {},
}; KO.LibModule.EnrichModules(M)


--[[-----------------------------------------------------------------------------
Enrich Namespace
-------------------------------------------------------------------------------]]
--- @class Namespace : PreNamespace, CategoryLoggerMixin, ChatLogFrameMixin
--- @field GC GlobalConstants
--- @field addon string
--- @field gameVersion GameVersion
--- @field CategoryLoggerMixin CategoryLoggerMixin
--- @field O Modules
--- @field LocaleUtil LocaleUtil
--- @field fmt LibPrettyPrint_Formatter
--- @field printer LibPrettyPrint_Printer
--- @field eventTraceUtil EventTraceUtil
--- @field logHolder LogHolder
local ns = kns
ns.O = ns.O or {}
ns.nameShort = 'DS'

--[[-----------------------------------------------------------------------------
Colors
-------------------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_ColorDefinition
ns.consoleColors = {
    primary   = 'FF780A',
    secondary = 'fbeb2d',
    tertiary = 'ffffff',
}
--ns.ch = ns:NewConsoleHelper(ns.consoleColors)

--- Color Formatters
ns.f = {
    --- Use this for values
    val = K:cf(LIGHTGRAY_FONT_COLOR),
    debug = K:cf(COMMON_GRAY_COLOR),
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
--- @field printer1 fun(moduleName:Name) : LibPrettyPrint_PrintFn A simple printer
--- @field printer2 fun(moduleName:Name) : LibPrettyPrint_PrintFn A delayed printer
--- @field tracer1 fun(moduleName:Name) : TraceFn A simple tracer
--- @field tracer2 fun(moduleName:Name) : TraceFnFormatted A tracer with auto formatting of variables

ns.logHolder = {}; do
  local h = ns.logHolder; local noop = function(_moduleName) return function() end end
  h.printer1 = noop; h.printer2 = noop
  h.tracer1 = noop; h.tracer2 = noop
end

--- @type Modules
ns.M = M

-- todo: Remove CategoryLoggerMixin @see CategoryLoggerMixin#LC() and CategoryLoggerMixin#CreateDefaultLogger()
ns.CategoryLoggerMixin:Configure(ns, LogCategories)

ns.mt = { __tostring = function() return addonName .. '::Namespace'  end }
setmetatable(ns, ns.mt)

local function InitLocalLibStub()
  --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
  local LocalLibStub = ns:K().Objects.LibStubMixin:New(
          ns.addon, 1.0,
          function(name, newLibInstance) ns:Register(name, newLibInstance) end)
  ns.LibStubAce       = LibStub
  ns.LibStub          = LocalLibStub
end

-- ###############################################################
-- Loggers/Tracers:: NoOp in Official Releases
-- ###############################################################

--- @alias TraceFn fun(...: any) : void @Printer function that outputs plain values to Blizzard Trace UI (like print)
--- @alias TraceFnFormatted fun(...: any) : void @Printer function that outputs formatted values to Blizzard Trace UI (like print)

--- Returns the print, delayed-print, tracer, formatted-tracer functions
--- ```
--- local p, pd, t, tf = ns:log('EventHandler')
--- ```
--- @param moduleName Name
--- @return LibPrettyPrint_PrintFn, LibPrettyPrint_PrintFn, TraceFn, TraceFnFormatted
function ns:log(moduleName)
  local h = self.logHolder
  return h.printer1(moduleName), h.printer2(moduleName), h.tracer1(moduleName), h.tracer2(moduleName)
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
function ns:Ace() return LibStub('Kapresoft-AceLib-2-0') end
function ns:Table() return LibStub('Kapresoft-Table-2-0') end
function ns:String() return LibStub('Kapresoft-String-2-0') end
function ns:AceConfigUtil() return LibStub('Kapresoft-AceConfigUtil-2-0') end
function ns:ColorFormatter() return LibStub('Kapresoft-ColorFormatter-2-0') end

--- @return table<string, string>
function ns:GetLocale() return ns:Ace():GetLocale(self.addon, true) end

--- @param rgbHex RGBHex|nil    @Optional
--- @return fun(key:string) : string The color formatted key
function ns.colorFn(rgbHex)
  return function(text)
    local c = CreateColorFromRGBHexString(rgbHex)
    assert(c, ('Invalid RGBHex color: %s'):format(rgbHex))
    return c:WrapTextInColorCode(text)
  end
end

--- @param obj table The library object instance
function ns:Register(libName, obj)
  if not (libName or obj) then return end
  self.O[libName] = obj
end

--- Simple Library
function ns:NewLib(libName, ...)
  assert(libName, "LibName is required")
  local newLib = {}
  local len    = select("#", ...)
  if len > 0 then newLib = self:K():Mixin({}, ...) end
  newLib.mt = { __tostring = function() return 'Lib:' .. libName end }
  setmetatable(newLib, newLib.mt)
  self.O[libName] = newLib
  return newLib
end
function ns:NewLibWithEvent(libName, ...)
  assert(libName, "LibName is required")

  local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
  local newLib = self:AceLibrary().AceEvent:Embed({})
  local len    = select("#", ...)
  if len > 0 then newLib = self:K():Mixin(newLib, ...) end
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
function ns:g() return self:db().global end

--- @return DebugSettingsFlag_Config
function ns:dbg() return self:db().global.debug end

--- @return Profile_Config
function ns:profile()
  local db = self.addonDbFn();
  return db and db.profile
end
--- @return Character_Config
function ns:char() return self:db().char end

--- @return DevSuite
function ns.a() return DEV_SUITE end

--- @return DevConsoleModuleInterface
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

InitLocalLibStub()

--[[-----------------------------------------------------------------------------
--- Global Settings
-------------------------------------------------------------------------------]]
--- @type Namespace
DEV_SUITE_NS = ns
if not pf then pf = ns.pformat end
