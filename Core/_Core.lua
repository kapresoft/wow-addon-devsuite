--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--[[--- @class CoreNamespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion]]

--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local ns = select(2, ...)
local K = ns.Kapresoft_LibUtil
K:Mixin(ns, K.Objects.CoreNamespaceMixin, K.Objects.NamespaceAceLibraryMixin)

--- The "name" field conflicts with K.Objects. We need to restore it here
--- @deprecated Deprecated. Use ns.addon
ns.name           = ns.addon
ns.addonFriendlyName = 'Dev Suite'
ns.addonGlobalVarName = 'DEV_SUITE'
ns.addonGlobalNamespaceVarName = 'DEV_SUITE_NS'
ns.addonShortName = 'ds'
ns.addonLogName   = string.upper(ns.addonShortName)
ns.debugConsoleTabName = ns.addonFriendlyName
ns.useShortName   = true

function ns:preferredName() return (ns.useShortName == true and ns.addonShortName) or ns.addon end

--- @type Modules
ns.O = ns.O or {}

--- @type Kapresoft_LibUtil_ColorDefinition
ns.consoleColors = {
    primary   = 'FF780A',
    secondary = 'fbeb2d',
    tertiary = 'ffffff',
}
ns.ch = ns:NewConsoleHelper(ns.consoleColors)

--- Color Formatters
ns.f = {
    --- Use this for values
    val = K:cf(LIGHTGRAY_FONT_COLOR),
    debug = K:cf(COMMON_GRAY_COLOR),
}

--[[-----------------------------------------------------------------------------
Type: DebugSettingsFlag
-------------------------------------------------------------------------------]]
--- @class DebugSettingsFlag
--- @see GlobalDeveloper
local flag = {
    --- Enable developer mode: logging and debug tab settings
    developer = false,
}

--[[-----------------------------------------------------------------------------
Type: DebugSettings
--- Make sure to match this structure in GlobalDeveloper (which is not packaged in releases)
-------------------------------------------------------------------------------]]
--- @class DebugSettings
ns.debug = { flag = flag }

--[[-----------------------------------------------------------------------------
Namespace Methods
-------------------------------------------------------------------------------]]
--- @return boolean
function ns:IsDev() return ns.debug.flag.developer == true end
