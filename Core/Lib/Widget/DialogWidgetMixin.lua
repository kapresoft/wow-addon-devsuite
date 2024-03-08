--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal
local tinsert = table.insert

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UISpecialFrames = UISpecialFrames

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.LibStub

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
--- @class DialogWidgetMixin : BaseLibraryObject
local L = {}
ns:Register(M.DialogWidgetMixin, L)
local p = ns:CreateDefaultLogger(M.DialogWidgetMixin)

---@param frameName string
---@param frameInstance table The frame object
function L:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    tinsert(UISpecialFrames, frameName)
end



