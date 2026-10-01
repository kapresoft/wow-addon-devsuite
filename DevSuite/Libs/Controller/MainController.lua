--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame
--- @type Frame
local WorldFrame = WorldFrame
--- @type Frame, Frame
local MultiBarBottomLeft, MultiBarBottomRight = MultiBarBottomLeft, MultiBarBottomRight
--- @type FontString?
local FramerateLabel = FramerateLabel

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local E, MSG, AceEvent = GC.E, GC.M, ns:NewAceEvent()

-- Blizzard's FramerateLabel offset (Classic WorldFrame.xml)
local FPS_DEFAULT_OFFSET_Y = 64

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.MainController()
--- @class MainController
local o = ns:NewAceEvent(); ns:Register(libName, o)
local p, t, fmt = ns:log(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return Frame? @nil if neither bottom bar is visible
local function VisibleBottomBar()
  if MultiBarBottomLeft:IsVisible() then return MultiBarBottomLeft end
  if MultiBarBottomRight:IsVisible() then return MultiBarBottomRight end
end

--- Lifts the FPS text above bottom bars. Non-Retail only:
--- Retail anchors it to the Micro Menu, no adjustment needed.
local function AnchorFramerateLabel()
  if not FramerateLabel then return end
  local bar = VisibleBottomBar()
  FramerateLabel:ClearAllPoints()
  if bar then return FramerateLabel:SetPoint('TOPRIGHT', bar, 'TOPRIGHT', 0, 24) end
  FramerateLabel:SetPoint('BOTTOM', WorldFrame, 'BOTTOM', 0, FPS_DEFAULT_OFFSET_Y)
end

local function HookBottomBars()
  if not (FramerateLabel and MultiActionBar_Update) then return end
  hooksecurefunc('MultiActionBar_Update', AnchorFramerateLabel)
end

---Other modules can listen to message
---```Usage:
---AceEvent:RegisterMessage(MSG.OnAddonReady, function(evt, ...) end
---```

--- @param frame MainControllerFrame
--- @param event string The event name
local function OnPlayerEnteringWorld(frame, event, ...)
  local isLogin, isReload = ...

  local addon = frame.ctx.addon
  addon:SendMessage(MSG.OnAddOnReady)
  if not addon.PopupDialog then addon.PopupDialog = O.PopupDebugDialog() end

  --@do-not-package@
  if ns.IsDev() then
    isLogin = true
    t('IsLogin=', ns.f.val(isLogin), 'IsReload=', ns.f.val(isReload), 'IsDev=', ns:IsDev())
  end
  --@end-do-not-package@

  if not isLogin then return end

  p(GC:GetMessageLoadedText())
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- Init Method: Called by DevSuite.lua
--- @private
--- @param addon DevSuite
function o:Init(addon)
  self.addon = addon
  self:RegisterMessage(MSG.OnAfterInitialize, function(evt, ...) self:OnAfterInitialize() end)
end

--- @private
function o:OnAfterInitialize()
  self:RegisterEvents()
  HookBottomBars()
end

--- @private
function o:RegisterEvents()
  self:RegisterOnPlayerEnteringWorld()
  self:RegisterMessage(MSG.OnAddOnReady, function(msg) self:OnAddonReady(msg) end)
end

--- @private
function o:OnAddonReady(msg) self:InitializeState() end

--- @private
function o:InitializeState()
  self:OnShowEventTrace()
  C_Timer.After(3, function() self:OnToggleFrameRate() end)
end

function o:OnShowEventTrace()
  local m = ns:g().trace.show_at_startup and 'ShowUI' or 'HideUI'
  local tu = ns:traceUtil()
  tu[m](tu)
end

function o:OnToggleFrameRate()
  self:ShowFPS(ns:g().show_fps)
  AnchorFramerateLabel()
end

--- @private
function o:RegisterOnPlayerEnteringWorld()
  local f = self:CreateEventFrame()
  f:SetScript(E.OnEvent, OnPlayerEnteringWorld)
  f:RegisterEvent(E.PLAYER_ENTERING_WORLD)
end

---@param val boolean The config value
function o:ShowFPS(val)
  local frameShown = (FramerateText and FramerateText:IsShown())
    or (FramerateFrame and FramerateFrame:IsShown())
  local toggleFn = function() ToggleFramerate() end
  --- @type Frame
  local f = FramerateFrame
  if f then
    toggleFn = function()
      if f:IsShown() then
        f:Hide()
      else
        f:Show()
      end
    end
  end
  if true == frameShown then return val == false and toggleFn() end
  return val == true and toggleFn()
end

--- @param eventFrame MainControllerFrame
--- @return MainEventContext
function o:CreateEventContext(eventFrame)
  --- @class MainEventContext
  --- @field frame MainControllerFrame
  --- @field addon DevSuite
  local ctx = {
    frame = eventFrame,
    addon = self.addon,
  }
  return ctx
end

--- @return MainControllerFrame
function o:CreateEventFrame()
  --- @class MainControllerFrame : Frame
  --- @field ctx MainEventContext
  local f = CreateFrame('Frame', nil, self.addon.frame)
  f.ctx = self:CreateEventContext(f)
  return f
end

AceEvent:RegisterMessage(
  MSG.OnToggleFrameRate,
  function(msg, source, ...) o:OnToggleFrameRate() end
)
