--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, MS = ns.O, ns.GC.M
local AceConfigDialog = ns:Ace():AceConfigDialog()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @type string
local libName = ns.M.ConfigDialogController()
--- @class ConfigDialogController : AceEvent-3.0
local o = ns:NewLibWithEvent(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:OnAddonReady()
  self:CreateDialogEventFrame()
end

function o:CreateDialogEventFrame()
  local frameName = ns.sformat("%s_%sEventFrame", ns.addon, libName)
  --- @type Frame
  local f = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
  f:Hide()
  f:SetScript("OnHide", function(self)
    if not AceConfigDialog.OpenFrames[ns.addon] then return end
    AceConfigDialog:Close(ns.addon)
  end)
  self.dialogEventFrame = f
  RegisterStateDriver(self.dialogEventFrame, "visibility", "[combat]hide;show")
end

o:RegisterMessage(MS.OnAddOnReady, function() o:OnAddonReady() end)
