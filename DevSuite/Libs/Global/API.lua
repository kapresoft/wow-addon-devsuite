--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'API'
--- @class API
local o = {}; ns:Register(libName, o)
local p, t, fmt = ns:log(libName)

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
function o:GetUIScale()
  -- This returns "1" if UI scaling is enabled, "0" otherwise.
  local useUiScale = GetCVar('useUiScale')
  if useUiScale == "1" then
    local uiScale = GetCVar('uiScale')
    return tonumber(uiScale)
  else
    -- UI scaling is not enabled, so scale is effectively 1.
    return 1
  end
end

function o:GetCurrentPlayer() return UnitName('player') end
