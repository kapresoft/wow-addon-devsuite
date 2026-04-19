--[[-----------------------------------------------------------------------------
Externals
-------------------------------------------------------------------------------]]
--- @type DebugChatFrameInterface
local DebugChatFrame = DebugChatFrame
--- @type ChatFrame
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local sformat     = ns.sformat
local O, GC       = ns.O, ns.GC
local String = ns:String()
local MODULE_NAME = 'DevConsole'
local LIB_MIXIN   = { 'AceEvent-3.0' }
local libName     = ns.M.DevConsoleModuleMixin()

--[[-----------------------------------------------------------------------------
New Mixin
-------------------------------------------------------------------------------]]
--- @class DevConsoleModuleMixin : AceEvent-3.0
local L      = ns:NewLib(libName);
L.moduleName = MODULE_NAME

--- @class DevConsoleModule : DevConsoleModuleMixin
--
--
--- @alias AddonInterface AceAddon | AceConsole-3.0 | AceEvent-3.0 | AceHook-3.0

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param addon AddonInterface
--- @return DevConsoleModule
function L:NewModule(addon)
  --- @type DevConsoleModule
  local module = addon:NewModule(MODULE_NAME, L, unpack(LIB_MIXIN))
  module:RegisterMessage(GC.M.OnAddOnReady, 'OnAddonReady')
  return module
end

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
local primaryColor   = ns.consoleColors.primary
local secondaryColor = ns.consoleColors.secondary

local cfmt = ns:ColorFormatter()
local c1, c2  = cfmt:ColorFn(primaryColor), cfmt:ColorFn(secondaryColor)
local c3, c4  = cfmt:ColorFn(ADVENTURES_COMBAT_LOG_BLUE), cfmt:ColorFn(FACTION_GREEN_COLOR)
local c5  = cfmt:ColorFn(LIGHTGRAY_FONT_COLOR)
local windowAlpha, windowColor = 0.9, cfmt:ColorFromHex('343434')

local p, pd, t, tf = ns:log(libName)
local pre     = sformat('{{%s::%s}}:', c1(ns.nameShort), c2(MODULE_NAME))
local pre_dev = sformat('{{%s::%s}}:', ns.f.debug(nameShort), c2(MODULE_NAME))

--[[-----------------------------------------------------------------------------
LogFunctions
-------------------------------------------------------------------------------]]
local LogFunctions = {}
local TimeUtil = LibStub('Kapresoft-TimeUtil-2-0')
local function ts() return sformat('[%s]', TimeUtil:NowInHoursMinSeconds()) end

--- @param module Name
local function _PrintpFn(module, ...)
  print(ts(), module, ...)
end

--- @param module Name
local function _LogpFn(module, ...)
  local cf = ns.chatFrame
  if cf then return cf:log(ts(), module, ...) end
  print(ts(), module, ...)
end

--- ### Usage
--- ```
--- local logp = ns.f.logp('MyController')
--- logp('Hello', 'World!')
--- ```
--- @param module Name
--- @return fun(...:any) : void
function LogFunctions.logp(module) return function(...) _LogpFn(module, ...) end end

--- ### Usage
--- ```
--- local printp = ns.f.printp('MyController')
--- printp('Hello', 'World!')
--- ```
--- @param module Name
--- @return fun(...:any) : void
function LogFunctions.printp(module) return function(...) _PrintpFn(module, ...) end end

local logp = LogFunctions.logp(pre)
local printp = LogFunctions.printp(pre)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local d = L

function d:OnAddonReady()
  if ns:dbg().enableLogConsole ~= true then return self:Disable() end

  -- give some delay so the Chat Frame UI size isn't wonky on LogIn
  C_Timer.After(0.5, function()
    self:InitializeDebugChatFrame()
    self:Enable()
  end)
end

function d:RegisterMessages()
  self:RegisterMessage(GC.M.OnDebugConsoleDefaultChatFrameState, 'OnDefaultChatFrameChanged')
end

function d:OnEnable()
  if not DefaultChatFrame then self:EnableDebugChatFrame() end
  O.OptionsDebugConsole:EnableGroup()
  self:RegisterMessages()
  logp('Debug console ENABLED')
end

function d:OnDisable()
  if ns:HasChatFrame() then ns:ChatFrame():CloseTab() end
  O.OptionsDebugConsole:DisableGroup()
  self:UnregisterAllMessages()
  return printp('Debug console DISABLED')
end

function d:GetDefaultChatFrame()
  local cf = ns:ChatFrame()
  if cf and ns:dbg().makeDefaultChatFrame == true then
    return DebugChatFrame:GetChatFrameTabText(cf)
  end
  return DebugChatFrame:GetChatFrameTabText(ChatFrame1)
end

function d:OnDefaultChatFrameChanged()
  ns:ChatFrame():SetAsDefaultChatFrame(ns:dbg().makeDefaultChatFrame == true)
end

--- @private
function d:InitializeDebugChatFrame()
  if ns:dbg().enableLogConsole ~= true then return end

  local cf
  if not DefaultChatFrame then
    cf = self:EnableDebugChatFrame(); if not cf then return end
  end

  O.OptionsDebugConsole:EnableGroup()

  DEVTOOLS_MAX_ENTRY_CUTOFF = ns:dbg().DEVTOOLS_MAX_ENTRY_CUTOFF
  DEVTOOLS_DEPTH_CUTOFF = ns:dbg().DEVTOOLS_DEPTH_CUTOFF
  logp('DEVTOOLS_MAX_ENTRY_CUTOFF:', c3(DEVTOOLS_MAX_ENTRY_CUTOFF))
  logp('DEVTOOLS_DEPTH_CUTOFF:', c3(DEVTOOLS_DEPTH_CUTOFF))
  logp('DEVTOOLS_LONG_STRING_CUTOFF:', c3(DEVTOOLS_LONG_STRING_CUTOFF), '(String Size)')

  ns:ChatFrame():InitialTabSelection(ns:dbg().selectLogConsoleTab)
  --@do-not-package@
  logp('IsShown():', c3(ns:IsChatFrameTabShown()))
  logp('Addon Usage avail?', c3(O.API:IsAddonUsageAvailable()))
  --@end-do-not-package@
  self:OnDefaultChatFrameChanged()
end

--- @return ChatLogFrame?
function d:EnableDebugChatFrame()
  if ns:HasChatFrame() then
    local chatFrame = ns:ChatFrame()
    chatFrame:RestoreChatFrame(ns:dbg().selectLogConsoleTab)
    return chatFrame
  end

  local function LoadDebugChatFrame()
    if self.DebugChatFrameNotLoadable == true then return end

    local addonName = 'DebugChatFrame'
    local U = ns:AddonUtil()
    U:LoadOnDemand(addonName, function(loadSuccess, info, errorMsg)
      local successText = c2(tostring(loadSuccess))

      if loadSuccess then return
      else self.DebugChatFrameNotLoadable = true end
      if ns.IsDev() then
        p(sformat('DebugChatFrame Loaded OnDemand: %s', successText))
      end
      if info and loadSuccess ~= true then
        p(sformat('DebugChatFrame is not available. [Reason: %s]', info.reason))
      end
      if ns.IsDev() then
        p('Error Message:', errorMsg)
      end
    end)
  end; LoadDebugChatFrame()

  if not DebugChatFrame then return end

  --- @type DebugChatFrameInterface
  local dcf = DebugChatFrame

  --- @type DebugChatFrameOptionsInterface
  local opt = {
    chatFrameTabName = ns.addon,
    font = DCF_ConsoleMonoCondensedSemiBoldOutline,
    fontSize = ns:db().global.console_fontSize,
    windowAlpha = windowAlpha,
    maxLines = ns:dbg().maxLogConsoleLines,
  }

  --- @param chatFrame ChatLogFrameInterface|ChatLogFrame
  local cf  = dcf:New(opt, function(chatFrame)
    chatFrame:SetAlpha(1.0)
    local r, g, b = windowColor:GetRGB()
    FCF_SetWindowColor(chatFrame, r, g, b)
    FCF_SetWindowAlpha(chatFrame, opt.windowAlpha)
    local xns = ns; xns:RegisterChatFrame(chatFrame)
  end)

  logp(c5('-------------------------------------------'))
  logp(c1(':: Debug ChatFrame initialized ::'));
  logp('  IsDev:', c3(ns.IsDev()), 'GameVersion:', c4(ns.gameVersion))

  local maxFontLen = 45
  local font, size, flags = cf:GetFont()
  --- @type string
  local fontText = font
  if fontText:len() > maxFontLen then fontText = String.TruncateReversed(font, maxFontLen, nil) end
  logp('   Font:', c5(fontText))
  logp('  Flags:', c3(flags), 'Font-Size:', c3(size))
  logp('')
  logp(c1(':: Chat Frames ::'))
  printp(c2('  Name:'), c3(cf:GetChatFrameTabText()))
  printp(c2('    • Max Lines:'), c3(ns:dbg().maxLogConsoleLines))
  printp(c2('  Name:'), c3(DebugChatFrame:GetChatFrameTabText(ChatFrame1)))
  local dcfName = DebugChatFrame:GetChatFrameTabText(DEFAULT_CHAT_FRAME)
  printp(c2('  DEFAULT_CHAT_FRAME:'), c3(dcfName))
  logp(c5('-------------------------------------------'), '\n\n')

  return ns:ChatFrame()
end
