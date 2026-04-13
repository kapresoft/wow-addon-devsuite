--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
local AceLib = LibStub('Kapresoft-AceLib-2-0')
local DCFM = LibStub('Kapresoft-DebugChatFrameMixin-2-0')
local GVM = LibStub('Kapresoft-GameVersionMixin-2-0')
--[[-----------------------------------------------------------------------------
Type: CoreNamespace
-------------------------------------------------------------------------------]]
--- @class PreNamespace : Kapresoft-AceLib-2-0, Kapresoft-DebugChatFrameMixin-2-0, Kapresoft-GameVersionMixin-2-0
--- @field name Name
--- @field Kapresoft_LibUtil Kapresoft_LibUtil
--- @field O Modules
local ns = select(2, ...); Mixin(ns, GVM, AceLib, DCFM)

local K = ns.Kapresoft_LibUtil
--K:MixinWithDefExc(ns, K.Objects.CoreNamespaceMixin)

ns.sformat      = string.format
--ns.pformat      = K.pformat

--ns.LogFunctions = K.Objects.CoreNamespaceMixin.LogFunctions

function ns:K() return ns.Kapresoft_LibUtil end
function ns:KO() return ns.Kapresoft_LibUtil.Objects end

--@do-not-package@
function tr(prefix, ...)
    EventTrace:LogEvent('DEVSUITE::' .. prefix, ...)
end
--@end-do-not-package@
