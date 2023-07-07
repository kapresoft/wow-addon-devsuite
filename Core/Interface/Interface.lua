--[[-----------------------------------------------------------------------------
Global Vars
-------------------------------------------------------------------------------]]
--- @type fun(o:any, ...) : void
pformat = {}

--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
local function BaseLibraryObject_Def()
    --- @class BaseLibraryObject
    local o = {}
    --- @type table
    o.mt = { __tostring = function() end }
    --- @type fun() : Logger
    o.logger = {}
end

--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]
local function BaseLibraryObject_WithAceEvent_Def()
    --- @class BaseLibraryObject_WithAceEvent : AceEvent
    local o = {}
    --- @type table
    o.mt = { __tostring = function() end }
    --- @type Logger
    o.logger = {}
end

--[[-----------------------------------------------------------------------------
DevSuite_AceDB
-------------------------------------------------------------------------------]]
--- @class Profile_Config_Item
local item = {
    name = 'Saved #1',
    sortIndex = 1,
    value = ''
}

--- @alias AutoLoadedAddons table<AddOnName, Boolean>

--- @class Profile_Config : AceDB_Profile
local Profile_Config = {
    enable = true,
    debugDialog = {
        maxHistory = 9,
        --- @type table<number, Profile_Config_Item>
        items = { item }
    },
    --- @type AutoLoadedAddons
    auto_loaded_addons = AutoLoadedAddOns,
}

--- ``` ["Azwang - Smolderweb"] = "Azwang - Smolderweb" ```
--- @class Profile_DB_ProfileKeys : table<string, string>
local Profile_DB_ProfileKeys = { }

--- @class Profile_Global_Config : AceDB_Global
local Profile_Global_Config = {
    --- @type Boolean
    show_fps = true,
    --- @type Boolean
    auto_loaded_addons_characterSpecific = true,
    --- Addon: Addon Usage specific option
    --- @type Boolean
    addon_addonUsage_auto_show_ui = true,
    --- @type AutoLoadedAddons
    auto_loaded_addons = {},
}

--- @class AddOn_DB : AceDB
local DevSuite_AceDB = {
    --- @type Profile_Global_Config
    global = Profile_Global_Config,
    --- @type Profile_Config
    profile = Profile_Config,

    --- @type Profile_DB_ProfileKeys
    profileKeys = Profile_DB_ProfileKeys,
    --- @type table<string, Profile_Config>
    profiles = {}
}
--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @class Namespace
local Namespace = {

    --- @type string
    name = "",
    --- @type GlobalObjects
    O = {},
    --- @type Modules
    M = {},

    --- @type Kapresoft_LibUtil
    Kapresoft_LibUtil = {},

    --- @type fun(self:Namespace) : Kapresoft_LibUtil
    K = {},
    --- @type fun(self:Namespace) : Kapresoft_LibUtil_Objects
    KO = {},

    --- @type LocalLibStub
    LibStub = {},

    --- Used in TooltipFrame and BaseAttributeSetter to coordinate the GameTooltip Anchor
    --- @see TooltipAnchor#SCREEN_* vars
    --- @type string
    GameTooltipAnchor = "",
    --- @type fun(o:any, ...) : void
    pformat = {}
}
