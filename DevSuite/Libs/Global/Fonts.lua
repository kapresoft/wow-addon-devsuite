--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)
local Table = ns:Table()

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
local libName = 'Fonts'
--- @class Fonts_DevSuite
--- @field availableFonts table<string, string> @Display name to global FontObject name
--- @field availableFontKeys string[]           @Sorted display names
--- @field defaultFont string                   @Global FontObject name
local o = {}; ns:Register(libName, o)
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

--- Dropdown display order; the locale font is listed first
local FONT_ORDER = {
  'Inconsolata',
  'Inconsolata SemiBold',
  'Inconsolata Condensed',
  'Inconsolata ExtraCondensed',
  'Inconsolata UltraCondensed',
  'RobotoMono Medium',
  'NotoSansMono Regular',
}

local FONTS_BY_LOCALE = {
  ['ruRU'] = 'RobotoMono_ruRU',
  ['zhCN'] = 'NotoSansMono_zhCN',
  ['zhTW'] = 'NotoSansMono_zhTW',
  ['koKR'] = 'NotoSansMono_koKR',
}

--[[-----------------------------------------------------------------------------
Mixin Methods
-------------------------------------------------------------------------------]]
function o:RefreshFonts()
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
    local df = FONT_REGISTRY['Inconsolata ExtraCondensed']
    return _G[df] and df or 'ChatFontNormal'
  end)()
  self.availableFonts, self.availableFontKeys, self.defaultFont = f, keys, defaultFont
end

function o:GetDefaultFont() return self.defaultFont or 'ChatFontNormal' end

--- @return table<Name, Name> @Global FontObject name to display name
function o:GetFontChoices()
  local choices = {}
  if not self.availableFonts then return choices end
  for name, objName in pairs(self.availableFonts) do
    choices[objName] = name
  end
  return choices
end

--- @return Name[] @Global FontObject names: FONT_ORDER first, then the rest by name
function o:GetFontSorting()
  local sorting = {}
  local f = self.availableFonts
  if not f then return sorting end
  local added = {}
  local function add(name)
    if not f[name] or added[name] then return end
    added[name] = true
    table.insert(sorting, f[name])
  end
  add(FONTS_BY_LOCALE[GetLocale()])
  for _, name in ipairs(FONT_ORDER) do
    add(name)
  end
  -- AceConfig hides keys missing from sorting
  for _, name in ipairs(self.availableFontKeys) do
    add(name)
  end
  return sorting
end

--- @return Name, number @The user preference font by name and size
function o:GetUserFontSettings()
  local g = ns:g()
  local fName = g.console_font or self:GetDefaultFont()
  local fSize = g.console_fontSize or 12
  t('GetUserFontSettings', 'fName=', fName, 'fSize=', fSize)
  return fName, fSize
end
