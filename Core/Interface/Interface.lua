--[[-----------------------------------------------------------------------------
Global Vars
-------------------------------------------------------------------------------]]
--- @type fun(o:any, ...) : void
pformat = {}

--[[-----------------------------------------------------------------------------
Aliases and Callbacks
-------------------------------------------------------------------------------]]
--- @alias AddOnCallbackFn fun(addOn:AddOnInfo) | "function(addOn) print('addOn:', pformat(addOn)) end"

--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject A base library object class definition.
--- @field mt table The metatable for objects of this class, including a custom `__tostring` function for debugging or logging purposes.
--- @field name string Retrieves the module's name. This is an instance method that should be implemented to return the name of the module.
--- @field major string Retrieves the major version of the module. i.e., <LibName>-1.0
--- @field minor string Retrieves the minor version of the module. i.e., <LibName>-1.0

--[[-----------------------------------------------------------------------------
BaseLibraryObject_WithAceEvent
-------------------------------------------------------------------------------]]
--- @class BaseLibraryObject_WithAceEvent : AceEvent A base library object that includes AceEvent functionality.
--- @field mt table The metatable for objects of this class, including a custom `__tostring` function for debugging or logging purposes.
--- @field name string Retrieves the module's name. This is an instance method that should be implemented to return the name of the module.
--- @field major string Retrieves the major version of the module. i.e., <LibName>-1.0
--- @field minor string Retrieves the minor version of the module. i.e., <LibName>-1.0

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
Type: AddOnInfo
-------------------------------------------------------------------------------]]
--- @class AddOnInfo
--- @field name AddOnName
--- @field title AddOnTitle
--- @field notes Notes
--- @field loadable Boolean
--- @field reason AddOnIsNotLoadableReason
--- @field security AddOnSecurity
--- @field newVersion Boolean Unused
