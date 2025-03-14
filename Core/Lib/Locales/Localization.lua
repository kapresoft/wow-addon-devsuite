--- @type Namespace
local ns = select(2, ...)
local L = LibStub("AceLocale-3.0"):GetLocale(ns.addon)

-- General
DEVS_TITLE                                 = "DevSuite"
DEVS_CATEGORY                              = "AddOns/" .. DEVS_TITLE

-- Key binding localization text
BINDING_HEADER_DEVS                        = DEVS_TITLE
BINDING_HEADER_DEVS_OPTIONS                = DEVS_TITLE
BINDING_NAME_DEVS_OPTIONS_DLG              = L['BINDING_NAME_DEVS_OPTIONS_DLG']
BINDING_NAME_DEVS_DEBUG_DLG                = L['BINDING_NAME_DEVS_DEBUG_DLG']
BINDING_NAME_DEVS_TOGGLE_WINDOWED          = L['BINDING_NAME_DEVS_TOGGLE_WINDOWED']
BINDING_NAME_DEVS_TOGGLE_FRAMESTACK        = L['BINDING_NAME_DEVS_TOGGLE_FRAMESTACK']
BINDING_NAME_DEVS_GET_DETAILS_ON_MOUSEOVER = L['BINDING_NAME_DEVS_GET_DETAILS_ON_MOUSEOVER']
BINDING_NAME_DEVS_CLEAR_DEBUG_CONSOLE      = L['BINDING_NAME_DEVS_CLEAR_DEBUG_CONSOLE']

local c1        = ns:K():cf(HEIRLOOM_BLUE_COLOR)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
-- TODO: Deprecated. Use AceLocaleUtil
--- @class LocaleUtil
local LocaleUtil = {}; ns.LocaleUtil = LocaleUtil; do

    local o = LocaleUtil
    local globalSetting = c1(L['Global Setting'])
    local charSetting = c1(L['Character Setting'])

    --- @param localeKey string
    function o.G(localeKey)
        return ns.sformat('%s (%s)', L[localeKey], globalSetting)
    end

    --- @param localeKey string
    function o.Gn(localeKey)
        return ns.sformat('%s\n(%s)', L[localeKey], globalSetting)
    end

    --- @param localeKey string
    function o.C(localeKey)
        return ns.sformat('%s (%s)', L[localeKey], charSetting)
    end

    --- @param localeKey string
    function o.Cn(localeKey)
        return ns.sformat('%s\n(%s)', L[localeKey], charSetting)
    end

    --- @param opt AceConfigOption
    --- @param name string
    function o.NameDescGlobal(opt, name)
        opt.name = L[name]
        opt.desc = o.G(name .. '::Desc')
    end

    --- @param opt AceConfigOption
    --- @param name string
    function o.NameDescCharacter(opt, name)
        opt.name = L[name]
        opt.desc = o.C(name .. '::Desc')
    end

end
