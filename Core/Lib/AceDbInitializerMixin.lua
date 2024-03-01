--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = devsuite_ns(...)
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local LibUtil, AceEvent = ns:K(), ns:AceEvent()
local sformat = ns.sformat
local AceDB = O.AceLibrary.AceDB

local CONFIRM_RELOAD_UI_WITH_MSG = ns.name .. 'CONFIRM_RELOAD_UI_WITH_MSG'

local fn1 = [[-- evaluate a variable
{ GetBuildInfo() }]]
local fn2 = [[-- return a function
function()
  local version, build, date, tocversion = GetBuildInfo()
  local ret = {
    version=version, build=build, date=date, tocversion=tocversion
  }
  return ret
end]]
local fnN = [[
function()
  local ret = {
  }
  return ret
end]]

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias AceDbInitializer AceDbInitializerMixin
--- @class AceDbInitializerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.AceDbInitializerMixin)
local p = ns:LC().DB:NewLogger(M.AceDbInitializerMixin)

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
    function a:OnProfileChanged() ConfirmAndReload().data = GC.M.OnSyncAddOnEnabledState end
    function a:OnProfileCopied() ConfirmAndReload().data = GC.M.OnSyncAddOnEnabledState end
    function a:OnProfileReset() ConfirmAndReload().data = GC.M.OnSyncAddOnEnabledState end
end

---@param o AceDbInitializerMixin
local function Methods(o)

    --- Called by Mixin Automatically
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        --- @type AddOn_DB
        self.db = AceDB:New(GC.C.DB_NAME)
        ns:SetAddOnDB(self.db)
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
        self.db.RegisterCallback(self.addon, OnProfileChanged, OnProfileChanged)
        self.db.RegisterCallback(self.addon, OnProfileReset, OnProfileReset)
        self.db.RegisterCallback(self.addon, OnProfileCopied, OnProfileCopied)
        self:InitDbDefaults()
    end

    --- @return AddOn_DB
    function o:GetDefaultDB()

        --- @type AutoLoadedAddons
        local autoLoadedAddons = {
            ['!BugGrabber'] = true,
            ['BugSack'] = true,
            ['AddonUsage'] = true,
            ['Ace3'] = true,
            ['Boxer'] = false,
            ['M6'] = false,
        }

        --- @type Profile_Config
        local defaultProfile = {
            enable = true,
            debugDialog = {
                maxHistory = 15,
                items = {
                    { name='Saved #1', value=fn1, sortIndex=1 },
                    { name='Saved #2', value=fn2, sortIndex=2 },
                }
            },
            auto_loaded_addons = autoLoadedAddons
        }
        for i = 3, defaultProfile.debugDialog.maxHistory do
            local name = sformat('Saved #%s', i)
            --- @type Profile_Config_Item
            local t = { name=name, value = fnN, sortIndex = i, }
            table.insert(defaultProfile.debugDialog.items, t)
        end
        ---@param a Profile_Config_Item
        ---@param b Profile_Config_Item
        local function sortFn(a,b) return a.sortIndex <= b.sortIndex end
        table.sort(defaultProfile.debugDialog.items, sortFn)

        --- @type AddOn_DB
        local defaultDb = {
            global = {
                show_fps = true,
                auto_loaded_addons_characterSpecific = false,
                addon_addonUsage_auto_show_ui = true,
                auto_loaded_addons = autoLoadedAddons
            },
            profile = defaultProfile
        }
        return defaultDb
    end

    function o:InitDbDefaults()
        local profileName = self.db:GetCurrentProfile()
        p:d(function() return 'profile: %s', profileName end)
        self.db:RegisterDefaults(self:GetDefaultDB())
    end
end

Methods(L)

