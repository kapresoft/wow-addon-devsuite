--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local Table = ns:Table()
local Tbl_DeepCopy, Tbl_IsEmpty = Table.DeepCopy, Table.IsEmpty

local msg_RemovePresetKeyword = 'RemovePresetKeyword(keywordToDelete): {keywordToDelete} should be a string, but type was [%s]'

local libName = 'DatabaseSchema'
local p, pd, t, tf = ns:log(libName)

--[[-------------------------------------------------------------------
Type: DatabaseSchema
---------------------------------------------------------------------]]
--- @class DatabaseSchema
local o = ns:NewLib2(libName)

--[[-----------------------------------------------------------------------------
Type: DevSuite_AceDBObject_3_0
-------------------------------------------------------------------------------]]
---@class DevSuite_AceDBObject_3_0 : AceDBObject-3.0
---@field keys table
---@field sv table
---@field defaults AceDB.Schema Cache of defaults
---@field parent table
--
--

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
    local itemData = { name = name, value = fnN, sortIndex = i, }
    table.insert(defaultProfile.debugDialog.items, itemData)
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
--- @class Profile_Config
--- @field enable boolean This is the standard enable. Don't use.
--- @field auto_loaded_addons AutoLoadedAddons
--- @field debugDialog Profile_Config_DebugDialog
--- @field last_eval Index
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
Type: PresetFilterKeywords
-------------------------------------------------------------------------------]]
--- @alias PresetFilterKeywords table<string, number>
--

--[[-----------------------------------------------------------------------------
Type: TraceConfig
-------------------------------------------------------------------------------]]
--- @class TraceConfig
--- @field show_at_startup boolean
--- @field preset_keyword string
--- @field preset_filter_keywords PresetFilterKeywords

--[[-----------------------------------------------------------------------------
Type: Character_Config
-------------------------------------------------------------------------------]]
--- @class Character_Config

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
      preset_keyword       = '',
      preset_filter_keywords = {
        ['player'] = 1,
        ['spell'] = 2,
        ['unit'] = 3,
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
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @return PresetFilterKeywords
function GetPresetFilterKeywords() return ns:g().trace.preset_filter_keywords end

--- @param keyword string
--- @param callbackFn fun(keywords:PresetFilterKeywords, match:string) : void
local function FindFirstKeyword(keyword, callbackFn)
  assertsafe(type(keyword) == 'string', 'FindFirstKeyword(keyword): {keyword} should be a string.')
  local keywords = GetPresetFilterKeywords()
  local lower = keyword:lower()
  for kw in pairs(keywords) do
    if kw:lower() == lower then
      return callbackFn and callbackFn(keywords, kw)
    end
  end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]


--- @return AceDBObjectInstance
function o:GetDatabase() return Tbl_DeepCopy(DefaultAddOnDatabase) end

--- @return string[]
function o:GetPresetKeywordsAsArray()
  local keywords = GetPresetFilterKeywords()
  local ordered = {}
  for kw, order in pairs(keywords) do
    table.insert(ordered, { kw = kw, order = order })
  end
  table.sort(ordered, function(a, b) return a.order < b.order end)
  local result = {}
  for i, entry in ipairs(ordered) do result[i] = entry.kw end
  return result
end


--- @param newKeyword string
function o:AddPresetKeyword(newKeyword)
  assertsafe(type(newKeyword) == 'string', 'AddPresetKeyword(newKeyword): {newKeyword} should be a string.')
  local keywords = GetPresetFilterKeywords()
  if Tbl_IsEmpty(keywords) then keywords[newKeyword] = 1; return end
  local lower = newKeyword:lower()
  local maxOrder = 0
  for k, order in pairs(keywords) do
    if k:lower() == lower then return end
    if order > maxOrder then maxOrder = order end
  end
  keywords[newKeyword] = maxOrder + 1
end

--- @param keywordToDelete string
function o:RemovePresetKeyword(keywordToDelete)
  assertsafe(type(keywordToDelete) == 'string',
  msg_RemovePresetKeyword, type(keywordToDelete))

  FindFirstKeyword(keywordToDelete, function(keywords, match)
      keywords[match] = nil
  end)
end
