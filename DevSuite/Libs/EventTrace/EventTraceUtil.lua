local IsAddOnLoaded = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local UIParentLoadAddOn = UIParentLoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class EventTraceUtil
--- @field keyword string
--- @field evt EventTrace
local S = {}; ns.O.EventTraceUtil = S
S.__index = S

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
local o = S

--- @param addon Name
--- @param showAtStartup boolean
--- @return EventTraceUtil
function o:New(addon, showAtStartup)
  --- @type EventTraceUtil
  local tracer = setmetatable({}, o)
  local show = showAtStartup == true
  tracer:Init(addon, show)
  return tracer
end

--- @private
--- @param addon Name
--- @param showAtStartup boolean
function o:Init(addon, showAtStartup)
  assertsafe(
    type(addon) == 'string',
    'Init(addon, showAtStartup):: The param addon should be a string, but was [%s].',
    type(addon)
  )

  self.logName = addon
  self.evt = self:LoadEventTrace(showAtStartup)

  if self.evt then self.evt:SetClampedToScreen(true) end
end

function o:ShowUI() self.evt:Show() end

function o:HideUI() self.evt:Hide() end

--- /dump UIParentLoadAddOn("Blizzard_EventTrace")
--- @param showAtStartup boolean
--- @return EventTrace?
function o:LoadEventTrace(showAtStartup)
  if self.evt then return self.evt end

  local addOnName = EVENT_TRACE_ADDON

  if IsAddOnLoaded(addOnName) then return EventTrace end

  local success, reason = UIParentLoadAddOn(addOnName)
  if not success then
    print(('%s:: Failed to load [%s], reason=%s'):format(self.logName, addOnName, reason))
    return nil
  end
  assertsafe(EventTrace, '%s:: Failed to load [%s].', self.logName or ns.addon, addOnName)
  self.evt = EventTrace
  if not showAtStartup then self.evt:Hide() end
  return self.evt
end

--- @param keyword string
function o:SetEventTraceSearchKeyword(keyword)
  if type(keyword) ~= 'string' then return end
  local s = self.evt.Log.Bar.SearchBox
  if not s then return end
  s:SetText(keyword)
end
