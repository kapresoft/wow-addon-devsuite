--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, LogFactory, G = DEVS_LibGlobals:LibPack_NewLibrary()
local Table = G:LibPack_Utils()
local tinsert = Table.insert

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class DialogWidgetMixin : BaseMixin
local L = LibStub:NewMixin(M.DialogWidgetMixin)
local p = LogFactory(M.DialogWidgetMixin)

---@param frameName string
---@param frameInstance table The frame object
function L:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    tinsert(UISpecialFrames, frameName)
end



