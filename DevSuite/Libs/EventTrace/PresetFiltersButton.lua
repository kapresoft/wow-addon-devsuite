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

--- @class PresetFiltersButtonMixin : CheckButton, AceEvent-3.0, AceHook-3.0
--- @field Arrow Texture @See Core/EventTrace/_EventTracePresetFilters.xml#CheckButton/Arrow
local S = ns:AceEmbed({}, ns:AceEvent(), ns:AceHook()); DevSuite_PresetFiltersButtonMixin = S
--
--- @class PresetFiltersButton : PresetFiltersButtonMixin
--
--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function activeC(text) return activeColor:WrapTextInColorCode(text) end
local function ttC(text) return ttColor:WrapTextInColorCode(text) end

--- @return PresetFiltersContentFrame
local function contentFrame() return DevSuite_PresetFiltersContentFrame end

--[[-----------------------------------------------------------------------------
Module::PresetFiltersButton (Methods)
-------------------------------------------------------------------------------]]
local o = S

--- EventTrace will auto show on dependency
function o:OnLoad()
  self:RegisterMessage(GC.toMsg('PresetFilterClose'), 'OnPresetFilterClose')
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
function o:OnPresetFilterClose(evt, src) if self:GetChecked() then self:Click() end end

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
