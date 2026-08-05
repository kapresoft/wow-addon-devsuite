--- @type Namespace
local ns = select(2, ...)
local O, GC, M = ns.O, ns.GC, ns.M
local Str_IsBlank, Tbl_IsEmpty = ns:String().IsBlank, ns:Table().IsEmpty
local L = ns:GetLocale()

local keywordFrameHeight = 24
local DEVSUITE_CREATE_KEYWORD = 'DEVSUITE_CREATE_KEYWORD'
local enterTimer

local p, pd, t, tf = ns:log('PresetFiltersContentFrameMixin')

--- @class ButtonsContainerFrame : Frame
--- @field ScrollChild FrameObj
--- @field ClearButton ButtonObj
--- @field AddButton ButtonObj

--- @class PresetFiltersContentFrameMixin : Frame, AceEvent-3.0
--- @field anchorTo Button The predefined-filter button
--- @field ScrollFrame ScrollFrame
--- @field ScrollChild Frame
--- @field ButtonsContainerFrame ButtonsContainerFrame
--- @field HeaderTitle FontString
--- @field HeaderIconLeft Texture
--- @field HeaderBackground Texture
--- @field buttonPool table<string, KeywordButton>
DevSuite_PresetFiltersContentFrameMixin = ns:NewAceEvent()
--
--- @class PresetFiltersContentFrame : PresetFiltersContentFrameMixin
--

--[[-----------------------------------------------------------------------------
Static Dialog
-------------------------------------------------------------------------------]]
local function dbs() return ns.O.DatabaseSchema end
local function contentFrame() return DevSuite_PresetFiltersContentFrame end
local function presetFiltersButton() return DevSuite_PresetFiltersButton end

--- @param dlg StaticPopupDialog
local function Create_OnAccept(dlg)
  local keyword = dlg.EditBox:GetText()
  if Str_IsBlank(keyword) then return end
  dbs():AddPresetKeyword(keyword)
  local owner = contentFrame()
  owner:SaveEventTraceSearchKeyword(keyword)
  owner:NotifyListeners('CreateKeywordDialog')
end

local function InitCreateKeywordDialog()
  if StaticPopupDialogs[DEVSUITE_CREATE_KEYWORD] then return end
  StaticPopupDialogs[DEVSUITE_CREATE_KEYWORD] = {
    text = 'Add New Keyword',
    button1 = ADD,
    button2 = CANCEL,
    hasEditBox = 1, editBoxWidth = 100, maxLetters = 32,
    timeout = 0, exclusive = 1, whileDead = 1,

    --- @param dlg StaticPopupDialog
    OnShow = function(dlg)
      dlg:SetFrameStrata('FULLSCREEN_DIALOG')
      dlg.EditBox:SetText('')
      dlg.EditBox:SetFocus()
      dlg.EditBox:SetScript('OnEnterPressed', function()
        Create_OnAccept(dlg)
        StaticPopup_Hide(DEVSUITE_CREATE_KEYWORD)
      end)
      dlg.EditBox:SetScript('OnEscapePressed', function()
        StaticPopup_Hide(DEVSUITE_CREATE_KEYWORD)
      end)
    end,
    OnAccept = Create_OnAccept,
    OnCancel = function(dlg, data) end,
  }

  hooksecurefunc('StaticPopup_OnShow', function(dlg)
    if dlg.which ~= DEVSUITE_CREATE_KEYWORD then return end
    C_Timer.After(0, function()
      dlg:SetWidth(220)
      dlg.EditBox:SetWidth(150)

      local name = dlg:GetName()
      --- @type Button
      local btn1 = _G[name .. 'Button1']
      --- @type Button
      local btn2 = _G[name .. 'Button2']
      if btn1 and btn2 then
        btn1:ClearAllPoints()
        btn1:SetWidth(80)
        btn1:SetPoint('TOPRIGHT', dlg.EditBox, 'BOTTOM', -10, -10)
        btn2:ClearAllPoints()
        btn2:SetWidth(80)
        btn2:SetPoint('TOPLEFT', btn1, 'TOPRIGHT', 10, 0)
      end
    end)
  end)
end

--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
local function OnClick_ClearButton(b)
  local owner = contentFrame()
  owner:ClearEventTraceSearchKeyword()
  owner:NotifyListeners(b:GetText())
end
local function OnClick_KeywordButton(b)
  local owner = contentFrame()
  owner:SaveEventTraceSearchKeyword(b.text:GetText())
  owner:SendMessage(GC.toMsg('PresetFilterClose'), 'PresetFilterButton::' .. b.text:GetText())
end
--- @param self IconButton
local function OnClick_AddButton(self)
    StaticPopup_Show(DEVSUITE_CREATE_KEYWORD)
end
local function OnClick_DeleteButton(btn)
  local owner = contentFrame()

  --- @type PredefinedKeywordsButton
  local kwBtn = btn:GetParent()
  local txt = kwBtn.text:GetText()
  if Str_IsBlank(txt) then return end
  kwBtn:ClearAllPoints()
  kwBtn:Hide()
  kwBtn.__used = nil
  owner.buttonPool[txt] = nil

  dbs():RemovePresetKeyword(txt)
  owner:NotifyListeners(txt)

  local currentFilter = owner:GetEventTraceSearchKeyword()
  if currentFilter ~= txt then return end
  owner:ClearEventTraceSearchKeyword()
end

--- @param self IconButton
--- @param relativeTo Frame
local function AddButton_Init(self, relativeTo)
  -- todo: localize 'Add Keyword', 'Add Preset Filter Keyword'
  self.tooltipTitle = L['Add Keyword']
  self.tooltipText = L['Add Preset Filter Keyword']
  self:ClearAllPoints()
  self:SetPoint('TOPRIGHT', relativeTo, 'TOPRIGHT', -2, -2)
  InitCreateKeywordDialog()
  self.onClickHandler = OnClick_AddButton
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
  
  self:SetScript('OnClick', OnClick_ClearButton)
  self:SetScript('OnEnter', function(b)
    ns.GameTooltip_DefaultAnchor()
    GameTooltip:AddLine(L['Clear current preset'])
    GameTooltip:Show()
  end)
  self:SetScript('OnLeave', function(b) GameTooltip:Hide() end)
  
end

--[[-------------------------------------------------------------------
Methods:: EventTraceFrameMixin
---------------------------------------------------------------------]]
local o = DevSuite_PresetFiltersContentFrameMixin

--- @class KeywordButton : Button
--- @field protected __used boolean Internal use

function o:OnLoad()
  self.buttonPool = {}
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)

  local anchorTo = self.anchorTo  -- already resolved global
  self:SetParent(anchorTo)
  self:SetPoint('TOPLEFT', presetFiltersButton(), 'BOTTOMLEFT', 5, 2)
  self:SetFrameLevel(1000)
  self:SetAlpha(0.9)
  
  self.HeaderTitle:SetText(L['Preset Filters'])
  
  --- @type TextureObj
  local headerIcon = self.HeaderIconLeft
  headerIcon:SetDrawLayer('OVERLAY')
  headerIcon:SetScript('OnLeave', function() end)
  
  headerIcon:SetScript('OnEnter', function()
    ns.GameTooltip_DefaultAnchor()
    GameTooltip:AddLine(L['DevSuite addon feature'])
    GameTooltip:Show()
  end)

  AddButton_Init(self.ButtonsContainerFrame.AddButton, self.HeaderBackground)
  ClearButton_Init(self.ButtonsContainerFrame.ClearButton, self.HeaderTitle)

  self.ScrollChild = self.ScrollFrame.ScrollChild
  self.ScrollFrame:SetScrollChild(self.ScrollChild)
  self.ScrollFrame:SetFrameStrata('FULLSCREEN_DIALOG')

  local scrollBarWidth = self.ScrollFrame.ScrollBar:GetWidth() or 16
  local availableWidth = self.ScrollFrame:GetWidth() - scrollBarWidth - 4
  local deleteIconButtonWidth, bufferWidth = 12, 0
  self:SetWidth(availableWidth + deleteIconButtonWidth + bufferWidth)


  self:RegisterMessage(GC.M.OnAfterEnable, 'OnAfterEnable')
end

function o:OnAfterEnable(evt)
  self:SetCurrentEventTraceSearchKeyword()

  self:HookScript('OnEnter', function()
    if enterTimer then enterTimer:Cancel() end
  end)
  EventTrace:HookScript('OnEnter', function()
    if not presetFiltersButton():GetChecked() then return end
    enterTimer = C_Timer.NewTimer(0.8, function()
      enterTimer = nil
      presetFiltersButton():OnClickOthers()
    end)
  end)
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
function o:GetEventTraceSearchKeyword()
  local s = EventTrace.Log.Bar.SearchBox; if not s then return end
  return s:GetText()
end

function o:OnShow()
  self:RefreshPredefinedFilters()
end

--- @class PredefinedKeywordsButton : Button
--- @field private __used boolean
--- @field text FontString
--- @field DeleteButton IconButton|Button

--- @param self PredefinedKeywordsButton
--- @param owner PresetFiltersContentFrame
--- @param keyword string
local function PredefinedKeywordsButton_Init(self, owner, keyword)
  self.text:SetText(keyword)
  self.text:SetTextColor(1, 1, 1)
  self:Show()
  self.__used = true

  self:SetScript('OnClick', OnClick_KeywordButton)
  self:SetScript("OnEnter", function(btn)
    btn.HighlightBg:Show()
    btn.text:SetTextColor(1, 0.82, 0.25) -- gold (your theme)
  end)
  self:SetScript("OnLeave", function(btn)
    btn.HighlightBg:Hide()
    btn.text:SetTextColor(1, 1, 1) -- default
  end)
  local c1 = ns:ColorFn(WHITE_FONT_COLOR)
  -- Subdue the delete icon at rest
  local icon = self.DeleteButton.Icon
  icon:SetVertexColor(0.5, 0.5, 0.5, 0.6)
  -- todo: localize 'Delete keyword'
  self.DeleteButton.tooltipText = L['Delete keyword'] .. ': ' .. c1(self.DeleteButton:GetParent().text:GetText())
  self.DeleteButton.onClickHandler = OnClick_DeleteButton
  self.DeleteButton:ClearAllPoints()
  self.DeleteButton:SetPoint('RIGHT', self, 'RIGHT', -8, 0)
end

--- Button layout (ordered)
--- @param owner PresetFiltersContentFrame
local function PredefinedKeywordsButton_Layout(owner, presetKeywords)
  local prev, child = nil, owner.ScrollChild
  for _, keyword in ipairs(presetKeywords) do
    --- @type PredefinedKeywordsButton
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
  local presetKeywords = dbs():GetPresetKeywordsAsArray()
  if Tbl_IsEmpty(presetKeywords) then return end

  local child = self.ScrollChild
  local usedCount = 0

  for _, keyword in ipairs(presetKeywords) do
    --- @type ButtonObj
    local f = self.buttonPool[keyword]
    if not f then
      --- @type Template
      local template = 'DevSuite_PredefinedKeywordsButton'
      f = CreateFrame("Button", nil, child, template)
      self.buttonPool[keyword] = f
    end
    PredefinedKeywordsButton_Init(f, self, keyword)

    usedCount = usedCount + 1
  end
  
  PredefinedKeywordsButton_Layout(self, presetKeywords)
  
  -- cleanup
  for _, frame in pairs(self.buttonPool) do
    if not frame.__used then
      frame:ClearAllPoints()
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
  self:SendMessage(GC.toMsg('PresetFilterClose'), 'EventTraceFrame::' .. srcName)
end
