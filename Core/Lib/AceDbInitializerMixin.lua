--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, GC = ns.O, ns.LibStub, ns.M, ns.O.GlobalConstants
local LibUtil, KO = ns:K(), ns:KO()
local pformat, sformat = ns.pformat, ns.sformat

local AceDB, AceDBOptions = O.AceLibrary.AceDB, O.AceLibrary.AceDBOptions
local IsEmptyTable = KO.Table.isEmpty

local OnProfileChanged = "OnProfileChanged"
local OnProfileReset = "OnProfileReset"
local OnProfileCopied = "OnProfileCopied"

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
local p = L.logger();

--- Called by Mixin Automatically
--- @param addon DevSuite
function L:Init(addon)
    self.addon = addon
    --- @type AddOn_DB
    self.db = AceDB:New(GC.C.DB_NAME)
    ns:SetAddOnDB(self.db)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param a DevSuite
local function AddonCallbackMethods(a)
    function a:OnProfileChanged() ns:GC():ConfirmAndReload() end
    function a:OnProfileCopied() ns:GC():ConfirmAndReload() end
    function a:OnProfileReset() ns:GC():ConfirmAndReload() end
end

---@param o AceDbInitializerMixin
local function Methods(o)

    --- Usage:  local instance = AceDbInitializerMixin:New(addon)
    --- @param addon DevSuite
    --- @return AceDbInitializer
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    function o:InitDb()
        p:log(100, 'Initialize called...')
        AddonCallbackMethods(self.addon)
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
        p:log('profile: %s [%s]', profileName, type(self.db.RegisterDefaults))
        self.db:RegisterDefaults(self:GetDefaultDB())

    end
end

Methods(L)

