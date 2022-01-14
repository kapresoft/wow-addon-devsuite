local __defAceLibAddonFactory = function(LibStub, VERSION_FORMAT, ObjectFactory, pformat)

    local format, tonumber, unpack = string.format, tonumber, unpack

    local F = {}

    function F:GetAceLibVersion(libName)
        local major, minor = format(VERSION_FORMAT, libName), tonumber(("$Revision: 1 $"):match("%d+"))
        return { major, minor }
    end

    function F:NewAceLib(libName)
        local version = self:GetAceLibVersion(libName)
        local newLib = LibStub:NewLibrary(unpack(version))
        newLib.__name = libName
        return ObjectFactory(libName, newLib)
    end

    return F

end

local Constants = DEVT_Constants
DEVT_AceLibAddonFactory = __defAceLibAddonFactory(
        LibStub, Constants.VERSION_FORMAT, DEVT_ObjectFactory, DEVT_PrettyPrint.pformat)