## Taint Resolution & WotLKDB Restructure
- **[Architecture]** Refactored database files into smaller chunks using ddonTable, resolving global pollution and memory limits.
- **[Taint Fix]** Corrected WotLKDB exported global capitalization to match QuestieInit, preventing loading bugs and taint.
- **[Scripts]** Added automated node refactoring and splitting scripts.
- **[Version]** Bumped to 1.4.7.
