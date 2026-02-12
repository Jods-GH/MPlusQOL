local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")

local spells = {
    "192002", -- Food and Drink
    "185710", -- Sugar-Crusted Fish Feast
    "10257", -- Food
    "455289" -- eating
}
local spellNames = {}
local spellIcons = {}
for _, spellID in ipairs(spells) do
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    spellNames[spellInfo.name] = true
    spellIcons[spellInfo.iconID] = true
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


local function SendEatingMessage()
    local channel = FindComChannel()
    if channel then
        C_ChatInfo.SendChatMessage(private.getLocalisation("eatingReminderMessage"), channel)
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
            local hasBuff = C_UnitAuras.GetAuraDataBySpellName("player", spellName, "HELPFUL") ~= nil
            if hasBuff then
                SendEatingMessage()
                return
            end
        end
    end
    if info.addedAuras then
        for _, auraInfo in pairs(info.addedAuras) do
            if issecretvalue(auraInfo.name) then
                return
            elseif auraInfo.isHelpful and (spellNames[auraInfo.name] or spellIcons[auraInfo.icon]) then
                SendEatingMessage()
                return
            end
        end
    end
end
