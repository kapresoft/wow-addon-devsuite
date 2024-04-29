--- @type Namespace
local ns = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale(ns.addon)

-- General
DEVS_TITLE                                = "DevSuite"
DEVS_CATEGORY                             = "AddOns/" .. DEVS_TITLE

-- Key binding localization text
BINDING_HEADER_DEVS                        = DEVS_TITLE
BINDING_HEADER_DEVS_OPTIONS                = DEVS_TITLE
BINDING_NAME_DEVS_OPTIONS_DLG              = L["BINDING_NAME_DEVS_OPTIONS_DLG"]
BINDING_NAME_DEVS_DEBUG_DLG                = L["BINDING_NAME_DEVS_DEBUG_DLG"]
BINDING_NAME_DEVS_TOGGLE_WINDOWED          = L['BINDING_NAME_DEVS_TOGGLE_WINDOWED']
BINDING_NAME_DEVS_GET_DETAILS_ON_MOUSEOVER = L["BINDING_NAME_DEVS_GET_DETAILS_ON_MOUSEOVER"]


--[[-----------------------------------------------------------------------------
Lib: Localization
-------------------------------------------------------------------------------]]
local libName = ns.M.Localization()
--- @class Localization
local S = ns:NewLib(libName);
local p = ns:LC().DEFAULT:NewLogger(libName)

function S:Gn(localeKey)
    return ns.sformat("%s\n(%s)", L[localeKey], L['Global Setting'])
end
function S:G(localeKey)
    return ns.sformat("%s (%s)", L[localeKey], L['Global Setting'])
end

function S:Cn(localeKey)
    return ns.sformat("%s\n(%s)", L[localeKey], L['Character Setting'])
end

function S:C(localeKey)
    return ns.sformat("%s (%s)", L[localeKey], L['Character Setting'])
end
