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
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
local libName = ns.M.DialogWidgetMixin()
--- @class DialogWidgetMixin
local L = ns:NewLib(libName)
local p = ns:CreateDefaultLogger(libName)

---@param frameName string
---@param frameInstance table The frame object
function L:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    tinsert(UISpecialFrames, frameName)
end



