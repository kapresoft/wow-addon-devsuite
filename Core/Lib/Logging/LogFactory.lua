-- ## External -------------------------------------------------
local LibStub = LibStub
local Core = __K_Core_DevTools
local logger = Core:GetLogger()

-- ## Local ----------------------------------------------------

local major, minor = Core:GetLibVersion('LogFactory', 1)
---@class LogFactory
local _L = LibStub:NewLibrary(major, minor)


-- ## Functions ------------------------------------------------

---@return LogFactory
function _L:GetLogger() return logger end
function _L:EmbedLogger(obj, optionalLogName) self:GetLogger():Embed(obj, optionalLogName) end

---@class LoggerTemplate
local LoggerTemplate = {}
---@param format string The string format. Example: logger:log('hello: %s', 'world')
function LoggerTemplate:log(format, ...)  end


---```
---local newLib = LogFactory:GetLogger('Assert', LibStub:NewLibrary(MINOR, MAJOR))
---```
---@return LoggerTemplate A generic object with embedded AceConsole and Logger
function _L:NewLogger(logName, optionalObj)
    local o = {}
    if type(optionalObj) == 'table' then
        o = optionalObj
    end
    self:EmbedLogger(o, logName)
    return o
end

if type(_L.mt) ~= 'table' then _L.mt = {} end
_L.mt.__call = _L.NewLogger
setmetatable(_L, _L.mt)
