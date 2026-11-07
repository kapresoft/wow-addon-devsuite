--- @type DevSuite_Namespace
local ns = select(2, ...)
local Announcements = ns.O.Announcements

--- @class AnnouncementScrollChild : Frame
--- @field Body FontString

--- @class AnnouncementDialogFrame : Frame, BackdropTemplate
--- @field Title FontString
--- @field ScrollFrame ScrollFrame
--- @field OkButton Button
--- @field scrollMarginX number @Dialog width minus viewport width
--- @field scrollMarginY number @Dialog height minus viewport height
DevSuite_AnnouncementDialogMixin = {}
local o = DevSuite_AnnouncementDialogMixin

function o:OnLoad()
  BackdropTemplateMixin.OnBackdropLoaded(self)
  self:SetBackdrop(BACKDROP_TOAST_12_12)
  local scrollFrame = self.ScrollFrame
  scrollFrame:SetScrollChild(scrollFrame.ScrollChild)
  self.scrollMarginX = self:GetWidth() - scrollFrame:GetWidth()
  self.scrollMarginY = self:GetHeight() - scrollFrame:GetHeight()
end

--- @param def AnnouncementDef
function o:ApplySize(def)
  if not (def.width or def.height) then return end
  local width = def.width or self:GetWidth()
  local height = def.height or self:GetHeight()
  self:SetSize(width, height)
  self.ScrollFrame:SetSize(width - self.scrollMarginX, height - self.scrollMarginY)
end

--- @param body FontString
local function ApplyMonoFont(body)
  local file, size, flags = DevSuite_ConsoleMono:GetFont()
  body:SetFont(file, size, flags)
end

--- @param def AnnouncementDef
function o:Configure(def)
  self.Title:SetText(('%s: %s'):format(ns.addon, Announcements:Localized(def, 'title')))
  self:ApplySize(def)

  --- @type AnnouncementScrollChild
  local scrollChild = self.ScrollFrame.ScrollChild
  scrollChild:SetWidth(self.ScrollFrame:GetWidth())
  local body = scrollChild.Body
  ApplyMonoFont(body)
  body:SetText(Announcements:Localized(def, 'content'))

  local viewportHeight = self.ScrollFrame:GetHeight()
  scrollChild:SetHeight(math.max(body:GetStringHeight(), viewportHeight))
end

function o:OnClickOk() self:Hide() end
