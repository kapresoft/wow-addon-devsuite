--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local ns = select(2, ...)
local Tbl_DeepCopy = ns:Table().deep_copy

---@class DevSuite_AceDBObject_3_0
---@field keys table
---@field sv table
---@field defaults AceDB_3_0.Schema Cache of defaults
---@field parent table

--[[-------------------------------------------------------------------
Type: DatabaseSchema
---------------------------------------------------------------------]]
--- @class DatabaseSchema
local S = {};
ns.O.DatabaseSchema = S

--- @type DatabaseSchema
local o = S

--[[-----------------------------------------------------------------------------
Type: Profile_Config_Item
-------------------------------------------------------------------------------]]
--- @class Profile_Config_Item
--- @field name string
--- @field value string
--- @field sortIndex number

--[[-----------------------------------------------------------------------------
Type: Profile_Config_DebugDialog
-------------------------------------------------------------------------------]]
--- @class Profile_Config_DebugDialog
--- @field maxHistory number
--- @field items table<number, Profile_Config_Item>

--[[-----------------------------------------------------------------------------
Type: Profile_DB_ProfileKeys
-------------------------------------------------------------------------------]]
--- ``` ["Azwang - Smolderweb"] = "Azwang - Smolderweb" ```
--- @class Profile_DB_ProfileKeys : table<string, string>

--- @class DebugSettingsFlag_Config
--- @field enableLogConsole boolean @defaults is false
--- @field selectLogConsoleTab boolean @defaults is true
--- @field makeDefaultChatFrame boolean @defaults is true
--- @field maxLogConsoleLines number @defaults is 1000
--- @field DEVTOOLS_DEPTH_CUTOFF number @defaults is 5
--- @field DEVTOOLS_MAX_ENTRY_CUTOFF number @defaults is 50

--[[-----------------------------------------------------------------------------
Type: Profile_Global_Config
-------------------------------------------------------------------------------]]
--- @class DevSuite_Global_Config
--- @field debug DebugSettingsFlag_Config
--- @field debug_dialog DebugDialog_Config
--- @field trace TraceConfig
--- @field show_fps boolean
--- @field addon_addonUsage_auto_show_ui boolean
--- @field prompt_for_reload_to_enable_addons boolean
--- @field auto_loaded_addons AutoLoadedAddons
--- @field console_fontSize number
--
--
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

--- @param defaultProfile Profile_Config
local function InitDefaultProfile(defaultProfile)
  for i = 3, defaultProfile.debugDialog.maxHistory do
    local name = ns.sformat('Saved #%s', i)
    --- @type Profile_Config_Item
    local t = { name = name, value = fnN, sortIndex = i, }
    table.insert(defaultProfile.debugDialog.items, t)
  end
  ---@param a Profile_Config_Item
  ---@param b Profile_Config_Item
  local function sortFn(a, b) return a.sortIndex <= b.sortIndex end
  table.sort(defaultProfile.debugDialog.items, sortFn)
  
  return defaultProfile
end

--[[-----------------------------------------------------------------------------
Type: Profile_Config
-------------------------------------------------------------------------------]]
--- @class Profile_Config : AceDB_Profile
--- @field enable boolean This is the standard enable. Don't use.
--- @field auto_loaded_addons AutoLoadedAddons
--- @field debugDialog Profile_Config_DebugDialog
local DefaultProfileSettings = {
  enable      = true,
  debugDialog = {
    maxHistory = 15,
    items      = {
      { name = 'Saved #1', value = fn1, sortIndex = 1 },
      { name = 'Saved #2', value = fn2, sortIndex = 2 },
    }
  },
};
InitDefaultProfile(DefaultProfileSettings)

--[[-----------------------------------------------------------------------------
Type: TraceConfig
-------------------------------------------------------------------------------]]
---@class TraceConfig
---@field show_at_startup boolean
---@field preset_keyword string
---@field preset_filter_keywords string[]

--[[-----------------------------------------------------------------------------
Type: Character_Config
-------------------------------------------------------------------------------]]
--- @class Character_Config : AceDB_Character

--[[-----------------------------------------------------------------------------
Type: AceDBObjectInstance
-------------------------------------------------------------------------------]]
--- @class AceDBObjectInstance : DevSuite_AceDBObject_3_0
--- @field global DevSuite_Global_Config
--- @field char Character_Config
--- @field profile Profile_Config
--- @field profileKeys Profile_DB_ProfileKeys
--- @field profiles table<string, Profile_Config>
local DefaultAddOnDatabase = {
  --- @type DevSuite_Global_Config
  global = {
    show_fps                           = true,
    prompt_for_reload_to_enable_addons = true,
    addon_addonUsage_auto_show_ui      = true,
    show_AddonManagerHasMovedNotice    = true,
    console_fontSize                   = 14,
    --- @type DebugSettingsFlag_Config
    debug = {
      enableLogConsole                 = false,
      selectLogConsoleTab              = true,
      makeDefaultChatFrame             = true,
      maxLogConsoleLines               = 1000,
      DEVTOOLS_DEPTH_CUTOFF            = 5,
      DEVTOOLS_MAX_ENTRY_CUTOFF        = 50,
    },
    --- @type DebugDialog_Config
    debug_dialog = {
      width                            = 500,
      height                           = 600,
      --- @type DevSuite_Anchor_Config
      anchor = {
        point                          = "CENTER"
      }
    },
    --- @type TraceConfig
    trace = {
      show_at_startup      = false,
      preset_keyword        = '',
      preset_filter_keywords = {
        "devsuite", 'abpv2', 'gears',
        'filter 1a',  'filter 2a',  'filter 3a',  'filter 4a',  'filter 5a',
        'filter 1b',  'filter 2b',  'filter 3b',  'filter 4b',  'filter 5b',
      },
    },
  },
  profile                              = DefaultProfileSettings,
  char                                 = {},
}

--- @class DevSuite_Anchor_Config
--- @field point string | "CENTER" | "TOPLEFT"
--- @field relativeTo any
--- @field relativePoint string | "CENTER" | "TOPLEFT"
--- @field x number
--- @field y number

--- @class DebugDialog_Config
--- @field width number @default 400
--- @field height number @default 500
--- @field anchor DevSuite_Anchor_Config

--- @return AceDBObjectInstance
function o:GetDatabase() return Tbl_DeepCopy(DefaultAddOnDatabase) end

