# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DevSuite is a World of Warcraft addon dev toolkit: a debug UI and code editor for evaluating Lua on the fly, `/etrace` preset filters, frame-under-mouse inspection, and auto-load/auto-show control for other dev-facing addons (DebugChatFrame, etc.). It supports every WoW client (Retail, Classic Era, TBC, Wrath, Cata, Mists).

## Build & Release

See "Build & Release (WoW addons)" in the global `~/.claude/CLAUDE.md`.

## Architecture

Single addon in the `DevSuite/` subfolder. A single `DevSuite.toc` lists every client in its `## Interface:` line and loads `ThirdParty\ThirdParty.xml`, then `DevSuite.xml`, which wires up load order. Entry point is `DevSuite/DevSuite.lua`.

### Namespace & module registry

All code uses a central namespace object (`ns`) defined in `Libs/Global/Namespace.lua`, mixing in `Kapresoft-AceLib-2-0`, `Kapresoft-DebugChatFrameMixin-2-0` and `Kapresoft-GameVersionMixin-2-0`. Modules register into `ns.O` and are accessed via `ns.O.ModuleName`. Global constants (message names, etc.) live on `ns.GC` (`GlobalConstants.lua`), a plain constants table rather than ABP's `ns:msg()` namespaced-string helper.

### Key modules (`DevSuite/Libs/`)

| Folder | Role |
|---|---|
| `Global/` | Namespace, API surface, global constants |
| `Database/` | AceDB setup/init (`AceDbInitializerMixin`), schema |
| `Options/` | Options dialog UI |
| `Dialog/` | Debug-eval popup dialog (`PopupDebugDialog`, `DebugDialog`, `DialogWidgetMixin`) |
| `CodeEditor/` | Code editor dialog and bundled fonts |
| `Controller/` | `MainController` (top-level wiring) and `ConfigDialogController` |
| `EventTrace/` | `/etrace` preset filters UI, event trace utilities |
| `Console/` | Dev console module |
| `Hooks/` | `hooksecurefunc`-based integrations |
| `Developer/` | Dev-only settings/utilities, icon picker |
| `Annotations/` | EmmyLua type annotations |
| `Locales/` | Localization |
| `Assets/` | Textures |

### Addon lifecycle

`o:OnInitialize()` in `DevSuite.lua` calls `O.AceDbInitializerMixin:New(self):InitDb()`, then builds the Options dialog and registers slash commands. `O.MainController:Init(o)` runs at file-load time (before `OnInitialize`), not inside it; check `MainController.lua` before assuming lifecycle ordering matches ABP's Core/BarsUI/OptionsUI split.

### Dev-only code

Dev-only XML includes are wrapped in `<!--@do-not-package@-->` / `<!--@end-do-not-package@-->` (see `DevSuite.xml`). The packager strips these blocks in release builds.

## Key conventions

- **Mixin-based OOP:** composition via `Mixin()`/`CreateFromMixins()`, not inheritance chains. Keep mixins focused on a single concern.
- **Testing in game:** `/etrace` (DevSuite's own feature) to watch events, `/fstack` to inspect frames, `/dump` to inspect values.
- **Diagnostics:** several EmmyLua diagnostic categories are disabled repo-wide; don't chase warnings in those categories.
- **SavedVariables:** `DEVS_DB` (account), `DEVS_CHARACTER_DB` (per-character), `DEVS_DEBUG_MODE`/`DEVS_DEBUG_ENABLED_CATEGORIES` (debug state); see `DevSuite.toc`.
- **OptionalDeps:** `Ace3, DebugChatFrame, Blizzard_EventTrace, Blizzard_DebugTools`. Ace3 is embedded; DevSuite should degrade gracefully, not error, when any of the others isn't installed or enabled. Guard integration points with them accordingly.

## Code style

Formatting is enforced by `stylua.toml`: 100-column width, 2-space indent, Unix line endings, prefer single quotes, keep parens on function calls, collapse simple statements onto one line. Match this on touched lines; don't reformat whole files as a side effect of an unrelated change.
