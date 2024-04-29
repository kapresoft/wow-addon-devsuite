--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC, M, LibStub = ns.O, ns.GC, ns.M, ns.LibStub
local LibUtil, AceEvent = ns:K(), ns:AceEvent()
local AceDB = ns:AceDB()

local CONFIRM_RELOAD_UI_WITH_MSG = ns.addon .. 'CONFIRM_RELOAD_UI_WITH_MSG'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.AceDbInitializerMixin()
--- @alias AceDbInitializer AceDbInitializerMixin
--- @class AceDbInitializerMixin : Module
local L = LibStub:NewLibrary(libName)
local p = ns:LC().DB:NewLogger(libName)

--[[-----------------------------------------------------------------------------
ConfirmAndReload UI
-------------------------------------------------------------------------------]]
StaticPopupDialogs[CONFIRM_RELOAD_UI_WITH_MSG] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    --- @param messageName Name|nil
    OnAccept = function(self, messageName)
        if messageName then AceEvent:SendMessage(messageName, M.AceDbInitializerMixin) end
        ReloadUI()
    end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function ConfirmAndReload()
    if StaticPopup_Visible(CONFIRM_RELOAD_UI_WITH_MSG) == nil then return StaticPopup_Show(CONFIRM_RELOAD_UI_WITH_MSG) end
    return false
end


---@param a DevSuite
local function AddonCallbackMethods(a)
    function a:OnProfileChanged() p:f1('OnProfileChanged() called..') end
    function a:OnProfileCopied() p:f1('OnProfileCopied() called...') end
    function a:OnProfileReset() p:f1('OnProfileReset() called...') end
end

---@param o AceDbInitializerMixin
local function Methods(o)

    --- Called by Mixin Automatically
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        --- @type AddOn_DB
        self.addon.db = AceDB:New(GC.C.DB_NAME)
        ns:SetAddOnFn(function() return self.addon.db end)
    end

    --- Usage:  local instance = AceDbInitializerMixin:New(addon)
    --- @param addon DevSuite
    --- @return AceDbInitializer
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    function o:InitDb()
        p:f1('Initialize called...')
        AddonCallbackMethods(self.addon)

        local OnProfileChanged = "OnProfileChanged"
        local OnProfileReset = "OnProfileReset"
        local OnProfileCopied = "OnProfileCopied"
        ns:db().RegisterCallback(self.addon, OnProfileChanged, OnProfileChanged)
        ns:db().RegisterCallback(self.addon, OnProfileChanged, OnProfileChanged)
        ns:db().RegisterCallback(self.addon, OnProfileReset, OnProfileReset)
        ns:db().RegisterCallback(self.addon, OnProfileCopied, OnProfileCopied)
        self:InitDbDefaults()
    end

    function o:InitDbDefaults()
        local profileName = ns:db():GetCurrentProfile()
        p:d(function() return 'profile: %s', profileName end)
        ns:db():RegisterDefaults(ns.DefaultAddOnDatabase)
    end
end

Methods(L)

