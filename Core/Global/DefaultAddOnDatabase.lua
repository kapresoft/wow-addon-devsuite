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
local DebugSettingsFlag = {
    enableLogConsole = false,
    selectLogConsoleTab = true,
    makeDefaultChatFrame = true,
    maxLogConsoleLines = 1000,
    DEVTOOLS_DEPTH_CUTOFF = 5,
    DEVTOOLS_MAX_ENTRY_CUTOFF = 50,
}

--[[-----------------------------------------------------------------------------
Type: Profile_Global_Config
-------------------------------------------------------------------------------]]
--- @class Profile_Global_Config : AceDB_Global
--- @field show_fps boolean
--- @field addon_addonUsage_auto_show_ui boolean
--- @field prompt_for_reload_to_enable_addons boolean
--- @field auto_loaded_addons AutoLoadedAddons
local DefaultGlobal = {
    show_fps = true,
    prompt_for_reload_to_enable_addons = true,
    addon_addonUsage_auto_show_ui = true,
    show_AddonManagerHasMovedNotice = true,
    debug = DebugSettingsFlag,
}

--[[-----------------------------------------------------------------------------
Type: Profile_Character_Config
-------------------------------------------------------------------------------]]
--- @class Profile_Character_Config
local DefaultCharacterSettings = {
    nickName = 'Uber Player'
}

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
--- @class Character_Config
local DefaultCharacterSettings = {

}

--[[-----------------------------------------------------------------------------
Type: AddOn_DB
-------------------------------------------------------------------------------]]
--- @class AddOn_DB : AceDB
--- @field global Profile_Global_Config
--- @field profile Profile_Config
--- @field profileKeys Profile_DB_ProfileKeys
--- @field profiles table<string, Profile_Config>
local DefaultAddOnDatabase = {
    global = DefaultGlobal,
    profile = DefaultProfileSettings,
    char = DefaultCharacterSettings,
}

--[[-----------------------------------------------------------------------------
Namespace Var
-------------------------------------------------------------------------------]]
ns.DefaultAddOnDatabase = DefaultAddOnDatabase

