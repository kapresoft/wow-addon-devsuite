local __def = function(ADDON_NAME, LIB)
    local format, unpack, pack, tinsert = string.format, table.unpackIt, table.pack, table.insert
    local C = LIB:NewAceLib('Config')
    if not C then return end

    ---- ## Start Here ----

    function C:OnAfterInitialize()
    end

    function C:OnAfterEnable()
    end

    function C:OnAfterAddonLoaded()
    end

    -- Main Entry Point to config dialog
    function C:GetOptions()
        return {
            name = ADDON_NAME, handler = C.addon, type = "group",
            args = {
                enabled = {
                    type = "toggle",
                    name = format("Enable %s", ADDON_NAME),
                    desc = format("Enable or Disable %s", ADDON_NAME),
                    order = 0,
                    get = function(_) return end,
                    set = function(_, v) return end,
                }
            }
        }
    end

    return C
end

DEVT_Config = __def(DEVT_Constants.ADDON_NAME, DEVT_AceLibAddonFactory)
