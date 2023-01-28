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
local AceConfig, AceConfigDialog = ACE.AceConfig, ACE.AceConfigDialog

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
---@class OptionsMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.OptionsMixin)
local p = L.logger;

---@param addon DevSuite
function L:Init(addon)
    self.addon = addon
end

---@param o OptionsMixin
local function Methods(o)

    --- Usage:  local instance = OptionsMixin:New(addon)
    --- @param addon DevSuite
    --- @return OptionsMixin
    function o:New(addon) return LibUtil:CreateAndInitFromMixin(o, addon) end

    function o:CreateOptions()
        local options = {
            name = ns.name,
            handler = self,
            type = "group",
            args = {
                --enable = {
                --    type = "toggle",
                --    name = "Enable",
                --    desc = "Enable Addon",
                --    order = 1,
                --},
                general = {
                    type = "group",
                    name = "General",
                    desc = "General Settings",
                    order = 2,
                    args = {
                        desc = { name = " General Configuration ", type = "header", order = 0 },
                    },
                },
                debugging = self:CreateDebuggingGroup(),
            }
        }
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
        AceConfig:RegisterOptionsTable(ns.name, self:CreateOptions(), { "sdnr_options" })
        AceConfigDialog:AddToBlizOptions(ns.name, ns.nameShort)
    end

end

Methods(L)
