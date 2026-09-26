--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local O, Table = ns.O, ns:Table()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'Fonts'
--- @class Fonts_DevSuite
local o = {}
ns:Register(libName, o)
local p, t = ns:log(libName)

-- These are global var names that is provided by DebugChatFrame
--- @class FontRegistry_DevSuite
--- @field Inconsolata string
--- @field ['Inconsolata SemiBold'] string
--- @field ['Inconsolata Condensed'] string
--- @field ['Inconsolata ExtraCondensed'] string
--- @field ['Inconsolata UltraCondensed'] string
--- @field ['RobotoMono Medium'] string
--- @field ['NotoSansMono Regular'] string
local FONT_REGISTRY = {
  ['Inconsolata'] = 'DCF_Inconsolata_Regular_Outline',
  ['Inconsolata SemiBold'] = 'DCF_Inconsolata_SemiBold_Outline',
  ['Inconsolata Condensed'] = 'DCF_InconsolataCondensed_SemiBold_Outline',
  ['Inconsolata ExtraCondensed'] = 'DCF_InconsolataExtraCondensed_SemiBold_Outline',
  ['Inconsolata UltraCondensed'] = 'DCF_InconsolataUltraCondensed_SemiBold_Outline',
  ['RobotoMono Medium'] = 'DCF_RobotoMono_Medium_Outline',
  ['NotoSansMono Regular'] = 'DCF_NotoSansMono_Regular_Outline',
}

-- These are global var names that is provided by DebugChatFrame
--- @class FontRegistryNonWestern_DevSuite
--- @field RobotoMono_ruRU string
--- @field NotoSansMono_zhCN string
--- @field NotoSansMono_zhTW string
--- @field NotoSansMono_koKR string
local FONT_REGISTRY_NON_WESTERN = {
  ['RobotoMono_ruRU'] = 'DCF_RobotoMono_ruRU_Outline',
  ['NotoSansMono_zhCN'] = 'DCF_NotoSansMono_zhCN_Outline',
  ['NotoSansMono_zhTW'] = 'DCF_NotoSansMono_zhTW_Outline',
  ['NotoSansMono_koKR'] = 'DCF_NotoSansMono_koKR_Outline',
}

local FONTS_BY_LOCALE = {
  ['ruRU'] = 'RobotoMono_ruRU',
  ['zhCN'] = 'NotoSansMono_zhCN',
  ['zhTW'] = 'NotoSansMono_zhTW',
  ['koKR'] = 'NotoSansMono_koKR',
}

--- @type table<string, string>, string[], string
local AVAILABLE_FONTS, AVAILABLE_FONT_KEYS, DEFAULT_FONT = (function()
  -- loop through FONT_REGISTRY
  local f = {}
  local loc = GetLocale()
  local locFont = FONTS_BY_LOCALE[loc]
  if locFont then
    local locFontObjName = FONT_REGISTRY_NON_WESTERN[locFont]
    if locFontObjName and _G[locFontObjName] then
      t('AVAILABLE_FONTS', 'loc=', loc, 'font=', locFont, 'fo=', _G[locFontObjName])
      f[locFont] = locFontObjName
    end
  end
  for fontName, fontObjName in pairs(FONT_REGISTRY) do
    if fontObjName and _G[fontObjName] then f[fontName] = fontObjName end
  end

  local keys = (function()
    if not next(f) then return {} end
    local k = Table.Keys(f)
    table.sort(k)
    return k
  end)()
  local defaultFont = (function()
    local df = FONT_REGISTRY["Inconsolata ExtraCondensed"]
    return _G[df] and df or 'ChatFontNormal'
  end)()
  return f, keys, defaultFont
end)()

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
--- @return Name[] @Sorted names
function o:GetFontNames() return AVAILABLE_FONT_KEYS end
function o:GetDefaultFont() return DEFAULT_FONT or 'ChatFontNormal' end

--- @return Name, number @The user preference font by name and size
function o:GetUserFontSettings()
  local g = ns:g()
  local fName = g.console_font or self:GetDefaultFont()
  local fSize = g.console_fontSize or 12
  t('GetUserFontSettings', 'fName=', fName, 'fSize=', fSize)
  return fName, fSize
end
