if type(DEVS_DB) ~= "table" then DEVS_DB = {} end
if type(DEVS_LOG_LEVEL) ~= "number" then DEVS_LOG_LEVEL = 1 end
if type(DEVS_DEBUG_MODE) ~= "boolean" then DEVS_DEBUG_MODE = false end

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata = GetAddOnMetadata
local date = date


--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type string
local addon
--- @class GenericNamespace : Kapresoft_Base_Namespace
local ns
addon, ns = ...
local kch = ns.Kapresoft_LibUtil.CH

local addonShortName = 'DS'
local consoleCommand = "devsuite"
local consoleCommandShort = "ds"
local consoleCommandOptions = consoleCommand .. '-options'
local consoleCommandOptionsShort = consoleCommandShort .. '-options'
local useShortName = true

local CONFIRM_RELOAD_UI_NAME = addon .. '_CONFIRM_RELOAD_UI'

--- The original Ace LibStub
local LibStub = LibStub

local ADDON_INFO_FMT = '%s|cfdeab676: %s|r'
local TOSTRING_ADDON_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe}}|r'
local TOSTRING_SUBMODULE_FMT = '|cfdfefefe{{|r|cfdeab676%s|r|cfdfefefe::|r|cfdfbeb2d%s|r|cfdfefefe}}|r'

--- @param moduleName string
--- @param optionalMajorVersion number|string
local function LibName(moduleName, optionalMajorVersion)
    assert(moduleName, "Module name is required for LibName(moduleName)")
    local majorVersion = optionalMajorVersion or '1.0'
    local v = sformat("%s-%s-%s", addon, moduleName, majorVersion)
    return v
end
--- @param moduleName string
local function ToStringFunction(moduleName)
    local name = addon
    if useShortName then name = addonShortName end
    if moduleName then return function() return string.format(TOSTRING_SUBMODULE_FMT, name, moduleName) end end
    return function() return string.format(TOSTRING_ADDON_FMT, name) end
end

--[[-----------------------------------------------------------------------------
ConfirmAndReload UI
-------------------------------------------------------------------------------]]
StaticPopupDialogs[CONFIRM_RELOAD_UI_NAME] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    --- @param messageName Name|nil
    OnAccept = function(self) ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

--[[-----------------------------------------------------------------------------
Console Colors
-------------------------------------------------------------------------------]]
--- @type Kapresoft_LibUtil_ColorDefinition
local consoleColors = {
    primary   = 'FF780A',
    secondary = 'fbeb2d',
    tertiary = 'ffffff',
}
local command = kch:FormatColor(consoleColors.primary, '/' .. consoleCommand)
local commandShort = kch:FormatColor(consoleColors.primary, '/' .. consoleCommandShort)

--[[-----------------------------------------------------------------------------
GlobalConstants
-------------------------------------------------------------------------------]]
--- @class GlobalConstants
local L = LibStub:NewLibrary(LibName('GlobalConstants'), 1); if not L then return end

--- @param o GlobalConstants
local function GlobalConstantProperties(o)

    o.LibName = LibName
    o.ToStringFunction = ToStringFunction

    local consoleCommandTextFormat = '|cfd2db9fb%s|r'

    --- @class GlobalAttributes
    local C = {
        DB_NAME = 'DEVS_DB',
        CHECK_VAR_SYNTAX_FORMAT = '|cfdeab676%s ::|r %s',
        CONSOLE_COMMAND = consoleCommand,
        CONSOLE_COMMAND_SHORT = consoleCommandShort,
        CONSOLE_COMMAND_OPTIONS = consoleCommandOptions,
        CONSOLE_COMMAND_OPTIONS_SHORT = consoleCommandOptionsShort,
        CONSOLE_COLORS = consoleColors,
        CONSOLE_HEADER_FORMAT = '|cfdeab676### %s ###|r',
        CONSOLE_OPTIONS_FORMAT = '  - %-8s|cfdeab676:: %s|r',
        CONSOLE_PLAIN = command,
        HELP_COMMAND = sformat(consoleCommandTextFormat, command .. ' help'),
    }

    --- @class EventNames
    local E = {
        OnEnter = 'OnEnter',
        OnEvent = 'OnEvent',
        OnLeave = 'OnLeave',
        OnModifierStateChanged = 'OnModifierStateChanged',
        OnDragStart = 'OnDragStart',
        OnDragStop = 'OnDragStop',
        OnMouseUp = 'OnMouseUp',
        OnMouseDown = 'OnMouseDown',
        OnReceiveDrag = 'OnReceiveDrag',

        -- Blizzard Events
        PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD',
        UPDATE_INSTANCE_INFO = 'UPDATE_INSTANCE_INFO',
    }

    --- @class MessageNames
    local MessageNames = {
        --- @type Name
        OnAfterInitialize = {},
        --- @type Name
        OnAddonReady = {},
        --- @type Name
        OnToggleFrameRate = {},
        --- @type Name
        OnApplyAndRestart = {},
        --- @type Name
        OnSyncAddOnEnabledState = {},
    };
    local function InitMessageNames()
        local function uniqueName(name)
            local prefix = (useShortName and addonShortName) or addon
            return sformat('%s::%s', prefix, name)
        end
        for n,_ in pairs(MessageNames) do
            local addOnMessage = uniqueName(n)
            MessageNames[n] = addOnMessage
        end
    end; InitMessageNames(MessageNames)

    o.C = C
    o.E = E
    o.M = MessageNames

end

--- @param o GlobalConstants
local function Methods(o)

    function o:GetLogName()
        local logName = addon
        if useShortName then logName = addonShortName end
        return logName
    end

    ---#### Example
    ---```
    ---local version, curseForge, issues, repo, lastUpdate, wowInterfaceVersion = GC:GetAddonInfo()
    ---```
    --- @return string, string, string, string, string, string
    function o:GetAddonInfo()
        local versionText, lastUpdate
        --@non-debug@
        versionText = GetAddOnMetadata(ns.name, 'Version')
        lastUpdate = GetAddOnMetadata(ns.name, 'X-Github-Project-Last-Changed-Date')
        --@end-non-debug@
        --@debug@
        versionText = '1.0.x.dev'
        lastUpdate = date("%m/%d/%y %H:%M:%S")
        --@end-debug@
        local wowInterfaceVersion = select(4, GetBuildInfo())

        return versionText, GetAddOnMetadata(ns.name, 'X-CurseForge'),
        GetAddOnMetadata(ns.name, 'X-Github-Issues'),
        GetAddOnMetadata(ns.name, 'X-Github-Repo'),
        lastUpdate, wowInterfaceVersion
    end

    function o:GetAddonInfoFormatted()
        local version, curseForge, issues, repo, lastUpdate, wowInterfaceVersion = self:GetAddonInfo()
        --p:log("Addon Info:\n  Version: %s\n  Curse-Forge: %s\n  File-Bugs-At: %s\n  Last-Changed-Date: %s\n  WoW-Interface-Version: %s\n",
        --        version, curseForge, issues, lastChanged, wowInterfaceVersion)
        return sformat("Addon Info:\n%s\n%s\n%s\n%s\n%s\n%s",
                sformat(ADDON_INFO_FMT, 'Version', version),
                sformat(ADDON_INFO_FMT, 'Curse-Forge', curseForge),
                sformat(ADDON_INFO_FMT, 'Bugs', issues),
                sformat(ADDON_INFO_FMT, 'Repo', repo),
                sformat(ADDON_INFO_FMT, 'Last-Update', lastUpdate),
                sformat(ADDON_INFO_FMT, 'Interface-Version', wowInterfaceVersion)
        )
    end

    function o:GetMessageLoadedText()
        local consoleCommandMessageFormat = sformat('Type %s or %s for available commands.',
                command, commandShort)
        return sformat("%s version %s by %s is loaded. %s",
                kch:P(addon) , self:GetAddonInfo(), kch:FormatColor(consoleColors.primary, 'kapresoft'),
                consoleCommandMessageFormat)
    end

    function o:ConfirmAndReload()
        if StaticPopup_Visible(CONFIRM_RELOAD_UI_NAME) == nil then return StaticPopup_Show(CONFIRM_RELOAD_UI_NAME) end
        return false
    end
end

GlobalConstantProperties(L)
Methods(L)

