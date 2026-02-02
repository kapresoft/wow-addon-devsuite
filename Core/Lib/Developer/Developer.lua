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

local libName = M.Developer()
local p = ns:LC().DEV:NewLogger(libName)

-- Settings
-- /run DEVS_SHOW_ADDON_LIST_ON_LOGIN = true
--- @boolean
local SHOW_ADDON_LIST_ON_LOGIN

--[[-----------------------------------------------------------------------------
Developer
-------------------------------------------------------------------------------]]
--- @class Developer
local L = ns:NewLibWithEvent(libName); d = L

local c1 = ns:K():cf(RED_THREAT_COLOR)
local libNamePretty = c1(libName)

--[[-----------------------------------------------------------------------------
Event::OnAddOnReady
-------------------------------------------------------------------------------]]

local function OnAddOnReady()
    if not ShadowUF then L:FrameFormation2() end

    SHOW_ADDON_LIST_ON_LOGIN = DEVS_SHOW_ADDON_LIST_ON_LOGIN
    p:vv(function() return "DEVS_SHOW_ADDON_LIST_ON_LOGIN: %s", SHOW_ADDON_LIST_ON_LOGIN end)
    if SHOW_ADDON_LIST_ON_LOGIN and AddonList then AddonList:Show() end
end

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

-- /run d:Formation1()
function L:FrameFormation1()
    if ShadowUF then return end

    local scale = 0.85
    local ofsy = -200
    if ns:IsMoP() then ofsy = -120 end

    --- @type Frame
    local pf = PlayerFrame
    pf:SetScale(scale)
    pf:ClearAllPoints()
    pf:SetPoint("TOPRIGHT", UIParent, "CENTER", -100, ofsy)

    local tf = TargetFrame
    tf:ClearAllPoints()
    tf:SetScale(scale)
    tf:SetPoint("TOPLEFT", UIParent, "CENTER", 100, ofsy)
end

-- /run d:Formation2()
function L:FrameFormation2()
    if ShadowUF then return end

    local scale = 0.85
    local ofsy = -110
    if ns:IsMoP() then ofsy = -120 end

    --- @type Frame
    local pf = PlayerFrame
    pf:SetScale(scale)
    pf:ClearAllPoints()
    pf:SetPoint("TOPRIGHT", UIParent, "TOP", -100, ofsy)

    local tf = TargetFrame
    tf:ClearAllPoints()
    tf:SetScale(scale)
    tf:SetPoint("TOPLEFT", UIParent, "TOP", 100, ofsy)
end



--- Usage: /run d:c('hello', 'world')
function L:c(...) ns.logp(libNamePretty, ...) end


-- TODO: Add this as a feature; a textbox that takes a code to execute on login
--- @type Frame
local f = CreateFrame('Frame')
FrameUtil.RegisterFrameForEvents(f, {'PLAYER_LOGIN'})
f:SetScript('OnEvent', function(self, event, ...)
    if event ~= 'PLAYER_LOGIN' then return end
    C_Timer.After(0.01, function()
        return OnAddOnReady()
    end)
end)
