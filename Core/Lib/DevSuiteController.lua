--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local ns = devsuite_ns(...)
local O, GC, M, LibStub, LC = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.LogCategories()
local LL, AceEvent = ns:AceLocale(), ns:AceEvent()
local EnableAddOn, DisableAddOn = EnableAddOn or C_AddOns.EnableAddOn, DisableAddOn or C_AddOns.DisableAddOn

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class DevSuiteController : BaseLibraryObject
local L = LibStub:NewLibrary(M.DevSuiteController); if not L then return end
local p = ns:CreateDefaultLogger(M.DevSuiteController)

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
        EnableAddOn(name, charName)
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

    --- @param nameOrIndex string|Index
    --- @return Disabled
    function L:IsAddonDisabled(nameOrIndex)
        local name, title, notes, loadable, reason, security = GetAddOnInfo(nameOrIndex)
        p:f2(function()
            return 'Add-On: %s loadable=%s r=%s s=%s', name, tostring(loadable), tostring(reason), security end)
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
            p:vv('ActionbarPlus is in Developer mode and needs to restart to load additional addons.')
            local dlg = StaticPopup_Show(DEV_RELOAD_CONFIRM, AddOnsToString(addonsToEnable))
            dlg.data = addonsToEnable
        end

        -- AddonUsage is the "Addon Usage" global var
        C_Timer.After(3, function() self:ApplyInitialStates() end)
    end

    function o:ApplyInitialStates()
        local g = ns:db().global
        self:InitAddonUsage()
        if ToggleFramerate and g.show_fps == true then ToggleFramerate() end
    end

    function o:InitAddonUsage()
        local g = ns:db().global
        --- @type _Frame
        local au = AddonUsage
        local autoShowUI = au and g.addon_addonUsage_auto_show_ui == true
        if not autoShowUI then return end

        -- TODO: Add "compact" option
        au:SetSize(385, 200)
        if ChatFrame1Tab then
            -- TODO: Add "align" option
            au:ClearAllPoints()
            au:SetPoint("BOTTOM", ChatFrame1Tab, "TOP", 155, 0)
        end
        au:Show();
    end

    function o:InitializeDevMode()
        self:InitStaticDialog()
        self:RefreshAutoLoadedAddons()
    end

end; PropsAndMethods(L)

AceEvent:RegisterMessage(GC.M.OnAddonReady, function(msg, source, ...)
    p:d(function() return "MSG:R:%s", msg end)
    L:InitializeDevMode()
end)
