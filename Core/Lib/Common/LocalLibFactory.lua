local Table, String, Assert, Mixin = DEVS_LibGlobals:LibPack_Utils()

local LibStub, format, unpack = LibStub, string.format, Table.unpackIt
local assert, type, tonumber, isTable = assert, type, tonumber, Table.isTable
--local C, AceUtil = ABP_Constants, ABP_AceUtil
--local versionFormat = C.versionFormat
--local LOGF = ABP_LogFactory
--local LocalLibStub = AceUtil.LocalLibStub

---@class LocalLibFactory
local F = {}

local function Embed(libName, lib, version)
    LOGF:GetLogger():Embed(lib, libName)

    function lib:GetVersion() return version end
    function lib:GetVersionUnpacked() return unpack(self:GetVersion()) end

    function lib:OnAddonLoaded()
        local major, minor = self:GetVersionUnpacked()
        self:log(10, '%s.%s initialized yyyy', major, minor)
        --self:log(1, 'Profile: %s', type(self.profile))
        if type(self.OnAfterAddonLoaded) == 'function' then self:OnAfterAddonLoaded() end
    end

    ---
    --- `lib:OnInitialized{ addon=<handler>, profile=<profiledb> }`
    --- @param context @vararg table A vararg parameter
    ---
    --- Example:
    ---
    ---`{ addon=<handler>, profile=<profiledb> }`
    ---
    function lib:OnInitialize(context)
        assert(isTable(context), 'The passed context is not a table')
        self.addon = context.handler
        self.profile = context.profile
        if type(self.OnAfterInitialize) == 'function' then self:OnAfterInitialize() end
    end

    function lib:GetAddon() return self.addon end
    function lib:GetProfile() return self.profile end
end

---@return table A library instance with embedded methods
---@param libName string The library name
function F:NewLocalLibrary(libName)
    -- TODO: Rename to NewLocalLibrary()
    local version = C:GetLibVersion(libName)
    local newLib = LibStub:NewLibrary(unpack(version))
    newLib.__name = libName
    Embed(libName, newLib, version)
    return newLib
end

function F:LazyGetLocalAceLib(libObj, localLibName)
    if not libObj then return LocalLibStub(localLibName) end
    return libObj
end

---Helper for repetitive code
---Example:
---`local C,F,M = AceLibAddonFactory:NewAddonLibPack()`
---`local S = F:NewLocalLibrary(M.Settings)`
function F:NewAddonLibPack()
    return C, self, C.AddonModule
end
