--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
--- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
--- @class _Mixin
local Mixin = Mixin

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addonName
--- @type Namespace
local _ns
addonName, _ns = ...

--- @type LibStub
local LibStub = LibStub
--- @type GlobalConstants
local GC = LibStub(addonName .. '-GlobalConstants-1.0')

--- @type Kapresoft_LibUtil
local LibUtil = _ns.Kapresoft_LibUtil
local pformat = LibUtil.pformat


--- @type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = pformat.pprint
PrettyPrint.setup({ show_function = true, show_metatable = true, indent_size = 2, depth_limit = 3 })

--[[-----------------------------------------------------------------------------
GlobalObjects
-------------------------------------------------------------------------------]]
--- @class GlobalObjects
local GlobalObjects = {
    --- @type Kapresoft_LibUtil_Table
    Table = {},
    --- @type Kapresoft_LibUtil_String
    String = {},
    --- @type Kapresoft_LibUtil_Assert
    Assert = {},
    --- @type Kapresoft_LibUtil_Mixin
    Mixin = {},
    --- @type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    --- @type LibStub
    LibStubAce = {},
    --- @type LocalLibStub
    LibStub = {},
    --- @type LoggerMixinV2
    LoggerMixinV2 = {},
    --- @type fun(fmt:string, ...)|fun(val:string)
    pformat = {},
    --- @type fun(fmt:string, ...)|fun(val:string)
    sformat = {},

    --- @type AceDbInitializerMixin
    AceDbInitializerMixin = {},
    --- @type API
    API = {},
    --- @type OptionsMixin
    OptionsMixin = {},
    --- @type OptionsMixinEventHandler
    OptionsMixinEventHandler = {},
    --- @type DebuggingSettingsGroup
    DebuggingSettingsGroup = {},
    --- @type DevSuiteController
    DevSuiteController = {},
    --- @type DialogWidgetMixin
    DialogWidgetMixin = {},
    --- @type PopupDebugDialog
    PopupDebugDialog = {},
    --- @type GlobalConstants
    GlobalConstants = {},
    --- @type Logger
    Logger = {},
}

--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
--- @class Modules
local M = {
    LibStubAce = 'LibStubAce',
    LU = 'LU',
    pformat = 'pformat',
    sformat = 'sformat',
    AceLibrary = 'AceLibrary',

    GlobalConstants = 'GlobalConstants',
    Logger = 'Logger',
    AceLibFactory = 'AceLibFactory',

    Table = 'Table',
    String = 'String',
    Assert = 'Assert',
    Mixin = 'Mixin',
    -- Local Types
    AceDbInitializerMixin = 'AceDbInitializerMixin',
    API = 'API',
    Config = 'Config',
    DebugDialog = 'DebugDialog',
    DebuggingSettingsGroup = 'DebuggingSettingsGroup',
    Developer = 'Developer',
    DevSuiteController = 'DevSuiteController',
    DialogWidgetMixin = 'DialogWidgetMixin',
    LoggerMixinV2 = 'LoggerMixinV2',
    OptionsMixin = 'OptionsMixin',
    OptionsMixinEventHandler = 'OptionsMixinEventHandler',
    PopupDebugDialog = 'PopupDebugDialog',
}

local LibUtilObjects = LibUtil.Objects
local AceLibraryObjects = LibUtilObjects.AceLibrary.O
local InitialModuleInstances = {
    AceLibrary = AceLibraryObjects,
    -- Internal Libs --
    GlobalConstants = GC,
    pformat = pformat,

    Table = LibUtilObjects.Table,
    String = LibUtilObjects.String,
    Assert = LibUtilObjects.Assert,
    Mixin = LibUtilObjects.Mixin,
}

--[[-----------------------------------------------------------------------------
Type: LibPackMixin
-------------------------------------------------------------------------------]]
--- @class LibPackMixin
--- @field O GlobalObjects
--- @field KO fun() : Kapresoft_LibUtil_Objects
--- @field name Name The addon name
local LibPackMixin = { };

---@param o LibPackMixin
local function LibPackMixinMethods(o)

    --- Create a new instance of AceEvent or embed to an obj if passed
    --- @return AceEvent
    --- @param obj|nil The object to embed or nil
    function o:AceEvent(obj) return self.O.AceLibrary.AceEvent:Embed(obj or {}) end

    --- Create a new instance of AceBucket or embed to an obj if passed
    --- @return AceBucket
    --- @param obj|nil The object to embed or nil
    function o:AceBucket(obj) return self.LibStubAce('AceBucket-3.0'):Embed(obj or {}) end

    --- @return AceLocale
    function o:AceLocale() return LibStub("AceLocale-3.0"):GetLocale(self.name, true) end

    --- @return Kapresoft_LibUtil_SequenceMixin
    --- @param startingSequence number|nil
    function o:CreateSequence(startingSequence)
        return self:KO().SequenceMixin:New(startingSequence)
    end

end; LibPackMixinMethods(LibPackMixin)

--- @alias NameSpaceFn fun() : Namespace
--- @return Namespace
local function nsfn() return DEVS_NS end

--- Some Utility Methods to make things easier to access the Library
--- @class __NamespaceKapresoftMixin
local NamespaceKapresoftMixin = {}
---@param o __NamespaceKapresoftMixin
local function NamespaceKapresoftMixinMethods(o)

    --- @return Kapresoft_LibUtil
    function o:K() return _ns.Kapresoft_LibUtil end
    --- @return Kapresoft_LibUtil_Objects
    function o:KO() return _ns.Kapresoft_LibUtil.Objects  end

end; NamespaceKapresoftMixinMethods(NamespaceKapresoftMixin)

--- @class __NamespaceLoggerMixin
--- @field O GlobalObjects
local NamespaceLoggerMixin = {}
---@param o __NamespaceLoggerMixin
---@param ns NameSpaceFn
local function NamespaceLoggerMethods(o, ns)
    DEVS_DEBUG_ENABLED_CATEGORIES = DEVS_DEBUG_ENABLED_CATEGORIES or {}

    local function LoggerMixin() return ns().O.LoggerMixinV2 end

    --- @return LogLevel
    function o:GetLogLevel() return DEVS_LOG_LEVEL end
    --- @param level LogLevel
    function o:SetLogLevel(level) DEVS_LOG_LEVEL = level or 1 end
    --- @deprecated
    function o:NewLogger(libName) return ns().O.Logger:NewLogger(libName) end
    --- @param level LogLevel
    function o:ShouldLog(level) return self:GetLogLevel() >= level end
    --- @return boolean
    function o:IsVerboseLogging() return self:ShouldLog(20) end

    --- @param name string | "'ADDON'" | "'BAG'" | "'BUTTON'" | "'DRAG_AND_DROP'" | "'EVENT'" | "'FRAME'" | "'ITEM'" | "'MESSAGE'" | "'MOUNT'" | "'PET'" | "'PROFILE'" | "'SPELL'"
    --- @param v boolean|number | "1" | "0" | "true" | "false"
    function o:SetLogCategory(name, val)
        assert(name, 'Debug category name is missing.')
        ---@param v boolean|nil
        local function normalizeVal(v) if v == 1 or v == true then return 1 end; return 0 end
        DEVS_DEBUG_ENABLED_CATEGORIES[name] = normalizeVal(val)
    end
    function o:IsLogCategoryEnabled(name)
        assert(name, 'Debug category name is missing.')
        local val = DEVS_DEBUG_ENABLED_CATEGORIES[name]
        return val == 1 or val == true
    end
    function o.LogCategory() return LoggerMixin().Category end
    function o.LogCategories() return o.LogCategory():GetCategories() end
    function o:LC() return o.LogCategories() end
    function o:CreateDefaultLogger(moduleName) return LoggerMixin():New(moduleName) end

end; NamespaceLoggerMethods(NamespaceLoggerMixin, nsfn)

---@param n Namespace
local function InitLocalLibStub(n)
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = n:K().Objects.LibStubMixin:New(n.name, 1.0,
            function(name, newLibInstance)
                --- @type Logger
                local loggerLib = LibStub(n:LibName(n.M.Logger))
                if loggerLib then
                    local logger = loggerLib:NewLogger(name)
                    newLibInstance.logger = function() return logger  end
                    logger:log(20, 'New Lib: %s', newLibInstance.major)
                end
                n:Register(name, newLibInstance)
            end)
    n.LibStubAce = LibStub
    n.LibStub = LocalLibStub
    n.O.LibStub = LocalLibStub
end

---@param o __Namespace | Namespace
local function NameSpacePropertiesAndMethods(o)
    local getSortedKeys = o:KO().Table.getSortedKeys

    --- @type AddOn_DB
    local addonDb

    --- @type string
    o.nameShort = GC:GetLogName()

    if 'table' ~= type(o.O) then o.O = {} end

    for key, _ in pairs(M) do
        local lib = InitialModuleInstances[key]
        if lib then o.O[key] = lib end
    end

    o.pformat = o.O.pformat
    o.sformat = sformat
    o.M = M
    o.requiresReload = false
    o.event = o:AceEvent()

    if not _G['pformat'] then _G['pformat'] = o.pformat end

    function o:RequiresReload() return self.requiresReload == true end
    function o:NotifyIfRequiresReload()
        if not self:RequiresReload() then return end
        self:db().callbacks:Fire('OnProfileChanged')
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

    --- @param db AddOn_DB
    function o:SetAddOnDB(db) addonDb = db end

    --- @return AddOn_DB
    function o:db() return addonDb end

    --- @return Profile_Config
    function o:profile() return addonDb and addonDb.profile end

    --- @return GlobalConstants
    function o:GC() return self.O.GlobalConstants end

    --- @return EventNames
    function o:E() return self:GC().E end

    --- @param libName string The library name. Ex: 'GlobalConstants'
    --- @return Logger
    function o:ToStringNamespaceKeys() return self.pformat(getSortedKeys(self)) end
    function o:ToStringObjectKeys() return self.pformat(getSortedKeys(self.O)) end

    InitLocalLibStub(o)
end

--- @alias Namespace __Namespace | LibPackMixin | __NamespaceLoggerMixin | __NamespaceKapresoftMixin

--- @return Namespace
local function CreateNameSpace(...)

    --- @type string
    local addon
    --- @class __Namespace : LibPackMixin
    --- @field O GlobalObjects
    --- @field LibStubAce LibStub
    --- @field LibStub LocalLibStub
    local ns

    addon, ns = ...

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- @type string
    ns.name = addon
    --- @type string
    ns.nameShort = GC:GetLogName()

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    --- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
    Mixin(ns, LibPackMixin, NamespaceKapresoftMixin, NamespaceLoggerMixin)
    NameSpacePropertiesAndMethods(ns)

    --- print(ns.name .. '::Namespace:: pformat:', pformat)
    --- Global Function
    pformat = pformat or ns.pformat

    return ns
end

if _ns.name then return end;

--- @return Namespace
DEVS_NS = CreateNameSpace(...)
--- @return Namespace
function devsuite_ns(...) local _, namespace = ...; return namespace end

