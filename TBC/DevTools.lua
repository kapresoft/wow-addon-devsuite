--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UISpecialFrames = UISpecialFrames

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local Constants, ObjectFactory,
    LibStub, ACELIB, C, PrettyPrint, table, String,
    StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown =
            DEVT_Constants, DEVT_ObjectFactory,
            LibStub, DEVT_AceLibFactory, DEVT_Config, DEVT_PrettyPrint, DEVT_Table, DEVT_String,
            StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown

local AddonDetails = Constants.AddonDetails
local ADDON_NAME = AddonDetails.name
local ADDON_PREFIX = AddonDetails.prefix
local unpack = table.unpackIt
local print, format, tinsert, pformat = print, string.format, table.insert, PrettyPrint.pformat
local tostring, type = tostring, type
local IsNotBlank, ToTable = String.IsNotBlank, String.ToTable
local ACEDB, ACEDBO, ACECFG, ACECFGD = unpack(ACELIB:GetAddonAceLibs())


local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVT_DebugDialog"
local MAJOR, MINOR = AddonDetails.name .. '-1.0', 1 -- Bump minor on changes

---@class DevTools
local A = ObjectFactory:NewAddon()
if not A then return end

---@class DebugDialog
local debugDialog = nil

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--_G[TEXTURE_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
--table.insert(UISpecialFrames, TEXTURE_DIALOG_GLOBAL_FRAME_NAME)
local function ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    table.insert(UISpecialFrames, frameName)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function A:CreateDebugPopupDialog()
    local p = DEVT_logger:NewLogger('DebugDialog')
    local AceGUI = ACELIB:GetAceGUI()
    local frame = AceGUI:Create("Frame")
    -- The following makes the "Escape" close the window
    --_G[DEBUG_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
    --tinsert(UISpecialFrames, DEBUG_DIALOG_GLOBAL_FRAME_NAME)
    Constants:ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, frame)

    frame:SetTitle("Debug Frame")
    frame:SetStatusText('')
    frame:SetCallback("OnClose", function(_)
        frame:SetCodeText('')
        frame:SetContent('')
        frame:SetStatusText('')
    end)
    frame:SetLayout("Flow")
    frame:SetCallback("OnShow", function(widget, event)
        frame:EnableAcceptButton()
        --if frame:HasCodeContent() then frame:Submit() end
    end)
    frame:SetHeight(800)
    --frame:SetWidth(800)

    local inlineGroup = AceGUI:Create("InlineGroup")
    --inlineGroup:SetTitle("Evaluate LUA Variable")
    inlineGroup:SetLayout("List")
    inlineGroup:SetFullWidth(true)
    frame:AddChild(inlineGroup)

    local codeEditBox = AceGUI:Create("MultiLineEditBox")
    frame.codeEditBox = codeEditBox
    codeEditBox:SetLabel('')
    codeEditBox:SetFullWidth(true)
    codeEditBox:SetHeight(200)
    codeEditBox:SetText('')
    codeEditBox:SetCallback("OnEditFocusGained", function(widget, event)
        frame:EnableAcceptButton()
    end)
    codeEditBox:SetCallback("OnEnterPressed", function(widget, event, literalVarName)
        if DEVT_String.IsBlank(literalVarName) then return end
        self.profile.last_eval = literalVarName

        local includeFn = frame:IsShowFunctions()
        local baseOptions = 'show_metatable=true, depth_limit=true'
        local scriptToEval = format([[ DEVT_PrettyPrint.setup({ show_function=%s, %s })
        return %s]], tostring(includeFn), baseOptions, literalVarName)
        p:log(30, 'Eval Code: %s', scriptToEval)
        --local cmd = format(evalCode , literalVarName)
        local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
        frame:SetStatusText(errorMessage)
        local val = func()
        if type(val) == 'function' then val = val() end
        frame:SetContent(val)
    end)

    local showFnEditBox = AceGUI:Create("CheckBox")
    showFnEditBox:SetLabel("Show Functions")
    showFnEditBox:SetCallback("OnValueChanged", function(_, _, checkedState)
        codeEditBox.button:Enable()
    end)
    --frame:AddChild(showFnEditBox)
    --frame:AddChild(codeEditBox)
    inlineGroup:AddChild(showFnEditBox)
    inlineGroup:AddChild(codeEditBox)

    -- PrettyPrint.format(obj)
    local contentEditBox = AceGUI:Create("MultiLineEditBox")
    contentEditBox:SetLabel('Output:')
    contentEditBox:SetText('')
    contentEditBox:SetFullWidth(true)
    contentEditBox:SetFullHeight(true)
    contentEditBox.button:Hide()
    frame:AddChild(contentEditBox)
    frame.contentEditBox = contentEditBox


    function frame:SetCodeText(text)
        frame.codeEditBox:SetText(text or '')
    end
    function frame:SetContent(o)
        local text = nil
        if type(o) == 'text' then text = '' end
        text = pformat(o)
        frame.contentEditBox:SetText(text)
    end
    function frame:SetIcon(iconPathOrId)
        if not iconPathOrId then return end
        self.iconFrame:SetImage(iconPathOrId)
    end
    function frame:EnableAcceptButton()
        codeEditBox.button:Enable()
    end
    function frame:IsShowFunctions()
        return showFnEditBox:GetValue()
    end
    function frame:Submit()
        frame.codeEditBox.button:Click()
    end
    function frame:HasCodeContent()
        local codeValue = frame.codeEditBox:GetText()
        return IsNotBlank(codeValue)
    end

    frame:Hide()
    return frame
end

function A:ShowDebugDialog()
    debugDialog:SetCodeText(self.profile.last_eval)
    debugDialog:Show()
end
function A:ShowDebugDialogCurrentProfile()
    PrettyPrint.setup({ show_all = false, show_function = true } )
    local profileData = self:GetCurrentProfileData()
    local profileName = self.db:GetCurrentProfile()
    debugDialog:SetCodeText('')
    debugDialog:SetContent(profileData)
    debugDialog:SetStatusText(format('Current Profile Data for [%s]', profileName))
    debugDialog:Show()
end

function A:EvalVar(globalVarName)
    --if stringOrObjToEval ~= nil then debugDialog:SetCodeTextContent(optionalLabel) end
    debugDialog:SetCodeText(globalVarName)
    debugDialog:SetContent(pformat(getglobal(globalVarName)))
    local label = format('Global variable name: %s', globalVarName)
    debugDialog:SetStatusText(label)
    debugDialog:Show()
end

function A:EvalObject(o, varName, _isGlobal)
    local isGlobal = _isGlobal or false
    local codeText = ''
    local localityLabel = 'Local'
    if isGlobal then
        codeText = varName
        localityLabel = 'Global'
    end
    debugDialog:SetCodeText(codeText)
    debugDialog:SetContent(pformat(o))
    local label = format('%s variable name: %s', localityLabel, varName)
    debugDialog:SetStatusText(label)
    debugDialog:Show()
end

function A:Version()
    self:Printf("DevTools Version: %s", "1.0")
    self:Print("")
end

function A:Help()
    A:Version()
    local ftext = '  %-30s - %s'
    print("Available commands:")
    print(format(ftext, "help", "show this help text"))
    print(format(ftext, "config", "open config UI"))
    print(format(ftext, "profile", "show current profile data"))
    print(' ')
    print("Other commands:")
    print(format("/devtc    - %s", "open config UI"))
    print(format("/devtp   - %s", "show current profile"))
end

function A:RegisterKeyBindings()
    --SetBindingClick("SHIFT-T", self:Info())
    --SetBindingClick("SHIFT-F1", BoxerButton3:GetName())
    --SetBindingClick("ALT-CTRL-F1", BoxerButton1:GetName())

    -- Warning: Replaces F5 keybinding in Wow Config
    -- SetBindingClick("F5", BoxerButton3:GetName())
    -- TODO: Configure Button 1 to be the Boxer Follow Button (or create an invisible one)
    --SetBindingClick("SHIFT-R", BoxerButton1:GetName())
end

function A:OnProfileChanged()
    self:ConfirmReloadUI()
end

function A:ConfirmReloadUI()
    if IsShiftKeyDown() then
        ReloadUI()
        return
    end
    ShowReloadUIConfirmation()
end

function A:OpenConfig(_)
    ACECFGD:Open(AddonDetails.name)
end

function A:OnUpdate()
    self:log('OnUpdate called...')
end

-- AceAddon Hook
--function A:OnEnable() self:log('OnEnable...') end
-- AceAddon Hook
--function A:OnDisable() self:log('OnDisable...') end

function A:InitDbDefaults()
    local profileName = self.db:GetCurrentProfile()
    --local defaultProfile = P:CreateDefaultProfile(profileName)
    --local defaults = { profile =  defaultProfile }
    --self.db:RegisterDefaults(defaults)
    self.profile = self.db.profile
    --if table.isEmpty(ABP_PLUS_DB.profiles[profileName]) then
    --    ABP_PLUS_DB.profiles[profileName] = defaultProfile
end

function A:GetCurrentProfileData() return self.profile end

function A:OnInitialize()
    -- Set up our database
    self.db = ACEDB:New(Constants.DB_NAME)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self:InitDbDefaults()

    debugDialog = self:CreateDebugPopupDialog()
    ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, debugDialog.frame)

    local options = C:GetOptions()
    -- Register options table and slash command
    ACECFG:RegisterOptionsTable(ADDON_NAME, options, { "abp_options" })
    --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
    ACECFGD:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

    -- Get the option table for profiles
    options.args.profiles = ACEDBO:GetOptionsTable(self.db)

    self:RegisterSlashCommands()
    self:RegisterKeyBindings()

    --macroIcons = self:FetchMacroIcons()
    C:OnAfterInitialize{ profile = self.db.profile }
end

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

function A:RegisterSlashCommands()
    self:RegisterChatCommand("devtc", "OpenConfig")
    self:RegisterChatCommand("devtp", "Handle_SlashCommand_ShowProfile")
    self:RegisterChatCommand("devt", "Handle_SlashCommands")
end

function A:Handle_SlashCommands(input)
    local args = ToTable(input)
    local cmd = args[1] or ''
    if String.IsBlank(cmd) then return A:Help() end
    if 'config' == cmd then return A:OpenConfig() end
    if 'profile' == cmd then return A:ShowDebugDialogCurrentProfile() end
    A:Help()
end

function A:Handle_SlashCommand_ShowProfile() A:ShowDebugDialogCurrentProfile() end

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

function A.BINDING_DEVT_OPTIONS_DLG() A:OpenConfig() end

function A.BINDING_DEVT_DEBUG_DLG() A:ShowDebugDialog() end

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

function A.OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...

    --for _, module in ipairs(libModules) do module:OnAddonLoaded() end
    local prefix = format(ADDON_PREFIX, '')
    --A:log('isLogin: %s, isReload: %s', tostring(isLogin), tostring(isReload))
    if not isLogin then return end
    A:log('%s.%s initialized', MAJOR, MINOR)

    --print(format("%s: %s.%s initialized", prefix, MAJOR, MINOR))
    local cprefix = format('|cfffc4e03%s|r', '/devt')
    print(format('%s: Available commands: ' .. cprefix, prefix))
    print(format('%s: More at https://kapresoft.com/wow-addon-devtools', prefix))

    --local helper = DEVT_ObjectFactory('Helper', { hello = 'there' })
    --helper:log('Helper value: %s', helper.hello)
end

---@type DevTools
DEVT = A

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
local frame = CreateFrame("Frame", Constants.AddonDetails.name .. "Frame", UIParent)
frame:SetScript("OnEvent", DEVT.OnAddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
