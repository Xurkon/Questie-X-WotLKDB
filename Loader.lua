-- WotLK DB split-files populate addonTable at addon load time.
-- This Loader publishes them to globals that QuestieInit:LoadBaseDB() consumes.
local _, addonTable = ...

-- Helper to merge corrections into the main data tables
-- This ensures that overrides are applied correctly to the split-table format
local function merge(base, overrides)
    if not overrides then return end
    for id, data in pairs(overrides) do
        if not base[id] then
            base[id] = data
        else
            for key, value in pairs(data) do
                base[id][key] = value
            end
        end
    end
end

-- Apply all corrections before exporting to globals
local function applyAllCorrections()
    if not QuestieLoader then return end

    local modules = {
        { name = "QuestieTBCQuestFixes",    target = addonTable.questData,  methods = {"Load", "LoadFactionFixes"} },
        { name = "QuestieTBCNpcFixes",      target = addonTable.npcData,    methods = {"Load", "LoadFactionFixes"} },
        { name = "QuestieTBCItemFixes",     target = addonTable.itemData,   methods = {"Load", "LoadFactionFixes"} },
        { name = "QuestieTBCObjectFixes",   target = addonTable.objectData, methods = {"Load", "LoadFactionFixes"} },
        { name = "QuestieWotlkQuestFixes",  target = addonTable.questData,  methods = {"Load"} },
        { name = "QuestieWotlkNpcFixes",    target = addonTable.npcData,    methods = {"Load", "LoadFactionFixes", "LoadAutomatics"} },
        { name = "QuestieWotlkItemFixes",   target = addonTable.itemData,   methods = {"Load", "LoadFactionFixes"} },
        { name = "QuestieWotlkObjectFixes", target = addonTable.objectData, methods = {"Load", "LoadFactionFixes"} },
    }

    for _, modInfo in ipairs(modules) do
        local mod = QuestieLoader:ImportModule(modInfo.name)
        if mod then
            for _, methodName in ipairs(modInfo.methods) do
                if mod[methodName] then
                    merge(modInfo.target, mod[methodName](mod))
                end
            end
        end
    end
end

applyAllCorrections()

_G.QuestieX_WotLKDB_npc = addonTable.npcData
_G.QuestieX_WotLKDB_item = addonTable.itemData
_G.QuestieX_WotLKDB_object = addonTable.objectData
_G.QuestieX_WotLKDB_quest = addonTable.questData

_G.QuestieX_WotLKDB_npcKeys = addonTable.npcKeys
_G.QuestieX_WotLKDB_itemKeys = addonTable.itemKeys
_G.QuestieX_WotLKDB_objectKeys = addonTable.objectKeys
_G.QuestieX_WotLKDB_questKeys = addonTable.questKeys

-- This Loader also registers the plugin. Counts are stored by LoadBaseDB()
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
