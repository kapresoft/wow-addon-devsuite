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
local DebugSettings, IsAddonSuiteEnabled = O.DebuggingSettingsGroup, O.API.IsAddonSuiteEnabled
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
local function MethodsAndProps(o)
    local L = ns:AceLocale()

    --- Automatically called by CreateAndInitFromMixin(..)
    --- @param addon DevSuite
    function o:Init(addon)
        self.addon = addon
        self.util = O.OptionsUtil:New(o)
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
                            name = L['Show Frames-Per-Second (FPS)'],
                            desc = L['Show Frames-Per-Second (FPS)::Desc'],
                            order = order:next(),
                            get = self.util:GlobalGet('show_fps', false),
                            set = self.util:GlobalSet('show_fps', GC.M.OnToggleFrameRate)
                        },
                        promptForReload = {
                            type = 'toggle',
                            width = 'full',
                            name = L['Prompt to Reload and Enable Addons'],
                            desc = L['Prompt to Reload and Enable Addons::Desc'],
                            order = order:next(),
                            get = self.util:GlobalGet('prompt_for_reload_to_enable_addons'),
                            set = self.util:GlobalSet('prompt_for_reload_to_enable_addons')
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
        if IsAddonSuiteEnabled() then
            p:w(function() return 'AddonSuite detected. The AddOn Management tab will be disabled to avoid conflict' end)
            return nil
        end

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
                hidden = true,
                order = order:next(),
                type = 'header',
                name = '  Auto-Loaded Add-Ons Settings ',
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
                get = self.util:GlobalGet('addon_addonUsage_auto_show_ui'),
                set = self.util:GlobalSet('addon_addonUsage_auto_show_ui')
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

    function o:InitOptions()
        local options = self:CreateOptions()
        -- This creates the Profiles Tab/Section in Settings UI
        options.args.profiles = AceDBOptions:GetOptionsTable(ns:db())

        AceConfig:RegisterOptionsTable(ns.name, options, { "devsuite_options" })
        AceConfigDialog:AddToBlizOptions(ns.name, ns.name)
        if API:GetUIScale() > 1.0 then return end

        AceConfigDialog:SetDefaultSize(ns.name, 950, 600)

    end

end

MethodsAndProps(LIB)
