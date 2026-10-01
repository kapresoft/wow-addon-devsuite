--[[-----------------------------------------------------------------------------
StepperDropdown Widget
AceGUI select control using Blizzard's Settings dropdown with stepper arrows.
Use via `dialogControl = 'DevSuite_StepperDropdown'` on a 'select' option.
-------------------------------------------------------------------------------]]
local Type, Version = 'DevSuite_StepperDropdown', 1
local AceGUI = LibStub and LibStub('AceGUI-3.0', true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
if not DropdownWithSteppersMixin then return end

--- @type DevSuite_Namespace
local ns = select(2, ...)
local CONFIG = ns.O.Ace3WidgetConfig
local Util = ns.O.Ace3WidgetUtil

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @param list table<any, string>
--- @return any[] @Keys sorted by their display text
local function SortedKeys(list)
  local keys = {}
  for k in pairs(list) do
    table.insert(keys, k)
  end
  table.sort(keys, function(a, b) return tostring(list[a]) < tostring(list[b]) end)
  return keys
end

--- @param self table
local function SetupMenu(self)
  local function IsSelected(key) return key == self.value end
  local function SetSelected(key)
    if self.disabled or key == self.value then return end
    self.value = key
    self:Fire('OnValueChanged', key)
  end
  self.dropdown:SetupMenu(function(_, root)
    for _, key in ipairs(self.order) do
      root:CreateRadio(self.list[key], IsSelected, SetSelected, key)
    end
  end)
end

--- Blizzard uses TOOLTIP strata only if the owner has it
--- @param dropdown DropdownButton
local function OpenMenuAboveDialogs(dropdown)
  local openMenu = dropdown.OpenMenu
  function dropdown:OpenMenu()
    local strata = self:GetFrameStrata()
    self:SetFrameStrata('TOOLTIP')
    openMenu(self)
    self:SetFrameStrata(strata)
  end
end

--- @param self table
local function Refresh(self)
  if self.dropdown:IsShown() then self.dropdown:GenerateMenu() end
end

--- Arrow widths plus the gaps from Blizzard's OnLoad
--- @param control Frame
--- @return number @px
local function SteppersWidth(control)
  local back, forward = control.DecrementButton, control.IncrementButton
  local _, _, _, backX = back:GetPoint()
  local _, _, _, forwardX = forward:GetPoint()
  return back:GetWidth() - backX + forward:GetWidth() + forwardX
end

--- @param self table
local function Dropdown_OnEnter(self)
  local tooltip = CONFIG:DropdownTooltip(self)
  if not tooltip then return end
  GameTooltip:SetOwner(self.dropdown, 'ANCHOR_NONE')
  Util:AnchorTooltip(self, GameTooltip, self.dropdown)
  if type(tooltip) == 'function' then
    tooltip(GameTooltip)
  else
    GameTooltip:SetText(tooltip)
  end
  GameTooltip:Show()
end

--- Undo line fonts a tooltip set; the lines are shared
local function Dropdown_OnLeave()
  for i = 1, GameTooltip:NumLines() do
    local line = _G['GameTooltipTextLeft' .. i]
    line:SetFontObject(i == 1 and GameTooltipHeaderText or GameTooltipText)
  end
  GameTooltip:Hide()
end

--- Runs on each SetWidth; the option is only known by then
--- @param self table
local function ApplyLayout(self)
  local layout = CONFIG:Layout(self)
  local width = layout.dropdown.width
  self.label:SetWidth(layout.label.width)
  self.control:SetSize(width, layout.dropdown.height)
  self.dropdown:SetWidth(width - self.steppersWidth)
  self:SetHeight(layout.row.height)
  Util:LimitHoverToLabel(self, layout.label.width)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  OnAcquire = function(self)
    self.hover:Hide()
    self.list, self.order, self.value = {}, {}, nil
    self:SetWidth(200)
    self:SetDisabled(false)
  end,

  OnRelease = function(self)
    if self.dropdown.CloseMenu then self.dropdown:CloseMenu() end
    self.list, self.order, self.value = {}, {}, nil
  end,

  OnWidthSet = ApplyLayout,

  SetLabel = function(self, text) self.label:SetText(text) end,

  SetDisabled = function(self, disabled)
    self.disabled = disabled
    self.control:SetEnabled(not disabled)
    local color = disabled and GRAY_FONT_COLOR or NORMAL_FONT_COLOR
    self.label:SetTextColor(color:GetRGB())
  end,

  SetList = function(self, list, order)
    self.list = list or {}
    self.order = order or SortedKeys(self.list)
    Refresh(self)
  end,

  SetValue = function(self, value)
    self.value = value
    Refresh(self)
  end,

  GetValue = function(self) return self.value end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
  local frame = CreateFrame('Frame', nil, UIParent)
  frame:EnableMouse(true)

  local label = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  label:SetPoint('LEFT')
  label:SetJustifyH('LEFT')

  local template = 'DevSuite_DropdownWithSteppersTemplate' --[[@as Template ]]
  local control = CreateFrame('Frame', nil, frame, template)
  control:SetPoint('LEFT', label, 'RIGHT')

  local widget = {
    label = label,
    hover = Util:CreateRowHighlight(frame),
    control = control,
    dropdown = control.Dropdown,
    steppersWidth = SteppersWidth(control),
    list = {},
    order = {},
    alignoffset = 30,
    frame = frame,
    type = Type,
  }
  for method, func in pairs(methods) do
    widget[method] = func
  end
  OpenMenuAboveDialogs(widget.dropdown)
  SetupMenu(widget)
  Util:HookRowHover(widget, control)
  control.Dropdown:HookScript('OnEnter', function() Dropdown_OnEnter(widget) end)
  control.Dropdown:HookScript('OnLeave', Dropdown_OnLeave)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
