--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, MS = ns.O, ns.GC.M
local AceConfigDialog = ns:AceConfigDialog()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.ConfigDialogController()
--- @class ConfigDialogController
local L = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o ConfigDialogController | AceEventInterface
local function PropsAndMethods(o)

    function o:OnAddonReady()
        p:f1('OnAddonReady() called...')
        self:CreateDialogEventFrame()
    end

    function o:CreateDialogEventFrame()
        local frameName = ns.sformat("%s_%sEventFrame", ns.addon, libName)
        --- @type _Frame
        local f = CreateFrame("Frame", frameName, UIParent, "SecureHandlerStateTemplate")
        f:Hide()
        f:SetScript("OnHide", function(self)
            if not AceConfigDialog.OpenFrames[ns.addon] then return end
            AceConfigDialog:Close(ns.addon)
        end)
        self.dialogEventFrame = f
        RegisterStateDriver(self.dialogEventFrame, "visibility", "[combat]hide;show")
    end

    o:RegisterMessage(MS.OnAddOnReady, function() o:OnAddonReady()  end)
end; PropsAndMethods(L)


