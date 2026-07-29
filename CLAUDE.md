# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DevSuite is a World of Warcraft addon dev toolkit: a debug UI for evaluating Lua on the fly, event tracing (`/etrace`), frame-under-mouse inspection, and auto-load/auto-show control for other dev-facing addons (Addon Usage, DebugChatFrame, etc). It supports all WoW versions (Retail, Classic, TBC, Wrath, Cata, Mists).

## Build & Release

### Pull external library dependencies

```shell
w-sync-libs
# Output goes to .release/
```

### Deployment to local WoW installs

#### One-time deploy
```shell
w-deployer -c ./dev/deployer-config.lua
```

#### Continuous Deploy with 'quiet' -q and 'watch' -w mode

```shell
w-deployer -c ./dev/deployer-config.lua -qw
```

### Clean build
```shell
./dev/release-clean.sh
```

### Release process
1. Create pull requests
2. Create tag to publish--an automated github action will push any tag created
3. Verify CurseForge build is green, then publish the GitHub draft release

There are no automated tests. Validation is done in-game.

## Architecture

Single addon (not split into multiple TOCs like some of the other kapresoft addons). Entry point is `Core/DevSuite.lua`; `DevSuite.xml`/`DevSuite.toc` wire up load order.

### Namespace & module registry

All code uses a central namespace object (`ns`) defined in `Core/Global/Namespace.lua`, mixing in `Kapresoft-AceLib-2-0`, `Kapresoft-DebugChatFrameMixin-2-0`, and `Kapresoft-GameVersionMixin-2-0`. Modules register into `ns.O` and are accessed anywhere via `ns.O.ModuleName`. Global constants (message names, etc.) live on `ns.GC` (`GlobalConstants.lua`), analogous to ABP's `ns:msg()` convention but as a plain constants table rather than a namespaced-string helper.

### Key modules (`Core/`)

| Folder | Role |
|---|---|
| `Global/` | Namespace, API surface, global constants |
| `Database/` | AceDB setup/init (`AceDbInitializerMixin`) |
| `Options/` | Options dialog UI |
| `Dialog/` | Debug-eval popup dialog (`PopupDebugDialog`, `DebugDialogWidget`) |
| `Controller/` | `MainController` -- top-level wiring, invoked from `OnInitialize` |
| `EventTrace/` | `/etrace` preset filters UI, event trace utilities |
| `Developer/` | Dev-only settings/utilities, icon picker |
| `Console/` | Slash command handling |
| `Hooks/` | Hooksecurefunc-based integrations |
| `Annotations/` | EmmyLua type annotations (`DevSuite-Annotations.lua`, `LibIconPicker-Annotations.lua`) |
| `Locales/` | Localization |
| `Assets/` | Textures |

### Addon lifecycle

`o:OnInitialize()` in `Core/DevSuite.lua` calls `O.AceDbInitializerMixin:New(self):InitDb()`, then builds the Options dialog and registers slash commands. `O.MainController:Init(o)` is wired at file-load time (before `OnInitialize` runs), not inside it -- check `MainController.lua` before assuming lifecycle ordering matches ABP's Core/BarsUI/OptionsUI split.

## Key conventions

- **Mixin-based OOP** -- composition via `Mixin()`/`CreateFromMixins()`, not inheritance chains. Keep mixins focused on a single concern.
- **No unit test framework** -- test in-game. Use `/etrace` (DevSuite's own feature) to watch events, `/fstack` to inspect frames, `/dump` to inspect values.
- **EmmyLua annotations** -- the codebase uses EmmyLua (`---@param`, `---@return`, `---@class`) for IDE type checking. Maintain these on public APIs. `.emmyrc.json` disables several diagnostics repo-wide (`undefined-global`, `undefined-field`, `missing-fields`, `need-check-nil`, `unused`, etc.) and declares a large Blizzard-API globals list -- don't chase warnings in categories that are intentionally disabled there.
- **SavedVariables**: `DEVS_DB` (account), `DEVS_CHARACTER_DB` (per-character), `DEVS_DEBUG_MODE`/`DEVS_DEBUG_ENABLED_CATEGORIES` (debug state) -- see `DevSuite.toc`.
- **OptionalDeps, not RequiredDeps**: `Ace3, AddonUsage, DebugChatFrame, Blizzard_EventTrace` are all optional -- DevSuite should degrade gracefully, not error, if any of these aren't installed/enabled. Guard accordingly when touching integration points with these.

## Code style

Formatting is enforced by `stylua.toml`: 100-column width, 2-space indent, Unix line endings, prefer single quotes, keep parens on function calls, collapse simple statements onto one line. Match this on touched lines; don't reformat whole files as a side effect of an unrelated change.