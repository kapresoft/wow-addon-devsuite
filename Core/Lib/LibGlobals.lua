-- log levels, 10, 20, (+10), 100

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
--local format = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

-- ## Start Here ---
local Core = __K_Core_DevTools
local LibStub = Core:LibPack()

-- ABP_LOG_LEVEL is also in use here
local DB_NAME = 'DEVT_DB'

local addonName, versionFormat, logPrefix = Core:GetAddonInfo()

---@class Module
local M = {

    --Logger = 'Logger',
    LogFactory = 'LogFactory',
    --PrettyPrint = 'PrettyPrint',
    AceLibFactory = 'AceLibFactory',

    -- ## Lib/Util ## --
    Table = 'Table',
    String = 'String',
    Assert = 'Assert',
    Mixin = 'Mixin',

    Config = 'Config',

    -- ## Widgets ## --
    DialogWidgetMixin = 'DialogWidgetMixin',
    DebugDialog = 'DebugDialog',
    Developer = 'Developer',

}
-- TODO: Remove 'Module'
local Module = M

---@class LibGlobals
local L = {
    -- use whole number if no longer in beta
    name = addonName,
    addonName = addonName,
    version = GetAddOnMetadata(addonName, 'Version'),
    versionText = GetAddOnMetadata(addonName, 'X-Github-Project-Version'),
    dbName = DB_NAME,
    versionFormat = versionFormat,
    logPrefix = logPrefix,
    M = Module,
    mt = {
        __tostring = function() return addonName .. "::LibGlobals" end,
        __call = function (_, ...)
            --local libNames = {...}
            --print("G|libNames:", pformat(libNames))
            return Core:Lib(...)
        end
    }
}
setmetatable(L, L.mt)

---@type Core
function L:Core() return Core end

---```
---Example:
---local LibStub, M, G = DEVT_LibGlobals:LibPack()
---```
---@return LocalLibStub, Module, LibGlobals
function L:LibPack() return LibStub, M, L end

---@return LocalLibStub, LogFactory
--function _L:LibPack() return LibStub, LibStub('LogFactory') end

---@return LibStub, NewLibrary, LibGlobals
function L:LibPack_Ace()
    local AceLibStub = Core:LibPack_Ace()
    local _, NewLibrary = Core:LibPack()
    return AceLibStub, NewLibrary, L
end

---@return Module, LibGlobals
function L:LibPack_Module() return Module, L
end

---### Example:
---local LibStub, Module, LogFactory, LibGlobals = LibGlobals:LibPack()
---@return LocalLibStub, Module, LogFactory, LibGlobals
function L:LibPack_UI() return LibStub, Module, self:Get(M.LogFactory), L
end

---```
---Example:
---local LibStub, Module, Core, LibGlobals = LibGlobals:LibPack_NewMixin()
---```
---@return LocalLibStub, Module, Core, LibGlobals
function L:LibPack_NewMixin() return LibStub, Module, Core, L
end

---@return AceLibFactory
function L:LibPack_AceLibFactory() return L:Get(M.AceLibFactory)  end

---### Usage:
---```
---local AceDB, AceDBOptions, AceConfig, AceConfigDialog = AceLibFactory:GetAddonAceLibs()
---```
---@return AceDB, AceDBOptions, AceConfig, AceConfigDialog
function L:LibPack_AceAddonLibs()
    local alf = self:LibPack_AceLibFactory()
    return alf:GetAceDB(), alf:GetAceDBOptions(), alf:GetAceConfig(), alf:GetAceConfigDialog()
end

---### Get New Addon LibPack
---```
---local LibStub, Module, AceLibFactory, ProfileInitializer, LibGlobals = LibGlobals:LibPack_NewAddon()
---```
---@return LocalLibStub, Module, AceLibFactory, LibGlobals
function L:LibPack_NewAddon()
    local AceLibFactory, WidgetLibFactory, ProfileInitializer = self:Get(
            M.AceLibFactory, M.ProfileInitializer)
    return LibStub, Module, AceLibFactory, WidgetLibFactory, L
end
---### Usage
---```
---local LibStub, M, LogFactory, G = DEVT_LibGlobals:LibPack_NewLibrary()
---```
---@return LocalLibStub, Module, LoggerTemplate, LibGlobals
function L:LibPack_NewLibrary()
    return LibStub, Module, self:Lib_LogFactory(), self
end

---### Example
---```
---local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
---```
---@return AceEvent, AceGUI, AceHook
function L:LibPack_AceLibrary()
    ---@type AceLibFactory
    local AceLibFactory = self:Get(M.AceLibFactory)
    return AceLibFactory:GetAceEvent(), AceLibFactory:GetAceGUI(), AceLibFactory:GetAceHook()
end

---@param object any The target object
---@return any The mixed-in object
function L:MixinAll(object, ...) return self:LibPack_Mixin():Mixin(object, ...) end

---The standard mixin that skips "GetName", "mt (metatables)", etc.. [Preferred]
---@param object any The target object
---@return any The mixed-in object
function L:Mixin(object, ...) return self:LibPack_Mixin():MixinStandard(object, ...) end

---@return Mixin
function L:LibPack_Mixin() return self:Get(M.Mixin) end

--- ### Usage
---```
---local Table, String, Assert, Mixin = DEVT_LibGlobals:LibPack_Utils()
---```
---@return Table, String, Assert, Mixin
function L:LibPack_Utils()
    return self:Get(M.Table, M.String, M.Assert, M.Mixin);
end

---@return Config
function L:Lib_Config() return self:Get(M.Config) end
---@return LogFactory
function L:Lib_LogFactory() return self:Get(M.LogFactory) end
---@return Table
function L:Lib_Table() return LibStub(M.Table) end

---@return DialogWidgetMixin
function L:LibMixin_DialogWidgetMixins() return LibStub:GetMixin(M.DialogWidgetMixin) end

---@return UnitIDAttributes
function L:UnitIdAttributes()
    ---@class UnitIDAttributes
    local unitIDAttributes = {
        focus = 'focus',
        target = 'target',
        mouseover = 'mouseover',
        none = 'none',
        pet = 'pet',
        player = 'player',
        vehicle = 'vehicle',
    }
    return unitIDAttributes
end

function L:Get(...)
    local libNames = {...}
    local libs = {}
    for _, lib in ipairs(libNames) do
        local o = LibStub(lib)
        assert(o ~= nil, 'Lib not found: ' .. lib)
        table.insert(libs, o)
    end
    return unpack(libs)
end

function L:GetLogPrefix() return self.logPrefix end

---### Addon Version Info
---```Example:
---local version, major = G:GetVersionInfo()
---```
---@return string, string The version text, major version of the addon.
function L:GetVersionInfo() return self.versionText, self.version end

---### Addon URL Info
---```Example:
---local versionText, curseForge, githubIssues, githubRepo = G:GetAddonInfo()
---```
---@return string, string, string The version and URL info for curse forge, github issues, github repo
function L:GetAddonInfo()
    local versionText = self.versionText
    --@debug@
    if versionText == '1.0.0.10-beta' then versionText = addonName .. '-' .. self.version .. '.dev' end
    --@end-debug@
    return versionText, GetAddOnMetadata(addonName, 'X-CurseForge'), GetAddOnMetadata(addonName, 'X-Github-Issues'),
                GetAddOnMetadata(addonName, 'X-Github-Repo')
end

---@type LibGlobals
DEVT_LibGlobals = L
