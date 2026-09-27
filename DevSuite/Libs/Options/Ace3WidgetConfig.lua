--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local Table = ns:Table()
local t_merge = Table.MergeRecursive

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- Per-option override passed through AceConfig's `arg`
--- @class Ace3WidgetArg_DevSuite
--- @field layout? Ace3WidgetLayout_DevSuite
--- @field tooltip? Ace3WidgetTooltipArg_DevSuite

--- Tooltip content, keyed by the part it shows over
--- @class Ace3WidgetTooltipArg_DevSuite
--- @field dropdown? string|fun(tooltip:GameTooltip) @Shown over the dropdown, not its arrows

--- @class Ace3WidgetSize_DevSuite
--- @field width? number  @px
--- @field height? number @px

--- Only height is used; AceGUI sets the row width
--- @class Ace3WidgetRow_DevSuite : Ace3WidgetSize_DevSuite

--- @class Ace3WidgetLabel_DevSuite : Ace3WidgetSize_DevSuite

--- Width includes the stepper arrows
--- @class Ace3WidgetDropdown_DevSuite : Ace3WidgetSize_DevSuite

--- Width excludes the value label
--- @class Ace3WidgetSlider_DevSuite : Ace3WidgetSize_DevSuite

--- @class Ace3WidgetCheckbox_DevSuite : Ace3WidgetSize_DevSuite

--- Tooltip BOTTOMLEFT offset from its context's TOPRIGHT
--- @class Ace3WidgetTooltip_DevSuite
--- @field x? number @px
--- @field y? number @px

--- @class Ace3WidgetLayout_DevSuite
--- @field row? Ace3WidgetRow_DevSuite
--- @field label? Ace3WidgetLabel_DevSuite
--- @field dropdown? Ace3WidgetDropdown_DevSuite
--- @field slider? Ace3WidgetSlider_DevSuite
--- @field checkbox? Ace3WidgetCheckbox_DevSuite
--- @field tooltip? Ace3WidgetTooltip_DevSuite

--[[-----------------------------------------------------------------------------
Defaults
-------------------------------------------------------------------------------]]
--- @type Ace3WidgetLayout_DevSuite
local DEFAULT_LAYOUT = {
  row = { height = 30 },
  label = { width = 150 },
  dropdown = { width = 260, height = 30 },
  slider = { width = 220, height = 19 },
  checkbox = { width = 30, height = 30 },
  tooltip = { x = 20, y = 20 },
}

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.Ace3WidgetConfig()
--- Shared by our AceGUI widgets so their rows line up
--- @class Ace3WidgetConfig_DevSuite
local o = {}; ns:Register(libName, o)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param widget AceGUIWidget
--- @return Ace3WidgetArg_DevSuite? @The option's AceConfig `arg`; nil if unset
local function ArgFor(widget)
  local option = widget:GetUserData('option')
  return option and option.arg
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- The option's `arg.layout` merged over the defaults
--- @param widget AceGUIWidget
--- @return Ace3WidgetLayout_DevSuite
function o:Layout(widget)
  local arg = ArgFor(widget)
  local override = type(arg) == 'table' and arg.layout or {}
  -- Merge into a copy; arg tables are shared across options
  return t_merge(DEFAULT_LAYOUT, t_merge(override, {}))
end

--- @param widget AceGUIWidget
--- @return (string|fun(tooltip:GameTooltip))? @nil if the option sets none
function o:DropdownTooltip(widget)
  local arg = ArgFor(widget)
  local tooltip = type(arg) == 'table' and arg.tooltip
  return type(tooltip) == 'table' and tooltip.dropdown or nil
end
