local LibStub, format, unpack = LibStub, string.format, table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, table.isTable

local __def = function(LibStub, AceUtil, AceModule)

    local A = {}

    local libSharedMedia = nil
    local libAceHook = nil
    local libAceDB = nil
    local libAceDBOptions = nil
    local libAceConfigDialog = nil
    local libAceConfig = nil
    local libAceGUI = nil

    -- ############################################################

    function A:LazyGetAceLib(libObj, libName)
        return AceUtil:LazyGetAceLib(libObj, libName)
    end

    function A:GetAceConsole()
        return AceUtil:GetAceConsole()
    end

    function A:GetAceSharedMedia()
        libSharedMedia = self:LazyGetAceLib(libSharedMedia, AceModule.AceLibSharedMedia)
        return libSharedMedia
    end

    function A:GetAceHook()
        libAceHook = self:LazyGetAceLib(libAceHook, AceModule.AceHook)
        return libAceHook
    end

    function A:GetAceDB()
        libAceDB = self:LazyGetAceLib(libAceDB, AceModule.AceDB)
        return libAceDB
    end

    function A:GetAceDBOptions()
        libAceDBOptions = self:LazyGetAceLib(libAceDBOptions, AceModule.AceDBOptions)
        return libAceDBOptions
    end

    function A:GetAceConfig()
        libAceConfig = self:LazyGetAceLib(libAceConfig, AceModule.AceConfig)
        return libAceConfig
    end

    function A:GetAceConfigDialog()
        libAceConfigDialog = self:LazyGetAceLib(libAceConfigDialog, AceModule.AceConfigDialog)
        return libAceConfigDialog
    end
    function A:GetAceGUI()
        libAceGUI = self:LazyGetAceLib(libAceGUI, AceModule.AceGUI)
        return libAceGUI
    end

    function A:GetAddonAceLibs()
        return { self:GetAceDB(), self:GetAceDBOptions(), self:GetAceConfig(), self:GetAceConfigDialog() }
    end

    return A
end

local Constants = DEVT_Constants
DEVT_AceLibFactory = __def(LibStub, DEVT_AceUtil, Constants.AceModule)