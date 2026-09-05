--[[-----------------------------------------------------------------------------
Namespace
-------------------------------------------------------------------------------]]
--- @type DevSuite_Namespace
local ns = select(2, ...)

local L = ns:NewLocale('esES'); if not L then return end

--[[-----------------------------------------------------------------------------
Locale Entries
-------------------------------------------------------------------------------]]

L['BINDING_NAME_DEVS_OPTIONS_DLG']              = 'Ventana de opciones'
L['BINDING_NAME_DEVS_DEBUG_DLG']                = 'Ventana de depuración'
L['BINDING_NAME_DEVS_GET_DETAILS_ON_MOUSEOVER'] = 'Obtener detalles al pasar el ratón'
L['BINDING_NAME_DEVS_TOGGLE_FRAMESTACK']        = 'Alternar pila de marcos'
L['BINDING_NAME_DEVS_CLEAR_DEBUG_CONSOLE']      = 'Limpiar consola de depuración'
L['BINDING_NAME_DEVS_TOGGLE_DEBUG_CONSOLE']     = 'Alternar consola de depuración'
L['BINDING_NAME_DEVS_DUMP_CURSOR_INFO']         = 'Volcar GetCursorInfo()'
L['BINDING_NAME_DEVS_TOGGLE_SHOW_EVENT_TRACE_UI_AT_STARTUP'] = 'Alternar mostrar seguimiento de eventos al iniciar'

L['Version']           = 'Versión'
L['Curse-Forge']       = 'Curse-Forge'
L['Bugs']              = 'Errores'
L['Repo']              = 'Repositorio'
L['Last-Update']       = 'Última actualización'
L['Interface-Version'] = 'Versión de interfaz'
L['Game-Version']      = 'Versión del juego'
L['Locale']            = 'Idioma'

L['Debugging::Category::Enable All::Button']        = 'Activar todo'
L['Debugging::Category::Enable All::Button::Desc']  = 'Activa todas las categorías de registro a continuación. Ten en cuenta que la categoría predeterminada (no mostrada aquí) siempre estará activa.'
L['Debugging::Category::Disable All::Button']       = 'Desactivar todo'
L['Debugging::Category::Disable All::Button::Desc'] = 'Desactiva todas las categorías de registro a continuación. Ten en cuenta que la categoría predeterminada (no mostrada aquí) siempre estará activa.'

L['Global Setting']          = 'Configuración global'
L['Character Setting']       = 'Configuración de personaje'

L['REQUIRES_RELOAD']         = 'Los complementos adicionales requieren recargar la interfaz para aplicarse. ¿Deseas recargar ahora?\n\n'
L['General']                 = 'General'
L['General::Desc']           = 'Configuración general'
L['Debug Console']           = 'Consola de depuración'
L['Debug Console::Desc']     = 'Consola de depuración'

L['Add-On Management']       = 'Gestión de complementos'
L['Add-On Management::Desc'] = 'Activa, desactiva y personaliza fácilmente algunos de tus complementos de WoW para una experiencia de juego a medida.'

L['Show Frames-Per-Second (FPS)']             = 'Mostrar cuadros por segundo (FPS)'
L['Show Frames-Per-Second (FPS)::Desc']       = 'Muestra el indicador de cuadros por segundo de Blizzard'
L['Prompt to Reload and Enable Addons']       = 'Preguntar para recargar y activar complementos'
L['Prompt to Reload and Enable Addons::Desc'] = 'Solicita al jugador recargar la interfaz si es necesario activar complementos al cerrar la ventana de configuración. (Configuración global)'

L['Console Font Size']             = 'Tamaño de fuente de la consola'
L['Console Font Size::Desc']       = 'Elige un tamaño de fuente para la consola'
L['Console Font Size::ConfirmFmt'] = 'Has seleccionado el tamaño de fuente %d para la consola.\n¿Recargar la interfaz para aplicar este cambio?'

L['Add-On Specific Options']    = 'Opciones específicas del complemento'
L['Available Add-Ons']          = 'Complementos disponibles'
L['Available Add-Ons::Desc']    = 'Para activar o desactivar un complemento, marca o desmarca su casilla correspondiente. Después de hacer tus selecciones, haz clic en "Aplicar y recargar interfaz" para implementar los cambios en tu configuración.'
L['Debugging']                  = 'Depuración'
L['Debugging::Desc']            = 'Configuración de depuración para solución de problemas'
L['Enable Debug Console']       = 'Activar consola de depuración'
L['Enable Debug Console::Desc'] = 'Activa la consola de depuración, permitiendo que se muestre dentro del marco de chat. Usa esta opción para habilitar salidas de depuración en tiempo real e interactuar con el sistema de depuración directamente desde la interfaz de chat.'
L['Show Tab On Load']           = 'Mostrar pestaña al cargar'
L['Show Tab On Load::Desc']     = 'Cuando la consola de depuración está activa, esta configuración asegura que la pestaña de la consola de depuración se seleccione automáticamente al iniciar el juego o recargar la interfaz. Actívalo para ver y monitorear inmediatamente las salidas de depuración sin cambiar manualmente a la pestaña de depuración.'
L['Default Chat Frame']         = 'Marco de chat predeterminado'
L['Default Chat Frame::Desc']   = 'Establece el marco de chat seleccionado como el destino predeterminado para todas las salidas. Cualquier mensaje o salida de comandos y complementos se dirigirá a este marco de chat.'

L['Max Lines']                  = 'Líneas máximas'
L['Max Lines::Desc']            = 'Define el número máximo de líneas que la consola de depuración puede mostrar en un momento dado. Ajustar esta configuración ayuda a gestionar la cantidad de información visible en la consola de depuración, evitando desbordamientos y ayudándote a centrarte en los mensajes y salidas más recientes. Adecuado para adaptar la capacidad de la consola a tus necesidades de depuración.'
L['Debug Configuration']        = 'Configuración de depuración'

L['Log Level']                  = 'Nivel de registro'
L['Log Level::Desc']            = 'Los niveles de registro más altos generan más registros:\nNiveles de registro: ERROR(5), WARN(10), INFO(15), DEBUG(20), FINE(25), FINER(30), FINEST(35), TRACE(50)'
L['Apply and ReloadUI']         = 'Aplicar y recargar interfaz'
L['Apply and ReloadUI::Desc']   = 'Para activar o desactivar un complemento, marca o desmarca su casilla correspondiente. Después de hacer tus selecciones, haz clic en este botón para implementar los cambios en tu configuración.'
L['Select Profile']             = 'Seleccionar perfil'
L['Select Profile::Desc']       = 'Selecciona un perfil para activarlo. Se te pedirá recargar la interfaz. Ten en cuenta que estos perfiles se gestionan en la pestaña Perfiles.'

L['Addon Manager Special Notice']    = 'La función de Gestor de Complementos ahora forma parte de un complemento nuevo y mejorado, "Addon Suite". Para una funcionalidad mejorada y actualizaciones, visita CurseForge para descargar la última versión de "Addon Suite". Agradecemos tu apoyo y esperamos que disfrutes de las nuevas funciones y mejoras. ¡Gracias!'
L['DEVTOOLS_DEPTH_CUTOFF']           = 'DEVTOOLS_DEPTH_CUTOFF'
L['DEVTOOLS_DEPTH_CUTOFF::Desc']     = 'Este parámetro controla la profundidad máxima a la que se inspeccionan las tablas en herramientas de desarrollo como |cff00ccff/dump|r. Al establecer este valor, los usuarios pueden limitar cuán profundamente las herramientas recorren tablas anidadas durante operaciones como la depuración o la visualización de estructuras de datos. Una profundidad menor puede evitar tiempos de procesamiento excesivos y saturación de salida al trabajar con tablas profundamente anidadas. La configuración predeterminada es |cff00ccff10|r, pero se puede ajustar para adaptarse a diferentes niveles de complejidad o mejorar el rendimiento durante las tareas de desarrollo.'
L['DEVTOOLS_MAX_ENTRY_CUTOFF']       = 'DEVTOOLS_MAX_ENTRY_CUTOFF'
L['DEVTOOLS_MAX_ENTRY_CUTOFF::Desc'] = 'Este parámetro establece el número máximo de entradas de tabla que muestran las herramientas de desarrollo como |cff00ccff/dump|r. Ayuda a gestionar la salida al inspeccionar tablas grandes, evitando que se muestren cantidades abrumadoras de datos a la vez. Por defecto, solo se muestran las primeras |cff00ccff30|r entradas de una tabla. Ajustar este parámetro puede ser útil para desarrolladores que necesiten limitar o ampliar su vista al depurar estructuras de datos complejas, según el nivel de detalle requerido para su análisis.'

L['DevSuite addon feature']     = 'Función del complemento DevSuite'
L['Clear current preset']       = 'Borrar preajuste actual'
L['Preset Filters']             = 'Filtros preestablecidos'
L['Preset Filters::DESC']       = 'Haz clic para mostrar filtros de texto|npredefinidos del complemento DevSuite.'
L['Add Preset Filter Keyword']  = 'Añadir palabra clave de filtro preestablecido'
L['Clear']                      = 'Borrar'
L['Show Event Trace At Startup']        = 'Mostrar seguimiento de eventos al iniciar'
L['Show Event Trace At Startup::Desc']  = 'Muestra la ventana de seguimiento de eventos automáticamente al cargar el complemento'

L['Showing variable value for']         = 'Mostrando el valor de la variable para'

L['Accept']                  = 'Aceptar'
L['Accept::Desc']            = 'Evalúa el código anterior.'
L['Accept and Reload UI']    = 'Aceptar y recargar interfaz'
L['Accept and Reload UI::Desc'] = 'Evalúa el código anterior y recarga la interfaz de inmediato (sin confirmación).'

L['Debug Frame']             = 'Ventana de depuración'
L['Evaluate a variable or return a function'] = 'Evalúa una variable o devuelve una función'
L['History:']                = 'Historial:'
L['Output:']                 = 'Salida:'
L['ERROR']                   = 'ERROR'
