--[[-------------------------------------------------------------------
This is a utility loader for LibIconPicker
---------------------------------------------------------------------]]

--- @type Namespace
local ns = select(2, ...)

--[[-------------------------------------------------------------------
Local Vars
---------------------------------------------------------------------]]
-- The old GetAddOnEnableState requires the second arg 'character'
local GetAddOnEnableState = C_AddOns.GetAddOnEnableState or GetAddOnEnableState
local LoadAddOn   = C_AddOns.LoadAddOn or LoadAddOn
local EnableAddOn = C_AddOns.EnableAddOn or EnableAddOn
local OKAY = OKAY
local iconPickerAddOn = 'LibIconPicker'

--[[-------------------------------------------------------------------
New Library
---------------------------------------------------------------------]]
local libName = 'LibIconPickerUtil'
--- @class LibIconPickerUtil
local S = {}; ns:Register(libName, S)

local libName = 'LibIconPickerUtil'
local p = ns:LC().DEV:NewLogger(libName)

--- @type LibIconPickerUtil
local o = S;

--- temp locale
local L = {}
L['LibIconPicker Missing'] = 'This feature requires LibIconPicker.|nPlease make sure LibIconPicker is installed and enabled, then reload the UI.'

StaticPopupDialogs["LibIconPicker_Missing"] = {
  text = L['LibIconPicker Missing'],
  button1 = OKAY, timeout = 0, whileDead = 1, hideOnEscape = 1,
}
--[[-------------------------------------------------------------------
Methods
---------------------------------------------------------------------]]
--- Get LibIconPicker instance
--- The global var `LibIconPicker` is available if the addon is already loaded.
--- @param callbackFn fun(lip:LibIconPicker) | "function(lip) end"
--- @return LibIconPickerUtil
function o:Get(callbackFn)
  -- if embedded
  if LibIconPicker then callbackFn(LibIconPicker); return end
  
  -- if on demand
  EnableAddOn(iconPickerAddOn, UnitName('player'))
  local loaded, reason = LoadAddOn(iconPickerAddOn)
  if loaded == true then callbackFn(LibIconPicker); return end
  
  p:vv(function() return 'LoadAddOn(%q) failed to load with reason=%q', iconPickerAddOn, reason end)
  StaticPopup_Show("LibIconPicker_Missing")
end



