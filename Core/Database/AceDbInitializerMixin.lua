--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = DevSuite_NS
local O, GC, M = ns.O, ns.GC, ns.M
local Ace = ns:Ace()
local AceEvent = Ace:NewAceEvent()
local AceDB = Ace:AceDB()

local CONFIRM_RELOAD_UI_WITH_MSG = ns.addon .. 'CONFIRM_RELOAD_UI_WITH_MSG'

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = M.AceDbInitializerMixin()
--- @class AceDbInitializerMixin : AceEvent-3.0
local S = ns:NewAceEvent(); ns:Register(libName, S)
local p, pd, t, tf = ns:log(libName)
--
--- @class AceDbInitializer : AceDbInitializerMixin
--

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
  function a:OnProfileChanged() t('OnProfileChanged() called..') end
  function a:OnProfileCopied() t('OnProfileCopied() called...') end
  function a:OnProfileReset() t('OnProfileReset() called...') end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local o = S

--- Called by Mixin Automatically
--- @param addon DevSuite
function o:Init(addon)
  self.addon = addon
  --- @type AceDBObjectInstance
  self.addon.db = AceDB:New(GC.C.DB_NAME)
  ns:SetAddOnFn(function() return self.addon.db end)
end

--- Usage:  local instance = AceDbInitializerMixin:New(addon)
--- @param addon DevSuite
--- @return AceDbInitializer
function o:New(addon) return CreateAndInitFromMixin(o, addon) end

function o:InitDb()
  AddonCallbackMethods(self.addon)

  local OnProfileChanged = "OnProfileChanged"
  local OnProfileReset   = "OnProfileReset"
  local OnProfileCopied  = "OnProfileCopied"
  ns:db().RegisterCallback(self.addon, OnProfileChanged, OnProfileChanged)
  ns:db().RegisterCallback(self.addon, OnProfileChanged, OnProfileChanged)
  ns:db().RegisterCallback(self.addon, OnProfileReset, OnProfileReset)
  ns:db().RegisterCallback(self.addon, OnProfileCopied, OnProfileCopied)
  self:InitDbDefaults()
end

function o:InitDbDefaults()
  local profileName = ns:db():GetCurrentProfile()
  ns:db():RegisterDefaults(ns.O.DatabaseSchema:GetDatabase())
end


