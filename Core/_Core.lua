--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--[[--- @class CoreNamespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion]]

--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @type string
local addon
--- @type CoreNamespace | Kapresoft_LibUtil_NamespaceAceLibraryMixin | Kapresoft_LibUtil_NamespaceAceLibraryMixin
local ns
addon, ns = ...;
ns.addon     = addon
ns.shortName = 'devst'
local K = ns.Kapresoft_LibUtil

K:Mixin(ns, K.Objects.CoreNamespaceMixin, K.Objects.NamespaceAceLibraryMixin)

--[[-----------------------------------------------------------------------------
Type: DebugSettingsFlag
-------------------------------------------------------------------------------]]
--- @class DebugSettingsFlag
--- @see GlobalDeveloper
local flag = {
    --- Enable developer mode: logging and debug tab settings
    developer = false,
    --- Enables the DebugChatFrame log console
    enableLogConsole = false,
    --- Enable selection of chat frame tab
    selectLogConsoleTab = false,
}

--- @return DebugSettings
local function debug()
    --- @class DebugSettings
    local o = {
        flag = flag,
    }
    --- @return boolean
    function o:IsDeveloper() return self.flag.developer == true  end
    --- @return boolean
    function o:IsEnableLogConsole()
        return self:IsDeveloper() and self.flag.enableLogConsole == true
    end
    function o:IsSelectLogConsoleTab()
        return self:IsEnableLogConsole() and self.flag.selectLogConsoleTab
    end
    return o;
end

ns.debug = debug()
