--- @alias LibIconPicker_CallbackFn fun(sel:LibIconPicker_Selection) | "function(sel) end"

--- @class LibIconPicker
--- @field Open fun(self:LibIconPicker, callback:LibIconPicker_CallbackFn, options:LibIconPicker_Options)

--- @class LibIconPicker_Selection
--- @field textInputValue string|nil The final text input value, if enabled
--- @field icon number The ID of the selected entity (spell or item)

--- @class LibIconPicker_TextInputOptions
--- @field value string|nil
--- @field label string|nil
--- @field min number|nil
--- @field max number|nil

--- @class LibIconPicker_Options
--- @field icon IconIDOrPath|nil Set the selected icon/texture. nil defaults to the question-mark icon (ID=134400)
--- @field showTextInput boolean|nil Defaults to false
--- @field textInput LibIconPicker_TextInputOptions|nil Text Input Options (only if showTextInput)
--- @field anchor LibIconPicker_Anchor

--[[-----------------------------------------------------------------------------
AnchorPoint
-------------------------------------------------------------------------------]]
--- @alias LibIconPicker_AnchorPoint string | "'TOPLEFT'" | "'TOPRIGHT'" | "'BOTTOMLEFT'" | "'BOTTOMRIGHT'" | "'TOP'" | "'BOTTOM'" | "'LEFT'" | "'RIGHT'" | "'CENTER'"

--[[-----------------------------------------------------------------------------
Anchor
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_Anchor
--- @field point LibIconPicker_AnchorPoint
--- @field relativePoint LibIconPicker_AnchorPoint
--- @field relativeTo any
--- @field x number
--- @field y number

--[[-----------------------------------------------------------------------------
CallbackInfo
-------------------------------------------------------------------------------]]
--- @class LibIconPicker_CallbackInfo
--- @field callback LibIconPicker_CallbackFn
--- @field opt LibIconPicker_Options

