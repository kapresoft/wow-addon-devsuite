local IsAddOnLoaded     = C_AddOns.IsAddOnLoaded or IsAddOnLoaded
local LoadAddOn         = C_AddOns.LoadAddOn or LoadAddOn
local EVENT_TRACE_ADDON = 'Blizzard_EventTrace'
local upperc            = string.upper
--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

--- @type AceGUI_3_0
local AceGUI = LibStub('AceGUI-3.0')
--- @type AceEvent_3_0
local AceEvent = LibStub('AceEvent-3.0')
--- @type AceHook_3_0
local AceHook = LibStub('AceHook-3.0')

RegisterCVar(ns.trace_cvar_keyword, '')

--[[-----------------------------------------------------------------------------
Library
-------------------------------------------------------------------------------]]
--- @class EventTracePrinter
--- @field keyword string
local S = AceHook:Embed(AceEvent:Embed({}))
ns.EvenTracePrinter = S
S.__index = S
--
--- @alias EventTracePrinterObject EventTracePrinter | AceEvent_3_0 | AceHook_3_0
--

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param btn AceGUIButton
local function GameTooltip_SetText(btn, relativeTo, text)
  btn.frame:SetScript('OnEnter', function(f)
    GameTooltip:SetOwner(relativeTo, "ANCHOR_NONE")
    GameTooltip:SetPoint('TOPLEFT', relativeTo, 'BOTTOMLEFT', 0, -10)
    GameTooltip:SetText(text)
  end)
  btn.frame:SetScript('OnLeave', function() GameTooltip:Hide() end)
end

--[[-----------------------------------------------------------------------------
Library: Methods
-------------------------------------------------------------------------------]]
--- @type EventTracePrinter | EventTracePrinterObject
local o = S

--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
--- @return EventTracePrinterObject
function o:New(addon, predicateFn)
  --- @type EventTracePrinter
  local tracer = setmetatable({}, o)
  tracer:Init(addon, predicateFn)
  return tracer
end

-- light green
local c_base = ns:colorFn('88ff88')

--- @private
--- @param addon Name
--- @param predicateFn PredicateFn|nil  | "function() return true end"
function o:Init(addon, predicateFn)
  assert(addon, "The param addon is required.")
  
  self.logName     = addon
  self.eventBase   = upperc(c_base(addon))
  self.predicateFn = predicateFn or function() return true  end
  self.evt         = self:LoadEventTrace()
  
  if self.evt then
    self.evt:SetClampedToScreen(true)
    self:__HookEventTraceOnShow()
  end
end

--- @private
function o:InitUI()
  if self.evt.ABP_2_0_InitUI then return end
  self:SetSearchKeyword(self:GetTraceKeyword())
  
  --- @type AceGUISimpleGroup
  local container = AceGUI:Create("SimpleGroup")
  container.frame:SetParent(self.evt)
  container:SetLayout('Flow')
  
  local btn1 = self:CreateButton('ABP-V2', function(btn)
    self:SetSearchKeyword('abpv2')
  end, nil, 'Apply search keyword: abpv2')
  local btn2 = self:CreateButton('Bars-UI', function()
    self:SetSearchKeyword('BarsUI')
  end, nil, 'Apply search keyword: barsui')
  local btn3 = self:CreateButton('Auto-Open', function()
    --self:SetSearchKeyword('')
  end, 95, 'Auto-open EventTrace on startup')
  local btn4 = self:CreateButton('x', function()
    self:SetSearchKeyword('')
  end, 40, 'Clear search keyword')
  
  container:AddChild(btn1)
  container:AddChild(btn2)
  container:AddChild(btn3)
  container:AddChild(btn4)
  container:SetPoint('TOP', self.evt.NineSlice, 'BOTTOM', 0, 28)
  
  self.evt.ABP_2_0_InitUI = true
end

--- @param text string The button text
--- @param callbackFn fun(btn:AceGUIButton) : void
--- @param width number|nil The button width
--- @param tooltipText string
--- @return AceGUIButton
function o:CreateButton(text, callbackFn, width, tooltipText)
  --- @type AceGUIButton
  local btn = AceGUI:Create("Button")
  btn:SetText(text)
  --- @type FontStringObj
  local fs = btn.frame:GetFontString()
  local font, height, flags = fs:GetFont()
  fs:SetFont(font, height - 1, flags)
  btn:SetWidth(width or 80)
  btn:SetHeight(21)
  btn:SetCallback("OnClick", function(b)
    if callbackFn then callbackFn(b) end
  end)
  if type(tooltipText) == 'string' then
    GameTooltip_SetText(btn, self.evt, tooltipText)
  end
  
  return btn
end

function o:__HookEventTraceOnShow()
  if self.evt.__abpHooked then return end
  self.evt.__abpHooked = true
  
  self:InitUI()
  self:HookScript(self.evt, "OnShow", function(frame)
    print("EventTrace shown")
  end)
end

--- @param keyword string
function o:SetSearchKeyword(keyword)
  keyword = keyword or ''
  local s = self.evt.Log.Bar.SearchBox
  if s then
    s:SetText(keyword)
    SetCVar(ns.trace_cvar_keyword, keyword)
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


--- @private
--- @return EventTrace
function o:LoadEventTrace()
  local addOnName = EVENT_TRACE_ADDON
  
  if IsAddOnLoaded(addOnName) then return EventTrace end

  local success, reason = LoadAddOn(addOnName)
  if not success then
    return print(('%s:: Failed to load [%s], reason=%s'):format(
            self.logName, addOnName, reason))
  end
  assert(EventTrace, ('%s:: Failed to load [%s].'):format(self.logName, addOnName))
  return EventTrace
end

--- @param prefix Name|nil
function o:_EventName(prefix)
  if prefix == nil then return self.eventBase end
  return ("%s::%s"):format(self.eventBase, upperc(prefix))
end

--- @return string
function o:GetTraceKeyword() return GetCVar(ns.trace_cvar_keyword) or '' end
