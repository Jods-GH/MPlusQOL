local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local LibEditMode = LibStub("LibEditMode")
local variables = {
     position = {
        point = 'CENTER',
        y = 0,
        x = 0,
    },
}

local function CreateBrezTimer()
    local widget = AceGui:Create("MQOL_BrezTimer")
    widget.frame:Show()
    widget:StartTimer()
    return widget
end

local function ShowBrezTimer()
    if not private.brezTimer then
        private.brezTimer = CreateBrezTimer()
    end

    if not private.brezTimer.frame:IsShown() then
        private.brezTimer.frame:Show()
    end
end

local function HideBrezTimer()
    if private.brezTimer then
        private.brezTimer.frame:Hide()
    end
end

local function ToggleBrezTimer(shouldShow)
    if shouldShow then
        ShowBrezTimer()
    else
        HideBrezTimer()
    end
end


function private.Addon:CHALLENGE_MODE_START(event)
    ToggleBrezTimer(true)
end

function private.Addon:CHALLENGE_MODE_COMPLETED(event)
    ToggleBrezTimer(false)
end

function private.Addon:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleBrezTimer(true)
end

function private.Addon:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleBrezTimer(false)
end

local function shouldBrezTimerBeShown()
    return C_ChallengeMode.IsChallengeModeActive() or C_InstanceEncounter.IsEncounterInProgress()
end

function private.Addon:ZONE_CHANGED_NEW_AREA(event)
    ToggleBrezTimer(shouldBrezTimerBeShown())
end

function private.Addon:PLAYER_ENTERING_WORLD(event)
    ToggleBrezTimer(shouldBrezTimerBeShown())
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.brezTimer = private.db.global.brezTimer or {}
    private.db.global.brezTimer[layoutName] = private.db.global.brezTimer[layoutName] or {}
    private.db.global.brezTimer[layoutName].x = x
    private.db.global.brezTimer[layoutName].y = y
    private.db.global.brezTimer[layoutName].point = point

    private.brezTimer.frame:ClearAllPoints()
    private.brezTimer.frame:SetPoint(point, UIParent, point, x, y)
end

local brezTimerHasBeenAddedToEditMode = false
local function SetupEditModeSettings(frame)
    if not brezTimerHasBeenAddedToEditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, variables.position,
            "MPlus QOL - " .. private.getLocalisation("BrezTimer"))


        LibEditMode:AddFrameSettings(frame, {
            {
                name = private.getLocalisation("EnableBrezTimer"),
                desc = private.getLocalisation("EnableBrezTimerDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.brezTimer[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.brezTimer[layoutName].enabled = value
                end,
            },
        })
        brezTimerHasBeenAddedToEditMode = true
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    ToggleBrezTimer(true)
    private.brezTimer:StartTimer(true)
    SetupEditModeSettings(private.brezTimer.frame)
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
     private.brezTimer:StartTimer(false)
    ToggleBrezTimer(shouldBrezTimerBeShown())
end)
