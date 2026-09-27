--[[-----------------------------------------------------------------------------
StepperSlider Widget
AceGUI range control using Blizzard's Settings slider with stepper arrows.
Use via `dialogControl = 'DevSuite_StepperSlider'` on a 'range' option.
-------------------------------------------------------------------------------]]
local Type, Version = 'DevSuite_StepperSlider', 1

--- @type DevSuite_Namespace
local ns = select(2, ...)

local CONFIG = ns.O.Ace3WidgetConfig
local Util = ns.O.Ace3WidgetUtil
local AceGUI = LibStub and LibStub('AceGUI-3.0', true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end
if not MinimalSliderWithSteppersMixin then return end

local floor = math.floor
local Mixin_ = MinimalSliderWithSteppersMixin
local RIGHT_LABEL = Mixin_.Label.Right

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @param self table
--- @param value number
local function FormatValue(self, value)
  if self.ispercent then return ('%s%%'):format(floor(value * 1000 + 0.5) / 10) end
  return floor(value * 100 + 0.5) / 100
end

--- @param self table
--- @param value number
local function Snap(self, value)
  local step = self.step
  if not step or step <= 0 then return value end
  local minValue = self.min or 0
  return floor((value - minValue) / step + 0.5) * step + minValue
end

--- @param self table
local function Reinit(self)
  local minValue, maxValue = self.min or 0, self.max or 100
  local step = (self.step and self.step > 0) and self.step or 1
  local steps = (maxValue - minValue) / step
  local format = function(v) return FormatValue(self, v) end
  local formatters = { [RIGHT_LABEL] = CreateMinimalSliderFormatter(RIGHT_LABEL, format) }
  self.setup = true
  self.stepper:Init(self.value or minValue, minValue, maxValue, steps, formatters)
  self.setup = nil
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
--- @param self table
--- @param value number
local function Stepper_OnValueChanged(self, value)
  if self.setup or self.disabled then return end
  local snapped = Snap(self, value)
  if snapped == self.value then return end
  self.value = snapped
  self:Fire('OnValueChanged', snapped)
end

--- @param self table
local function Slider_OnMouseUp(self) self:Fire('OnMouseUp', self.value) end

--- Runs on each SetWidth; the option is only known by then
--- @param self table
local function ApplyLayout(self)
  local layout = CONFIG:Layout(self)
  self.label:SetWidth(layout.label.width)
  self.stepper:SetSize(layout.slider.width, layout.slider.height)
  self:SetHeight(layout.row.height)
  Util:LimitHoverToLabel(self, layout.label.width)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  OnAcquire = function(self)
    self.hover:Hide()
    self:SetWidth(200)
    self:SetIsPercent(nil)
    self:SetSliderValues(0, 100, 1)
    self:SetValue(0)
    self:SetDisabled(false)
  end,

  SetDisabled = function(self, disabled)
    self.disabled = disabled
    self.stepper:SetEnabled(not disabled)
    local color = disabled and GRAY_FONT_COLOR or NORMAL_FONT_COLOR
    self.label:SetTextColor(color:GetRGB())
  end,

  SetValue = function(self, value)
    self.value = value
    self.setup = true
    self.stepper:SetValue(value)
    self.setup = nil
  end,

  GetValue = function(self) return self.value end,

  OnWidthSet = ApplyLayout,

  SetLabel = function(self, text) self.label:SetText(text) end,

  SetSliderValues = function(self, minValue, maxValue, step)
    self.min, self.max, self.step = minValue, maxValue, step
    Reinit(self)
  end,

  SetIsPercent = function(self, value)
    self.ispercent = value
    Reinit(self)
  end,
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

  -- The value label draws past the stepper's right edge
  local template = 'MinimalSliderWithSteppersTemplate' --[[@as Template ]]
  local stepper = CreateFrame('Frame', nil, frame, template)
  stepper:SetPoint('LEFT', label, 'RIGHT')

  local widget = {
    label = label,
    hover = Util:CreateRowHighlight(frame),
    stepper = stepper,
    alignoffset = 25,
    frame = frame,
    type = Type,
  }
  for method, func in pairs(methods) do widget[method] = func end

  stepper:RegisterCallback(Mixin_.Event.OnValueChanged, function(_, value)
    Stepper_OnValueChanged(widget, value)
  end, widget)
  stepper.Slider:HookScript('OnMouseUp', function() Slider_OnMouseUp(widget) end)
  Util:HookRowHover(widget, stepper, stepper.Slider, stepper.Back, stepper.Forward)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
