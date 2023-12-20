--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local O, GC, M, LibStub = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub
local LL = ns:GetAceLocale()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @alias DeveloperMode DeveloperModeMixin | _Frame
--- @class DeveloperModeMixin : BaseLibraryObject
local L = LibStub:NewLibrary(M.DeveloperModeMixin); if not L then return end
--- @type DeveloperModeMixin
DS_DeveloperModeMixin = L
local p = L.logger()

--[[-----------------------------------------------------------------------------
Developer Mode Settings
 • Enabling this will load addons needed for development
-------------------------------------------------------------------------------]]
local DEV_MODE = {
    enable = true,
    enableAddOnForAllCharacters = false,
    addOns = { 'AddonUsage', 'Boxer', 'M6', '!BugGrabber', 'BugSack', 'Ace3' }
}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param addons table<number, AddOnName>
local function EnableAddOns(addons)
    if #addons <= 0 then return end
    local charSpecific = ns:db().global.auto_loaded_addons_characterSpecific
    local charName
    if charSpecific == true then charName = UnitName("player") end
    for i, name in ipairs(addons) do
        C_AddOns.EnableAddOn(name, charName)
    end
end

---@param addons table<number, AddOnName>
local function AddOnsToString(addons)
    if #addons <=0 then return '' end
    local str = ''
    for i, n in ipairs(addons) do
        str = str .. n .. '\n'
    end
    return str
end
---@param o DialogWidgetMixin|_Frame|BaseLibraryObject
local function PropsAndMethods(o)
    local DEV_RELOAD_CONFIRM = 'DEV_RELOAD_CONFIRM'

    --- #### See Also:
    --- - [Creating_simple_pop-up_dialog_boxes](https://wowpedia.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes)
    function o:InitStaticDialog()
        if StaticPopupDialogs[DEV_RELOAD_CONFIRM] then return end
        StaticPopupDialogs[DEV_RELOAD_CONFIRM] = {
            text =  sformat(':: %s ::\n\n', ns.name) .. LL['REQUIRES_RELOAD'] .. '\n%s\n',
            button1 = YES,
            button2 = NO,
            OnAccept = function(self, addonsToEnable)
                EnableAddOns(addonsToEnable)
                ReloadUI()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            showAlert = true,
        }
    end

    function o:OnLoad()
        self:RegisterEvent(ns:E().PLAYER_ENTERING_WORLD)
        ns:Register(M.DeveloperMode, self)
    end

    function o:OnEvent(event, ...)
        if (event ~= ns:E().PLAYER_ENTERING_WORLD) then return end
        self:InitializeDevMode()
    end

    --- @param nameOrIndex string|Index
    --- @return Disabled
    function L:IsAddonDisabled(nameOrIndex)
        local name, title, notes, loadable, reason, security = GetAddOnInfo(nameOrIndex)
        p:log(5, 'name: %s loadable=%s r=%s s=%s',
                name, tostring(loadable), tostring(reason), security)
        return reason and O.String.EqualsIgnoreCase(reason, 'disabled')
    end

    function o:RefreshAutoLoadedAddons()
        local addons = ns:profile().auto_loaded_addons
        if not addons then return end

        local addonsToEnable = {}
        for addonName, autoEnable in pairs(addons) do
            if autoEnable == true then
                local disabled = L:IsAddonDisabled(addonName)
                if disabled == true then table.insert(addonsToEnable, addonName) end
            end
        end

        if #addonsToEnable > 0 then
            p:log('ActionbarPlus is in Developer mode and needs to restart to load additional addons.')
            local dlg = StaticPopup_Show(DEV_RELOAD_CONFIRM, AddOnsToString(addonsToEnable))
            dlg.data = addonsToEnable
        end

        -- AddonUsage is the "Addon Usage" global var
        C_Timer.After(3, function()
            local g = ns:db().global
            if AddonUsage and g.addon_addonUsage_auto_show_ui == true then AddonUsage:Show(); end
            if ToggleFramerate and g.show_fps == true then ToggleFramerate() end
        end)
    end

    function o:InitializeDevMode()
        if DEV_MODE.enable ~= true then return end
        self:InitStaticDialog()
        self:RefreshAutoLoadedAddons()
    end

end; PropsAndMethods(L)

