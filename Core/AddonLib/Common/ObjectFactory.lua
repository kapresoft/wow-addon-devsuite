-- ObjectFactory
local __def = function(Constants, Logger, pformat, table)

    local AddonDetails = Constants.AddonDetails
    local isNotTable = table.isNotTable
    local setmetatable, type, format = setmetatable, type, string.format

    local F = {}

    local function initMetatable(optionalLogName, obj)
        local prefix = ''
        if type(optionalLogName) == 'string' then prefix = '::' .. optionalLogName end
        if type(obj.mt) ~= 'table' then obj.mt = {} end

        obj.mt.__tostring = function() return format(AddonDetails.prefix, prefix)  end

        setmetatable(obj, obj.mt)
    end

    ---@param optionalLogName string The optional logger name
    ---@param optionalEmbedObj table Optional existing object, otherwise a new one will be returned
    function F:New(optionalLogName, optionalEmbedObj)
        local obj = optionalEmbedObj
        if not obj then obj = {} end
        initMetatable(optionalLogName, obj)
        Logger:Embed(obj)
        return obj
    end

    function F:NewAddon()
        local addon = LibStub("AceAddon-3.0"):NewAddon(AddonDetails.name, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
        return self:New(nil, addon)
    end

    local mt = {
        __tostring = function() return format(AddonDetails.prefix, 'ObjectFactory')  end,
        __call = F.New
    }
    setmetatable(F, mt)

    return F
end

DEVT_PrettyPrint.setup({ show_all = true })
DEVT_ObjectFactory = __def(DEVT_Constants, DEVT_logger, DEVT_PrettyPrint.pformat, DEVT_Table)