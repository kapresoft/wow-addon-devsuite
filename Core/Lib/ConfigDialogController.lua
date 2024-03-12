--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, MS = ns.O, ns.GC.M
local AceConfigDialog = O.AceLibrary.AceConfigDialog
local libName = ns.M.ConfigDialogController
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class ConfigDialogController : BaseLibraryObject_WithAceEvent
local L = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ConfigDialogController
local function PropsAndMethods(o)

    function o:OnAddonReady()
        p:f1('OnAddonReady() called...')
        self:CreateDialogEventFrame()
    end

    function o:CreateDialogEventFrame()
        local frameName = ns.sformat("%s_%sEventFrame", ns.name, libName)
        --- @type _Frame
        local f = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
        f:Hide()
        f:SetScript("OnHide", function(self)
            if not AceConfigDialog.OpenFrames[ns.name] then return end
            AceConfigDialog:Close(ns.name)
        end)
        self.dialogEventFrame = f
        RegisterStateDriver(self.dialogEventFrame, "visibility", "[combat]hide;show")
    end

    L:RegisterMessage(MS.OnAddonReady, function() o:OnAddonReady()  end)
end; PropsAndMethods(L)


