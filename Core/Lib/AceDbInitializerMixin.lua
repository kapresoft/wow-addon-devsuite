--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M, GC = ns.O, ns.LibStub, ns.M, ns.O.GlobalConstants
local LibUtil, KO = ns:K(), ns:KO()
local pformat, sformat = ns.pformat, ns.sformat

local AceDB = O.AceLibrary.AceDB
local IsEmptyTable = KO.Table.isEmpty
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
---@class AceDbInitializerMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.AceDbInitializerMixin)
local p = L.logger;

--- Called by Mixin Automatically
--- @param addon DevSuite
function L:Init(addon)
    self.addon = addon
    self.addon.db = AceDB:New(GC.C.DB_NAME)
    self.addon.dbInit = self
    self.db = self.addon.db
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param a DevSuite
local function AddonCallbackMethods(a)
    function a:OnProfileChanged()
        p:log('OnProfileChanged called...')
    end
    function a:OnProfileChanged()
        p:log('OnProfileReset called...')
    end
    function a:OnProfileChanged()
        p:log('OnProfileCopied called...')
    end
end

---@param o AceDbInitializerMixin
local function Methods(o)

    --- Usage:  local instance = AceDbInitializerMixin:New(addon)
    --- @param addon DevSuite
    --- @return AceDbInitializerMixin
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    ---@return AceDB
    function o:GetDB() return self.addon.db end

    function o:InitDb()
        p:log(100, 'Initialize called...')
        AddonCallbackMethods(self.addon)
        self.db.RegisterCallback(self.addon, "OnProfileChanged", "OnProfileChanged")
        self.db.RegisterCallback(self.addon, "OnProfileReset", "OnProfileChanged")
        self.db.RegisterCallback(self.addon, "OnProfileCopied", "OnProfileChanged")
        self:InitDbDefaults()
    end


    function o:InitDbDefaults()
        local profileName = self.addon.db:GetCurrentProfile()
        --- @type Profile_Config
        local defaultProfile = {
            ['debugDialog'] = {
                maxHistory = 15,
                items = {
                    { name='Saved #1', value=fn1, sortIndex=1 },
                    { name='Saved #2', value=fn2, sortIndex=2 },
                }
            },
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

        local defaults = { profile = defaultProfile }
        self.db:RegisterDefaults(defaults)
        self.addon.profile = self.db.profile
        local wowDB = _G[GC.C.DB_NAME]
        if IsEmptyTable(wowDB.profiles[profileName]) then wowDB.profiles[profileName] = defaultProfile end
        self.addon.profile.enable = false
        p:log(10, 'Profile: %s', self.db:GetCurrentProfile())
    end
end

Methods(L)

