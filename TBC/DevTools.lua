local __addonDef = function(
        Constants, ObjectFactory,
        LibStub, ACELIB, C, PrettyPrint, table,
        StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown)

    local AddonDetails = Constants.AddonDetails
    local ADDON_NAME = AddonDetails.name
    local ADDON_PREFIX = AddonDetails.prefix
    local unpack = table.unpackIt
    local format, tinsert, pformat = string.format, table.insert, PrettyPrint.pformat
    local tostring, type = tostring, type

    local ACEDB, ACEDBO, ACECFG, ACECFGD = unpack(ACELIB:GetAddonAceLibs())


    local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVT_DebugDialog"
    local MAJOR, MINOR = AddonDetails.name .. '-1.0', 1 -- Bump minor on changes

    local A = ObjectFactory:NewAddon()
    if not A then return end

    --local macroIcons = nil
    local debugDialog = nil

    function A:RegisterSlashCommands()
        self:RegisterChatCommand("devt", "OpenConfig")
        -- self:RegisterChatCommand("cv", "SlashCommand_CheckVariable")
    end

    --A.categoryCache = {}

    function A:CreateDebugPopupDialog()
        local AceGUI = ACELIB:GetAceGUI()
        local frame = AceGUI:Create("Frame")
        -- The following makes the "Escape" close the window
        --_G[DEBUG_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
        --tinsert(UISpecialFrames, DEBUG_DIALOG_GLOBAL_FRAME_NAME)
        Constants:ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, frame)

        frame:SetTitle("Debug Frame")
        frame:SetStatusText('')
        frame:SetCallback("OnClose", function(widget)
            widget:SetTextContent('')
            widget:SetStatusText('')
        end)
        frame:SetLayout("Flow")
        frame:SetCallback("OnShow", function(widget, event)
            frame:EnableAcceptButton()
        end)
        --frame:SetWidth(800)

        local inlineGroup = AceGUI:Create("InlineGroup")
        --inlineGroup:SetTitle("Evaluate LUA Variable")
        inlineGroup:SetLayout("List")
        inlineGroup:SetFullWidth(true)
        frame:AddChild(inlineGroup)

        local codeEditBox = AceGUI:Create("MultiLineEditBox")
        codeEditBox:SetLabel('')
        codeEditBox:SetFullWidth(true)
        codeEditBox:SetHeight(100)
        codeEditBox:SetText(self.profile.last_eval or '')
        codeEditBox:SetCallback("OnEnterPressed", function(widget, event, text)
            if DEVT_String.IsBlank(text) then return end
            self.profile.last_eval = text
            local includeFn = frame:IsShowFunctions()
            local baseOptions = 'show_metatable=true, depth_limit=true'
            local pre = format('PrettyPrint.setup({ show_function=%s, %s }); ',
                    tostring(includeFn), baseOptions)
            local evalCode = pre .. 'return PrettyPrint.pformat(%s)'
            print(format('%s Code to eval: %s', Constants.AddonDetails.prefix, evalCode))
            local cmd = format(evalCode , text)
            local func, errorMessage = loadstring(cmd, "Eval-Variable")
            frame:SetStatusText(errorMessage)
            local val = func()
            --print('val:', val)
            frame:SetTextContent(val)
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
        local multiEditbox = AceGUI:Create("MultiLineEditBox")
        multiEditbox:SetLabel('Output:')
        multiEditbox:SetText('')
        multiEditbox:SetFullWidth(true)
        multiEditbox:SetFullHeight(true)
        multiEditbox.button:Hide()
        frame:AddChild(multiEditbox)
        frame.multiEditbox = multiEditbox

        function frame:SetTextContent(text)
            self.multiEditbox:SetText(text)
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

        frame:Hide()
        return frame
    end

    function A:HandleSlashCommand_ShowProfile()
        PrettyPrint.setup({ show_all = true } )
        local profileData = self:GetCurrentProfileData()
        local strVal = PrettyPrint.pformat(profileData)
        local profileName = self.db:GetCurrentProfile()
        debugDialog:SetTextContent(strVal)
        debugDialog:SetStatusText(format('Current Profile Data for [%s]', profileName))
        debugDialog:Show()
    end

    function A:ShowDebugDialog(obj, optionalLabel)
        local text = nil
        local label = optionalLabel or ''
        if obj ~= nil then
            if type(obj) == 'table' then
                text = PrettyPrint.pformat(obj)
            else
                text = tostring(obj)
            end
            debugDialog:SetTextContent(text)
        end
        debugDialog:SetStatusText(label)
        debugDialog:Show()
    end

    function A:DBG(obj, optionalLabel) self:ShowDebugDialog(obj, optionalLabel) end
    function A:TI()
        -- local macroIcons = GetMacroItemIcons()
        -- self:ShowTextureDialog(macroIcons, 'Macro Icons')
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
    function A:OnEnable()
        self:log('OnEnable...')
    end

    -- AceAddon Hook
    function A:OnDisable()
        self:log('OnDisable...')
    end

    function A:InitDbDefaults()
        local profileName = self.db:GetCurrentProfile()
        --local defaultProfile = P:CreateDefaultProfile(profileName)
        --local defaults = { profile =  defaultProfile }
        --self.db:RegisterDefaults(defaults)
        self.profile = self.db.profile
        --if table.isEmpty(ABP_PLUS_DB.profiles[profileName]) then
        --    ABP_PLUS_DB.profiles[profileName] = defaultProfile
    end

    function A:GetCurrentProfileData()
        return self.profile
    end

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

    -- ##################################################################################

    function A.BINDING_DEVT_OPTIONS_DLG()
        A:OpenConfig()
    end

    function A.BINDING_DEVT_DEBUG_DLG()
        local profileName = A.db:GetCurrentProfile()
        --A:ShowDebugDialog(A.db.profile, format('Current Profile: %s', profileName))
        A:ShowDebugDialog()
    end

    function A.AddonLoaded(frame, event)
        --for _, module in ipairs(libModules) do module:OnAddonLoaded() end
        local prefix = format(ADDON_PREFIX, '')
        A:log('%s.%s initialized', MAJOR, MINOR)
        --print(format("%s: %s.%s initialized", prefix, MAJOR, MINOR))
        print(format('%s: Available commands: /devt to open config dialog.', prefix))
        print(format('%s: More at https://kapresoft.com/wow-addon-devtools', prefix))

        --local helper = DEVT_ObjectFactory('Helper', { hello = 'there' })
        --helper:log('Helper value: %s', helper.hello)
    end

    return A
end

local Constants = DEVT_Constants
DEVT = __addonDef(
        Constants, DEVT_ObjectFactory,
        LibStub, DEVT_AceLibFactory, DEVT_Config, DEVT_PrettyPrint, DEVT_Table,
        StaticPopupDialogs, StaticPopup_Show, ReloadUI, IsShiftKeyDown)

local frame = CreateFrame("Frame", Constants.AddonDetails.name .. "Frame", UIParent)
frame:SetScript("OnEvent", DEVT.AddonLoaded)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")


