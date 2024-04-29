--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @type CoreNamespace
local ns = select(2, ...)
--[[-----------------------------------------------------------------------------
Debug Flags
-------------------------------------------------------------------------------]]
local d                  = ns.debug
local flag               = ns.debug.flag
flag.developer           = true
flag.enableLogConsole    = true
flag.selectLogConsoleTab = true

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local K          = ns:K()
local sformat    = string.format

-- TODO: The color should match once we put the color options into DebugChatFrameOptionsInterface
local colorUtil = ns:KO().ColorUtil
local primaryColor = colorUtil:NewColorFromHex( ns.consoleColors.primary .. 'fc')
local secondaryColor = colorUtil:NewColorFromHex(ns.consoleColors.secondary .. 'fc')

local c1, c2       = K:cf(primaryColor.color), K:cf(secondaryColor.color)
local c3, c4       = K:cf(ADVENTURES_COMBAT_LOG_BLUE), K:cf(FACTION_GREEN_COLOR)
local c5        = K:cf(LIGHTGRAY_FONT_COLOR)
local libName    = c2('DeveloperSetup')

--- @class DeveloperSetup
local L = {}; ns.DeveloperSetup = L

--[[-----------------------------------------------------------------------------
Main Code
Available Fonts:
 ConsoleMonoCondensedSemiBold
 ConsoleMonoCondensedSemiBoldOutline
 ConsoleMonoSemiCondensedBlack
 ConsoleMedium
 ConsoleMediumOutline
 SystemFont_Outline_Small
-------------------------------------------------------------------------------]]
function L:EnableDebugChatFrame()
    local pre = sformat('{{%s::%s}}', c1(ns.addon), libName)
    print('pre:', pre)
    local function LoadDebugChatFrame()
        local addonName = 'DebugChatFrame'
        local U = ns:KO().AddonUtil
        U:LoadOnDemand(addonName, function(loadSuccess)
            print(pre, addonName, 'Loaded OnDemand:', loadSuccess)
        end)
    end; LoadDebugChatFrame()
    if not DebugChatFrame then return print(pre, 'DebugChatFrame is not available') end


    --- @type DebugChatFrameInterface
    local devConsole = DebugChatFrame

    --- @type DebugChatFrameOptionsInterface
    local opt = {
        addon = string.upper(ns.addonLogName),
        chatFrameTabName = ns.addonShortName,
        font = DCF_ConsoleMonoCondensedSemiBoldOutline,
        fontSize = 16,
        windowAlpha = 0.5,
        maxLines = 200,
    }

    --- @type ChatLogFrameInterface
    local cf = devConsole:New(opt, function(chatFrame)
        chatFrame:SetAlpha(1.0)
        local windowColor = ns:ColorUtil():NewColorFromHex('343434fc')
        FCF_SetWindowColor(chatFrame, windowColor:GetRGBA())
        FCF_SetWindowAlpha(chatFrame, opt.windowAlpha)
    end);
    ns:RegisterChatFrame(ns, cf)
    local logp = ns.logp

    cf:InitialTabSelection(d:IsSelectLogConsoleTab())

    logp(libName, c5('-------------------------------------------'))
    logp(libName, 'Debug ChatFrame initialized.')
    logp(libName,
         'Developer:', c3(d:IsDeveloper()),
         'SelectLogConsoleTab:', c3(d:IsSelectLogConsoleTab()))
    logp(libName,
         'ConsoleEnabled:', c3(d:IsEnableLogConsole()))
    logp(libName, 'GameVersion:', c4(ns.gameVersion))

    local font, size, flags = cf:GetFont()
    logp(libName, 'Size:', c3(size), 'Flags:', c3(flags), 'Font:', c5(font))

    logp(libName, 'chatFrame:',
         c2(cf:GetName()), c3(sformat('(%s)', opt.chatFrameTabName)), 'selected:', c3(cf:IsSelected()))
    --logp(libName, 'Log Command:', c3('/run c("hello", "there")'))
    logp(libName, 'Log Command:', c3('/run d:log("hello","there")'))
    logp(libName, 'Log Command:', c3('/run d:logp("hello","there")'))
    logp(libName, c5('-------------------------------------------'), '\n\n')

end; if not ns.debug:IsEnableLogConsole() then return end

L:EnableDebugChatFrame()
