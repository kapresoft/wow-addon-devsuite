--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local GC, E, M = ns.GC, ns.GC.E, ns.GC.M
local libName = 'EventToMessageRelay'
--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class EventToMessageRelay
local L = ns:NewLibWithEvent(libName)
local p = ns:CreateDefaultLogger(libName)
local pm = ns:LC().MESSAGE:NewLogger(libName)
--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local CreateFrame, FrameUtil = CreateFrame, FrameUtil
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

do
    --- @type EventToMessageRelay | AceEventInterface
    local o = L;

    ---@param frame Frame
    function o.OnLoad(frame)
        p:vv(function() return 'OnLoad called... frame=%s', frame:GetParentKey() end)
        frame:SetScript(E.OnEvent, o.OnMessageTransmitter)

        --- @see GlobalConstants#M (Messages)
        RegisterFrameForEvents(frame, {
            E.MODIFIER_STATE_CHANGED,
        })
    end

    --- Blizzard Event to App Message
    local transformations = { }

    --- @param frame Frame
    --- @param event string
    function o.OnMessageTransmitter(frame, event, ...)
        local a = {...}
        local msg = transformations[event] or GC.toMsg(event)
        p:f3(function() return "Relaying event[%s] to message[%s] args=[%s]", event, msg, a end)
        o:SendMessage(msg, libName, ...)
    end

    --- @type Frame
    local ef = CreateFrame('Frame', nil, UIParent)
    ef:SetParentKey(libName)
    --o.OnLoad(ef)

end


