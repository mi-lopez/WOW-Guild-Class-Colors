-- Guild Class Colors Addon
-- Version: 1.0.0

local addon = CreateFrame("Frame")

-- Table of class colors
local CLASS_COLORS = {
    ["WARRIOR"] = "|cFFC79C6E",
    ["MAGE"] = "|cFF40C7EB",
    ["ROGUE"] = "|cFFFFFF69",
    ["DRUID"] = "|cFFFF7D0A",
    ["HUNTER"] = "|cFFABD473",
    ["SHAMAN"] = "|cFF0070DE",
    ["PRIEST"] = "|cFFFFFFFF",
    ["WARLOCK"] = "|cFF9482C9",
    ["PALADIN"] = "|cFFF58CBA"
}

-- Simple function to format the class name
local function FormatClassName(className)
    if not className then return "" end
    return className:sub(1,1):upper() .. className:sub(2):lower()
end

-- Main update function
local function UpdateGuildColors()
    if not GuildFrame or not GuildFrame:IsVisible() then return end
    
    local offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
    local numTotal = GetNumGuildMembers()
    
    for i = 1, GUILDMEMBERS_TO_DISPLAY do
        local button = _G["GuildFrameButton"..i]
        if button then
            local classText = _G["GuildFrameButton"..i.."Class"]
            if classText then
                local index = offset + i
                if index <= numTotal then
                    local _, _, _, _, _, _, _, _, _, _, className = GetGuildRosterInfo(index)
                    if className then
                        local formattedName = FormatClassName(className)
                        local colorCode = CLASS_COLORS[className:upper()] or "|cFFFFFFFF"
                        classText:SetText(colorCode .. formattedName .. "|r")
                    end
                end
            end
        end
    end
end

-- Register events
addon:RegisterEvent("GUILD_ROSTER_UPDATE")
addon:RegisterEvent("ADDON_LOADED")

-- Event handler
addon:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "GuildClassColors" then
        -- Hook to the original update
        hooksecurefunc("GuildStatus_Update", UpdateGuildColors)
        -- Hook to the scroll
        if GuildListScrollFrame then
            GuildListScrollFrame:HookScript("OnVerticalScroll", 
                function(self, offset)
                    FauxScrollFrame_OnVerticalScroll(self, offset, GUILD_ITEM_HEIGHT, 
                        function()
                            GuildStatus_Update()
                        end)
                end)
        end
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "GUILD_ROSTER_UPDATE" then
        UpdateGuildColors()
    end
end)

-- Additional hook for when the window is displayed
if GuildFrame then
    GuildFrame:HookScript("OnShow", UpdateGuildColors)
end