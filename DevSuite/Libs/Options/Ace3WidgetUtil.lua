--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local CONFIG = ns.O.Ace3WidgetConfig
local ACD = LibStub('AceConfigDialog-3.0', true)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.Ace3WidgetUtil()
--- Row and tooltip helpers for our AceGUI widgets
--- @class Ace3WidgetUtil_DevSuite
local o = {}; ns:Register(libName, o)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Same look as the hover highlight on Blizzard's Settings rows
--- @param frame Frame
--- @return Texture
function o:CreateRowHighlight(frame)
  local hover = frame:CreateTexture(nil, 'BACKGROUND')
  hover:SetPoint('TOPLEFT', -10, 0)
  hover:SetPoint('BOTTOMRIGHT', -5, 0)
  hover:SetColorTexture(1, 1, 1, 0.1)
  hover:Hide()
  return hover
end

--- Only the row frame shows the highlight; all fire tooltips
--- @param widget table
--- @param control Frame   @Tooltip context for the extra regions
--- @param ... ScriptRegion @Parts of the control that also show the tooltip
function o:HookRowHover(widget, control, ...)
  local frame = widget.frame
  frame:HookScript('OnEnter', function() widget.hover:Show() end)
  frame:HookScript('OnLeave', function() widget.hover:Hide() end)
  for _, region in ipairs({ frame, ... }) do
    local context = region == frame and widget.label or control
    region:HookScript('OnEnter', function() self:FireEnter(widget, context) end)
    region:HookScript('OnLeave', function() widget:Fire('OnLeave') end)
  end
end

--- Label column only; the control handles its own hover
--- @param widget table
--- @param labelWidth number @px
function o:LimitHoverToLabel(widget, labelWidth)
  local rightInset = math.max(0, widget.frame:GetWidth() - labelWidth)
  widget.frame:SetHitRectInsets(0, rightInset, 0, 0)
end

--- @param widget AceGUIWidget
--- @param tooltip GameTooltip
--- @param context ScriptRegion
function o:AnchorTooltip(widget, tooltip, context)
  local offset = CONFIG:Layout(widget).tooltip
  tooltip:SetAnchorType('ANCHOR_NONE')
  tooltip:ClearAllPoints()
  tooltip:SetPoint('BOTTOMLEFT', context, 'TOPRIGHT', offset.x, offset.y)
end

--- Also moves AceConfigDialog's tooltip beside the context
--- @param widget AceGUIWidget
--- @param context ScriptRegion
function o:FireEnter(widget, context)
  widget:Fire('OnEnter')
  local tooltip = ACD and ACD.tooltip
  if not (tooltip and tooltip:IsShown() and tooltip:GetOwner() == widget.frame) then return end
  self:AnchorTooltip(widget, tooltip, context)
end
