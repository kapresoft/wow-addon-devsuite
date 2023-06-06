--[[-----------------------------------------------------------------------------
BaseLibraryObject
-------------------------------------------------------------------------------]]
local function BaseLibraryObject_Def()
    --- @class BaseLibraryObject
    local o = {}
    --- @type table
    o.mt = { __tostring = function() end }
    --- @type Logger
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
--- @class DevSuite_AceDB
local _db = {
    --- @type Profile_Global_Config
    global = {},
    ----- @type Profile_Config
    profile = {},
}

--- @class Profile_Global_Config
local Profile_Global_Config = {

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
    --- @type DevSuite_AceDB,
    db = {},
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

--- @class Profile_Config_Item
local item = {
    name = 'Saved #1',
    sortIndex = 1,
    value = ''
}

--- @class Profile_Config
local defaultProfile = {
    ['enabled'] = true,
    ['debugDialog'] = {
        maxHistory = 9,
        --- @type table<number, Profile_Config_Item>
        items = { }
    },
}
