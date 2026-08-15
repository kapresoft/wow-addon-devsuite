--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
--- @type LibTraceKit-1.0
local LibTraceKit = LibStub('LibTraceKit-1.0')
assertsafe(type(LibTraceKit) ~= nil, 'Failed to reference LibTraceKit-1.0')


--[[-------------------------------------------------------------------
Support Functions
---------------------------------------------------------------------]]
--- @return string|nil
local function resolveModuleName(moduleName)
  if type(moduleName) == 'string' then
    return strtrim(moduleName)
  end
  return nil
end

--- @param moduleName Name
local function printerFn1(moduleName)
  local _ns = ns
  local m = resolveModuleName(moduleName)
  local pr = _ns.printer
  if m and #m > 0 then pr = _ns.printer:WithSubPrefix(m) end
  return pr
end

--- @param moduleName Name
local function printerFn(moduleName)
  local _ns = ns
  local m = resolveModuleName(moduleName)
  
  return function(...)
    local args = { ... }
    C_Timer.After(1, function()
      local pr = _ns.printer
      if m and #m > 0 then pr = _ns.printer:WithSubPrefix(m) end
      pr(unpack(args))
    end)
  end
end

--- @param prefix string?
--- @return TracerFunction
local function traceFn(prefix)
  local t = LibTraceKit:New(ns.addon, prefix):WithDelimiter('_')
  return t --[[@as TracerFunction ]]
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder; h.printer = printerFn; h.tracer = traceFn
end

--[[-------------------------------------------------------------------
Verbose Logging in Dev Mode
---------------------------------------------------------------------]]
local t = select(2, ns:log('DeveloperNamespace'))
t('DevNamespace', 'Loaded...')
