local __def = function()
    local C = {}

    -- TODO: Deprecate these. use AddOnDetails instead
    C.ADDON_NAME = 'DevTools'
    C.ADDON_PREFIX = '|cfdffffff{{|r|cfd91603a' .. C.ADDON_NAME .. '|r|cfdfbeb2d%s|r|cfdffffff}}|r'

    C.AddonDetails = {
        name = C.ADDON_NAME,
        prefix = C.ADDON_PREFIX
    }

    -- Library Format: DevTools-{LibraryName}-1.0
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

    C.Module = {
        Logger = 'Logger',
        Config = 'Config',
        Profile = 'Profile',
        ButtonUI = 'ButtonUI',
        ButtonFactory = 'ButtonFactory',
    }

    return C

end

DEVT_Constants = __def()