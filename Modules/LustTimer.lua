local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local SharedMedia = LibStub("LibSharedMedia-3.0")

private.LustTimer = {}

local registeredAuraSoundIDs = {}

local function UnregisterLustSounds()
    for _, soundID in ipairs(registeredAuraSoundIDs) do
        C_UnitAuras.RemoveAuraSound(soundID)
    end
    wipe(registeredAuraSoundIDs)
end

local function RegisterLustSounds()
    UnregisterLustSounds()

    local layout = private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT]
    local soundName = layout and layout.sound
    if not soundName or soundName == "None" then
        return
    end

    local soundFile = SharedMedia:Fetch("sound", soundName)
    if not soundFile then
        return
    end

    for spellId in pairs(private.lustBuffIds) do
        local soundID = C_UnitAuras.AddAuraSound(Enum.UnitAuraSoundTrigger.Added, {
            unitToken = "player",
            spellID = spellId,
            soundFileName = soundFile,
            outputChannel = "Master",
        })
        if soundID then
            table.insert(registeredAuraSoundIDs, soundID)
        end
    end
end
private.RegisterLustSounds = RegisterLustSounds

local function ShowLustTimer()
    if not private.lustTimer then
        return
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
    ToggleLustTimer(shouldLustTimerBeShown())
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
                    -- Re-register the aura-applied sound and give an immediate preview.
                    RegisterLustSounds()
                    local soundFile = SharedMedia:Fetch("sound", value)
                    if soundFile then
                        PlaySoundFile(soundFile, "Master")
                    end
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

    if not private.lustTimer then
        private.lustTimer = AceGui:Create("MQOL_LustTimer")
    end
    private.lustTimer:ApplySettings()
    ToggleLustTimer(shouldLustTimerBeShown())

    RegisterLustSounds()
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        if not private.lustTimer then
            private.lustTimer = AceGui:Create("MQOL_LustTimer")
        end
        private.lustTimer:ApplySettings()
        private.lustTimer.frame:Show()
        private.lustTimer:SetPreview(true)
        SetupEditModeSettings(private.lustTimer.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.lustTimer then
        private.lustTimer:SetPreview(false)
        ToggleLustTimer(shouldLustTimerBeShown())
    end
end)
