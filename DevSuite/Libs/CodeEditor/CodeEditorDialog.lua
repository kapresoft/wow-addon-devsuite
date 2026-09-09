--[[-----------------------------------------------------------------------------
CodeEditorDialog: standalone (non-Ace3) line-numbered code editor prototype.
Self-contained: not wired into the DevSuite namespace/module registry.
See GitHub issue #90.
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local libName = 'CodeEditorDialog'
local p, t = ns:log(libName)

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame = CreateFrame

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- BACKDROP_TOAST_12_12 with its edge dropped, for bars that should only show
-- a background fill (no border).
local BACKDROP_TOAST_12_12_NO_EDGE = {
  bgFile = BACKDROP_TOAST_12_12.bgFile,
  tile = BACKDROP_TOAST_12_12.tile,
  tileSize = BACKDROP_TOAST_12_12.tileSize,
  insets = BACKDROP_TOAST_12_12.insets,
}

-- Sample text long enough to force scrolling, for testing gutter/scroll sync.
local SAMPLE_CODE = [[
local function fibonacci(n)
  if n <= 1 then
    return n
  end
  return fibonacci(n - 1) + fibonacci(n - 2)
end

local function printFibonacciSequence(count)
  for i = 1, count do
    print(i, fibonacci(i))
  end
end

local Frame = CreateFrame('Frame')
Frame:RegisterEvent('PLAYER_ENTERING_WORLD')
Frame:SetScript('OnEvent', function(self, event, ...)
  if event ~= 'PLAYER_ENTERING_WORLD' then return end
  printFibonacciSequence(10)
end)

local t = {}
for i = 1, 20 do
  t[i] = i * i
end

local function sum(tbl)
  local total = 0
  for _, v in ipairs(tbl) do
    total = total + v
  end
  return total
end

print('Sum of squares:', sum(t))
--end]]

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class DevSuite_CodeEditorGutterChild : Frame
--- @field Numbers FontString "1\n2\n...\nN" in the code font, right-justified

--- @class DevSuite_CodeEditorGutter : ScrollFrame
--- @field ScrollChild DevSuite_CodeEditorGutterChild

--- @class DevSuite_CodeEditorBottomBar : Frame
--- @field WrapCheckButton CheckButton

--- @class DevSuite_CodeEditorWrapMeasure : Frame
--- @field Text FontString Hidden; same font/wrap as CodeEditBox, used to count wrapped rows

--- @class DevSuite_CodeEditorDialogMixin : Frame
--- @field TopBar Frame Reserved space for future toolbar/controls
--- @field BottomBar DevSuite_CodeEditorBottomBar
--- @field WrapMeasure DevSuite_CodeEditorWrapMeasure
--- @field wrapText boolean Current wrap-mode state
--- @field GutterBackdrop Frame Draws the gutter's border; Gutter is inset inside it
--- @field Gutter DevSuite_CodeEditorGutter
--- @field CodeBackdrop Frame Draws the code area's border; ScrollFrame is inset inside it
--- @field ScrollFrame ScrollFrame
--- @field CodeEditBox DevSuite_CodeEditBox
--- @field CloseButton Button
--- @field SizerSE Frame Bottom-right resize grip
--- @field HeaderTitle FontString
DevSuite_CodeEditorDialogMixin = {}
local o = DevSuite_CodeEditorDialogMixin

--
--- @class DevSuite_CodeEditorDialog : DevSuite_CodeEditorDialogMixin
--

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param self DevSuite_CodeEditorDialog
--- @return number
local function CountLines(self)
  local text = self.CodeEditBox:GetText() or ''
  local _, count = text:gsub('\n', '\n')
  return count + 1
end

--- @param numLines number
--- @return string "1\n2\n...\nN"
local function LineNumbersText(numLines)
  local parts = {}
  for i = 1, numLines do parts[i] = i end
  return table.concat(parts, '\n')
end

--- Wrap mode: each logical line gets its number followed by (rows - 1) blank
--- lines, so the gutter's rows mirror the code's wrapped visual rows.
--- @param self DevSuite_CodeEditorDialog
--- @return string
local function WrappedLineNumbersText(self)
  local measure = self.WrapMeasure.Text
  local parts = {}
  local n = 0
  -- Trailing '\n' keeps a final empty line counted, matching CountLines().
  for line in (self.CodeEditBox:GetText() .. '\n'):gmatch('(.-)\n') do
    n = n + 1
    parts[#parts + 1] = n
    measure:SetText(line)
    local rows = measure:GetNumLines()
    for _ = 2, rows do parts[#parts + 1] = '' end
  end
  return table.concat(parts, '\n')
end

--- Width the EditBox actually wraps text at: viewport minus its text insets.
--- @param self DevSuite_CodeEditorDialog
--- @return number
local function CodeTextWidth(self)
  local left, right = self.CodeEditBox:GetTextInsets()
  return self.ScrollFrame:GetWidth() - left - right
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:OnLoad()
  -- parentKey="CodeEditBox" resolves onto the ScrollFrame (its immediate XML
  -- parent), not this dialog frame -- alias it here so the rest of this file
  -- can address it as self.CodeEditBox.
  self.CodeEditBox = self.ScrollFrame.CodeEditBox

  self:SetBackdrop(BACKDROP_TOAST_12_12)
  self.TopBar:SetBackdrop(BACKDROP_TOAST_12_12_NO_EDGE)
  self.BottomBar:SetBackdrop(BACKDROP_TOAST_12_12_NO_EDGE)
  self.GutterBackdrop:SetBackdrop(BACKDROP_TOAST_12_12)
  self.CodeBackdrop:SetBackdrop(BACKDROP_TOAST_12_12)

  -- Diagonal resize-grip lines, matching AceGUI-3.0's sizer_se exactly
  -- (SetTexCoord's 8-value quad form isn't expressible via XML <TexCoords>).
  local line1 = self.SizerSE.Line1
  local x1 = 0.1 * 14 / 17
  line1:SetTexCoord(0.05 - x1, 0.5, 0.05, 0.5 + x1, 0.05, 0.5 - x1, 0.5 + x1, 0.5)
  local line2 = self.SizerSE.Line2
  local x2 = 0.1 * 8 / 17
  line2:SetTexCoord(0.05 - x2, 0.5, 0.05, 0.5 + x2, 0.05, 0.5 - x2, 0.5 + x2, 0.5)

  if self.SetResizeBounds then -- WoW 10.0+
    self:SetResizeBounds(400, 250)
  else
    self:SetMinResize(400, 250)
  end

  self.HeaderTitle:SetText('Code Editor (Prototype)')

  local wrapCheck = self.BottomBar.WrapCheckButton
  wrapCheck.text:SetText('Wrap Text')
  wrapCheck:SetChecked(false)

  -- Default is no-wrap: the EditBox is fixed-width and wider than the scroll
  -- viewport, so lines never reach a wrap boundary and logical line count
  -- (\n-based) always equals visual line count. Start at the viewport's
  -- height (not 1px) so there's a clickable/visible area before any text
  -- is typed; RefreshGutter grows it from here as needed.
  self.CodeEditBox:SetHeight(self.ScrollFrame:GetHeight())
  self.CodeEditBox:SetAutoFocus(false)
  self:SetWrapText(false)
  -- Horizontal text padding: EditBox insets are the actual API for this --
  -- the frame's own anchors position the whole (4000px-wide, no-wrap) hit
  -- region, not the glyphs within it, so nudging those anchors doesn't pad
  -- the text. Top/bottom stay 0 -- the gutter's line labels are positioned
  -- independently of CodeEditBox's insets, so a vertical inset here would
  -- desync line 1's label from the code's actual first line.
  self.CodeEditBox:SetTextInsets(6, 6, 0, 0)

  -- Prototype-only: pre-fill with sample code long enough to force scrolling,
  -- so gutter/scroll sync can be tested immediately on open.
  self:SetText(SAMPLE_CODE)

  self:RefreshGutter()
end

function o:OnClickClose() self:Hide() end

--- Vertical scroll of the code ScrollFrame moves the gutter's own scroll in
--- lockstep, via the real ScrollFrame API (not a manual re-anchor) so the
--- gutter's content clips to its viewport exactly like the code area's does.
--- @param offset number
function o:OnCodeEditBoxScroll(offset)
  self.Gutter:SetVerticalScroll(offset)
end

function o:OnCodeEditBoxTextChanged()
  -- CodeEditBox's own OnLoad wires this script and can fire it during
  -- construction, before this dialog's OnLoad has aliased self.CodeEditBox.
  if not self.CodeEditBox then return end
  self:RefreshGutter()
end

function o:OnCodeEditBoxCursorChanged(x, y, w, h)
  -- Keep the cursor's line visible by scrolling the ScrollFrame; horizontal
  -- position is handled natively by the EditBox/ScrollFrame pairing.
end

function o:OnCodeEditBoxSizeChanged()
  if not self.CodeEditBox then return end
  self:RefreshGutter()
end

--- @param checked boolean
function o:OnWrapToggled(checked) self:SetWrapText(checked) end

--- Toggles wrap mode. In no-wrap mode the EditBox is oversized (4000px) so
--- lines never wrap; in wrap mode it is pinned to the viewport width so the
--- text engine wraps at the visible edge.
--- @param enabled boolean
function o:SetWrapText(enabled)
  self.wrapText = enabled and true or false
  local editBox = self.CodeEditBox
  if self.wrapText then
    editBox:SetWidth(self.ScrollFrame:GetWidth())
    self.ScrollFrame:SetHorizontalScroll(0)
  else
    editBox:SetWidth(4000)
  end
  self:RefreshGutter()
end

--- Rebuilds the gutter's "1..N" text and sizes both columns to the content.
function o:RefreshGutter()
  if not self.CodeEditBox then return end -- not constructed yet (see OnCodeEditBoxTextChanged)
  local gutter = self.Gutter
  local child = gutter.ScrollChild
  local numbers = child.Numbers

  -- Width must be set explicitly (scroll children ignore right-side anchors)
  -- so the right-justified numbers land at the Gutter's clip edge, not past it.
  child:SetWidth(gutter:GetWidth())

  if self.wrapText then
    -- Keep the EditBox and the measuring string wrapping at the same width;
    -- wrap points move with the viewport, so this must track resizes too.
    local textWidth = CodeTextWidth(self)
    self.CodeEditBox:SetWidth(self.ScrollFrame:GetWidth())
    self.WrapMeasure.Text:SetWidth(textWidth)
    numbers:SetText(WrappedLineNumbersText(self))
  else
    numbers:SetText(LineNumbersText(CountLines(self)))
  end

  -- Both columns render the same line count in the same font, so the gutter's
  -- measured text height IS the code's content height -- no guessed pitch.
  -- Sizing both to it also gives the two ScrollFrames an identical scroll
  -- range, keeping SetVerticalScroll in sync down to the last line.
  local contentHeight = math.max(numbers:GetStringHeight(), self.ScrollFrame:GetHeight())
  child:SetHeight(contentHeight)
  self.CodeEditBox:SetHeight(contentHeight)
end

--- @return DevSuite_CodeEditorDialog
function o:GetText() return self.CodeEditBox:GetText() end

--- @param text string
function o:SetText(text)
  self.CodeEditBox:SetText(text or '')
  self:RefreshGutter()
end