--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local ns = select(2, ...)

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
--- @class DevSuite_Global_Config : AceDB_Global
--- @field debug DebugSettingsFlag_Config
--- @field debug_dialog DebugDialog_Config
--- @field show_fps boolean
--- @field addon_addonUsage_auto_show_ui boolean
--- @field prompt_for_reload_to_enable_addons boolean
--- @field auto_loaded_addons AutoLoadedAddons
--- @field console_fontSize

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
        local t = { name=name, value = fnN, sortIndex = i, }
        table.insert(defaultProfile.debugDialog.items, t)
    end
    ---@param a Profile_Config_Item
    ---@param b Profile_Config_Item
    local function sortFn(a,b) return a.sortIndex <= b.sortIndex end
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
    enable = true,
    debugDialog = {
        maxHistory = 15,
        items = {
            { name='Saved #1', value=fn1, sortIndex=1 },
            { name='Saved #2', value=fn2, sortIndex=2 },
        }
    },
}; InitDefaultProfile(DefaultProfileSettings)

--[[-----------------------------------------------------------------------------
Type: Character_Config
-------------------------------------------------------------------------------]]
--- @class Character_Config : AceDB_Character

--[[-----------------------------------------------------------------------------
Type: AddOn_DB
-------------------------------------------------------------------------------]]
--- @class AddOn_DB : AceDB
--- @field global DevSuite_Global_Config
--- @field char Character_Config
--- @field profile Profile_Config
--- @field profileKeys Profile_DB_ProfileKeys
--- @field profiles table<string, Profile_Config>
local DefaultAddOnDatabase = {
    global = {
      show_fps = true,
      prompt_for_reload_to_enable_addons = true,
      addon_addonUsage_auto_show_ui = true,
      show_AddonManagerHasMovedNotice = true,
      console_fontSize = 14,
      debug = {
        enableLogConsole = false,
        selectLogConsoleTab = true,
        makeDefaultChatFrame = true,
        maxLogConsoleLines = 1000,
        DEVTOOLS_DEPTH_CUTOFF = 5,
        DEVTOOLS_MAX_ENTRY_CUTOFF = 50,
      },
      debug_dialog = {
        width=500,
        height=600,
        anchor= {
          point = "CENTER"
        }
      }
    },
    profile = DefaultProfileSettings,
    char = {},
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
Namespace Var
-------------------------------------------------------------------------------]]
ns.DefaultAddOnDatabase = DefaultAddOnDatabase

