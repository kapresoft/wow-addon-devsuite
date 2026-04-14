--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)

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

local function DelayedCall(delay, fn)
  assert(type(delay) == 'number' and delay > 0)
  
  return function(moduleName)
    local printer = fn(moduleName)
    return function(...)
      local args = { ... }
      C_Timer.After(delay, function()
        printer(unpack(args))
      end)
    end
  end
end

--- @param moduleName Name
local function printerFn1(moduleName)
  local _ns = ns
  local m = resolveModuleName(moduleName)
  local pr = _ns.printer
  if m and #m > 0 then pr = _ns.printer:WithSubPrefix(m) end
  --print('xx moduleName=', m, 'pr=', pr); pr('Module', 'hello')
  return pr
end

--- @param moduleName Name
local function printerFn2(moduleName)
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

--- @param prefix string|any
--- @return TraceFn @Printer function that outputs plain values to Blizzard Trace UI (like print)
local function traceFn1(prefix)
  if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:td(...) end end
  return function(...) return ns:traceUtil() and ns:traceUtil():t(strtrim(prefix), ...) end
end

--- With auto formatting of objects
--- @param prefix string|nil
--- @return TraceFnFormatted @Printer function that outputs formatted values to Blizzard Trace UI (like print)
local function traceFn2(prefix)
  if type(prefix) ~= 'string' then return function(...) return ns.tracer and ns.tracer:tdf(...) end end
  return function(...) return ns:traceUtil() and ns:traceUtil():tf(strtrim(prefix), ...) end
end

--[[-----------------------------------------------------------------------------
Core:: Namespace Override for Dev Namespace
-------------------------------------------------------------------------------]]
do
  local h = ns.logHolder
  h.printer1 = printerFn1
  h.printer2 = printerFn2
  h.tracer1 = traceFn1
  h.tracer2 = traceFn2
end

--[[-------------------------------------------------------------------
Verbose Logging in Dev Mode
---------------------------------------------------------------------]]
local _, _, t = ns:log('DeveloperNamespace')
