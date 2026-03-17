-- WotLK DB split-files populate QuestieX_WotLKDB_* globals at addon load time.
-- QuestieInit:LoadBaseDB() consumes those globals directly at init time.
-- This Loader only registers the plugin. Counts are stored by LoadBaseDB()
-- into _G.QuestieX_WotLKDB_Counts and read by the Database options panel.

local _wotlkDBFrame = CreateFrame("Frame")
_wotlkDBFrame:RegisterEvent("PLAYER_LOGIN")
_wotlkDBFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")

    local QuestiePluginAPI = QuestieLoader and QuestieLoader.ImportModule and QuestieLoader:ImportModule("QuestiePluginAPI")
    if not QuestiePluginAPI then return end

    local plugin = QuestiePluginAPI:RegisterPlugin("WotLKDB")
    if not plugin then return end

    -- Note: QuestieX_WotLKDB_Counts is set by QuestieInit:LoadBaseDB() which runs
    -- inside an async coroutine AFTER PLAYER_LOGIN. We intentionally do NOT read it
    -- here. The Database options panel reads _G.QuestieX_WotLKDB_Counts directly
    -- when it renders, by which time init is complete.

    print("|cFF5EBAF3Questie|r|cFFDAFAFD-X|r [WotLKDB] Plugin registered.")
    plugin:FinishLoading("WotLKDB")
end)
