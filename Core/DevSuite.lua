--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

local O, GC = ns.O, ns.GC
local AceConfigDialog = ns:Ace():AceConfigDialog()

local AceAddon = ns:Ace():AceAddon()
local addonLibs = { 'AceConsole-3.0', 'AceEvent-3.0', 'AceBucket-3.0', 'AceHook-3.0' }
local Table, String = ns:Table(), ns:String()
local tostring, type = tostring, type
local IsAnyOf, IsEmptyTable = String.IsAnyOf, Table.IsEmpty
local DebugDialog = O.DebugDialog

local c1 = ns:ColorFormatter():ColorFn(BLUE_FONT_COLOR)
--- @type any
DEVS_MF = nil

--[[-----------------------------------------------------------------------------
NewAddOn
-------------------------------------------------------------------------------]]
--- @class DevSuite : AceConsole-3.0, AceEvent-3.0, AceHook-3.0, AceBucket-3.0
--- @field private configDialogWidget AceConfigDialog-3.0
--- @field private onHideHooked boolean
--- @field PopupDialog PopupDebugDialog
local o = AceAddon:NewAddon(ns.addon, unpack(addonLibs)); if not o then return end
local p, pd, t, tf = ns:log(ns.addon)

--- @type PopupDebugDialog
o.PopupDialog = nil
--- @type DebugDialogWidget
local debugDialog

--[[-----------------------------------------------------------------------------
Methods
UIParentLoadAddOn("Blizzard_DebugTools")
/dump UIParentLoadAddOn("Blizzard_EventTrace")
/dump IsAddOnLoaded('Blizzard_DebugTools')
/dump IsAddOnLoaded('Blizzard_EventTrace')
/dump EventTrace
-------------------------------------------------------------------------------]]

O.MainController:Init(o)

function o:OnInitialize()
  self.onHideHooked = false

  O.AceDbInitializerMixin:New(self):InitDb()
  self.OptionsDialog = O.OptionsDialogMixin:New(self.addon)
  self.OptionsDialog:InitOptions()
  self:SendMessage(GC.M.OnAfterInitialize, self)
  self:RegisterSlashCommands()
  O.DevConsoleModuleMixin:NewModule(self)
  
  --local isLoggedIn = IsLoggedIn()
  --local isPlayerInWorld = IsPlayerInWorld()
  --C_Timer.After(2, function()
  --  local tu = ns:traceUtil()
  --  tu:t('OnInitialize', 'isLoggedIn=', isLoggedIn)
  --  tu:t('OnInitialize', 'isPlayerInWorld=', isPlayerInWorld)
  --end)
  
  --if not EventTrace then return end
  --
  --local trace = ns:g().trace
  ----trace.show_at_startup = true
  --ns:SetEventTraceSearchKeyword(trace.preset_keyword)
  --if EventTrace:IsVisible() and trace.show_at_startup then return end
  --EventTrace:Hide()
end

--- #### See Also: [Ace-addon-3-0](https://www.wowace.com/projects/ace3/pages/api/ace-addon-3-0)
function o:OnEnable()
  self:RegisterHooks()
  debugDialog = DebugDialog:New()
  o.OnLoadEventTrace()
  if IsPlayerInWorld() then
    self:SendMessage(GC.M.OnAfterEnable, self)
  else
    self:RegisterEvent(GC.E.PLAYER_ENTERING_WORLD, 'OnPlayerEnteringWorld')
  end
end

function o:OnPlayerEnteringWorld()
  self:UnregisterEvent(GC.E.PLAYER_ENTERING_WORLD)
  self:SendMessage(GC.M.OnAfterEnable, self)
end

function o.OnLoadEventTrace()
  local trace = ns:g().trace
  ns:InitEventTrace()
  --trace.show_at_startup = true
  ns:traceUtil():SetEventTraceSearchKeyword(trace.preset_keyword)
  local evt = ns:evt()
  if evt:IsVisible() and trace.show_at_startup then return end
  evt:Hide()
end

--- @return any
function o:GetMouseFocus()
  local focusFn = GetMouseFoci or GetMouseFocus
  local mf = focusFn()
  if not mf then return end
  local val
  if #mf > 0 then val = mf[1] end
  if not val then return end
  
  --- @class MouseFocusVarDebugInfo
  --- @field name string
  --- @field dbgName string
  --- @field dbgNameByParentKey string
  --
  --
  --- @class MouseFocusParentDebugInfo
  --- @field name string
  --- @field parentKey string
  --- @field dbgName string
  --- @field dbgNameByParentKey string
  --
  --- @class MouseFocusDebugInfo
  --- @field globalVarName string
  --- @field mouseFocus MouseFocusVarDebugInfo
  --- @field parent MouseFocusParentDebugInfo
  --- @field children table<string[]>
  --
  --
  --- @class MouseFocusInfo
  --- @field debugInfo MouseFocusDebugInfo
  --- @field val any The mouse focus value
  local retVal = {
    debugInfo = {
      globalVarName = '_G.DEVS_MF',
      mouseFocus = {},
      parent = {},
      children = {},
    },
    val = val
  }
  --
  local debugInfo = retVal.debugInfo
  local mouseFocus = debugInfo.mouseFocus
  DEVS_MF = val
  local name = 'Mouse Focused Object'
  if type(val.GetName) == "function" then
      local n = val:GetName()
      name = n or 'Unnamed'
      mouseFocus.name = n or 'nil'
      mouseFocus.dbgName = val:GetDebugName()
      mouseFocus.dbgNameByParentKey = val:GetDebugName(true)
  end
  name = name .. '; var=DEVS_MF'

  if type(val.GetParentKey) == 'function' then mouseFocus.parentKey = val:GetParentKey() or 'nil' end
  if type(val.GetParent) == 'function' then
    local parent = debugInfo.parent
    local pf = val:GetParent()
    if type(pf) == 'table' then
      parent.name = pf and pf.GetName and pf:GetName() or 'nil'
      if type(pf.GetDebugName) == 'function' then
        parent.dbgName = pf:GetDebugName() or 'nil'
        parent.dbgNameByParentKey = pf:GetDebugName(true) or 'nil'
      end
    end
  end
  
  -- children
  local children = val.GetChildren and val:GetChildren()
  if type(children) == 'table' then
    local cL = debugInfo.children
    for _, c in pairs(children) do
      if type(c) == 'table' then
        local d = {}
        if c and c.GetParentKey then
          local n = c:GetParentKey()
          local dbgn = c.GetDebugName and c:GetDebugName()
          d[n] = dbgn
          table.insert(cL, d)
        end
      end
    end
  end
  
  self.PopupDialog:EvalObjectThenShow(retVal, name)
  if o.IsFrameStackToolEnabled() then o.ToggleFrameStack() end
end

function o.EvalVar(globalVarName)
    --if stringOrObjToEval ~= nil then debugDialog:SetCodeTextContent(optionalLabel) end
    debugDialog:SetCodeText(globalVarName)
    debugDialog:SetContent(ns.fmt(getglobal(globalVarName)))
    local label = ns.sformat('Global variable name: %s', globalVarName)
    debugDialog:SetStatusText(label)
    debugDialog:Show()
end

function o.EvalObject(obj, varName, _isGlobal)
    local isGlobal = _isGlobal or false
    local codeText = ''
    local localityLabel = 'Local'
    if isGlobal then
        codeText = varName
        localityLabel = 'Global'
    end
    debugDialog:SetCodeText(codeText)
    debugDialog:SetContent(ns.fmt(obj))
    local label = ns.sformat('%s variable name: %s', localityLabel, varName)
    debugDialog:SetStatusText(label)
    debugDialog:Show()
end

function o:OpenConfig()
  if AceConfigDialog.OpenFrames[ns.addon] then return end
  AceConfigDialog:SelectGroup(ns.addon)
  o.DialogGlitchHack();
  PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
  self.configDialogWidget = AceConfigDialog.OpenFrames[ns.addon]
  if not self.onHideHooked then
    self:HookScript(self.configDialogWidget.frame, 'OnHide', 'OnHide_Config_WithSound')
    self.onHideHooked = true
  end
end

--- This hacks solves the range UI notch not positioning properly
function o.DialogGlitchHack()
    AceConfigDialog:SelectGroup(ns.addon, "debugging")
    AceConfigDialog:Open(ns.addon)
    C_Timer.After(0.01, function()
        AceConfigDialog:ConfigTableChanged('anyEvent', ns.addon)
        AceConfigDialog:SelectGroup(ns.addon, "autoload_addons")
    end)
end

function o.OpenConfigGeneral() AceConfigDialog:Open(ns.addon) end
function o.OpenConfigAutoLoadedOptions() AceConfigDialog:Open(ns.addon, AceConfigDialog:SelectGroup(ns.addon, 'autoload_addons')) end
function o.DebugSettings() AceConfigDialog:Open(ns.addon, AceConfigDialog:SelectGroup(ns.addon, 'debugging')) end

function o.OnHide_Config_WithSound() o.OnHide_Config(true) end
function o.OnHide_Config_WithoutSound() o.OnHide_Config() end

--- @param enableSound BooleanOptional|nil
function o.OnHide_Config(enableSound)
    local enable = enableSound == true
    if true == enable then PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE) end
end

function o:RegisterHooks()
    local f = SettingsPanel or InterfaceOptionsFrame
    if f then self:HookScript(f, 'OnHide', 'OnHide_Config_WithoutSound') end
end

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

function o:RegisterSlashCommands()
  self:RegisterChatCommand(GC.C.CONSOLE_COMMAND, 'SlashCommands')
  self:RegisterChatCommand(GC.C.CONSOLE_COMMAND_SHORT, 'SlashCommands')
end

function o:SlashCommand_Config_Handler()
  self:OpenConfig()
end
function o.SlashCommand_Dialog_Handler()
  if debugDialog:IsShown() then debugDialog.a:Hide()
  else debugDialog:Show()
  end
end
function o.SlashCommand_Info_Handler()
    p(GC:GetAddonInfoFormatted())
end
function o.SlashCommand_Help_Handler()
  local C = GC.C
  print('')
  local COMMAND_DIALOG_TEXT = 'Toggles the debug dialog UI'
  local COMMAND_CONFIG_TEXT = 'Shows the config UI'
  local COMMAND_INFO_TEXT   = 'Prints additional info about the addon on this console'
  local COMMAND_CLEAR_TEXT  = 'Clears the debug console (Alias: cls, clr)'
  local COMMAND_HELP_TEXT   = 'Shows this help'
  local OPTIONS_LABEL       = 'options'
  local USAGE_LABEL         = ns.sformat("usage: %s [%s]", C.CONSOLE_PLAIN, OPTIONS_LABEL)
  print(USAGE_LABEL)
  print(OPTIONS_LABEL .. ":")
  print(C.CONSOLE_OPTIONS_FORMAT:format('info', COMMAND_INFO_TEXT))
  print(C.CONSOLE_OPTIONS_FORMAT:format('config', COMMAND_CONFIG_TEXT))
  print(C.CONSOLE_OPTIONS_FORMAT:format('dialog', COMMAND_DIALOG_TEXT))
  print(C.CONSOLE_OPTIONS_FORMAT:format('clear', COMMAND_CLEAR_TEXT))
  print(C.CONSOLE_OPTIONS_FORMAT:format('help', COMMAND_HELP_TEXT))
  print('Other commands:')
  print(c1('/devsuite-options'), 'or /ds-options for the Ace3 AceConfig command line options.')
end

--- @param text string The space separated string. Example: 'one two three'
local function ParseSpaceSeparatedVar(text)
    local rt = {}
    for a in text:gmatch("%S+") do table.insert(rt, a) end
    return rt
end

--- @param spaceSeparatedArgs string
function o:SlashCommands(spaceSeparatedArgs)
    local args = ParseSpaceSeparatedVar(spaceSeparatedArgs)
    --local cmd, qualifier = unpack(args)
    if IsEmptyTable(args) then
        return o.SlashCommand_Help_Handler()
    end
    if IsAnyOf('config', unpack(args)) or IsAnyOf('conf', unpack(args)) then
        return self:SlashCommand_Config_Handler()
    end
    if IsAnyOf('dialog', unpack(args)) then
        return o.SlashCommand_Dialog_Handler()
    end
    if IsAnyOf('cls', unpack(args))
            or IsAnyOf('clr', unpack(args))
            or IsAnyOf('clear', unpack(args)) then
        return self.BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
    end
    if IsAnyOf('info', unpack(args)) then
        return o.SlashCommand_Info_Handler()
    end
    o.SlashCommand_Help_Handler(); return
end

local GX_MAXIMIZE, SetCVar, GetCVarBool, RestartGx = 'gxMaximize', SetCVar, GetCVarBool, RestartGx
function o.ToggleWindowed()
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
function o.BINDING_DEVS_TOGGLE_WINDOWED() o.ToggleWindowed() end
function o.BINDING_DEVS_TOGGLE_FRAMESTACK() o.ToggleFrameStack() end
function o.BINDING_DEVS_CLEAR_DEBUG_CONSOLE()
    if ns:HasChatFrame() then ns.chatFrame:Clear() end
end
function o.BINDING_DEVS_TOGGLE_DEBUG_CONSOLE()
    if not ns:HasChatFrame() then return end
    local module = ns:DevConsoleModule()
    local val = ns:dbg().enableLogConsole
    ns:dbg().enableLogConsole = not val
    if ns:dbg().enableLogConsole == true then
        return module:Enable()
    end
    module:Disable()
end

--- @see Interface/AddOns/Blizzard_DebugTools/Blizzard_DebugTools.lua for mod key options
--- Option Key - go up in the UI tree
--- Control Key - inspect current
--- @see Interface/FrameXML/ChatFrame.lua
--- arg1: showHidden
--- arg2: showRegions
--- arg3 showAnchors
--- Example showing all:  "111" or "true true true"
--- TODO: Show Tooltip/Message to press 'Control' to show dialog
function o.ToggleFrameStack() SlashCmdList["FRAMESTACK"]("false true true") end
function o.IsFrameStackToolEnabled() return FrameStackTooltip and FrameStackTooltip:IsShown() end
function o:DevConsole() return self:GetModule(O.DevConsoleModuleMixin.moduleName, false) end
function o.ns() return DevSuite_NS end

--[[-------------------------------------------------------------------
Global Var
---------------------------------------------------------------------]]
DEV_SUITE = o;

