--- @type DevSuite_Namespace
local ns = select(2, ...)

local libName = 'Announcements'
local TEMPLATE = 'DevSuite_AnnouncementDialogTemplate'

--- Self-contained, per-locale announcement content. A locale override is
--- a `title_<locale>` or `content_<locale>` field, e.g. `title_esES`.
--- @class AnnouncementDef
--- @field dbKey string    @Unique key under global.announcementsShown; shown at most once
--- @field title string    @enUS title, the fallback
--- @field content string  @enUS content, the fallback; may span several lines
--- @field width number?
--- @field height number?

--- @class Announcements
local o = ns:NewLib2(libName)

--- @type table<string, AnnouncementDef>
local registry = {}
--- @type string[]
local registrationOrder = {}

--- @return table<string, boolean>
local function ShownKeys() return ns:g().announcementsShown end

--- @param def AnnouncementDef
local function ShowDialog(def)
  --- @type AnnouncementDialogFrame
  local frame = CreateFrame('Frame', nil, UIParent, TEMPLATE)
  frame:Configure(def)
  frame:Show()
end

--- @param def AnnouncementDef
--- @param field 'title'|'content'
--- @return string
function o:Localized(def, field) return def[field .. '_' .. GetLocale()] or def[field] end

--- Registers a definition without showing it
--- @param def AnnouncementDef
function o:Register(def)
  assertsafe(
    type(def) == 'table' and type(def.dbKey) == 'string',
    'Announcements:Register(def): {def.dbKey} is required'
  )
  if not registry[def.dbKey] then registrationOrder[#registrationOrder + 1] = def.dbKey end
  registry[def.dbKey] = def
end

--- A no-op if the key was already shown or isn't registered
--- @param dbKey string
function o:ShowByKey(dbKey)
  local def = registry[dbKey]
  if not def or ShownKeys()[dbKey] then return end
  ShownKeys()[dbKey] = true
  ShowDialog(def)
end

--- Shows the first-registered unseen announcement, at most one per call
function o:ShowNextUnseen()
  for _, dbKey in ipairs(registrationOrder) do
    if not ShownKeys()[dbKey] then return self:ShowByKey(dbKey) end
  end
end
