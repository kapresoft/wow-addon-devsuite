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
--- @field Kapresoft_LibUtil Kapresoft_LibUtil
--- @field O Modules
local ns = select(2, ...)
local K = ns.Kapresoft_LibUtil
K:MixinWithDefExc(ns, K.Objects.CoreNamespaceMixin)

