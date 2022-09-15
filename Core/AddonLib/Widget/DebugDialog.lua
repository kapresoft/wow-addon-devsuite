local LibStub, M, LogFactory, G = DEVT_LibGlobals:LibPack_NewLibrary()
local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class DebugDialog : DialogWidgetMixins
local L = LibStub:NewLibrary(M.DebugDialog)
p = LogFactory(M.DebugDialog)
--_L.mt.__index = {
--    ['hi'] = function() p:log('hi') end
--}
L.mt.__call = function (_, ...) return L:Constructor(...) end
--setmetatable(L, L.mt)

local MX = G:LibPack_Mixin()
MX:MixinStandard(L, LibStub:GetMixin(M.DialogWidgetMixin))


function L:Constructor()
    p:log('in constructor')
end

DD = L

