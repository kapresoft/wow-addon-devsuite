--- @type DevSuite_Namespace
local ns = select(2, ...)
local O, GC = ns.O, ns.GC

local cmdColor = ns:ColorFn(HEIRLOOM_BLUE_COLOR)

--- @param label string
--- @param desc string
--- @return string
local function Line(label, desc)
  local padded = ('%-24s'):format(label)
  return ('%s - %s'):format(cmdColor(padded), desc)
end

--- @param opener string
--- @param descCommand string
--- @param keysLabel string
--- @param descKeys string
--- @return string
local function BuildContent(opener, descCommand, keysLabel, descKeys)
  return table.concat({
    opener,
    '',
    Line('/' .. GC.C.CONSOLE_COMMAND .. ' graphics', descCommand),
    Line(keysLabel, descKeys),
  }, '\n')
end

--- @type AnnouncementDef
local def = {
  dbKey = 'openGraphicsSettings',
  width = 520,
  height = 200,

  title = 'Open Graphics Settings',
  title_esES = 'Abrir ajustes de gráficos',

  content = BuildContent(
    'Heads up! DevSuite can now open Options > Graphics directly.',
    'opens Options > Graphics',
    'Key Bindings',
    'AddOns > DevSuite > Open Graphics Settings'
  ),

  content_esES = BuildContent(
    'Aviso rápido: DevSuite ahora puede abrir Opciones > Gráficos directamente.',
    'abre Opciones > Gráficos',
    'Atajos de teclado',
    'AddOns > DevSuite > Abrir ajustes de gráficos'
  ),
}

O.Announcements:Register(def)
