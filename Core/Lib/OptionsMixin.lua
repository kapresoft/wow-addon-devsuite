--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, LibStub, M = ns.O, ns.LibStub, ns.M
local LibUtil = ns.Kapresoft_LibUtil

local ACE = O.AceLibrary
local AceConfig, AceConfigDialog, AceDBOptions = ACE.AceConfig, ACE.AceConfigDialog, ACE.AceDBOptions

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class OptionsMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.OptionsMixin)
local p = L.logger();

---@param addon DevSuite
function L:Init(addon)
    self.addon = addon
    self.LL = ns:GetAceLocale()
end

--- @param propKey string
--- @param defVal any
local function _GetGlobalValue(propKey, defVal) return ns:db().global[propKey] or defVal end

--- @param propKey string
--- @param val any
local function _SetGlobalValue(propKey, val) ns:db().global[propKey] = val end

--- @param fallback any The fallback value
--- @param key string The key value
local function GlobalGet(key, fallback)
    return function(_)
        return _GetGlobalValue(key, fallback)
    end
end
--- @param key string The key value
local function GlobalSet(key)
    return function(_, v) _SetGlobalValue(key, v) end
end

--- @param fallback boolean The fallback value
--- @param addonName string The key value
local function AutoLoadAddOnsGet(addonName, fallback)
    return function(_)
        return ns:db().profile.auto_loaded_addons[addonName] or fallback
    end
end

--- @param addonName string The key value
local function AutoLoadAddOnsSet(addonName)
    --- @param v boolean
    return function(_, v)
        ns:db().profile.auto_loaded_addons[addonName] = v
    end
end

---@param o OptionsMixin
local function Methods(o)

    --- Usage:  local instance = OptionsMixin:New(addon)
    --- @param addon DevSuite
    --- @return OptionsMixin
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    function o:CreateOptions()
        local order = ns:K():CreateIncrementer(1, 1)

        local options = {
            name = ns.name,
            handler = self,
            type = "group",
            args = {
                general = {
                    type = "group",
                    name = "General",
                    desc = "General Settings",
                    order = order:next(),
                    args = {
                        desc = { name = " General Configuration ", type = "header", order = 1 },
                        showFPS = {
                            type = 'toggle',
                            width = 'full',
                            name = "Show Frames-Per-Second (FPS)",
                            desc = "Shows the Blizzard Frames-per-second display (Global Setting)",
                            order = order:next(),
                            get = GlobalGet('show_fps', false),
                            set = GlobalSet('show_fps')
                        },
                    },
                },
                autoload_addons = self:CreateAutoLoadAddOnsGroup(order),
                debugging = self:CreateDebuggingGroup(),
            }
        }
        return options
    end

    --- @param order Kapresoft_Incrementer
    function o:CreateAutoLoadAddOnsGroup(order)
        return {
            type = 'group',
            name = 'Auto-Loaded Add-Ons',
            desc = 'Settings for Auto-Loading Add-Ons',
            order = order:next(),
            args = self:CreateAddOnsOptions()
        }
    end

    function o:CreateAddOnsOptions()
        local order = ns:K():CreateIncrementer(1, 1)
        local options = {
            header1 = {
                order = order:next(),
                type = 'header',
                name = '  Auto-Loaded Add-Ons Settings ',
            },
            characterSpecific = {
                order = order:next(),
                width = 'full',
                name = "Character Specific",
                type = 'toggle',
                get = GlobalGet('auto_loaded_addons_characterSpecific'),
                set = GlobalSet('auto_loaded_addons_characterSpecific')
            },
            header2 = {
                order = order:next(),
                type = 'header',
                name = sformat('      %s      ', self.LL['Add-On Specific Options']),
            },
            addonUsage_AutomaticallyShow = {
                order = order:next(),
                width = 'full',
                name = "Addon Usage: Automatically Show UI",
                desc = "If enabled, this will automatically show the [Addon Usage] UI after player login. (Global Setting)",
                type = 'toggle',
                get = GlobalGet('addon_addonUsage_auto_show_ui'),
                set = GlobalSet('addon_addonUsage_auto_show_ui')
            },
            spacer1 = { order = order:next(), type = "description", name = "\n" },
            header3 = {
                order = order:next(),
                type = 'header',
                name = sformat('      %s      ', self.LL['Available Add-Ons']),
            },
            spacer2 = { order = order:next(), type = "description", name = "\n" },
            spacer3 = { order = order:next(), type = "description", name = self.LL['Available Add-Ons::Description'] .. '\n\n' },
        }

        local addOnCount = GetNumAddOns()
        if addOnCount <= 0 then
            options['no_addon_found'] = {
                name = "\n\nNo Add-Ons were detected", type = "description", order=order:next(),
            }
            return options
        end

        for i = 1, addOnCount do
            local name, title = GetAddOnInfo(i)
            if name ~= ns.name then
                options[name] = {
                    order = order:next(),
                    name = title,
                    type = 'toggle',
                    width = 1.3,
                    get = AutoLoadAddOnsGet(name),
                    set = AutoLoadAddOnsSet(name)
                }
            end
        end


        return options
    end

    function o:CreateDebuggingGroup()
        return {
            type = 'group',
            name = 'Debugging',
            desc = 'Debug Settings for troubleshooting',
            -- Place right before Profiles
            order = 90,
            args = {
                desc = { name = sformat(" %s ", 'Debugging Configuration'), type = "header", order = 0 },
                log_level = {
                    type = 'range',
                    order = 1,
                    step = 5,
                    min = 0,
                    max = 50,
                    width = 1.2,
                    name = 'Log Level',
                    desc = 'Higher log levels generate more logs',
                    get = function(_) return ns:GetLogLevel() end,
                    set = function(_, v) ns:SetLogLevel(v) end,
                },
            },
        }
    end

    function o:InitOptions()
        local options = self:CreateOptions()
        -- This creates the Profiles Tab/Section in Settings UI
        options.args.profiles = AceDBOptions:GetOptionsTable(ns:db())

        AceConfig:RegisterOptionsTable(ns.name, options, { "devsuite_options" })
        AceConfigDialog:AddToBlizOptions(ns.name, ns.name)
    end

end

Methods(L)
