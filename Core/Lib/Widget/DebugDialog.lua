--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local loadstring = loadstring
local tinsert = table.insert

--- @type Namespace
local ns = select(2, ...)
local O, M = ns.O, ns.M

local ERROR_STATUS = 'ERROR'
local ERROR_COLOR = '|cffFF7D83'

local String, AceGUI = ns:String(), ns:AceLibrary().AceGUI
local DEBUG_DIALOG_GLOBAL_FRAME_NAME = "DEVS_DebugDialog"
local IsBlank, IsNotBlank = String.IsBlank, String.IsNotBlank
local EqualsIgnoreCase = String.EqualsIgnoreCase
--[[-----------------------------------------------------------------------------
New Library
-------------------------------------------------------------------------------]]
local libName = M.DebugDialog()
--- @class DebugDialog : DialogWidgetMixin
local D = ns:NewLib(libName); ns:K():Mixin(D, O.DialogWidgetMixin)
local p = ns:CreateDefaultLogger(libName)
local pformat = ns.pformat

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

local function ClampDialogSize(desiredW, desiredH)
  local uiW, uiH = UIParent:GetWidth(), UIParent:GetHeight()
  if not uiW or not uiH then
    return desiredW, desiredH
  end
  
  local marginW = 20
  local marginH = 20
  
  local maxW = uiW - marginW
  local maxH = uiH - marginH
  
  -- only shrink if exceeding available space
  if desiredW > maxW then desiredW = maxW end
  if desiredH > maxH then desiredH = maxH end
  
  return desiredW, desiredH
end

---@param w DebugDialogWidget
local function DebugDialogWidget_AdjustSize(w)
  if w.__sizeAdjusted then return end
  w.__sizeAdjusted = true
  
  local settings = ns:g().debug_dialog
  
  local desiredW = settings.width or w.f:GetWidth()
  local desiredH = settings.height or w.f:GetHeight()
  local width, height = ClampDialogSize(desiredW, desiredH)
  w.a:SetWidth(width)
  w.a:SetHeight(height)
end

--- @param w DebugDialogWidget
local function OnShow(w)
  DebugDialogWidget_AdjustSize(w)
  
  w:EnableAcceptButtonDelayed()
  --w:SetCodeText(w.profile.last_eval or FUNCTION_TEMPLATE)
  local profile = ns:profile()
  local text
  local items   = profile.debugDialog.items
  if profile.last_eval then
    local item = items[profile.last_eval]
    if item then text = item.value end
    w.histDropdown:SetValue(profile.last_eval)
  end
  if not text then
    local sel  = w.histDropdown:GetValue()
    local item = findItem(sel, items)
    if item then text = item.value end
  end
  w:SetCodeText(text)
  
  local s_anchor = ns:g().debug_dialog.anchor
  local anchor = CreateAnchor(s_anchor.point, s_anchor.relativeTo, s_anchor.relativePoint, s_anchor.x, s_anchor.y)
  anchor:SetPoint(w.f, true)
end

---@type DebugDialogWidget
local function CodeEditBox_OnEditFocusGained(w) w:EnableAcceptButton() end


---@param w DebugDialogWidget
local function CodeEditBox_OnEnterPressed(w, literalVarName)
    -- todo: new checkbox to clear output every time
    -- ns:a().BINDING_DEVS_CLEAR_DEBUG_CONSOLE()

    if IsBlank(literalVarName) then return end
  
    local scriptToEval = ns.sformat([[ return %s ]], literalVarName)
    local func, errorMessage = loadstring(scriptToEval, "Eval-Variable")
    if errorMessage then
        w:SaveHistory()
        w:SetStatusText(ERROR_STATUS)
        w:SetErrorContent(errorMessage)
        return
    end

    local env = { pformat = ns.pformat, sformat = ns.sformat }
    env.mt = { __index = _G }
    setmetatable(env, env.mt)
    setfenv(func, env)

    w.a:SetStatusText(errorMessage)

    local val = func()

    if type(val) == 'function' then
        local status, error = pcall(function() val = val() end)
        if not status then
            val = nil
            w:SaveHistory()
            w:SetStatusText("ERROR")
            w:SetErrorContent(error)
            return
        end

        local replace = ns:String().replace

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

--- @param w DebugDialogWidget
local function ShowFnEditBox_OnValueChanged(w, checkedState) w.codeEditBox.button:Enable() end

--- @param frame FrameObj
local function Frame_OnSizeChanged(frame)
  local resizeTimer
  --- @param self FrameObj
  frame:HookScript("OnSizeChanged", function(self)
    if resizeTimer then resizeTimer:Cancel() end
    local s = ns:g().debug_dialog

    resizeTimer = C_Timer.NewTimer(0.1, function()
      local curW, curH = self:GetSize()
      local newW, newH = ClampDialogSize(curW, curH)
      -- Only correct if overflowed
      if newW ~= curW or newH ~= curH then
        self:StopMovingOrSizing()
        self:SetSize(newW, newH)
      end
      s.width, s.height  = newW, newH
    end)
  end)
end

--- Resizes dialog if overflowed size of wow window
--- @param self FrameObj
local function Frame_UpdateSize(self)
  local s = ns:g().debug_dialog
  local curW, curH = self:GetSize()
  local newW, newH = ClampDialogSize(curW, curH)
  -- Only correct if overflowed
  if newW ~= curW or newH ~= curH then self:SetSize(newW, newH) end
  s.width, s.height  = newW, newH
end

--- Save Frame anchor and size
--- @param self FrameObj
local function Frame_SaveDialogAnchorHook(self)
  Frame_UpdateSize(self)
  
  --- @type AnchorMixin
  local anchor = AnchorUtil.CreateAnchorFromPoint(self, 1)
  if not anchor then return end
  
  local point, relativeTo, relativePoint, x, y = anchor:Get()
  local s = ns:g().debug_dialog
  s.anchor = { point = point, relativeTo = relativeTo,
    relativePoint = relativePoint, x = x, y = y }
end

--- @param w DebugDialogWidget
local function RegisterCallbacks(w)
  w.a:SetCallback("OnClose", function() OnClose(w) end)
  w.a:SetCallback("OnShow", function() OnShow(w) end)
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
  hooksecurefunc(w.f, "StopMovingOrSizing", Frame_SaveDialogAnchorHook)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @param w DebugDialogWidget
local function widgetMethods(w)
  function w:Show() w.a:Show() end
  function w:GetTitle() return w.a.titletext:GetText() end
  function w:EnableAcceptButtonDelayed() C_Timer.After(0.1, function() self:EnableAcceptButton() end) end
  function w:EnableAcceptButton() w.a.codeEditBox.button:Enable() end
  function w:IsShowFunctions() return self.showFnEditBox:GetValue() end
  function w:IsShown() return self.f:IsShown() end
  
  function w:SetCodeText(text) self.codeEditBox:SetText(text or '') end
  function w:SetStatusText(text) w.a:SetStatusText(text) end
  function w:ClearContent() self.contentEditBox:SetText('') end
  function w:SetContent(content)
    local text
    if type(content) == 'string' then text = '' end
    if #tostring(content) > 0 then
      if self:IsShowFunctions() then
        text = pformat:A():pformat(content)
      else
        text = pformat(content)
      end
    end
    self.contentEditBox:SetText(text)
    w:SaveHistory()
  end
  
  --- Splits a string at the first ':' character (nil-safe)
  --- @param s string|nil
  --- @return string|nil string|nil
  function w:SplitFirstColon(s)
    if type(s) ~= "string" then
      return nil, nil
    end
    
    local left, right = s:match("^(.-):(.*)$")
    return left, right
  end
  
  --- @param text string
  function w:SetErrorContent(text)
    self:SetStatusText(ERROR_STATUS)
    local argType = type(text)
    assert(argType == 'string', ('Expected type[string] but got [%s] instead.'):format(argType))
    --if not text then self:ClearContent(); return end
    if #text <= 0 then return end
    
    local source, msg = self:SplitFirstColon(text)
    if source and msg then
      local msgp = ("%s%s|r|n%s"):format(ERROR_COLOR, source, msg)
      self.contentEditBox:SetText(msgp)
    else
      self.contentEditBox:SetText(("%s%s|r"):format(ERROR_COLOR, text))
    end
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
    local item  = findItem(selectedKey, items)
    if item then
      item.value = codeText;
      return
    end
    --p:log('SaveHistory::Error: failed to save history.')
  end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
--- @return DebugDialogWidget
function D:New()
  
  --- @class DebugDialogAceFrameWidget : AceGUIWidget
  --- @field frame FrameObj
  --- @field sizer_se FrameObj
  --- @field titletext FontStringObj
  --- @field titlebg TextureObj
  local dialog  = AceGUI:Create("Frame")
  
  -- so we don't resize to larger than the screen
  dialog.frame:SetClampedToScreen(true)
  dialog.sizer_se:SetClampedToScreen(true)
  
  local profile = ns:profile()
  
  -- The following makes the "Escape" close the window
  --_G[DEBUG_DIALOG_GLOBAL_FRAME_NAME] = frame.frame
  --tinsert(UISpecialFrames, DEBUG_DIALOG_GLOBAL_FRAME_NAME)
  self:ConfigureFrameToCloseOnEscapeKey(DEBUG_DIALOG_GLOBAL_FRAME_NAME, dialog)
  
  dialog:SetTitle("Debug Frame")
  dialog:SetStatusText('')
  dialog:SetLayout("Flow")
  dialog:SetHeight(800)
  
  local settings = ns:g().debug_dialog
  local f        = dialog.frame
  if f.SetResizeBounds then -- WoW 10.0
    f:SetResizeBounds(400, 550)
  else
    f:SetMinResize(400, 550)
  end
  dialog:SetWidth(settings.width)
  dialog:SetHeight(settings.height)
  
  local label = AceGUI:Create("Label")
  label:SetFullWidth(true)
  label:SetText(' Evaluate a variable or return a function')
  dialog:AddChild(label)
  
  local inlineGroup = AceGUI:Create("InlineGroup")
  inlineGroup:SetLayout("List")
  inlineGroup:SetFullWidth(true)
  dialog:AddChild(inlineGroup)
  
  --- @class DebugDialog_Code_MultiLineEditBox
  local codeEditBox = AceGUI:Create("MultiLineEditBox")
  dialog.codeEditBox = codeEditBox
  codeEditBox:SetLabel('')
  codeEditBox:SetFullWidth(true)
  codeEditBox:SetHeight(200)
  codeEditBox:SetText('')
  
  --- @class DebugDialog_ShowFunction_CheckBox
  local showFnEditBox = AceGUI:Create("CheckBox")
  showFnEditBox:SetLabel("Show Functions")
  -- checked by default
  showFnEditBox:SetValue(true)
  
  --- @class DebugDialog_History_Dropdown
  local histDropdown = AceGUI:Create("Dropdown")
  histDropdown:SetLabel("History:")
  --- @type table<number, Profile_Config_Item>
  local orderKeys = {}
  local list      = {}
  
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
  
  --- @class DebugDialog_Content_MultiLineEditBox
  local contentEditBox = AceGUI:Create("MultiLineEditBox")
  contentEditBox:SetLabel('Output:')
  contentEditBox:SetText('')
  contentEditBox:SetFullWidth(true)
  contentEditBox:SetFullHeight(true)
  contentEditBox.button:Hide()
  dialog:AddChild(contentEditBox)
  dialog.contentEditBox = contentEditBox
  
  dialog:Hide()
  
  --- @class DebugDialogWidget
  --- @field f FrameObj
  --- @field a DebugDialogAceFrameWidget
  --- @field private __sizeAdjusted boolean
  local widget  = {
    profile        = profile,
    a              = dialog,
    f              = dialog.frame,
    codeEditBox    = codeEditBox,
    contentEditBox = contentEditBox,
    showFnEditBox  = showFnEditBox,
    histDropdown   = histDropdown,
  }
  dialog.widget = widget
  widgetMethods(widget)
  RegisterCallbacks(widget)
  
  return widget;
end

