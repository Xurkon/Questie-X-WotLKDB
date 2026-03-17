-- WotLK DB split-files populate QuestieX_WotLKDB_* globals at addon load time.
-- QuestieInit:LoadBaseDB() consumes those globals directly at init time.
-- This file only handles plugin registration at PLAYER_LOGIN.

local _wotlkDBFrame = CreateFrame("Frame")
_wotlkDBFrame:RegisterEvent("PLAYER_LOGIN")
_wotlkDBFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")

    local QuestiePluginAPI = QuestieLoader and QuestieLoader.ImportModule and QuestieLoader:ImportModule("QuestiePluginAPI")
    if not QuestiePluginAPI then return end

    local plugin = QuestiePluginAPI:RegisterPlugin("WotLKDB")
    if not plugin then return end

    -- Read counts stored by QuestieInit:LoadBaseDB() before the globals were cleared
    local counts = _G.QuestieX_WotLKDB_Counts
    if counts then
        plugin.stats.QUEST  = counts.QUEST  or 0
        plugin.stats.NPC    = counts.NPC    or 0
        plugin.stats.OBJECT = counts.OBJECT or 0
        plugin.stats.ITEM   = counts.ITEM   or 0
        _G.QuestieX_WotLKDB_Counts = nil
    end

    local questCount = plugin.stats.QUEST
    local npcCount   = plugin.stats.NPC
    local objCount   = plugin.stats.OBJECT
    local itemCount  = plugin.stats.ITEM

    print("|cFF5EBAF3Questie|r|cFFDAFAFD-X|r [WotLKDB] Plugin registered.")
    Questie:Debug(Questie.DEBUG_DEVELOP, "[WotLKDB] Quests:" .. questCount .. " NPCs:" .. npcCount .. " Objects:" .. objCount .. " Items:" .. itemCount)
    if questCount == 0 then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[WotLKDB] CRITICAL: questData is empty! Check DB plugin load order.")
    end

    plugin:FinishLoading("WotLKDB")
end)
