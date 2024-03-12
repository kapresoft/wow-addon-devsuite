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
--- @type Kapresoft_Base_Namespace
local kns
addonName, kns = ...

--- @type LibStub
local LibStub = LibStub
--- @type GlobalConstants
local GC = LibStub(addonName .. '-GlobalConstants-1.0')

--- @type Kapresoft_LibUtil
local LibUtil = kns.Kapresoft_LibUtil
local KO = LibUtil.Objects
local pformat = LibUtil.pformat

--- @type Kapresoft_LibUtil_PrettyPrint
local PrettyPrint = pformat.pprint
PrettyPrint.setup({ show_function = true, show_metatable = true, indent_size = 2, depth_limit = 3 })

--[[-----------------------------------------------------------------------------
Log Categories
-------------------------------------------------------------------------------]]
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
GlobalObjects
-------------------------------------------------------------------------------]]
--- @class GlobalObjects
--- @field LibStubAce LibStub
--- @field LibStub LocalLibStub
--- @field Table Kapresoft_LibUtil_Table
--- @field String Kapresoft_LibUtil_String
--- @field Assert Kapresoft_LibUtil_Assert
--- @field Mixin Kapresoft_LibUtil_Mixin
--- @field AceLibrary Kapresoft_LibUtil_AceLibraryObjects
--- @field AceDbInitializerMixin AceDbInitializerMixin
--- @field API API
--- @field OptionsMixin OptionsMixin
--- @field OptionsMixinEventHandler OptionsMixinEventHandler
--- @field DebuggingSettingsGroup DebuggingSettingsGroup
--- @field ConfigDialogController ConfigDialogController
--- @field MainController MainController
--- @field DialogWidgetMixin DialogWidgetMixin
--- @field PopupDebugDialog PopupDebugDialog
--- @field GlobalConstants GlobalConstants
--- @field OptionsUtil OptionsUtil
--- @field pformat fun(fmt:string, ...)|fun(val:string)
--- @field sformat fun(fmt:string, ...)|fun(val:string)

--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
--- @class Modules
local M = {
    LibStubAce = '',
    LU = '',
    pformat = '',
    sformat = '',
    AceLibrary = '',

    GlobalConstants = '',
    Logger = '',
    AceLibFactory = '',

    Table = '',
    String = '',
    Assert = '',
    Mixin = '',
    -- Local Types
    AceDbInitializerMixin = '',
    API = '',
    Config = '',
    DebugDialog = '',
    DebuggingSettingsGroup = '',
    ConfigDialogController = '',
    Developer = '',
    MainController = '',
    DialogWidgetMixin = '',
    OptionsMixin = '',
    OptionsMixinEventHandler = '',
    OptionsUtil = '',
    PopupDebugDialog = '',
}; for moduleName in pairs(M) do M[moduleName] = moduleName end

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

--- @alias NameSpaceFn fun() : Namespace
--- @return Namespace
local function nsfn() return DEVS_NS end

--- @class __NamespaceLoggerMixin
--- @field O GlobalObjects
local NamespaceLoggerMixin = {}
---@param o __NamespaceLoggerMixin
---@param ns NameSpaceFn
local function NamespaceLoggerMethods(o, ns)
    DEVS_DEBUG_ENABLED_CATEGORIES = DEVS_DEBUG_ENABLED_CATEGORIES or {}

    local CategoryLogger = KO.CategoryMixin
    CategoryLogger:Configure(addonName, LogCategories, {
        consoleColors = GC.C.CONSOLE_COLORS,
        levelSupplierFn = function() return DEVS_LOG_LEVEL  end,
        enabledCategoriesSupplierFn = function() return DEVS_DEBUG_ENABLED_CATEGORIES end,
    })
    o.LogCategory = CategoryLogger

    --- @return number
    function o:GetLogLevel() return DEVS_LOG_LEVEL end
    --- @param level number
    function o:SetLogLevel(level) DEVS_LOG_LEVEL = level or 1 end

    --- @param name string | "'ADDON'" | "'BAG'" | "'BUTTON'" | "'DRAG_AND_DROP'" | "'EVENT'" | "'FRAME'" | "'ITEM'" | "'MESSAGE'" | "'MOUNT'" | "'PET'" | "'PROFILE'" | "'SPELL'"
    --- @param v boolean|number | "1" | "0" | "true" | "false"
    function o:SetLogCategory(name, val)
        assert(name, 'Debug category name is missing.')
        ---@param v boolean|nil
        local function normalizeVal(v) if v == 1 or v == true then return 1 end; return 0 end
        DEVS_DEBUG_ENABLED_CATEGORIES[name] = normalizeVal(val)
    end
    --- @return boolean
    function o:IsLogCategoryEnabled(name)
        assert(name, 'Debug category name is missing.')
        local val = DEVS_DEBUG_ENABLED_CATEGORIES[name]
        return val == 1 or val == true
    end
    function o:LC() return LogCategories end
    function o:CreateDefaultLogger(moduleName) return LogCategories.DEFAULT:NewLogger(moduleName) end

end; NamespaceLoggerMethods(NamespaceLoggerMixin, nsfn)

---@param n Namespace
local function InitLocalLibStub(n)
    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = n:K().Objects.LibStubMixin:New(n.name, 1.0,
            function(name, newLibInstance)
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

    --- Simple Library
    function o:NewLib(libName, ...)
        assert(libName, "LibName is required")
        local newLib = {}
        local len = select("#", ...)
        if len > 0 then newLib = self:K():Mixin({}, ...) end
        newLib.mt = { __tostring = GC.ToStringFunction(libName)}
        setmetatable(newLib, newLib.mt)
        self.O[libName] = newLib
        return newLib
    end
    function o:NewLibWithEvent(libName, ...)
        assert(libName, "LibName is required")
        local newLib = self.O.AceLibrary.AceEvent:Embed({})
        local len = select("#", ...)
        if len > 0 then newLib = self:K():Mixin(newLib, ...) end
        newLib.mt = { __tostring = GC.ToStringFunction(libName)}
        setmetatable(newLib, newLib.mt)
        self.O[libName] = newLib
        return newLib
    end

    --- @param dbfn fun() | "function() return addon.db end"
    function o:SetAddOnFn(dbfn) self.addonDbFn = dbfn end

    --- @return AddOn_DB
    function o:db() return self.addonDbFn() end

    --- @return Profile_Config
    function o:profile() local db = self.addonDbFn(); return db and db.profile end

    --- @return Logger
    function o:ToStringNamespaceKeys() return self.pformat(getSortedKeys(self)) end
    function o:ToStringObjectKeys() return self.pformat(getSortedKeys(self.O)) end

    function o:_ns() print('Namespace keys:', pformat(self:ToStringNamespaceKeys())) end
    function o:_o() print('Namespace Object keys:', pformat(self:ToStringObjectKeys())) end

    InitLocalLibStub(o)
end

--- @alias Namespace __Namespace | Kapresoft_LibUtil_NamespaceAceLibraryMixin | Kapresoft_LibUtil_NamespaceKapresoftLibMixin

--- @return Namespace
local function CreateNameSpace(...)

    --local LibPackMixin = _ns.ext.LibPackMixin

    --- @type string
    local addon
    --- @class __Namespace : __NamespaceLoggerMixin
    --- @field O GlobalObjects
    --- @field LibStubAce LibStub
    --- @field LibStub LocalLibStub
    local ns

    addon, ns = ...

    local AceLibraryMixin = LibUtil.Objects.NamespaceAceLibraryMixin
    local KapresoftLibMixin = LibUtil.Objects.NamespaceKapresoftLibMixin

    --- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
    Mixin(ns, AceLibraryMixin, KapresoftLibMixin, NamespaceLoggerMixin)
    -- NamespaceKapresoftMixin

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- @type string
    ns.addon = addon
    --- @type string
    ns.name = addon
    --- @type string
    ns.nameShort = GC:GetLogName()
    ns.GC = GC

    NameSpacePropertiesAndMethods(ns)

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)


    --- print(ns.name .. '::Namespace:: pformat:', pformat)
    --- Global Function
    pformat = pformat or ns.pformat

    return ns
end

if kns.name then return end;

--- @return Namespace
DEVS_NS = CreateNameSpace(...)
--- @return Namespace
function devsuite_ns(...) return select(2, ...) end
