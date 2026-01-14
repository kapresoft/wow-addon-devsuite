--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local geterrorhandler = geterrorhandler
local str_lower = string.lower
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn
local StaticPopupDialogs, ReloadUI = StaticPopupDialogs, ReloadUI
local StaticPopup_Visible, StaticPopup_Show = StaticPopup_Visible, StaticPopup_Show
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local GX_MAXIMIZE, SetCVar, GetCVarBool, RestartGx = 'gxMaximize', SetCVar, GetCVarBool, RestartGx

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local M = ns.M

-- Settings
local SHOW_ADDON_LIST_ON_LOGIN = false

--[[-----------------------------------------------------------------------------
Developer
-------------------------------------------------------------------------------]]
local libName = M.Developer()
--- @class Developer
local L = ns:NewLibWithEvent(libName); d = L
local p = ns:LC().DEV:NewLogger(libName)

local c1 = ns:K():cf(RED_THREAT_COLOR)
local libNamePretty = c1(libName)

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function errorhandler(err) return geterrorhandler()(err) end

local function safecall(func, ...)
    if func then
        return xpcall(func, errorhandler, ...)
    end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

function L:ll() self:logp('Log Level:', DEVS_LOG_LEVEL) end
function L:IsScriptErrorsEnabled()
    self:logp('scriptErrors:', GetCVarBool('scriptErrors'))
end

function L:GetProfile() return ns:db().profile end
function L:GetProfileNames() return ns:db():GetProfiles() end

function L:T() self:ToggleWindowed() end
function L:ToggleWindowed()
    local isMaximized = GetCVarBool(GX_MAXIMIZE)
    SetCVar(GX_MAXIMIZE, isMaximized and 0 or 1)
    RestartGx()
end
function L:MaxScreen() SetCVar(GX_MAXIMIZE, 1); RestartGx() end
function L:Windowed() SetCVar(GX_MAXIMIZE, 0); RestartGx() end


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

function L:API(name)
    -- call /api first
    local doc = APIDocumentation
    local api = doc:FindSystemByName(name)
    local t = OutputAllSystemAPI(doc, api)
    t.__tostring = true
    return t
end

--- @see Interface/SharedXML/Color.lua
function L:GetColors()
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

--- Usage: /run d:c('hello', 'world')
function L:c(...) ns.logp(libNamePretty, ...) end


-- TODO: Add this as a feature; a textbox that takes a code to execute on login

if SHOW_ADDON_LIST_ON_LOGIN then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event, ...)
        if event ~= "PLAYER_LOGIN" then return end
        C_Timer.After(1, function()
            if AddonList then AddonList:Show() end
        end)
    end)
end
