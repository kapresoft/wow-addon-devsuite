--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type LibStub
local LibStub = LibStub

--- @type CoreNamespace
local kns = select(2, ...)

--- @type string
local addonName = kns.addon
--- @type GlobalConstants
local GC = kns.GC
--- @type Kapresoft_LibUtil
local K = kns:K()
--- @type Kapresoft_LibUtil_Modules
local KO = kns:KO()

local c2  = K:cf(YELLOW_FONT_COLOR)
local pre_dev = kns.sformat('{{%s::%s}}:', kns.f.debug(kns.addonLogName), c2('Ns'))
local logpd   = kns.LogFunctions.logp(pre_dev)

--[[-----------------------------------------------------------------------------
Log Categories
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
    --- @type OptionsMixin
    OptionsMixin = {},
    --- @type OptionsDebugConsole
    OptionsDebugConsole = {},
    --- @type OptionsUtil
    OptionsUtil = {},
    --- @type PopupDebugDialog
    PopupDebugDialog = {},
}; KO.LibModule.EnrichModules(M)

--- @param o __Namespace | Namespace
local function NameSpacePropertiesAndMethods(o)
  
  local function InitLocalLibStub()
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = o:K().Objects.LibStubMixin:New(
            o.addon, 1.0,
            function(name, newLibInstance) o:Register(name, newLibInstance) end)
    o.LibStubAce       = LibStub
    o.LibStub          = LocalLibStub
  end
  
  --- @param moduleName string The module name, i.e. Logger
  --- @param optionalMajorVersion number|string
  --- @return string The complete module name, i.e. 'DevSuite-Logger-1.0'
  function o:LibName(moduleName, optionalMajorVersion) return GC.LibName(moduleName, optionalMajorVersion) end
  --- @param moduleName string The module name, i.e. Logger
  function o:ToStringFunction(moduleName) return GC.ToStringFunction(moduleName) end
  
  --- @param obj table The library object instance
  function o:Register(libName, obj)
    if not (libName or obj) then return end
    self.O[libName] = obj
  end
  
  --- Simple Library
  function o:NewLib(libName, ...)
    assert(libName, "LibName is required")
    local newLib = {}
    local len    = select("#", ...)
    if len > 0 then newLib = self:K():Mixin({}, ...) end
    newLib.mt = { __tostring = function() return 'Lib:' .. libName end }
    setmetatable(newLib, newLib.mt)
    self.O[libName] = newLib
    --@do-not-package@
    if kns:IsDev() then
      logpd("Lib:", kns.f.val(libName))
    end
    --@end-do-not-package@
    return newLib
  end
  function o:NewLibWithEvent(libName, ...)
    assert(libName, "LibName is required")
    local newLib = self:AceLibrary().AceEvent:Embed({})
    local len    = select("#", ...)
    if len > 0 then newLib = self:K():Mixin(newLib, ...) end
    newLib.mt = { __tostring = GC.ToStringFunction(libName) }
    setmetatable(newLib, newLib.mt)
    self.O[libName] = newLib
    --@do-not-package@
    if kns:IsDev() then
      local n = kns.f.val(kns.sformat('%s (with AceEvent)', libName))
      logpd("Lib:", n)
    end
    --@end-do-not-package@
    return newLib
  end
  
  --- @param dbfn fun() | "function() return addon.db end"
  function o:SetAddOnFn(dbfn) self.addonDbFn = dbfn end
  
  --- @return AddOn_DB
  function o:db() return self.addonDbFn() end
  
  --- @return DevSuite_Global_Config
  function o:g() return self:db().global end
  
  --- @return DebugSettingsFlag_Config
  function o:dbg() return self:db().global.debug end
  
  --- @return Profile_Config
  function o:profile()
    local db = self.addonDbFn();
    return db and db.profile
  end
  --- @return Character_Config
  function o:char() return self:db().char end
  
  --- @return DevSuite
  function o:a() return DEV_SUITE end
  
  --- @return DevConsoleModuleInterface
  function o:DevConsoleModule() return self:a():DevConsole() end
  
  InitLocalLibStub()
end

--- @alias Namespace __Namespace | CategoryLoggerMixin | Kapresoft_LibUtil_NamespaceAceLibraryMixin

--[[-----------------------------------------------------------------------------
Enrich Namespace
-------------------------------------------------------------------------------]]
--- @class __Namespace : CoreNamespace
--- @field gameVersion GameVersion
--- @field LocaleUtil LocaleUtil
local ns = kns

--- @type Modules
ns.M = M

ns.O.CategoryLoggerMixin:Configure(ns, LogCategories)
NameSpacePropertiesAndMethods(ns)

ns.mt = { __tostring = function() return addonName .. '::Namespace'  end }
setmetatable(ns, ns.mt)

--- @type Namespace
DEV_SUITE_NS = ns
if not pf then pf = ns.pformat end
