--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addonName
--- @type CoreNamespace
local kns
addonName, kns = ...

--- @type LibStub
local LibStub = LibStub
--- @type GlobalConstants
local GC = kns.GC

--- @type Kapresoft_LibUtil
local LibUtil = kns.Kapresoft_LibUtil
local KO = LibUtil.Objects
local pformat = LibUtil.pformat

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
    --- @type ConfigDialogController
    ConfigDialogController = {},
    --- @type Developer
    Developer = {},
    --- @type MainController
    MainController = {},
    --- @type DialogWidgetMixin
    DialogWidgetMixin = {},
    --- @type OptionsMixin
    OptionsMixin = {},
    --- @type OptionsUtil
    OptionsUtil = {},
    --- @type PopupDebugDialog
    PopupDebugDialog = {},
    --- @type Localization
    Localization = {},
};

--- @param name Name
--- @param module Module
for name, module in pairs(M) do
    module.name = name
    module.mt = {
        __tostring = function() return "Module:" .. name  end,
        __call = function() return name  end
    }
    setmetatable(module, module.mt)
end

--- @class __NamespaceLoggerMixin
--- @field O Modules
local NamespaceLoggerMixin = {}
---@param o __NamespaceLoggerMixin
local function NamespaceLoggerMethods(o)
    DEVS_DEBUG_ENABLED_CATEGORIES = DEVS_DEBUG_ENABLED_CATEGORIES or {}

    local CategoryLogger = KO.CategoryMixin:New()
    CategoryLogger:Configure(kns.addonLogName, LogCategories, {
        consoleColors = GC.C.CONSOLE_COLORS,
        levelSupplierFn = function() return DEVS_LOG_LEVEL  end,
        enabledCategoriesSupplierFn = function() return DEVS_DEBUG_ENABLED_CATEGORIES end,
        printerFn = kns.print,
        enabled = kns.debug:IsDeveloper(),
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
    --- @return Kapresoft_CategoryLogger
    function o:CreateDefaultLogger(moduleName)
        local p = self:LC().DEFAULT:NewLogger('Namespace.CDL')
        p:f3(function() return 'Creating Default Logger for: %s', moduleName end)
        return LogCategories.DEFAULT:NewLogger(moduleName) end

end; NamespaceLoggerMethods(NamespaceLoggerMixin)

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

    --- Simple Library
    function o:NewLib(libName, ...)
        assert(libName, "LibName is required")
        local newLib = {}
        local len = select("#", ...)
        if len > 0 then newLib = self:K():Mixin({}, ...) end
        newLib.mt = { __tostring = function() return 'Lib:' .. libName end}
        setmetatable(newLib, newLib.mt)
        self.O[libName] = newLib
        --@do-not-package@
        if kns.debug:IsDeveloper() then
            local p  = self:LC().DEFAULT:NewLogger('Ns')
            p:vv(function() return "Lib: %s", kns.f.val(libName) end)
        end
        --@end-do-not-package@
        return newLib
    end
    function o:NewLibWithEvent(libName, ...)
        assert(libName, "LibName is required")
        local newLib = self:AceLibrary().AceEvent:Embed({})
        local len = select("#", ...)
        if len > 0 then newLib = self:K():Mixin(newLib, ...) end
        newLib.mt = { __tostring = GC.ToStringFunction(libName)}
        setmetatable(newLib, newLib.mt)
        self.O[libName] = newLib
        --@do-not-package@
        if kns.debug:IsDeveloper() then
            local p  = self:LC().DEFAULT:NewLogger('Ns')
            local n =  kns.f.val(kns.sformat('%s (with AceEvent)', libName))
            p:vv(function() return "Lib: %s", n end)
        end
        --@end-do-not-package@
        return newLib
    end

    --- @param dbfn fun() | "function() return addon.db end"
    function o:SetAddOnFn(dbfn) self.addonDbFn = dbfn end

    --- @return AddOn_DB
    function o:db() return self.addonDbFn() end

    --- @return Profile_Config
    function o:profile() local db = self.addonDbFn(); return db and db.profile end

    InitLocalLibStub(o)
end

--- @alias Namespace __Namespace | __NamespaceLoggerMixin

--- @return Namespace
local function CreateNameSpace(...)

    --- @class __Namespace : CoreNamespace
    --- @field gameVersion GameVersion
    --- @field O Modules
    --- @field LibStubAce LibStub
    --- @field LibStub LocalLibStub
    local ns = select(2, ...)

    --- @type Modules
    ns.O = ns.O or {}

    --- @type Modules
    --- TODO: O or M needs to be deprecated. Which one?
    ns.M = M

    --- @type string
    --- @deprecated Deprecated. Use ns.addonShortName
    ns.nameShort = ns.addonShortName

    --- @see BlizzardInterfaceCode:Interface/SharedXML/Mixin.lua
    ns:K():Mixin(ns, NamespaceLoggerMixin)
    NameSpacePropertiesAndMethods(ns)

    ns.mt = { __tostring = function() return ns.addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    return ns
end;
--- @type Namespace
DEVS_NS = CreateNameSpace(...)
