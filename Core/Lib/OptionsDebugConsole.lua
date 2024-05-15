--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC
local MSG = GC.M
local L = ns:AceLocale()
local ACU = ns:KO().AceConfigUtil:New(ns.addon)
local NameDescG = ns.LocaleUtil.NameDescGlobal
local sformat = ns.sformat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = ns.M.OptionsDebugConsole()
--- @class OptionsDebugConsole : AceEvent
local S = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)

--- spacer
local sp = '                                                                   '

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function NotifyChange() ns.LibStubAce("AceConfigRegistry-3.0"):NotifyChange(ns.addon) end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function S:CreateDebugConsoleGroup()

    --- @class DebugConsoleOption : AceConfigOption
    --- @field args DebugConsoleOptionArgs
    local options = {
        type  = "group",
        name  = L['Debug Console'],
        desc  = L['Debug Console::Desc'],
        order = 2,
    }
    options.args  = {}

    local seq = ns:CreateSequence(1)
    self:DebugConsoleSection(options, seq)
    return options
end

function S:Args() return ns:a().Options.options.args end

function S:DebugConsoleSection(debugConf, seq)

    local a = debugConf.args

    a.showTabOnLoad = {
        type = 'toggle', order = seq:next(), width = 'normal',
        get  = function() return ns:dbg().selectLogConsoleTab == true end,
        set  = function(_, v) ns:dbg().selectLogConsoleTab = (v == true) end,
    }; NameDescG(a.showTabOnLoad, 'Show Tab On Load')

    a.defaultChatFrame = ACU:CreateGlobalOption('Default Chat Frame', {
        type = 'toggle', order = seq:next(), width = 'normal',
        get  = function()
            return ns:dbg().makeDefaultChatFrame == true end,
        set  = function(_, v)
            ns:dbg().makeDefaultChatFrame = (v == true)
            self:SendMessage(MSG.OnDebugConsoleDefaultChatFrameState, libName)
        end,
    })

    a.maxLines = ACU:CreateGlobalOption('Max Lines', {
        type = 'range', order = seq:next(), width = 'normal',
        min  = 10, max = 10000, softMin = 500, softMax = 5000,
        step = 1, bigStep = 100,
        get  = function() return ns:dbg().maxLogConsoleLines end,
        set  = function(_, v)
            ns:dbg().maxLogConsoleLines = v
            if not ns:HasChatFrame() then return end; ns:ChatFrame():SetMaxLines(v)
        end,
    }); a.spacer1c = { type="description", name=sp, width="full", order = seq:next() }

    a.DEVTOOLS_DEPTH_CUTOFF = ACU:CreateGlobalOption('DEVTOOLS_DEPTH_CUTOFF', {
        type = 'range', order = seq:next(), width = 1.5,
        min  = 1, max = 50, softMin = 2, softMax = 10, step = 1, bigStep = 1,
        get  = function() return ns:dbg().DEVTOOLS_DEPTH_CUTOFF end,
        set  = function(_, v)
            DEVTOOLS_DEPTH_CUTOFF = v
            ns:dbg().DEVTOOLS_DEPTH_CUTOFF = DEVTOOLS_DEPTH_CUTOFF
        end,
    }); a.spacer1d = { type="description", name=sp, width=0.2, order = seq:next() }

    a.DEVTOOLS_MAX_ENTRY_CUTOFF = ACU:CreateGlobalOption('DEVTOOLS_MAX_ENTRY_CUTOFF', {
        type = 'range', order = seq:next(), width = 1.5,
        min  = 1, max = 1000, softMin = 10, softMax = 200, step = 1, bigStep = 10,
        get  = function() return ns:dbg().DEVTOOLS_MAX_ENTRY_CUTOFF end,
        set  = function(_, v)
            DEVTOOLS_MAX_ENTRY_CUTOFF = v
            ns:dbg().DEVTOOLS_MAX_ENTRY_CUTOFF = DEVTOOLS_MAX_ENTRY_CUTOFF
        end,
    }) a.spacer1e = { type="description", name=sp, width="full", order = seq:next() }
end

function S:EnableGroup()
    if not DebugChatFrame then return end
    self:Args().debugConsole = self:CreateDebugConsoleGroup()
    NotifyChange(ns.addon)
end

function S:DisableGroup()
    if not DebugChatFrame then return end

    self:Args().debugConsole = nil
    NotifyChange(ns.addon)
end
