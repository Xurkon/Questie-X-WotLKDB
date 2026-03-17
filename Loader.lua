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

    print("|cFF5EBAF3Questie|r|cFFDAFAFD-X|r [WotLKDB] Plugin registered.")

    plugin:FinishLoading("WotLKDB")
end)
