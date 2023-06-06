--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local geterrorhandler = geterrorhandler
local str_lower = string.lower
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn, DisableAddOn
local StaticPopupDialogs, ReloadUI = StaticPopupDialogs, ReloadUI
local StaticPopup_Visible, StaticPopup_Show = StaticPopup_Visible, StaticPopup_Show
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local GX_MAXIMIZE, SetCVar, GetCVarBool, RestartGx = 'gxMaximize', SetCVar, GetCVarBool, RestartGx

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local reloadUI = ns.name .. '_CONFIRM_RELOAD_UI'


---@class Developer : BaseLibraryObject
local L = LibStub:NewLibrary(M.Developer); if not L then return end

--- DevSuite_D is global
_G[ns.name .. '_D'] = L
local p = L.logger

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
StaticPopupDialogs[reloadUI] = {
    text = "Reload UI?", button1 = "Yes", button2 = "No",
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function() ReloadUI() end,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

local function ConfirmAndReload()
    if StaticPopup_Visible(reloadUI) == nil then return StaticPopup_Show(reloadUI) end
    return false
end

local function errorhandler(err) return geterrorhandler()(err) end

local function safecall(func, ...)
    if func then
        return xpcall(func, errorhandler, ...)
    end
end

---@class AddOnInfo
local _AddOnInfo = {
    name = '', title = '', notes = '', loadable = true,
    reason = '', security = '', newVersion = false
}
--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param o Developer
local function Methods(o)

    function o:T() self:ToggleWindowed() end
    function o:ToggleWindowed()
        local isMaximized = GetCVarBool(GX_MAXIMIZE)
        SetCVar(GX_MAXIMIZE, isMaximized and 0 or 1)
        RestartGx()
    end
    function o:MaxScreen() SetCVar(GX_MAXIMIZE, 1); RestartGx() end
    function o:Windowed() SetCVar(GX_MAXIMIZE, 0); RestartGx() end


    local function OutputAPIMatches(out, doc, apiMatches, headerName)
        if apiMatches and #apiMatches > 0 then
            for i, api in ipairs(apiMatches) do
                table.insert(out, api:GetSingleOutputLine())
            end
        end
    end

    local function OutputAllSystemAPI(doc, system)
        local apiMatches = system:ListAllAPI();
        local out = {}
        if apiMatches then
            OutputAPIMatches(out, doc, apiMatches.functions, "function(s)");
            OutputAPIMatches(out, doc, apiMatches.events, "events(s)");
            OutputAPIMatches(out, doc, apiMatches.tables, "table(s)");
        end
        return out
    end

    function o:API(name)
        -- call /api first
        local doc = APIDocumentation
        local api = doc:FindSystemByName(name)
        local t = OutputAllSystemAPI(doc, api)
        t.__tostring = true
        return t
    end

    function o:GetAllAddOns()
        local count = GetNumAddOns()
        ---@type table<string, AddOnInfo>
        local addons = {}
        for i=1,count do
            local name, title, notes, loadable, reason, security, newVersion = GetAddOnInfo(i)
            ---@type AddOnInfo
            local addonInfo = {
                name = name, title = title, loadable = loadable,
                reason = reason, security = security, newVersion = newVersion
            }
            --p:log('%s: %s', name, pformat(o))
            addons[str_lower(name)] = addonInfo
        end
        return addons
    end

    function o:GetAllAddOnsShort()
        local a = self:GetAllAddOns()
        local t = {}
        for k,n in pairs(a) do table.insert(t, n.name) end
        table.sort(t)
        return t
    end

    ---@param addons table<number, string>
    function o:EnableAddOns(addons)
        self:ForEachAddons(addons, function(addonName)
            local player = UnitName('player')
            EnableAddOn(addonName, player)
            p:log('Addons Enabled[%s]: %s', player, addonName)
        end)
    end

    ---@param addons table<number, string>
    function o:DisableAddOns(addons)
        self:ForEachAddons(addons, function(addonName)
            local player = UnitName('player')
            DisableAddOn(addonName, player)
            p:log('Addons Disabled[%s]: %s', player, addonName)
        end)
    end

    ---@param addons table<number, string>
    ---@param applyFn fun(addonName:string)
    function o:ForEachAddons(addons, applyFn)
        if #addons <= 0 then return end
        local a = self:GetAllAddOns()
        local overallStatus = true
        for i, n in ipairs(addons) do
            local n_lower = str_lower(n)
            local info = a[n_lower]
            if info then
                local status = safecall(applyFn, info.name)
                if not status then
                    overallStatus = false
                    p:log('Failed to Enable AddOn: %s', info.name)
                end
            else
                p:log('AddOn Not Found: %s', n)
                assert(false, 'AddOn Not Found: ' .. n)
                overallStatus = false
            end
        end
        if overallStatus then ConfirmAndReload() return end
    end

    function o:GetSavedInstances()

        local t = {}
        local c = GetNumSavedInstances()
        for i=1, c do
            local name, id, reset, difficulty, locked, extended, instanceIDMostSig,
                    isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress,
                    extendDisabled = GetSavedInstanceInfo(i)
            if true then
                local instance = {
                    name=name, id=id, reset=reset, difficulty=difficulty, locked=locked,
                    extended=extended, instanceIDMostSig=instanceIDMostSig, isRaid=isRaid,
                    maxPlayers=maxPlayers, difficultyName=difficultyName, numEncounters=numEncounters,
                    encounterProgress=encounterProgress, extendDisabled=extendDisabled
                }
                table.insert(t, instance)
            end
        end
        return t

    end

    --- @see Interface/SharedXML/Color.lua
    function o:GetColors()
        local ret = {
            names = {},
            codes = {}
        }
        do
            local DBColors = C_UIColor.GetColors();
            for _, dbColor in ipairs(DBColors) do
                table.insert(ret.names, dbColor.baseTag)
                table.insert(ret.codes, dbColor.baseTag .. "_CODE")
            end
        end
        return ret
    end

end

Methods(L)
