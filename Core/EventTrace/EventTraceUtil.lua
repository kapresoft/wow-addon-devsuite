local IsAddOnLoaded     = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local UIParentLoadAddOn = UIParentLoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
local upperc            = string.upper
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local Ace = ns:Ace()

--- @type AceEvent_3_0
local AceEvent = Ace:AceEvent()
--- @type AceHook_3_0
local AceHook = Ace:AceHook()

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class EventTraceUtil : AceEvent_3_0 : AceHook_3_0
--- @field keyword string
--- @field evt EventTrace
local S = AceHook:Embed(AceEvent:Embed({})); ns.O.EventTraceUtil = S
S.__index = S

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
local o = S

--- @param addon Name
--- @param showAtStartup boolean
--- @param predicateFn PredicateFn|nil  | "function() return true end"
--- @return EventTraceUtil
function o:New(addon, showAtStartup, predicateFn)
  --- @type EventTraceUtil
  local tracer = setmetatable({}, o)
  local show = showAtStartup == true
  tracer:Init(addon, show, predicateFn)
  return tracer
end

-- light green
local c_base = ns:ColorFn('88ff88')

--- @private
--- @param addon Name
--- @param showAtStartup boolean
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:Init(addon, showAtStartup, predicateFn)
  assert(addon, "The param addon is required.")
  
  self.logName     = addon
  self.eventBase   = upperc(c_base(addon))
  self.predicateFn = predicateFn or function() return true  end
  self.evt         = self:LoadEventTrace(showAtStartup)
  
  if self.evt then
    self.evt:SetClampedToScreen(true)
  end
end

function o:ShowUI() self.evt:Show() end

function o:HideUI() self.evt:Hide() end

--- Trace with default prefix as the addon name
--- @param ... any
function o:td(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ...)
end

--- Trace with default prefix as the addon name
--- @param ... any
function o:tdf(...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(), ns.fmt(...))
end

--- This is the default trace function
--- @param prefix Name
--- @param ... any
function o:t(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ...)
end

--- @param prefix Name
--- @param ... any
function o:tf(prefix, ...)
  if not self.predicateFn() then return end
  self.evt:LogEvent(self:_EventName(prefix), ns.fmt(...))
end

--- /dump UIParentLoadAddOn("Blizzard_EventTrace")
--- @param showAtStartup boolean
--- @return EventTrace
function o:LoadEventTrace(showAtStartup)
  if self.evt then return self.evt end
  
  local addOnName = EVENT_TRACE_ADDON
  
  if IsAddOnLoaded(addOnName) then return EventTrace end

  local success, reason = UIParentLoadAddOn(addOnName)
  if not success then
    return print(('%s:: Failed to load [%s], reason=%s'):format(
            self.logName, addOnName, reason))
  end
  assert(EventTrace, ('%s:: Failed to load [%s].'):format(self.logName or ns.addon, addOnName))
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

--- @param prefix Name|nil
function o:_EventName(prefix)
  if prefix == nil then return self.eventBase end
  return ("%s::%s"):format(self.eventBase, prefix)
end
