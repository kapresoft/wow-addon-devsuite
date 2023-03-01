--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...
local pformat = ns.pformat
local O, LibStub = ns.O, ns.LibStub
local AceGUI = O.AceLibrary.AceGUI
local LuaEvaluator = ns:KO().LuaEvaluator

local L = LibStub:NewLibrary('PopupDebugDialog')
--- @type LoggerTemplate
local p = L:GetLogger()
local FRAME_NAME = ns.name .. 'DebugDialog'
local FRAME_TITLE = ns.name .. ' Dialog'

local function ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
    local frame = frameInstance
    if frameInstance.frame then frame = frameInstance.frame end
    setglobal(frameName, frame)
    table.insert(UISpecialFrames, frameName)
end

--- @return PopupDebugDialogFrame
local function CreateDialog()
    --- @class PopupDebugDialogFrame
    local frame = AceGUI:Create("Frame")
    -- The following makes the "Escape" close the window
    ConfigureFrameToCloseOnEscapeKey(FRAME_NAME, frame)
    frame:SetTitle(FRAME_TITLE)
    frame:SetStatusText('')
    frame:SetCallback("OnClose", function(widget)
        widget:SetTextContent('')
        widget:SetStatusText('')
    end)
    frame:SetLayout("Flow")
    --frame:SetWidth(800)

    -- ABP_PrettyPrint.format(obj)
    local editbox = AceGUI:Create("MultiLineEditBox")
    editbox:SetLabel('')
    editbox:SetText('')
    --editbox:SetNumLines(20)
    editbox:SetMaxLetters(0)
    editbox:SetFullWidth(true)
    editbox:SetFullHeight(true)
    editbox.button:Hide()
    frame:AddChild(editbox)
    frame.editBox = editbox

    function frame:SetTextContent(text)
        self.editBox:SetText(text)
    end
    function frame:SetIcon(iconPathOrId)
        if not iconPathOrId then return end
        self.iconFrame:SetImage(iconPathOrId)
    end

    --- @param str string
    function frame:EvalThenShow(str)
        local strVal = LuaEvaluator:Eval(str)
        self:SetTextContent(pformat:A()(strVal))
        self:SetStatusText(sformat('Var: %s type: %s', str, type(strVal)))
        self:Show()
    end
    --- @param o table
    --- @param objectName string
    function frame:EvalObjectThenShow(o, objectName)
        --local strVal = pformat:A()(o)
        local options = { use_newline = false, wrap_string = true, indent_size=2, sort_keys=false,
                          show_metatable=false, show_function = false, show_string = true,
                          show_userdata = false,
                          level_widthx=120, depth_limit = false }
        local strVal = pformat(o, options)
        objectName = objectName or tostring(o)
        self:SetTextContent(strVal)
        self:SetStatusText(sformat('Showing variable value for [%s]', objectName))
        self:Show()
    end

    frame:Hide()
    return frame
end


--- @return PopupDebugDialog
function L:Constructor()
    
    --- @see "AceGUIContainer-Frame.lua"
    local frameWidget = CreateDialog()

    --- @class PopupDebugDialog : PopupDebugDialogFrame
    local dialog = ns:K():CreateFromMixins(L, frameWidget)

    return dialog
end

L.mt.__call = L.Constructor
PD = L
