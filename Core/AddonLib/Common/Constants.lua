if type(DEVS_DB) ~= "table" then DEVS_DB = {} end
if type(DEVS_LOG_LEVEL) ~= "number" then DEVS_LOG_LEVEL = 1 end
if type(DEVS_DEBUG_MODE) ~= "boolean" then DEVS_DEBUG_MODE = false end

---@type Table
local __def = function(UISpecialFrames, Table)
    local C = {}

    local setglobal = setglobal

    -- TODO: Deprecate these. use AddOnDetails instead
    C.ADDON_NAME = 'DevSuite'
    C.ADDON_PREFIX = '|cfdffffff{{|r|cfdba8054' .. C.ADDON_NAME .. '|r|cfdfbeb2d%s|r|cfdffffff}}|r'
    C.DB_NAME = 'DEVS_DB'

    C.AddonDetails = {
        name = C.ADDON_NAME,
        prefix = C.ADDON_PREFIX
    }

    -- Library Format: DevSuite-{LibraryName}-1.0
    C.VERSION_FORMAT = C.ADDON_NAME .. '-%s-1.0'

    C.AceModule = {
        AceConsole = 'AceConsole-3.0',
        AceDB = 'AceDB-3.0',
        AceDBOptions = 'AceDBOptions-3.0',
        AceConfig = 'AceConfig-3.0',
        AceConfigDialog = 'AceConfigDialog-3.0',
        AceHook = 'AceHook-3.0',
        AceGUI = 'AceGUI-3.0',
        AceLibSharedMedia = 'LibSharedMedia-3.0'
    }

    -- TODO: Deprecate these
    C.Module = {
        Logger = 'Logger',
        Config = 'Config',
        Profile = 'Profile',
        ButtonUI = 'ButtonUI',
        ButtonFactory = 'ButtonFactory',
    }

    function C:ConfigureFrameToCloseOnEscapeKey(frameName, frameInstance)
        local frame = frameInstance
        if frameInstance.frame then frame = frameInstance.frame end
        setglobal(frameName, frame)
        Table.insert(UISpecialFrames, frameName)
    end

    return C

end
---@type Table
local LibStub = __K_Core_DevSuite:LibStub()
DEVS_Constants = __def(UISpecialFrames, LibStub('Table'))
