--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UISpecialFrames = UISpecialFrames
local ReloadUI, IsShiftKeyDown = ReloadUI, IsShiftKeyDown
local CreateFrame = CreateFrame
local RegisterFrameForEvents = FrameUtil.RegisterFrameForEvents

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

local commandTextFormat = 'Type %s or %s on the console for available commands.'

local O, GC, M, LibStub, Ace = ns.O, ns.O.GlobalConstants, ns.M, ns.O.LibStub, ns.O.AceLibrary
local Table, String = O.Table, O.String
local pformat, sformat = ns.pformat, ns.sformat

--- @type DebugDialog
local DebugDialog = LibStub(M.DebugDialog)

local C = O.Config
local AceConfigDialog = Ace.AceConfigDialog

local unpack = Table.unpackIt
local print, format = print, string.format
local tostring, type = tostring, type
local IsNotBlank, ToTable = String.IsNotBlank, String.ToTable

local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVS_DebugDialog"
local MAJOR, MINOR = ns.name .. '-1.0', 1 -- Bump minor on changes

--- @class DevSuite
local A = LibStub:NewAddon(ns.name); if not A then return end

--- @type PopupDebugDialog
A.PopupDialog = nil

local p = ns:NewLogger(ns.name)

--- @type DebugDialogWidget
local debugDialog


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--_G[TEXTURE_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
--table.insert(UISpecialFrames, TEXTURE_DIALOG_GLOBAL_FRAME_NAME)
local function ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    Table.insert(UISpecialFrames, frameName)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o DevSuite | AceHook
local function PropsAndMethods(o)

    function o:GetMouseFocus()
        --p:log('Mouse Focus: %s', pformat(GetMouseFocus()))
        local mf = GetMouseFocus()
        DEVS_MF = mf
        if not mf then return end
        local name = 'Mouse Focused Object'
        if type(mf.GetName) == 'function' then name = mf:GetName() end
        self.PopupDialog:EvalObjectThenShow(mf, name)
    end

    function o:EvalVar(globalVarName)
        --if stringOrObjToEval ~= nil then debugDialog:SetCodeTextContent(optionalLabel) end
        debugDialog:SetCodeText(globalVarName)
        debugDialog:SetContent(pformat(getglobal(globalVarName)))
        local label = format('Global variable name: %s', globalVarName)
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end

    function o:EvalObject(obj, varName, _isGlobal)
        local isGlobal = _isGlobal or false
        local codeText = ''
        local localityLabel = 'Local'
        if isGlobal then
            codeText = varName
            localityLabel = 'Global'
        end
        debugDialog:SetCodeText(codeText)
        debugDialog:SetContent(pformat(obj))
        local label = format('%s variable name: %s', localityLabel, varName)
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end

    function o:Help()
        local ftext = '  %-30s - %s'
        p:log(' ')
        p:log("Available commands:")
        p:log(format(ftext, "help", "show this help text"))
        p:log(format(ftext, "config", "open config UI"))
        p:log(format(ftext, "dialog", "open config UI"))
        p:log(' ')
    end

    function o:OnProfileChanged()
        self:ConfirmReloadUI()
    end

    function o:ConfirmReloadUI()
        if IsShiftKeyDown() then
            ReloadUI()
            return
        end
        ShowReloadUIConfirmation()
    end

    function o:OpenConfig()
        self:OpenConfigAutoLoadedOptions()
        self.onHideHooked = self.onHideHooked or false
        self.configDialogWidget = AceConfigDialog.OpenFrames[ns.name]

        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        if not self.onHideHooked then
            self:HookScript(self.configDialogWidget.frame, 'OnHide', 'OnHide_Config_WithSound')
            self.onHideHooked = true
        end
    end

    function o:OpenConfigGeneral() AceConfigDialog:Open(ns.name) end
    function o:OpenConfigAutoLoadedOptions() AceConfigDialog:Open(ns.name, AceConfigDialog:SelectGroup(ns.name, 'autoload_addons')) end

    function o:OnHide_Config_WithSound() self:OnHide_Config(true) end
    function o:OnHide_Config_WithoutSound()
        self:OnHide_Config() end

    --- @param enableSound BooleanOptional
    function o:OnHide_Config(enableSound)
        local enable = enableSound == true
        p:log(10, 'OnHide_Config called with enableSound=%s', tostring(enable))
        if true == enable then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
        O.DeveloperMode:RefreshAutoLoadedAddons()
    end

    function o:RegisterHooks()
        local f = SettingsPanel or InterfaceOptionsFrame
        if f then self:HookScript(f, 'OnHide', 'OnHide_Config_WithoutSound') end
    end

    function o:OnInitialize()
        O.AceDbInitializerMixin:New(self):InitDb()
        O.OptionsMixin:New(self):InitOptions()
        self:RegisterSlashCommands()
    end

    --- #### See Also: [Ace-addon-3-0](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
    function o:OnEnable()
        self:RegisterHooks()
        debugDialog = DebugDialog(ns:profile())
    end

    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------

    function o:RegisterSlashCommands() self:RegisterChatCommand(GC.C.CONSOLE_COMMAND, "Handle_SlashCommands") end
    function o:RegisterSlashCommands() self:RegisterChatCommand(GC.C.CONSOLE_COMMAND_SHORT, "Handle_SlashCommands") end

    function o:Handle_SlashCommands(input)
        local args = ToTable(input)
        local cmd = args[1] or ''
        if String.IsBlank(cmd) then return o:Help() end
        if 'config' == cmd then return o:OpenConfig() end
        if 'dialog' == cmd then return debugDialog:Show() end
        o:Help()
    end

    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------

    function o.BINDING_DEVS_OPTIONS_DLG() o:OpenConfig() end

    function o.BINDING_DEVS_DEBUG_DLG() debugDialog:Show() end
    function o.BINDING_DEVS_GET_DETAILS_ON_MOUSEOVER() o:GetMouseFocus() end
end; PropsAndMethods(A)

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

---@param frame DevSuite_Frame
---@param event string The event name
local function OnPlayerEnteringWorld(frame, event, ...)
    local isLogin, isReload = ...

    local addon = frame.ctx.addon
    addon:SendMessage(GC.M.OnAddonReady)
    if not addon.PopupDialog then
        addon.PopupDialog = O.PopupDebugDialog()
    end
    --@debug@
    isLogin = true
    --@end-debug@

    if not isLogin then return end

    local version = GC:GetAddonInfo()
    p:log('%s Initialized. %s', version,
            ns.sformat(commandTextFormat, GC.C.COMMAND, GC.C.COMMAND_SHORT, GC.C.HELP_COMMAND))
    p:log('Type %s for available commands', GC.C.COMMAND)
end

--- @param addon DevSuite | AceEvent
local function RegisterEvents(addon)
    --- @class DevSuite_Frame: _Frame
    local f = CreateFrame('Frame',  ns.name .. 'Frame', UIParent)
    f.ctx = { addon = addon }
    f:SetScript(GC.E.OnEvent, OnPlayerEnteringWorld)
    RegisterFrameForEvents(f, { GC.E.PLAYER_ENTERING_WORLD })
end
RegisterEvents(A)

--- @type DevSuite
DEVS = A

