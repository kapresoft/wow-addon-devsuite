local LibStub, M, LogFactory, G = DEVT_LibGlobals:LibPack_NewLibrary()
local Table, String = G:LibPack_Utils()
local AceEvent, AceGUI, AceHook = G:LibPack_AceLibrary()
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVT_DebugDialog"
local FUNCTION_TEMPLATE = 'function()\n\n  return \"hello\"\n\nend'
local IsBlank, IsNotBlank = String.IsBlank, String.IsNotBlank
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class DebugDialog : DialogWidgetMixin
local D = LibStub:NewLibrary(M.DebugDialog)
local p = LogFactory(M.DebugDialog)
---@type DialogWidgetMixin
G:Mixin(D, LibStub:GetMixin(M.DialogWidgetMixin))
D.mt.__call = function (_, ...) return D:Constructor(...) end


--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param w DebugDialogWidget
local function OnClose(w)
    w:SetCodeText('')
    w:SetContent('')
    w:SetStatusText('')
end

---@param w DebugDialogWidget
local function OnShow(w)
    w:EnableAcceptButtonDelayed()
    --w:SetCodeText(w.profile.last_eval or FUNCTION_TEMPLATE)
    local text
    if w.profile.last_eval then
        text = w.profile.debugDialog.items[w.profile.last_eval]
        w.histDropdown:SetValue(w.profile.last_eval)
    end
    if not text then
        text = w.profile.debugDialog.items[w.histDropdown:GetValue()]
    end
    w:SetCodeText(text)
end

---@type DebugDialogWidget
local function CodeEditBox_OnEditFocusGained(w) w:EnableAcceptButton() end

---@param w DebugDialogWidget
local function CodeEditBox_OnEnterPressed(w, literalVarName)
    if IsBlank(literalVarName) then return end
    local scriptToEval = format([[ return %s]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    w.f:SetStatusText(errorMessage)
    local val = func()
    if type(val) == 'function' then
        local status, error = pcall(function() val = val() end)
        if not status then
            val = nil
            w:SetStatusText(string.format("ERROR: %s", tostring(error)))
        end
    end
    w:SetContent(val)
end

---@param w DebugDialogWidget
local function HistDropDown_OnValueChanged(w, selectedIndex)
    w.profile.last_eval = w.histDropdown:GetValue()
    local val = w.profile.debugDialog.items[selectedIndex]
    w:SetCodeText(val)
    w:EnableAcceptButtonDelayed()
end

---@param w DebugDialogWidget
local function ShowFnEditBox_OnValueChanged(w, checkedState) w.codeEditBox.button:Enable() end


---@param w DebugDialogWidget
local function RegisterCallbacks(w)
    w.f:SetCallback("OnClose", function() OnClose(w)  end)
    w.f:SetCallback("OnShow", function() OnShow(w)  end)
    w.codeEditBox:SetCallback("OnEditFocusGained", function()
        CodeEditBox_OnEditFocusGained(w)
    end)
    w.codeEditBox:SetCallback("OnEnterPressed", function(fw, event, literalVarName)
        CodeEditBox_OnEnterPressed(w, literalVarName)
    end)
    w.histDropdown:SetCallback("OnValueChanged", function(fw, event, selectedIndex)
        HistDropDown_OnValueChanged(w, selectedIndex)
    end)
    w.showFnEditBox:SetCallback("OnValueChanged", function(fw, event, checkedState)
        ShowFnEditBox_OnValueChanged(w, checkedState)
    end)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
---@param w DebugDialogWidget
local function widgetMethods(w)
    function w:Show() self.f:Show() end
    function w:GetTitle() return self.f.titletext:GetText() end
    function w:EnableAcceptButtonDelayed() C_Timer.After(0.1, function() self:EnableAcceptButton()  end) end
    function w:EnableAcceptButton() self.f.codeEditBox.button:Enable() end
    function w:IsShowFunctions() return self.showFnEditBox:GetValue() end

    function w:SetCodeText(text) self.codeEditBox:SetText(text or '') end
    function w:SetStatusText(text) self.f:SetStatusText(text) end
    function w:SetContent(o)
        local text
        if type(o) == 'text' then text = '' end
        if self:IsShowFunctions() then text = pformat:A():pformat(o) else text = pformat(o) end
        self.contentEditBox:SetText(text)
        w:SaveHistory()
    end

    function w:Submit() self.codeEditBox.button:Click() end
    function w:HasCodeContent()
        local codeValue = self.codeEditBox:GetText()
        return IsNotBlank(codeValue)
    end

    -- /run DEVT.profile.debugDialog.items = nil
    -- /dump DEVT.profile.debugDialog.items
    function w:SaveHistory()
        local codeText = w.codeEditBox:GetText()
        if IsNotBlank(codeText) then
            local selectedKey = w.histDropdown:GetValue()
            w.profile.debugDialog.items[selectedKey] = codeText
        end
    end
end

--[[-----------------------------------------------------------------------------
Constructor
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
    inlineGroup:SetLayout("List")
    inlineGroup:SetFullWidth(true)
    frame:AddChild(inlineGroup)

    ---@class DebugDialog_Code_MultiLineEditBox
    local codeEditBox = AceGUI:Create("MultiLineEditBox")
    frame.codeEditBox = codeEditBox
    codeEditBox:SetLabel('')
    codeEditBox:SetFullWidth(true)
    codeEditBox:SetHeight(200)
    codeEditBox:SetText('')

    ---@class DebugDialog_ShowFunction_CheckBox
    local showFnEditBox = AceGUI:Create("CheckBox")
    showFnEditBox:SetLabel("Show Functions")
    -- checked by default
    showFnEditBox:SetValue(true)

    ---@class DebugDialog_History_Dropdown
    local histDropdown = AceGUI:Create("Dropdown")
    histDropdown:SetLabel("History:")
    local orderKeys = {}
    local list = {}
    for k,_ in pairs(profile.debugDialog.items) do
        Table.insert(orderKeys, k)
        list[k] = k
    end
    table.sort(orderKeys)
    histDropdown:SetList(list, orderKeys)
    if #orderKeys > 1 then
        histDropdown:SetValue(orderKeys[1])
    end

    inlineGroup:AddChild(showFnEditBox)
    inlineGroup:AddChild(histDropdown)
    inlineGroup:AddChild(codeEditBox)

    ---@class DebugDialog_Content_MultiLineEditBox
    local contentEditBox = AceGUI:Create("MultiLineEditBox")
    contentEditBox:SetLabel('Output:')
    contentEditBox:SetText('')
    contentEditBox:SetFullWidth(true)
    contentEditBox:SetFullHeight(true)
    contentEditBox.button:Hide()
    frame:AddChild(contentEditBox)
    frame.contentEditBox = contentEditBox

    frame:Hide()

    ---@class DebugDialogWidget
    local widget = {
        profile = profile,
        f = frame,
        ---@deprecated
        frameWidget = frame,
        codeEditBox = codeEditBox,
        contentEditBox = contentEditBox,
        showFnEditBox = showFnEditBox,
        histDropdown = histDropdown,
    }
    frame.widget = widget
    widgetMethods(widget)

    RegisterCallbacks(widget)

    return widget;
end

