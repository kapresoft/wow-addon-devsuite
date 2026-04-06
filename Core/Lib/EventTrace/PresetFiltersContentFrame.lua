--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local L = ns:AceLocale()

local keywordFrameHeight = 24

--- @class ButtonsContainerFrame : Frame
--- @field ScrollChild FrameObj
--- @field ClearButton ButtonObj
--- @field AddButton ButtonObj

--- @class PresetFiltersContentFrameMixin
--- @field anchorTo ButtonObj The predefined-filter button
--- @field ScrollFrame ScrollFrameObj
--- @field ButtonsContainerFrame ButtonsContainerFrame
--- @field HeaderTitle FontStringObj
--- @field HeaderIconLeft TextureObj
--- @field HeaderBackground TextureObj
DevSuite_PresetFiltersContentFrameMixin = ns:AceEvent()
--
--- @alias PresetFiltersContentFrame PresetFiltersContentFrameMixin | FrameObj | AceEvent_3_0
--

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @param ... any
local function t(...) EventTrace:LogEvent(string.upper(ns.addon), 'EventTraceFrameMixin', ...) end

--- @param self ButtonObj
--- @param relativeTo Frame
local function AddButton_Init(self, relativeTo)
  self.tooltipText = L['Add Preset Filter Keyword']
  self:ClearAllPoints()
  self:SetPoint('TOPRIGHT', relativeTo, 'TOPRIGHT', -2, -2)
end

--- @param self ButtonObj
--- @param relativeTo Frame
--- @param owner PresetFiltersContentFrame
local function ClearButton_Init(self, relativeTo, owner)
  self:SetText(L['Clear'])
  self:ClearAllPoints()
  self:SetPoint('TOP', relativeTo, 'BOTTOM', 0, -5)
  local fs = self:GetFontString()
  local font, size, flags = fs:GetFont()
  fs:SetFont(font, size - 2, flags)
  
  self:SetScript('OnEnter', function(b)
    ns:GameTooltip_DefaultAnchor()
    GameTooltip:AddLine(L['Clear current preset'])
    GameTooltip:Show()
  end)
  self:SetScript('OnClick', function(b)
    owner:ClearEventTraceSearchKeyword()
    --frame:SendMessage(ns.GC.toMsg('PresetFilterClose'), 'EventTraceFrame::ClearButton')
    owner:NotifyListeners(b:GetText())
  end)
  self:SetScript('OnLeave', function(b) GameTooltip:Hide() end)
  
end

--[[-------------------------------------------------------------------
Methods:: EventTraceFrameMixin
---------------------------------------------------------------------]]
--- @type PresetFiltersContentFrameMixin | PresetFiltersContentFrame
local o = DevSuite_PresetFiltersContentFrameMixin

--- @class KeywordButton : Button
--- @field protected __used boolean Internal use
--
--- @alias KeywordButton__ KeywordButton | ButtonObj
--
--- @type KeywordButton__[]
o.buttonPool = {}

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)

  local anchorTo = self.anchorTo  -- already resolved global
  self:SetParent(anchorTo)
  self:SetPoint('TOPLEFT', DevSuite_PresetFiltersButton, 'BOTTOMLEFT', 5, 0)
  self:SetFrameLevel(1000)
  self:SetAlpha(0.9)
  
  self.HeaderTitle:SetText(L['Preset Filters'])
  
  --- @type TextureObj
  local headerIcon = self.HeaderIconLeft
  headerIcon:SetDrawLayer('OVERLAY')
  headerIcon:SetScript('OnLeave', function() end)
  
  headerIcon:SetScript('OnEnter', function()
    ns:GameTooltip_DefaultAnchor()
    GameTooltip:AddLine(L['DevSuite addon feature'])
    GameTooltip:Show()
  end)
  
  AddButton_Init(self.ButtonsContainerFrame.AddButton, self.HeaderBackground)
  ClearButton_Init(self.ButtonsContainerFrame.ClearButton, self.HeaderTitle, self)
  
  self.ScrollChild = self.ScrollFrame.ScrollChild
  self.ScrollFrame:SetScrollChild(self.ScrollChild)
  
  local scrollBarWidth = self.ScrollFrame.ScrollBar:GetWidth() or 16
  local availableWidth = self.ScrollFrame:GetWidth() - scrollBarWidth - 4
  self:SetWidth(availableWidth)
end

function o:ClearEventTraceSearchKeyword() self:SaveEventTraceSearchKeyword('') end

function o:SetCurrentEventTraceSearchKeyword()
  local keyword = ns:g().trace.preset_keyword
  if not keyword then return end
  self:SetEventTraceSearchKeyword(keyword)
end

function o:SaveEventTraceSearchKeyword(keyword)
  if not type(keyword) == 'string' then return end
  ns:g().trace.preset_keyword = keyword
  self:SetEventTraceSearchKeyword(ns:g().trace.preset_keyword)
end

function o:SetEventTraceSearchKeyword(keyword)
  local s = EventTrace.Log.Bar.SearchBox
  if s and keyword then
    s:SetText(keyword)
  end
end

function o:OnShow()
  self:SetCurrentEventTraceSearchKeyword()
  self:RefreshPredefinedFilters()
end

--- @param self ButtonObj
--- @param owner PresetFiltersContentFrame
--- @param keyword string
local function PredefinedKeywordsButton_Init(self, owner, keyword)
  self.text:SetText(keyword)
  self.text:SetTextColor(1, 1, 1)
  self:Show()
  self.__used = true
  self:SetScript('OnClick', function(b)
    owner:SaveEventTraceSearchKeyword(b.text:GetText())
    owner:SendMessage(ns.GC.toMsg('PresetFilterClose'), 'EventTraceFrame::' .. b.text:GetText())
  end)
  self:SetScript("OnEnter", function(btn)
    btn.HighlightBg:Show()
    btn.text:SetTextColor(1, 0.82, 0.25) -- gold (your theme)
  end)
  self:SetScript("OnLeave", function(btn)
    btn.HighlightBg:Hide()
    btn.text:SetTextColor(1, 1, 1) -- default
  end)
end

--- Button layout (ordered)
--- @param owner PresetFiltersContentFrame
local function PredefinedKeywordsButton_Layout(owner, presetKeywords)
  local prev, child = nil, owner.ScrollChild
  for _, keyword in ipairs(presetKeywords) do
    local btn = owner.buttonPool[keyword]
    if btn and btn.__used then
      btn:ClearAllPoints()
      if not prev then
        btn:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
      else
        btn:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -2)
      end
      prev = btn
    end
  end
end

function o:RefreshPredefinedFilters()
  local presetKeywords = ns:g().trace.preset_filter_keywords
  local child = self.ScrollChild
  local usedCount = 0
  local me = self
  for _, keyword in ipairs(presetKeywords) do
    --- @type ButtonObj
    local f = self.buttonPool[keyword]
    if not f then
      f = CreateFrame("Button", nil, child, "DevSuite_PredefinedKeywordsButton")
      self.buttonPool[keyword] = f
    end
    PredefinedKeywordsButton_Init(f, self, keyword)

    usedCount = usedCount + 1
  end
  
  PredefinedKeywordsButton_Layout(self, presetKeywords)
  
  -- cleanup
  for _, frame in pairs(self.buttonPool) do
    if not frame.__used then
      frame.info = nil
      frame:Hide()
    end
    frame.__used = nil
  end
  
  self:UpdateScrollHeight(usedCount)
end

--- @private
function o:UpdateScrollHeight(numRows)
  local child = self.ScrollChild

  local rowHeight = keywordFrameHeight
  local spacing   = 1
  local padding   = 1

  local height = 0
  if numRows > 0 then
    height = (numRows * rowHeight)
           + ((numRows - 1) * spacing)
           + padding
  end

  child:SetHeight(height)
end

--- @param srcName string
function o:NotifyListeners(srcName)
  t('NotifyListeners', 'btn=', srcName)
  self:SendMessage(ns.GC.toMsg('PresetFilterClose'), 'EventTraceFrame::' .. srcName)
end
