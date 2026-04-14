--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local GC, L = ns.GC, ns:GetLocale()
local strupper, strlower = strupper, strlower
local IsNotBlank = ns:String().IsNotBlank

-- classic green
local activeColor = CreateColorFromHexString("ff00ff00")
-- white
local ttColor = CreateColorFromHexString("ffeeffee")

--[[-----------------------------------------------------------------------------
Module::PresetFiltersButton
-------------------------------------------------------------------------------]]
--- @see NamespaceObjects
local libName = 'PresetFiltersButton'
local p, pd, t, tf = ns:log(libName)
local Ace = ns:Ace()
--- @class PresetFiltersButtonMixin : Button
--- @field Arrow TextureObj
local S = ns:AceEmbed({}, ns:AceEvent(), ns:AceHook()); DevSuite_PresetFiltersButtonMixin = S
--
--- @alias PresetFiltersButton PresetFiltersButtonMixin | CheckButtonObj | AceEvent_3_0 | AceHook_3_0
--
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function activeC(text) return activeColor:WrapTextInColorCode(text) end
local function ttC(text) return ttColor:WrapTextInColorCode(text) end

--- @param ... any
local function t(...)
  local evt = ns:evt(); if not evt then return end
  evt:LogEvent(strupper(ns.addon), libName, ...)
end

--- @return PresetFiltersContentFrame
local function contentFrame() return DevSuite_PresetFiltersContentFrame end

--[[-----------------------------------------------------------------------------
Module::PresetFiltersButton (Methods)
-------------------------------------------------------------------------------]]
--- @type PresetFiltersButtonMixin | PresetFiltersButton
local o = S

--- EventTrace will auto show on dependency
function o:OnLoad()
  self:RegisterMessage(ns.GC.toMsg('PresetFilterClose'), 'OnPresetFilterClose')
  self:RegisterMessage(GC.M.OnAfterEnable, 'OnAfterEnable')
end

--- @private
function o:OnAfterEnable()
  self:SetParent(ns:evt())
  self:EventTraceHooks()

  local anchorTo = ns:evt().SubtitleBar.ViewFilter
  self:Show()
  self:SetPoint('LEFT', anchorTo, 'RIGHT', 2, 0)
  self:SetText(L['Preset Filters'])
  local fs = self:GetFontString()
  fs:SetTextColor(1, 0.85, 0.4)
  fs:SetPoint("LEFT", 3, 0)
  fs:SetPoint("RIGHT", -10, 0)

  self:UpdateButtonTextState()
end

--- @private
function o:OnPresetFilterClose(evt, src) self:Click() end

--- @private
function o:EventTraceHooks()
  local subtitleBar = ns:evt().SubtitleBar
  local onClicks = { subtitleBar.ViewLog,
                     subtitleBar.ViewFilter,
                     subtitleBar.OptionsDropdown }
  for i, f in ipairs(onClicks) do
    if f and not self:IsHooked(f, 'OnClick') then
      self:HookScript(f, 'OnClick', 'OnClickOthers')
    end
  end
end

function o:OnClick()
  p('OnClick')
  local f = contentFrame()
  if self:GetChecked() then return f:Show() end
  f:Hide()
  self:UpdateButtonTextState()
end

function o:OnClickOthers()
  if self:GetChecked() then self:Click() end
end

function o:OnEnter()
  ns.GameTooltip_DefaultAnchor()
  GameTooltip:AddLine(L['Preset Filters::DESC'])
  self:UpdateGameTooltipActiveState()
  GameTooltip:Show()
end

function o:OnLeave() GameTooltip:Hide() end

--- @return string
function o:GetPresetKeyword() return ns:g().trace.preset_keyword end
--- @return boolean
function o:IsFilterActive() return IsNotBlank(self:GetPresetKeyword()) end

function o:UpdateGameTooltipActiveState()
  if not self:IsFilterActive() then return end
  
  GameTooltip:AddLine(' ')
  GameTooltip:AddDoubleLine(ttC(L['active']), activeC(strlower(YES)))
  GameTooltip:AddDoubleLine(ttC(L['keyword']), ttC(self:GetPresetKeyword()))
end

--- @private
function o:UpdateButtonTextState()
  if self:IsFilterActive() then
    self:SetText(activeC(L['Preset Filters'])); return
  end
  self:SetText(L['Preset Filters'])
end
