-- Guild Class Colors Addon
-- Version: 1.1.0

local addon = CreateFrame("Frame")
local locale = GetLocale()

-- Debug function
local function debug(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00GuildClassColors:|r " .. tostring(msg))
end

-- Table of class names in different languages
local CLASS_NAMES = {
    ["enUS"] = {
        ["WARRIOR"] = "Warrior",
        ["MAGE"] = "Mage",
        ["ROGUE"] = "Rogue",
        ["DRUID"] = "Druid",
        ["HUNTER"] = "Hunter",
        ["SHAMAN"] = "Shaman",
        ["PRIEST"] = "Priest",
        ["WARLOCK"] = "Warlock",
        ["PALADIN"] = "Paladin"
    },
    ["esES"] = {
        ["WARRIOR"] = "Guerrero",
        ["MAGE"] = "Mago",
        ["ROGUE"] = "Pícaro",
        ["DRUID"] = "Druida",
        ["HUNTER"] = "Cazador",
        ["SHAMAN"] = "Chamán",
        ["PRIEST"] = "Sacerdote",
        ["WARLOCK"] = "Brujo",
        ["PALADIN"] = "Paladín"
    },
    ["esMX"] = {  -- Agregamos soporte para español de México también
        ["WARRIOR"] = "Guerrero",
        ["MAGE"] = "Mago",
        ["ROGUE"] = "Pícaro",
        ["DRUID"] = "Druida",
        ["HUNTER"] = "Cazador",
        ["SHAMAN"] = "Chamán",
        ["PRIEST"] = "Sacerdote",
        ["WARLOCK"] = "Brujo",
        ["PALADIN"] = "Paladín"
    }
}

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

-- Función para obtener el nombre de la clase en el idioma correcto
local function GetLocalizedClassName(className)
    if not className then return "" end
    
    -- Convertimos el className a mayúsculas para asegurar consistencia
    className = className:upper()
    
    -- Determinamos qué tabla de idioma usar
    local languageTable = CLASS_NAMES[locale]
    if not languageTable then
        languageTable = CLASS_NAMES["enUS"]
        debug("Locale " .. tostring(locale) .. " no soportado, usando enUS")
    end
    
    -- Buscamos la traducción
    local localizedName = languageTable[className]
    if not localizedName then
        debug("Clase " .. tostring(className) .. " no encontrada en la tabla de traducciones")
        return className
    end
    
    return localizedName
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
                        local localizedName = GetLocalizedClassName(className)
                        local colorCode = CLASS_COLORS[className:upper()] or "|cFFFFFFFF"
                        classText:SetText(colorCode .. localizedName .. "|r")
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
        -- Debug message para verificar el locale
        debug("Addon cargado. Locale detectado: " .. tostring(locale))
        
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