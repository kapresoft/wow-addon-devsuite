--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local setglobal = setglobal

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local UISpecialFrames = UISpecialFrames
local ReloadUI, IsShiftKeyDown = ReloadUI, IsShiftKeyDown

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local LibStub, M, G = DEVT_LibGlobals:LibPack()
local Table, String, Assert, Mixin = DEVT_LibGlobals:LibPack_Utils()
---@type DebugDialog
local DebugDialog = LibStub(M.DebugDialog)
local Constants, ObjectFactory = DEVT_Constants, DEVT_ObjectFactory


local C = G:Lib_Config()
local AddonDetails = Constants.AddonDetails
local ADDON_NAME = AddonDetails.name
local ADDON_PREFIX = AddonDetails.prefix

local ACELIB = G:LibPack_AceLibFactory()
local ACEDB, ACEDBO, ACECFG, ACECFGD = G:LibPack_AceAddonLibs()

local unpack = Table.unpackIt
local print, format = print, string.format
local tostring, type = tostring, type
local IsNotBlank, ToTable = String.IsNotBlank, String.ToTable

local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVT_DebugDialog"
local MAJOR, MINOR = AddonDetails.name .. '-1.0', 1 -- Bump minor on changes

---@class DevSuite
local A = LibStub:NewAddon(G.addonName)
if not A then return end

--local p = DEVT_logger:NewLogger('DebugDialog')
local LogFactory = G:Lib_LogFactory()
local p = LogFactory()
---@type DebugDialogWidget
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
function A:GetMouseOver()
    p:log('GetMouseOver: entering...')
end

function A:ShowDebugDialogCurrentProfile()
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
    self:Printf("DevSuite Version: %s", "1.0")
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

    ---@class ProfileDb
    local defaultProfile = {
        ['enabled'] = true,
        ['debugDialog'] = {
            maxHistory = 9,
            items = { }
        },
    }
    local defaults = { profile =  defaultProfile }
    self.db:RegisterDefaults(defaults)
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

    --debugDialog = self:CreateDebugPopupDialog()
    --ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, debugDialog.frame)

    local options = C:GetOptions()
    -- Register options table and slash command
    ACECFG:RegisterOptionsTable(ADDON_NAME, options, { "devt_options" })
    --cfgDialog:SetDefaultSize(ADDON_NAME, 800, 500)
    ACECFGD:AddToBlizOptions(ADDON_NAME, ADDON_NAME)

    -- Get the option table for profiles
    options.args.profiles = ACEDBO:GetOptionsTable(self.db)

    self:RegisterSlashCommands()
    self:RegisterKeyBindings()

    --macroIcons = self:FetchMacroIcons()
    C:OnAfterInitialize{ profile = self.db.profile }
    debugDialog = DebugDialog(self.profile)
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

function A.BINDING_DEVT_DEBUG_DLG() debugDialog:Show() end
function A.BINDING_DEVT_GET_DETAILS_ON_MOUSEOVER() A:GetMouseOver() end

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------

function A.OnAddonLoaded(frame, event, ...)
    local isLogin, isReload = ...
    --for _, module in ipairs(libModules) do module:OnAddonLoaded() end
    local prefix = format(ADDON_PREFIX, '')
    if not isLogin then return end
    p:log('%s.%s initialized', MAJOR, MINOR)

    local cprefix = format('|cfffc4e03%s|r', '/devt')
    print(format('%s: Available commands: ' .. cprefix, prefix))
    print(format('%s: More at https://kapresoft.com/wow-addon-devsuite', prefix))
end

---@type DevSuite
DEVT = A

-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
-- ## -------------------------------------------------------------------------
local frame = CreateFrame("Frame", Constants.AddonDetails.name .. "Frame", UIParent)
frame:SetScript("OnEvent", DEVT.OnAddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
