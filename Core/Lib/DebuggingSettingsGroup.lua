--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local M, sformat = ns.M, ns.sformat

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]

local libName = M.DebuggingSettingsGroup()
--- @class DebuggingSettingsGroup
local S       = ns.LibStub:NewLibrary(libName);
local p       = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o DebuggingSettingsGroup
local function PropsAndMethods(o)
    --- spacer
    local sp = '                                                                   '
    local L = ns:AceLocale()

    --- @return AceConfigOption
    function o:CreateDebuggingGroup()
        local seq = ns:CreateSequence(3)
        local enableDebugConsolePosition = 2
        --- @type AceConfigOption
        local debugConf = {
            type = 'group',
            name = L['Debugging'],
            desc = L['Debugging::Desc'],
            -- Place right after Profiles
            order = 101,

            args = {
                desc = { name = sformat(" %s ", L['Debugging Configuration']), type = "header", order = seq:next() },
                spacer1a = { type="description", name=sp, width="full", order = 1 },
                log_level = {
                    type = 'range',
                    order = seq:next(),
                    step = 5,
                    min = 0,
                    max = 50,
                    width = 1.5,
                    name = L['Log Level'],
                    desc = L['Log Level::Desc'],
                    get = function(_) return ns:GetLogLevel() end,
                    set = function(_, v) ns:SetLogLevel(v) end,
                },
                spacer1b = { type="description", name=sp, width="full", order = seq:next() },
            },
        }

        local a = debugConf.args
        a.off           = {
            name = 'off',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Turn Off Logging",
            func = function()
                a.log_level.set({}, 0)
            end,
        }
        a.info          = {
            name = 'info',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Info Log Level (15)",
            func = function()
                a.log_level.set({}, 15)
            end,
        }
        a.debugBtn      = {
            name = 'debug',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Debug Log Level (20)",
            func = function()
                a.log_level.set({}, 20)
            end,
        }
        a.fineBtn       = {
            name = 'fine',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Fine Log Level (25)",
            func = function()
                a.log_level.set({}, 25)
            end,
        }
        a.finerBtn      = {
            name = 'finer',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Finer Log Level (30)",
            func = function()
                a.log_level.set({}, 30)
            end,
        }
        a.finestBtn     = {
            name = 'finest',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Finest Log Level (35)",
            func = function()
                a.log_level.set({}, 35)
            end,
        }
        a.traceBtn      = {
            name = 'trace',
            type = "execute", order = seq:next(), width = 'half',
            desc = "Trace Log Level (50)",
            func = function()
                a.log_level.set({}, 50)
            end,
        }
        a.desc_cat      = { name = "Categories", type = "header", order = seq:next() }
        a.spacer1c      = { type="description", name=sp, width="full", order = seq:next() }

        self:AddCategories(debugConf, seq)


        --@do-not-package@
        if ns.debug:IsDeveloper() and not ns.debug:IsEnableLogConsole() then
            a.enableDebugConsole = {
                name  = 'Enable Debug Console', type = 'execute',
                order = enableDebugConsolePosition,
                func  = function()
                    ns.DeveloperSetup:EnableDebugChatFrame()
                    ns.chatFrame:SelectInDock()
                end
            }
        end
        --@end-do-not-package@

        return debugConf;
    end

    ---@param conf AceConfigOption
    ---@param seq Kapresoft_LibUtil_SequenceMixin
    function o:AddCategories(conf, seq)
        conf.args.enable_all = {
            name = L['Debugging::Category::Enable All::Button'], desc = L['Debugging::Category::Enable All::Button::Desc'],
            type = "execute", order = seq:next(), width = 'normal',
            func = function()
                for _, option in pairs(conf.args) do
                    if option.type == 'toggle' then option.set({}, true) end
                end
            end }
        conf.args.disable_all = {
            name = L['Debugging::Category::Disable All::Button'], desc = L['Debugging::Category::Disable All::Button::Desc'],
            type ="execute", order = seq:next(), width = 'normal',
            func = function()
                for _, option in pairs(conf.args) do
                    if option.type == 'toggle' then option.set({}, false) end
                end
            end }
        conf.args.spacer2 = { type="description", name=sp, width="full", order = seq:next() },

        ns.LogCategory:ForEachCategory(function(cat)
            local elem = {
                type = 'toggle', name =cat.labelFn(), order = seq:next(), width =1.2,
                get  = function() return ns:IsLogCategoryEnabled(cat.name) end,
                set  = function(_, val) ns:SetLogCategory(cat.name, val) end
            }
            conf.args[cat.name] = elem
        end)
    end

end; PropsAndMethods(S)

