--[[-----------------------------------------------------------------------------
CodeEditBoxMixin: the no-wrap EditBox used by CodeEditorDialog's code area.
Delegates each event back up to the owning dialog, resolved once in OnLoad.
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @class DevSuite_CodeEditBoxMixin : EditBox
--- @field owner DevSuite_CodeEditorDialogMixin The dialog this EditBox belongs to
DevSuite_CodeEditBoxMixin = {}
local o = DevSuite_CodeEditBoxMixin

--
--- @class DevSuite_CodeEditBox : DevSuite_CodeEditBoxMixin
--

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:OnLoad()
  -- EditBox -> ScrollFrame (its ScrollChild parent) -> dialog
  self.owner = self:GetParent():GetParent()
end

function o:OnEscapePressed() self.owner:OnClickClose() end
function o:OnTextChanged() self.owner:OnCodeEditBoxTextChanged() end
function o:OnCursorChanged(...) self.owner:OnCodeEditBoxCursorChanged(...) end
function o:OnSizeChanged() self.owner:OnCodeEditBoxSizeChanged() end