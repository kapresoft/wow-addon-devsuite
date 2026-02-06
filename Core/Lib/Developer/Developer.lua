--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local geterrorhandler = geterrorhandler
local str_lower = string.lower
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn
local StaticPopupDialogs, ReloadUI = StaticPopupDialogs, ReloadUI
local StaticPopup_Visible, StaticPopup_Show = StaticPopup_Visible, StaticPopup_Show
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local GX_MAXIMIZE, SetCVar, GetCVarBool, RestartGx = 'gxMaximize', SetCVar, GetCVarBool, RestartGx

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

local libName = 'Developer'
local p = ns:LC().DEV:NewLogger(libName)

-- Settings
-- /run DEVS_SHOW_ADDON_LIST_ON_LOGIN = true
--- @boolean
local SHOW_ADDON_LIST_ON_LOGIN

--[[-----------------------------------------------------------------------------
Developer
-------------------------------------------------------------------------------]]
--- @class DevSuite_Developer
local L = ns:NewLibWithEvent(libName);
d = L

local c1 = ns:K():cf(RED_THREAT_COLOR)
local libNamePretty = c1(libName)

--- This method show's the caller
--p("SetIcon called from:", debugstack(2, 5, 5))

--[[-----------------------------------------------------------------------------
Event::OnAddOnReady
-------------------------------------------------------------------------------]]

local function OnAddOnReady()
  
  local MINIMAL_UI_MODE = true
  local MINIMAL_UI_FRAMES = {
    MinimapCluster,
    UIWidgetTopCenterContainerFrame, -- hellfire
    BuffFrame,
  }
  local FRAME_FORMATION = 0
  local SHOW_ADDON_LIST_ON_LOGIN = DEVS_SHOW_ADDON_LIST_ON_LOGIN
  
  --C_Timer.After(0.2, function()
  --  L:OpenLibIconPicker()
  --end)
  
  C_Timer.After(1, function()
    p:vv(function()
      return "MINIMAL_UI_MODE: %s", MINIMAL_UI_MODE
    end)
    p:vv(function()
      return "FRAME_FORMATION: %s", FRAME_FORMATION
    end)
    p:vv(function()
      return "DEVS_SHOW_ADDON_LIST_ON_LOGIN: %s", SHOW_ADDON_LIST_ON_LOGIN
    end)
  end)
  
  if SHOW_ADDON_LIST_ON_LOGIN and AddonList then AddonList:Show() end
  if MINIMAL_UI_MODE then L:HideFrames(MINIMAL_UI_FRAMES) end
  
  if not ShadowUF then
    C_Timer.After(1, function()
      if FRAME_FORMATION == 1 then L:FrameFormation1()
      elseif FRAME_FORMATION == 2 then L:FrameFormation2()
      else
        L:FrameFormation0()
        --UIParent_ManageFramePositions()
      end
    end)
  end

end


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function errorhandler(err) return geterrorhandler()(err) end

local function safecall(func, ...)
  if func then
    return xpcall(func, errorhandler, ...)
  end
end

local function getLIP()
  if LibIconPicker then return LibIconPicker end
  
  local LoadAddOn = C_AddOns.LoadAddOn or LoadAddOn
  local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn
  local libName = 'LibIconPicker'
  local c = UnitName('player')
  EnableAddOn(libName, UnitName('player'))
  local status, msg = LoadAddOn(libName)
  if not status then
    print(('LoadAddOn(%q) failed with status=%s; msg=%s'):format(libName, status, msg))
    return nil
  end
  return LibIconPicker
end
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function L:HideFrames(frames)
  for i, f in ipairs(frames) do
    if f and f.Hide then
      f:Hide()
    end
  end
end

function L:OpenLibIconPicker()
  local lip = getLIP();
  if not lip then return end
  --- @type LibIconPicker_Options
  local opt = {
    icon      = 132111, showTextInput = true,
    textInput = { label = 'Name:', value = 'My name' }
  }
  lip:Open(function(sel)
    print('selected:', pf(sel))
  end, opt)
end

function L:ll() self:logp('Log Level:', DEVS_LOG_LEVEL) end
function L:IsScriptErrorsEnabled()
  self:logp('scriptErrors:', GetCVarBool('scriptErrors'))
end

function L:GetProfile() return ns:db().profile end
function L:GetProfileNames() return ns:db():GetProfiles() end

function L:T() self:ToggleWindowed() end
function L:ToggleWindowed()
  local isMaximized = GetCVarBool(GX_MAXIMIZE)
  SetCVar(GX_MAXIMIZE, isMaximized and 0 or 1)
  RestartGx()
end
function L:MaxScreen()
  SetCVar(GX_MAXIMIZE, 1);
  RestartGx()
end
function L:Windowed()
  SetCVar(GX_MAXIMIZE, 0);
  RestartGx()
end

local function OutputAPIMatches(out, doc, apiMatches, headerName)
  if apiMatches and #apiMatches > 0 then
    for i, api in ipairs(apiMatches) do
      table.insert(out, api:GetSingleOutputLine())
    end
  end
end

local function OutputAllSystemAPI(doc, system)
  local apiMatches = system:ListAllAPI();
  local out = {}
  if apiMatches then
    OutputAPIMatches(out, doc, apiMatches.functions, "function(s)");
    OutputAPIMatches(out, doc, apiMatches.events, "events(s)");
    OutputAPIMatches(out, doc, apiMatches.tables, "table(s)");
  end
  return out
end

function L:API(name)
  -- call /api first
  local doc = APIDocumentation
  local api = doc:FindSystemByName(name)
  local t = OutputAllSystemAPI(doc, api)
  t.__tostring = true
  return t
end

--- @see Interface/SharedXML/Color.lua
function L:GetColors()
  local ret = {
    names = {},
    codes = {}
  }
  do
    local DBColors = C_UIColor.GetColors();
    for _, dbColor in ipairs(DBColors) do
      table.insert(ret.names, dbColor.baseTag)
      table.insert(ret.codes, dbColor.baseTag .. "_CODE")
    end
  end
  return ret
end

-- /run d:Formation0()
function L:FrameFormation0()
  if ShadowUF then return end
  
  local scale = 0.7
  
  --- @type FrameObj
  local pf = PlayerFrame
  pf:SetScale(scale)
  --PlayerFrame_ResetPosition(pf)
  --- @type FrameObj
  local tf = TargetFrame
  tf:SetScale(scale)
  
  --UIParent_ManageFramePositions()
end

-- /run d:Formation1()
function L:FrameFormation1()
  if ShadowUF then return end
  
  local scale = 0.85
  local ofsy = -200
  if ns:IsMoP() then ofsy = -120 end
  
  --- @type FrameObj
  local pf = PlayerFrame
  pf:SetScale(scale)
  pf:ClearAllPoints()
  pf:SetPoint("TOPRIGHT", UIParent, "CENTER", -100, ofsy)
  
  --- @type FrameObj
  local tf = TargetFrame
  tf:ClearAllPoints()
  tf:SetScale(scale)
  tf:SetPoint("TOPLEFT", UIParent, "CENTER", 100, ofsy)
end

-- /run d:Formation2()
function L:FrameFormation2()
  if ShadowUF then return end
  
  local scale = 0.85
  local ofsy = -110
  if ns:IsMoP() then ofsy = -120 end
  
  --- @type FrameObj
  local pf = PlayerFrame
  pf:SetScale(scale)
  pf:ClearAllPoints()
  pf:SetPoint("TOPRIGHT", UIParent, "TOP", -100, ofsy)
  
  --- @type FrameObj
  local tf = TargetFrame
  tf:ClearAllPoints()
  tf:SetScale(scale)
  tf:SetPoint("TOPLEFT", UIParent, "TOP", 100, ofsy)
end

--- Usage: /run d:c('hello', 'world')
function L:c(...) ns.logp(libNamePretty, ...) end


-- TODO: Add this as a feature; a textbox that takes a code to execute on login
--- @type Frame
local f = CreateFrame('Frame')
FrameUtil.RegisterFrameForEvents(f, { 'PLAYER_LOGIN' })
f:SetScript('OnEvent', function(self, event, ...)
  if event ~= 'PLAYER_LOGIN' then return end
  C_Timer.After(0.01, function()
    return OnAddOnReady()
  end)
end)
