local __def = function(C, AceUtil, table, PrettyPrint, LOG_LEVEL)

    local format, pack, unpack, sliceAndPack = string.format, table.pack, table.unpackIt, table.sliceAndPack
    local type, select, tostring, error = type, select, tostring, error
    local pformat = PrettyPrint.pformat
    local setmetatable = setmetatable
    local isNotTable = table.isNotTable

    local c = AceUtil:GetAceConsole()
    local L = {}

    ---@param obj table
    function L:Embed(obj)
        c:Embed(obj)

        function obj:log(...)
            local args = pack(...)
            if args.len == 1 then
                self:Print(self:ArgToString(args[1]))
                return
            end
            local level = 1
            local startIndex = 1
            if type(args[1]) == 'number' then
                level = args[1]
                startIndex = 2
            end
            if type(args[startIndex]) ~= 'string' then
                error(format('Argument #%s requires a string.format text', startIndex))
            end
            if LOG_LEVEL < level then return end
            --print(format('startIndex: %s level: %s', startIndex, level))
            args = sliceAndPack({...}, startIndex)
            local newArgs = {}
            for i=1,args.len do
                newArgs[i] = self:ArgToString(args[i])
            end
            --c:Print(prefix, format(unpack(newArgs)))
            self:Printf(format(unpack(newArgs)))
        end

        function obj:logn(...)
            local args = pack(...)
            local level = 1
            local startIndex = 1
            if type(args[1]) == 'number' then
                level = args[1]
                startIndex = 2
            end
            if type(args[startIndex]) ~= 'string' then
                error(format('Argument #%s requires a string.format text', startIndex))
            end
            if LOG_LEVEL < level then return end
            --print(format('startIndex: %s level: %s', startIndex, level))
            args = sliceAndPack({...}, startIndex)
            local newArgs = {}
            for i=1,args.len do
                local nl = '\n   '
                if i == 1 then nl = '' end
                local el = args[i]
                if type(el) == 'table' then newArgs[i] = nl .. tableToString(el)
                else newArgs[i] = nl .. tostring(el) end
            end
            self:Print(format(unpack(newArgs)))
        end

        -- Log a Pretty Formatted Object
        -- self:logp(itemInfo)
        -- self:logp("itemInfo", itemInfo)
        function obj:logp(...)
            local count = select('#', ...)
            if count == 1 then
                self:log(pformat(select(1, ...)))
                return
            end
            local label, obj = select(1, ...)
            self:log(label .. ': %s', pformat(obj))
        end

        function obj:printf(...)
            local args = pack(...)
            if args.len <= 0 then error('No arguments passed') end
            local formatText = args[1]
            if type(formatText) ~= 'string' then error('First argument must be a string.format string') end
            local newArgs = {}
            for i=1,args.len do
                local el = args[i]
                newArgs[i] = self:ArgToString(el)
            end
            self:Print(format(unpack(newArgs)))
        end

        function obj:ArgToString(any)
            if type(any) == 'table' then return tableToString(any)
            else
                return tostring(any)
            end
        end

    end

    local function initMetatable(optionalLogName, obj)
        local prefix = ''
        if type(optionalLogName) == 'string' then prefix = '::' .. optionalLogName end
        if type(obj.mt) ~= 'table' then obj.mt = {} end

        obj.mt.__tostring = function() return format(C.AddonDetails.prefix, prefix)  end

        setmetatable(obj, obj.mt)
    end

    --- Constructor
    --- Usage:  local logger = DEVT_Logger('DevTools')
    function L:NewLogger(logName)
        local _logger = {}
        initMetatable(logName, _logger)
        self:Embed(_logger)
        return _logger
    end

    local mt = {
        __tostring = function() return format(C.AddonDetails.prefix, '::Logger')  end,
        __call = L.NewLogger
    }
    setmetatable(L, mt)

    return L
end

---@class Logger
DEVT_logger = __def(
        DEVT_Constants, DEVT_AceUtil, DEVT_Table, DEVT_PrettyPrint, DEVT_LOG_LEVEL)
