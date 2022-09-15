local LibStub, M, LogFactory, G = DEVT_LibGlobals:LibPack_NewLibrary()
local Table, String = G:LibPack_Utils()
local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVT_DebugDialog"
local FUNCTION_TEMPLATE = 'function()\n\n  return \"hello\"\n\nend'
local IsBlank = String.IsBlank
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class DebugDialog : DialogWidgetMixin
local D = LibStub:NewLibrary(M.DebugDialog)
p = LogFactory(M.DebugDialog)
--_L.mt.__index = {
--    ['hi'] = function() p:log('hi') end
--}
--setmetatable(L, L.mt)

---@type DialogWidgetMixin
G:Mixin(D, LibStub:GetMixin(M.DialogWidgetMixin))
D.mt.__call = function (_, ...) return D:Constructor(...) end


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param w DebugDialogWidget
local function OnClose(w)
    local fw = w.frameWidget
    fw:SetCodeText('')
    fw:SetContent('')
    fw:SetStatusText('')
end

---@param w DebugDialogWidget
local function OnShow(w)
    local fw = w.frameWidget
    C_Timer.After(0.1, function() w:EnableAcceptButton()  end)
    fw:SetCodeText(w.profile.last_eval or FUNCTION_TEMPLATE)
end

---@param w DebugDialogWidget
local function widgetMethods(w)
    function w:Show() self.f:Show() end
    function w:GetTitle() return self.f.titletext:GetText() end
    function w:EnableAcceptButton() self.f.codeEditBox.button:Enable() end
    function w:IsShowFunctions() return self.showFnEditBox:GetValue() end

    function w:Submit() self.codeEditBox.button:Click() end
    function w:SetIcon(iconPathOrId)
        if not iconPathOrId then return end
        self.iconFrame:SetImage(iconPathOrId)
    end
    function w:HasCodeContent()
        local codeValue = self.codeEditBox:GetText()
        return IsNotBlank(codeValue)
    end
end

---@type DebugDialogWidget
local function CodeEditBox_OnEditFocusGained(w) w:EnableAcceptButton() end

---@param widget DebugDialogWidget
local function CodeEditBox_OnEnterPressed(widget, literalVarName)
    if IsBlank(literalVarName) then return end
    widget.profile.last_eval = literalVarName
    local includeFn = widget:IsShowFunctions()
    local scriptToEval = format([[ return %s]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    widget.f:SetStatusText(errorMessage)
    local val = func()
    if type(val) == 'function' then
        local status, error = pcall(function() val = val() end)
        if not status then
            val = nil
            frame:SetStatusText(string.format("ERROR: %s", tostring(error)))
        end
    end
    widget.f:SetContent(val, includeFn)
end

---@param widget DebugDialogWidget
local function RegisterCallbacks(widget)
    widget.f:SetCallback("OnClose", function() OnClose(widget)  end)
    widget.f:SetCallback("OnShow", function() OnShow(widget)  end)
    widget.codeEditBox:SetCallback("OnEditFocusGained", function() CodeEditBox_OnEditFocusGained(widget) end)
    widget.codeEditBox:SetCallback("OnEnterPressed", function(_, _, literalVarName) CodeEditBox_OnEnterPressed(widget, literalVarName) end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@return DebugDialogWidget
---@param profile ProfileDb
function D:Constructor(profile)
    ---@class DebugDialogAceFrameWidget
    local frame = AceGUI:Create("Frame")

    -- The following makes the "Escape" close the window
    --_G[DEBUG_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
    --tinsert(UISpecialFrames, DEBUG_DIALOG_GLOBAL_FRAME_NAME)
    self:ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, frame)

    frame:SetTitle("Debug Frame")
    frame:SetStatusText('')
    frame:SetLayout("Flow")
    frame:SetHeight(800)
    --frame:SetWidth(800)

    local inlineGroup = AceGUI:Create("InlineGroup")
    --inlineGroup:SetTitle("Evaluate LUA Variable")
    inlineGroup:SetLayout("List")
    inlineGroup:SetFullWidth(true)
    frame:AddChild(inlineGroup)

    ---@class DebugDialogMultiLineEditBox
    local codeEditBox = AceGUI:Create("MultiLineEditBox")
    frame.codeEditBox = codeEditBox
    codeEditBox:SetLabel('')
    codeEditBox:SetFullWidth(true)
    codeEditBox:SetHeight(200)
    codeEditBox:SetText('')


    local showFnEditBox = AceGUI:Create("CheckBox")
    showFnEditBox:SetLabel("Show Functions")
    showFnEditBox:SetCallback("OnValueChanged", function(_, _, checkedState)
        codeEditBox.button:Enable()
    end)
    -- checked by default
    showFnEditBox:SetValue(true)
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
    ---@param showFunctions boolean
    function frame:SetContent(o, showFunctions)
        local text = nil
        if type(o) == 'text' then text = '' end
        if showFunctions then text = pformat:A():pformat(o) else text = pformat(o) end
        frame.contentEditBox:SetText(text)
    end


    frame:Hide()

    ---@class DebugDialogWidget
    local widget = {
        profile = profile,
        f = frame,
        ---@deprecated
        frameWidget = frame,
        codeEditBox = codeEditBox,
        showFnEditBox = showFnEditBox,
    }
    frame.widget = widget
    widgetMethods(widget)
    D.frame = frame

    RegisterCallbacks(widget)

    return widget;
end




DD = D