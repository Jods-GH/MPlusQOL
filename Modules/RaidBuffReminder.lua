local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local LibEditMode = LibStub("LibEditMode")

local classRaidbuffs = {
      [8] =  1459,--Arcane Intellect,  
      [1] =  6673,--"Battle Shout",
      [5] =  21562,--"Power Word: Fortitude",
      [11] =  1126,--"Mark of the Wild",
      [7] =  462854,--"Skyfury",
      [13] =  364342, -- Blessing of the Bronze
}
local raidbuffs = {}
for classId, spellID in pairs(classRaidbuffs) do
    raidbuffs[spellID] = true
end

local function CreateRaidBuffReminder()
    local widget = AceGui:Create("MQOL_RaidBuffReminder")
    widget.frame:Show()
    return widget
end

local function ShowRaidBuffReminder(spellID)
    if not private.raidBuffReminder then
        private.raidBuffReminder = CreateRaidBuffReminder()
    end
    private.raidBuffReminder:SetSpellID(spellID)

    if not private.raidBuffReminder.frame:IsShown() then
        private.raidBuffReminder.frame:Show()
    end
end

local function HideRaidBuffReminder()
    if private.raidBuffReminder then
        private.raidBuffReminder.frame:Hide()
    end
end

local function ToggleRaidBuffReminder(spellID)
    if spellID then
        ShowRaidBuffReminder(spellID)
    else
        HideRaidBuffReminder()
    end
end


local function getPlayerBuffId()
    local class, classFile, classID = UnitClass("player")
    local spellID = classRaidbuffs[classID]
    return spellID
end

local function shouldRaidBuffReminderBeShown()
    --print("shouldRaidBuffReminderBeShown")
    local spellID = getPlayerBuffId()
    if not spellID then
        --print("No raid buff found for class " .. UnitClass("player"))
        return false
    end
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    if not issecretvalue(spellInfo) 
    and not C_RestrictedActions.IsAddOnRestrictionActive(0) -- combat
    and not C_RestrictedActions.IsAddOnRestrictionActive(1) -- encounter
    and not C_RestrictedActions.IsAddOnRestrictionActive(2) -- ChallengeMode
    and not C_RestrictedActions.IsAddOnRestrictionActive(3) -- PvP
    
    then 
        --print("Checking for raid buff " .. spellInfo.name .. " (" .. spellID .. ")")
        local hasBuffAmount, totalAmount = 0, GetNumGroupMembers() + 1
        for i = 1, GetNumGroupMembers() do
            local unit = IsInRaid() and "raid"..i or "party" .. i
            if not UnitExists(unit) or UnitIsDeadOrGhost(unit) or not C_Spell.IsSpellInRange(spellID, unit) then
                totalAmount = totalAmount - 1
            else
                if issecretvalue(C_UnitAuras.GetAuraDataBySpellName(unit, spellInfo.name, "HELPFUL")) then
                    --print("Unit " .. unit .. " has the buff, but it's a secret value, so skipping it")
                    return false
                else
                    local auraData = C_UnitAuras.GetAuraDataBySpellName(unit, spellInfo.name, "HELPFUL")
                    if auraData then
                        hasBuffAmount = hasBuffAmount + 1
                    end
                end
            end
        end      
        if C_UnitAuras.GetAuraDataBySpellName("player", spellInfo.name, "HELPFUL") then
            hasBuffAmount = hasBuffAmount + 1
        end
        if hasBuffAmount < totalAmount then
            --print("Player is missing raid buff " .. spellInfo.name .. ", showing reminder. " .. hasBuffAmount .. "/" .. totalAmount .. " have the buff.")
            return spellID
        else
            --print("Player has raid buff " .. spellInfo.name .. ". " .. hasBuffAmount .. "/" .. totalAmount .. " have the buff.")
            return false
        end
    end
    if C_SpellActivationOverlay.IsSpellOverlayed(spellID) then
        --print("Player is missing raid buff " .. spellInfo.name .. " and it is currently active, showing reminder.")
        return spellID
    end
    --print("fallback return")
    return false
end

function private.Addon:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(event, spellID)
    --print("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", spellID)
    if raidbuffs[spellID] then
        ToggleRaidBuffReminder(spellID)
    end
end

function private.Addon:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(event, spellID)
    --print("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", spellID)
    if raidbuffs[spellID] then
        ToggleRaidBuffReminder(false)
    end
end

function private.Addon:READY_CHECK(event)
    ToggleRaidBuffReminder(shouldRaidBuffReminderBeShown())
end

function private.Addon:READY_CHECK_FINISHED(event)
    ToggleRaidBuffReminder(false)
end

function private.Addon:UNIT_SPELLCAST_SUCCEEDED(event, unit, _, spellID)
    if unit == "player" and raidbuffs[spellID] then
        C_Timer.After(1, function() -- we should instead listen to UNIT_AURA but this should be good enough and is less expensive than checking auras every time they change
            ToggleRaidBuffReminder(shouldRaidBuffReminderBeShown())
        end)
    end
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.raidBuffReminder = private.db.global.raidBuffReminder or {}
    private.db.global.raidBuffReminder[layoutName] = private.db.global.raidBuffReminder[layoutName] or {}
    private.db.global.raidBuffReminder[layoutName].x = x
    private.db.global.raidBuffReminder[layoutName].y = y
    private.db.global.raidBuffReminder[layoutName].point = point

    private.raidBuffReminder.frame:ClearAllPoints()
    private.raidBuffReminder.frame:SetPoint(point, UIParent, point, x, y)
end

local raidBuffReminderHasBeenAddedToEditMode = false
local function SetupEditModeSettings(frame)
    if not raidBuffReminderHasBeenAddedToEditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, private.RaidBuffReminderVariables.position,
            "MPlus QOL - " .. private.getLocalisation("RaidBuffReminder"))


        LibEditMode:AddFrameSettings(frame, {
            {
                name = private.getLocalisation("enableRaidBuffReminder"),
                desc = private.getLocalisation("enableRaidBuffReminderDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.raidBuffReminder[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.raidBuffReminder[layoutName].enabled = value
                end,
            },
            {
                name = private.getLocalisation("raidBuffReminderSize"),
                desc = private.getLocalisation("raidBuffReminderSizeDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.RaidBuffReminderVariables.size,
                get = function(layoutName)
                    return private.db.global.raidBuffReminder[layoutName].size
                end,
                set = function(layoutName, value)
                    private.db.global.raidBuffReminder[layoutName].size = value
                    private.raidBuffReminder:ApplySettings()
                end,
                minValue = 1,
                maxValue = 200,
                valueStep = 1,
            },
        })
        raidBuffReminderHasBeenAddedToEditMode = true
    end
end

private.initializeRaidBuffReminder = function()
    if not private.db.global.raidBuffReminder then
        private.db.global.raidBuffReminder = {}
    end
    if not private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            x = private.RaidBuffReminderVariables.position.x,
            y = private.RaidBuffReminderVariables.position.y,
            point = private.RaidBuffReminderVariables.position.point,
            size = private.RaidBuffReminderVariables.size,
        }
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        local spellID = getPlayerBuffId()
        if not spellID then
            spellID = 1459 -- Arcane Intellect as a default icon for edit mode
        end
        ToggleRaidBuffReminder(spellID)
        SetupEditModeSettings(private.raidBuffReminder.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.isInitialized then
        ToggleRaidBuffReminder(shouldRaidBuffReminderBeShown())
    end
end)
