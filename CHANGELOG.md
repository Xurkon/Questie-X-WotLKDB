# Changelog

## v1.4.7 (2026-03-22)
- **[Architecture]** Refactored all monolithic database files to use an isolated `addonTable` rather than writing directly to the global `QuestieDB` variable. 
- **[Taint Prevention]** Completely eliminated global namespace pollution during database load to prevent `ADDON_ACTION_BLOCKED` errors on secure functions like `UseAction()` and `CastSpellByName()` in the core addon.
- **[Bugfix]** Fixed the capitalization of export globals in `Loader.lua` (`QuestieX_WotLKDB_npc` instead of `_NPC`) so the core addon can correctly absorb statistics and database contents during initialization.
