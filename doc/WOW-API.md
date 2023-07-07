## API Notes

### Expansion-Specific Functions

**See:** Interface/FrameXML/ActionBarController.lua

```lua
if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
    self:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR");
    self:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR");
end
```
