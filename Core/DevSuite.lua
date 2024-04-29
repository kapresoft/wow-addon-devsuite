--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

local O, GC, LibStub = ns.O, ns.GC, ns.O.LibStub
local AceConfigDialog = ns:AceConfigDialog()

local Table, String = ns:Table(), ns:String()
local pformat, sformat = ns.pformat, string.format
local tostring, type = tostring, type
local IsAnyOf, IsEmptyTable = String.IsAnyOf, Table.isEmpty
local DebugDialog = O.DebugDialog

local c1 = ns:ColorUtil():NewFormatterFromColor(BLUE_FONT_COLOR)

--[[-----------------------------------------------------------------------------
NewAddOn
-------------------------------------------------------------------------------]]
--- @class DevSuite
local A = LibStub:NewAddon(ns.addon); if not A then return end
local p = ns:CreateDefaultLogger(ns.addon)

--- @type PopupDebugDialog
A.PopupDialog = nil
--- @type DebugDialogWidget
local debugDialog

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param o DevSuite | AceHook | AceConsole
local function PropsAndMethods(o)
    O.MainController:Init(o)

    function o:OnInitialize()
        O.AceDbInitializerMixin:New(self):InitDb()
        O.OptionsMixin:New(self.addon):InitOptions()
        self:SendMessage(GC.M.OnAfterInitialize, self)
        self:RegisterSlashCommands()
    end


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
        local label = sformat('Global variable name: %s', globalVarName)
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
        local label = sformat('%s variable name: %s', localityLabel, varName)
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end

    function o:OpenConfig()
        if AceConfigDialog.OpenFrames[ns.addon] then return end
        AceConfigDialog:SelectGroup(ns.addon)
        self:DialogGlitchHack();
        self.onHideHooked = self.onHideHooked or false
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
        self.configDialogWidget = AceConfigDialog.OpenFrames[ns.addon]
        if not self.onHideHooked then
            self:HookScript(self.configDialogWidget.frame, 'OnHide', 'OnHide_Config_WithSound')
            self.onHideHooked = true
        end
    end
    --- This hacks solves the range UI notch not positioning properly
    function o:DialogGlitchHack()
        AceConfigDialog:SelectGroup(ns.addon, "debugging")
        AceConfigDialog:Open(ns.addon)
        C_Timer.After(0.01, function()
            AceConfigDialog:ConfigTableChanged('anyEvent', ns.addon)
            AceConfigDialog:SelectGroup(ns.addon, "autoload_addons")
        end)
    end

    function o:OpenConfigGeneral() AceConfigDialog:Open(ns.addon) end
    function o:OpenConfigAutoLoadedOptions() AceConfigDialog:Open(ns.addon, AceConfigDialog:SelectGroup(ns.addon, 'autoload_addons')) end
    function o:DebugSettings() AceConfigDialog:Open(ns.addon, AceConfigDialog:SelectGroup(ns.addon, 'debugging')) end

    function o:OnHide_Config_WithSound() self:OnHide_Config(true) end
    function o:OnHide_Config_WithoutSound()
        self:OnHide_Config() end

    --- @param enableSound BooleanOptional
    function o:OnHide_Config(enableSound)
        local enable = enableSound == true
        p:d(function() return 'OnHide_Config called with enableSound=%s', tostring(enable) end)
        if true == enable then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
    end

    function o:RegisterHooks()
        local f = SettingsPanel or InterfaceOptionsFrame
        if f then self:HookScript(f, 'OnHide', 'OnHide_Config_WithoutSound') end
    end

    --- #### See Also: [Ace-addon-3-0](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
    function o:OnEnable()
        self:RegisterHooks()
        debugDialog = DebugDialog:New()
    end

    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------


    function o:RegisterSlashCommands()
        self:RegisterChatCommand(GC.C.CONSOLE_COMMAND, "SlashCommands")
        self:RegisterChatCommand(GC.C.CONSOLE_COMMAND_SHORT, "SlashCommands")
        self:RegisterChatCommand('dmp', function(...) ns.O.Developer:dump(...)  end)
    end

    function o:SlashCommand_Config_Handler()
        self:OpenConfig()
    end
    function o:SlashCommand_Dialog_Handler()
        debugDialog:Show()
    end
    function o:SlashCommand_Info_Handler()
        p:a(GC:GetAddonInfoFormatted())
    end
    function o:SlashCommand_Help_Handler()
        p:a('')
        local COMMAND_DIALOG_TEXT = 'Shows debug dialog UI'
        local COMMAND_CONFIG_TEXT = 'Shows the config UI'
        local COMMAND_INFO_TEXT   = 'Prints additional info about the addon on this console'
        local COMMAND_HELP_TEXT = 'Shows this help'
        local OPTIONS_LABEL = 'options'
        local USAGE_LABEL = sformat("usage: %s [%s]", GC.C.CONSOLE_PLAIN, OPTIONS_LABEL)
        p:a(USAGE_LABEL)
        p:a(OPTIONS_LABEL .. ":")
        p:a(function() return GC.C.CONSOLE_OPTIONS_FORMAT, 'info', COMMAND_INFO_TEXT end)
        p:a(function() return GC.C.CONSOLE_OPTIONS_FORMAT, 'config', COMMAND_CONFIG_TEXT end)
        p:a(function() return GC.C.CONSOLE_OPTIONS_FORMAT, 'dialog', COMMAND_DIALOG_TEXT end)
        p:a(function() return GC.C.CONSOLE_OPTIONS_FORMAT, 'help', COMMAND_HELP_TEXT end)
        p:a('Other commands:')
        p:a(function() return c1('/devsuite-options')
                .. ' or /ds-options for the Ace3 AceConfig command line options.' end)
    end

    --- @param spaceSeparatedArgs string
    function o:SlashCommands(spaceSeparatedArgs)
        local args = Table.parseSpaceSeparatedVar(spaceSeparatedArgs)
        if IsEmptyTable(args) then
            self:SlashCommand_Help_Handler(); return
        end
        if IsAnyOf('config', unpack(args)) or IsAnyOf('conf', unpack(args)) then
            self:SlashCommand_Config_Handler(); return
        end
        if IsAnyOf('dialog', unpack(args)) then
            self:SlashCommand_Dialog_Handler(); return
        end
        if IsAnyOf('info', unpack(args)) then
            self:SlashCommand_Info_Handler(); return
        end        -- Otherwise, show help
        self:SlashCommand_Help_Handler(); return
    end

    local GX_MAXIMIZE, SetCVar, GetCVarBool, RestartGx = 'gxMaximize', SetCVar, GetCVarBool, RestartGx
    function o:ToggleWindowed()
        local isMaximized = GetCVarBool(GX_MAXIMIZE)
        SetCVar(GX_MAXIMIZE, isMaximized and 0 or 1)
        RaidNotice_AddMessage(RaidWarningFrame, "Toggling Window Mode!", ChatTypeInfo["RAID_WARNING"])
        C_Timer.After(1, function()
            RestartGx()
        end)
    end

    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------
    -- ## -------------------------------------------------------------------------

    function o.BINDING_DEVS_OPTIONS_DLG() o:OpenConfig() end

    function o.BINDING_DEVS_DEBUG_DLG() debugDialog:Show() end
    function o.BINDING_DEVS_GET_DETAILS_ON_MOUSEOVER() o:GetMouseFocus() end
    function o.BINDING_DEVS_TOGGLE_WINDOWED() o:ToggleWindowed() end
end; PropsAndMethods(A); DEV_SUITE = A
