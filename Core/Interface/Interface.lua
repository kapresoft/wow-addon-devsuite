--[[-----------------------------------------------------------------------------
Global Vars
-------------------------------------------------------------------------------]]
--- @type fun(o:any, ...) : void
pformat = {}

--[[-----------------------------------------------------------------------------
Aliases and Callbacks
-------------------------------------------------------------------------------]]
--- @alias AutoLoadedAddons table<AddOnName, Boolean>
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
Type: Profile_Config
-------------------------------------------------------------------------------]]
--- @class Profile_Config : AceDB_Profile
--- @field enable boolean This is the standard enable. Don't use.
--- @field auto_loaded_addons AutoLoadedAddons
--- @field debugDialog Profile_Config_DebugDialog

--[[-----------------------------------------------------------------------------
Type: Profile_DB_ProfileKeys
-------------------------------------------------------------------------------]]
--- ``` ["Azwang - Smolderweb"] = "Azwang - Smolderweb" ```
--- @class Profile_DB_ProfileKeys : table<string, string>

--[[-----------------------------------------------------------------------------
Type: Profile_Global_Config
-------------------------------------------------------------------------------]]
--- @class Profile_Global_Config : AceDB_Global
--- @field show_fps boolean
--- @field addon_addonUsage_auto_show_ui boolean
--- @field prompt_for_reload_to_enable_addons boolean
--- @field auto_loaded_addons AutoLoadedAddons

--[[-----------------------------------------------------------------------------
Type: AddOn_DB
-------------------------------------------------------------------------------]]
--- @class AddOn_DB : AceDB
--- @field global Profile_Global_Config
--- @field profile Profile_Config
--- @field profileKeys Profile_DB_ProfileKeys
--- @field profiles table<string, Profile_Config>

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
