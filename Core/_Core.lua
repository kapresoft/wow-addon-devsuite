--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--[[--- @class CoreNamespace : Kapresoft_Base_Namespace
--- @field gameVersion GameVersion]]

--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @class PreNamespace : CoreNamespace
--- @field name Name
--- @field O Modules
local ns = select(2, ...)
local K = ns.Kapresoft_LibUtil
K:MixinWithDefExc(ns, K.Objects.CoreNamespaceMixin, K.Objects.NamespaceAceLibraryMixin)

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
function ns.IsDev() return ns.debug.flag.developer == true end
