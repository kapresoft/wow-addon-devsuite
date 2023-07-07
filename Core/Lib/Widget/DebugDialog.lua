--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local loadstring = loadstring
local tinsert = table.insert

--- @type Namespace
local _, ns = ...
local O, M, LibStub, Ace, pformat = ns.O, ns.M, ns.O.LibStub, ns.O.AceLibrary, ns.pformat

local Table, String = O.Table, O.String
local AceGUI = Ace.AceGUI
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVS_DebugDialog"
local FUNCTION_TEMPLATE = 'function()\n\n  return \"hello\"\n\nend'
local IsBlank, IsNotBlank = String.IsBlank, String.IsNotBlank
local EqualsIgnoreCase = String.EqualsIgnoreCase
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
---@class DebugDialog : DialogWidgetMixin
local D = LibStub:NewLibrary(M.DebugDialog)
O.Mixin:Mixin(D, O.DialogWidgetMixin)
D.mt.__call = function (_, ...) return D:Constructor(...) end
local p = D.logger()

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param w DebugDialogWidget
local function OnClose(w)
    w:SetCodeText('')
    w:SetContent('')
    w:SetStatusText('')
end

---@param name string
---@return Profile_Config_Item
---@param items table<number, Profile_Config_Item>
local function findItem(name, items)
    for i, item in ipairs(items) do
        if EqualsIgnoreCase(name, item.name) then return item end
    end
end

---@param w DebugDialogWidget
local function OnShow(w)
    w:EnableAcceptButtonDelayed()
    --w:SetCodeText(w.profile.last_eval or FUNCTION_TEMPLATE)
    local profile = ns:profile()
    local text
    local items = profile.debugDialog.items
    if profile.last_eval then
        local item = items[profile.last_eval]
        if item then text = item.value end
        w.histDropdown:SetValue(profile.last_eval)
    end
    if not text then
        local sel = w.histDropdown:GetValue()
        local item = findItem(sel, items)
        if item then text = item.value end
    end
    w:SetCodeText(text)
end

---@type DebugDialogWidget
local function CodeEditBox_OnEditFocusGained(w) w:EnableAcceptButton() end

---@param w DebugDialogWidget
local function CodeEditBox_OnEnterPressed(w, literalVarName)
    if IsBlank(literalVarName) then return end
    local scriptToEval = ns.sformat([[ return %s ]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    if errorMessage then
        w.f:SetStatusText(errorMessage)
        return
    end
    local env = { pformat = ns.pformat, sformat = ns.sformat }
    env.mt = { __index = _G }
    setmetatable(env, env.mt)
    setfenv(func, env)

    w.f:SetStatusText(errorMessage)
    local val = func()

    if type(val) == 'function' then
        local status, error = pcall(function() val = val() end)
        if not status then
            val = nil
            w:SetStatusText(string.format("ERROR: %s", tostring(error)))
            w:SetContent('')
            return
        end

        local replace = O.String.replace

        if 'table' == type(val) and val.__tostring then
            local text = ''
            for i, v in ipairs(val) do
                v = replace(v, 'function ', 'function A:')
                text = text .. v .. ' end;'
            end
            w:SetContent(text)
            return
        end

    end
    w:SetContent(val)
end

---@param w DebugDialogWidget
local function HistDropDown_OnValueChanged(w, selectedValue)
    local profile = ns:profile()
    profile.last_eval = selectedValue
    local items = profile.debugDialog.items
    local selItem = findItem(selectedValue, items)
    if not selItem then return end
    w:SetCodeText(selItem.value)
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

    -- /run DEVS.profile.debugDialog.items = nil
    -- /dump DEVS.profile.debugDialog.items
    function w:SaveHistory()
        local codeText = w.codeEditBox:GetText()
        if IsBlank(codeText) then return end
        local selectedKey = w.histDropdown:GetValue()
        if IsBlank(selectedKey) then return end

        local items = ns:profile().debugDialog.items
        local item = findItem(selectedKey, items)
        if item then item.value = codeText; return end
        p:log('SaveHistory::Error: failed to save history.')
    end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
---@return DebugDialogWidget
---@param profile Profile_Config
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

    local label = AceGUI:Create("Label")
    label:SetFullWidth(true)
    label:SetText(' Evaluate a variable or return a function')
    frame:AddChild(label)

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
    --- @type table<number, Profile_Config_Item>
    local orderKeys = {}
    local list = {}

    for i, item in ipairs(profile.debugDialog.items) do
        tinsert(orderKeys, item.name)
        list[item.name] = item.name
    end

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

