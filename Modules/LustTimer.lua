local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local SharedMedia = LibStub("LibSharedMedia-3.0")

private.LustTimer = {}

private.HandleLustSound = function()
    local sound = SharedMedia:Fetch("sound", private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].sound)
    PlaySoundFile(sound, "Master")
end

local lustIds = {
    [57723] = true,          -- Exhaustion
    [57724] = true,          -- Sated
    [80354] = true,          -- Temporal Displacement
    [95809] = true,          -- Hunter Pet Insanity
    [160455] = true, [264689] = true, -- Hunter Pet Fatigued
    [390435] = true,         -- Exhaustion
}

local activeLustTimerInstanceID = nil
---@param event Event
---@param unit UnitId
---@param updateInfo UnitAuraUpdateInfo
function private.LustTimer:UNIT_AURA_PLAYER(event, unit, updateInfo)
    if not private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].enabled then
        return
    end
    if not private.lustTimer then
        return
    end
    if issecretvalue(updateInfo) then
        return
    end
    if updateInfo.isFullUpdate then
        for spellId in pairs(lustIds) do
            local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellId)
            local hasBuff = auraData ~= nil
            if hasBuff then
                local remainingDuration = auraData.expirationTime - GetTime()
                private.lustTimer:TriggerLust(remainingDuration)
                activeLustTimerInstanceID = auraData.auraInstanceID
                return
            end
        end
    else
        if updateInfo.removedAuraInstanceIDs then
            for _, auraInstanceId in pairs (updateInfo.removedAuraInstanceIDs) do
                if auraInstanceId == activeLustTimerInstanceID then
                    private.lustTimer:TriggerLust(0)
                    activeLustTimerInstanceID = nil
                end
            end
        end
        if updateInfo.updatedAuraInstanceIDs then
            for _, auraInstanceId in pairs (updateInfo.updatedAuraInstanceIDs) do
                if auraInstanceId == activeLustTimerInstanceID then
                    local auraData = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraInstanceId)
                    if not auraData or auraData.expirationTime == nil then
                        private.lustTimer:TriggerLust(0)
                        activeLustTimerInstanceID = nil
                    end
                    private.lustTimer:TriggerLust(auraData.expirationTime - GetTime())
                end
            end
        end
        if updateInfo.addedAuras then
            for _, aura in pairs (updateInfo.addedAuras) do
                if not issecretvalue(aura.spellId) then
                    if lustIds[aura.spellId] then
                        private.lustTimer:TriggerLust(aura.expirationTime - GetTime())
                        activeLustTimerInstanceID = aura.auraInstanceID
                        return
                    end
                end
            end
        end
    end
end

local function CreateLustTimer()
    local widget = AceGui:Create("MQOL_LustTimer")
    widget.frame:Show()
    return widget
end

local function ShowLustTimer()
    if not private.lustTimer then
        private.lustTimer = CreateLustTimer()
    end

    if not private.lustTimer.frame:IsShown() then
        private.lustTimer.frame:Show()
    end
end

local function HideLustTimer()
    if private.lustTimer then
        private.lustTimer.frame:Hide()
    end
end

local function ToggleLustTimer(shouldShow)
    if shouldShow then
        ShowLustTimer()
    else
        HideLustTimer()
    end
end

local function shouldLustTimerBeShown()
    return C_ChallengeMode.IsChallengeModeActive() or C_InstanceEncounter.IsEncounterInProgress()
end


function private.LustTimer:CHALLENGE_MODE_START(event)
    ToggleLustTimer(true)
end

function private.LustTimer:CHALLENGE_MODE_COMPLETED(event)
    ToggleLustTimer(false)
end

function private.LustTimer:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleLustTimer(true)
end

function private.LustTimer:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleLustTimer(shouldLustTimerBeShown())
end

function private.LustTimer:ZONE_CHANGED_NEW_AREA(event)
    ToggleLustTimer(shouldLustTimerBeShown())
end

function private.LustTimer:PLAYER_ENTERING_WORLD(event)
    ToggleLustTimer(shouldLustTimerBeShown())
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.lustTimer = private.db.global.lustTimer or {}
    private.db.global.lustTimer[layoutName] = private.db.global.lustTimer[layoutName] or {}
    private.db.global.lustTimer[layoutName].x = x
    private.db.global.lustTimer[layoutName].y = y
    private.db.global.lustTimer[layoutName].point = point

    private.lustTimer:ApplySettings()
end

local lustTimerHasBeenAddedToEditMode = false
local function SetupEditModeSettings(frame)
    if not lustTimerHasBeenAddedToEditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, private.lustTimerVariables.position,
            "MPlus QOL - " .. private.getLocalisation("LustTimer"))

        local soundOptions = {}
        for _, sound in ipairs(SharedMedia:List("sound")) do
            table.insert(soundOptions, {
                text = sound,
                value = sound,
                isRadio = false,
            })
        end

        LibEditMode:AddFrameSettings(frame, {
            {
                name = private.getLocalisation("enableLustTimer"),
                desc = private.getLocalisation("enableLustTimerDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.lustTimer[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.lustTimer[layoutName].enabled = value
                end,
            },
            {
                name = private.getLocalisation("lustTimerSize"),
                desc = private.getLocalisation("lustTimerSizeDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.lustTimerVariables.size,
                get = function(layoutName)
                    return private.db.global.lustTimer[layoutName].size
                end,
                set = function(layoutName, value)
                    private.db.global.lustTimer[layoutName].size = value
                    private.lustTimer:ApplySettings()
                end,
                minValue = 1,
                maxValue = 200,
                valueStep = 1,
            },           
            {
                name = private.getLocalisation("lustSound"),
                desc = private.getLocalisation("lustSoundDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.lustTimer[layoutName].sound
                end,
                set = function(layoutName, value)
                    private.db.global.lustTimer[layoutName].sound = value
                    private.HandleLustSound()
                end,
                default = private.lustTimerVariables.sound,
                height = 300,
                values = soundOptions,
            },
        })
        lustTimerHasBeenAddedToEditMode = true
    end
end

private.initializeLustTimer = function()
    if not private.db.global.lustTimer then
        private.db.global.lustTimer = {}
    end
    if not private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            size = private.lustTimerVariables.size,
            x = private.lustTimerVariables.position.x,
            y = private.lustTimerVariables.position.y,
            point = private.lustTimerVariables.position.point,
            sound = private.lustTimerVariables.sound,
        }
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        if not private.lustTimer then
            private.lustTimer = AceGui:Create("MQOL_LustTimer")
            private.lustTimer.frame:Show()
            private.lustTimer.frame.startTime = GetTime() - 10
            local loopDuration = 5
            private.lustTimer:TriggerLust(loopDuration)
            private.lustTimer.frame:SetScript("OnUpdate", function(self, elapsed)
                if self.startTime and GetTime() - self.startTime >= loopDuration  then
                    private.lustTimer:TriggerLust(loopDuration)
                    self.startTime = GetTime()
                end
            end)
            if private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT] then
                private.lustTimer.frame:SetPoint(private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].point,
                    UIParent,
                    private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].point,
                    private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].x,
                    private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].y)
            else
                private.lustTimer.frame:SetPoint("CENTER", UIParent, "CENTER")
            end
        end
        SetupEditModeSettings(private.lustTimer.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.lustTimer then
        private.lustTimer.frame:SetScript("OnUpdate", nil)
        private.lustTimer:Release()
        private.lustTimer = nil
    end
end)
