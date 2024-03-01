--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = devsuite_ns(...)
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub

local ACE, API = O.AceLibrary, O.API
local AceConfig, AceConfigDialog, AceDBOptions = ACE.AceConfig, ACE.AceConfigDialog, ACE.AceDBOptions
local DebugSettings = O.DebuggingSettingsGroup
local AceEvent = ns:AceEvent()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class OptionsMixin : BaseLibraryObject
local libName = M.OptionsMixin
local LIB = LibStub:NewLibrary(libName)
local p = ns:CreateDefaultLogger(libName)

--[[-----------------------------------------------------------------------------
Types: ProfileSelectValues
-------------------------------------------------------------------------------]]
--- @return ProfileSelect
local function CreateProfileSelect()

    local function GetProfiles() return ns:db():GetProfiles() end
    local function GetCurrentProfile() return ns:db():GetCurrentProfile()  end
    --- @param info table Ignored
    --- @param val string The profile name selected
    local function SetCurrentProfile(info, val) ns:db():SetProfile(val) end
    --- Get the Profile names to be used for the select values
    --- @return table<string, string> key is the same as value
    local function GetSortedProfiles()
        local profiles = {}
        for _, profileName in ipairs(GetProfiles()) do
            profiles[profileName] = profileName
        end
        return O.Table.getSortedKeys(profiles)
    end
    --- Get the Profile names to be used for the select values
    --- This table has to match the order of the original profile
    --- @return table<string, string> key is the same as value
    local function GetProfilesKV()
        local profiles = {}
        for _, pr in ipairs(GetProfiles()) do
            profiles[pr] = pr
        end
        return profiles
    end

    --- @class ProfileSelect
    local ret = {
        kvPairs = GetProfilesKV,
        sorting = GetSortedProfiles,
        get = GetCurrentProfile,
        set = SetCurrentProfile,
    }
    return ret
end

--- @see GlobalConstants#M for Message names
---@param optionalVal any|nil
local function SendMessage(addOnMessage, optionalVal)
    AceEvent:SendMessage(addOnMessage, libName, optionalVal)
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
local function GlobalSet(key, eventMessageToFire)
    return function(_, v)
        _SetGlobalValue(key, v)
        if 'string' == type(eventMessageToFire) then
            SendMessage(eventMessageToFire, v)
        end
    end
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
        ns.requiresReload = true
    end
end

---@param o OptionsMixin
local function Methods(o)
    local L = ns:AceLocale()

    --- Automatically called by CreateAndInitFromMixin(..)
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
    end

    --- Usage:  local instance = OptionsMixin:New(addon)
    --- @param addon DevSuite
    --- @return OptionsMixin
    function o:New(addon) return ns:K():CreateAndInitFromMixin(o, addon) end

    function o:CreateOptions()
        local order = ns:K():CreateIncrementer(1, 1)

        local options = {
            name = ns.name,
            handler = self,
            type = "group",
            args = {
                general = {
                    type = "group",
                    name = L['General'],
                    desc = L['General::Desc'],
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
                            set = GlobalSet('show_fps', GC.M.OnToggleFrameRate)
                        },
                    },
                },
                autoload_addons = self:CreateAutoLoadAddOnsGroup(order),
                debugging = DebugSettings:CreateDebuggingGroup(),
            }
        }
        return options
    end

    --- @param order Kapresoft_Incrementer
    function o:CreateAutoLoadAddOnsGroup(order)
        return {
            type = 'group',
            name = L['Add-On Management'],
            desc = L['Add-On Management::Desc'],
            order = order:next(),
            args = self:CreateAddOnsOptions()
        }
    end

    function o:CreateAddOnsOptions()
        local ps = CreateProfileSelect()
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
                name = sformat('      %s      ', L['Add-On Specific Options']),
            },
            addonUsage_AutomaticallyShow = {
                order = order:next(),
                width = 'full',
                name = L['Addon Usage: Automatically Show UI (Global)'],
                desc = L['Addon Usage: Automatically Show UI (Global)::Desc'],
                type = 'toggle',
                get = GlobalGet('addon_addonUsage_auto_show_ui'),
                set = GlobalSet('addon_addonUsage_auto_show_ui')
            },
            spacer1 = { order = order:next(), type = "description", name = "\n" },
            header3 = {
                order = order:next(),
                type = 'header',
                name = sformat('      %s      ', L['Available Add-Ons']),
            },
            spacer2 = { order = order:next(), type = "description", name = "\n" },
            spacer3 = { order = order:next(), type = "description", name = L['Available Add-Ons::Desc'] .. '\n\n' },
            applyAll = {
                name = L['Apply and ReloadUI'], desc = L['Apply and ReloadUI::Desc'],
                type = "execute", order = order:next(), width = 'normal',
                func = function()
                    AceEvent:SendMessage(GC.M.OnApplyAndRestart, libName)
                end
            },
            profileSelection = {
                name = L['Select Profile'] .. ':', desc = L['Select Profile::Desc'], order = order:next(),
                type = "select", width="normal",
                values = ps.kvPairs, sorting = ps.sorting,
                get = ps.get,
                set = ps.set
            },
            spacer4 = { order = order:next(), type='description', name='', width='full' }
        }

        local addOnCount = GetNumAddOns()
        if addOnCount <= 0 then
            options['no_addon_found'] = {
                name = "\n\nNo Add-Ons were detected", type = "description", order=order:next(),
            }
            return options
        end

        API:ForEachAddOn(function(addOn)
            local name = addOn.name
            if name ~= ns.name then
                options[name] = {
                    order = order:next(),
                    name = addOn.title,
                    type = 'toggle',
                    width = 1.3,
                    get = AutoLoadAddOnsGet(name),
                    set = AutoLoadAddOnsSet(name)
                }
            end
        end)

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

        --- TODO: Make it an option "Larger Options Frame: true/false"
        -- AceConfigDialog:SetDefaultSize(ns.name, 950, 750)
    end

end

Methods(LIB)
