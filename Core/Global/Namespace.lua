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
    --- @type fun(fmt:string, ...)|fun(val:string)
    pformat = {},
    --- @type fun(fmt:string, ...)|fun(val:string)
    sformat = {},

    --- @type AceDbInitializerMixin
    AceDbInitializerMixin = {},
    --- @type OptionsMixin
    OptionsMixin = {},

    --- @type DeveloperModeMixin
    DeveloperModeMixin = {},
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

    AceDbInitializerMixin = 'AceDbInitializerMixin',
    OptionsMixin = 'OptionsMixin',
    GlobalConstants = 'GlobalConstants',
    Logger = 'Logger',
    AceLibFactory = 'AceLibFactory',

    Table = 'Table',
    String = 'String',
    Assert = 'Assert',
    Mixin = 'Mixin',

    -- Local Types
    Config = 'Config',
    DebugDialog = 'DebugDialog',
    Developer = 'Developer',
    DeveloperModeMixin = 'DeveloperModeMixin',
    DialogWidgetMixin = 'DialogWidgetMixin',
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

--- Some Utility Methods to make things easier to access the Library
--- @class Kapresoft_LibUtil_Mixins
local Kapresoft_LibUtil_Mixins = {
    K = function(self) return self.Kapresoft_LibUtil end,
    KO = function(self) return self.Kapresoft_LibUtil.Objects  end,
}

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
    n.LibStub = LocalLibStub
    n.O.LibStub = LocalLibStub
end

---@param o Namespace
local function NameSpacePropertiesAndMethods(o)
    --- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
    Mixin(o, Kapresoft_LibUtil_Mixins)

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

    if not _G['pformat'] then _G['pformat'] = o.pformat end

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

    function o:GetAceLocale() return LibStub("AceLocale-3.0"):GetLocale(self.name, true) end

    --- @param libName string The library name. Ex: 'GlobalConstants'
    --- @return Logger
    function o:NewLogger(libName) return self.O.Logger:NewLogger(libName) end
    function o:ToStringNamespaceKeys() return self.pformat(getSortedKeys(self)) end
    function o:ToStringObjectKeys() return self.pformat(getSortedKeys(self.O)) end

    function o:GetLogLevel() return DEVS_LOG_LEVEL end
    --- @param level number The log level between 1 and 100
    function o:SetLogLevel(level) DEVS_LOG_LEVEL = level or 1 end
    --- @param level number
    function o:ShouldLog(level) return self:GetLogLevel() >= level end
    function o:IsVerboseLogging() return self:ShouldLog(20) end

    InitLocalLibStub(o)
end

---Usage:
---```
---local O, LibStub = SDNR_Namespace(...)
---local AceConsole = O.AceConsole
---```
--- @return Namespace
---@param addon string The addon name
---@param ns Namespace
local function CreatNameSpace(addon, ns)

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- @type string
    ns.name = addon
    --- @type string
    ns.nameShort = GC:GetLogName()

    NameSpacePropertiesAndMethods(ns)


    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    return ns
end

if _ns.name then return end; CreatNameSpace(addonName, _ns)
