local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")

local spells = {
    "192002", -- Food and Drink
    "185710", -- Sugar-Crusted Fish Feast
    "10257", -- Food
    "455289" -- eating
}
local spellNames = {}
for _, spellID in ipairs(spells) do
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    spellNames[spellInfo.name] = true
end

local FindComChannel = function()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return nil
    end
end

local eatingDebounce = 0
local EATING_DEBOUNCE_DURATION = 30 -- seconds
local activeAuraInstanceIds = {}
local function SendEatingMessage(auraInstanceID)
    if activeAuraInstanceIds[auraInstanceID] then
        return
    end
    activeAuraInstanceIds[auraInstanceID] = true
    if GetTime() - eatingDebounce > EATING_DEBOUNCE_DURATION then
        local channel = FindComChannel()
            eatingDebounce = GetTime()
        if channel then
            C_ChatInfo.SendChatMessage(private.getLocalisation("eatingReminderMessage"), channel)
        end
    end
end

function private.Addon:UNIT_AURA(event, unit, info)
    if not private.db.profile.enableEatingReminder then
        return
    end
    if not unit == "player" then
        return
    end
    if C_ChatInfo.InChatMessagingLockdown() then
        return
    end
    if not info then
        return
    end
    if info.isFullUpdate then
        for spellName in pairs(spellNames) do
            local auraData = C_UnitAuras.GetAuraDataBySpellName("player", spellName, "HELPFUL")
            local hasBuff = auraData ~= nil
            if hasBuff then
                SendEatingMessage(auraData.auraInstanceID)
                return
            end
        end
    end
    if info.addedAuras then
        for _, auraInfo in pairs(info.addedAuras) do
            if issecretvalue(auraInfo.name) then
                return
            elseif auraInfo.isHelpful and spellNames[auraInfo.name] then
                SendEatingMessage(auraInfo.auraInstanceID)
                return
            end
        end
    end
end
