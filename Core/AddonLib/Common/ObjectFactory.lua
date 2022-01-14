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

    function F:New(optionalLogName, embedObj, three)
        --error(format('optionalLogName: %s  embedObj: %s', optionalLogName, pformat(embedObj)))
        local obj = embedObj
        if not obj then obj = {} end
        initMetatable(optionalLogName, obj)
        Logger:Embed(obj)
        return obj
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