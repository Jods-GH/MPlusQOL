local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local LibEditMode = LibStub("LibEditMode")
local variables = {
    position = {
        x = 428,
        point = "BOTTOM",
        y = 22,
    },
}
private.BrezTimer = {}

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
    private.brezTimer:ApplySettings()
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

local function shouldBrezTimerBeShown()
    return C_ChallengeMode.IsChallengeModeActive() or C_InstanceEncounter.IsEncounterInProgress()
end


function private.BrezTimer:CHALLENGE_MODE_START(event)
    ToggleBrezTimer(true)
end

function private.BrezTimer:CHALLENGE_MODE_COMPLETED(event)
    ToggleBrezTimer(false)
end

function private.BrezTimer:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleBrezTimer(true)
end

function private.BrezTimer:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, groupSize)
    ToggleBrezTimer(shouldBrezTimerBeShown())
end

function private.BrezTimer:ZONE_CHANGED_NEW_AREA(event)
    ToggleBrezTimer(shouldBrezTimerBeShown())
end

function private.BrezTimer:PLAYER_ENTERING_WORLD(event)
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

        local backgroundTextures = {}
        for _, textureName in ipairs(SharedMedia:List("background")) do
            local texPath = SharedMedia:Fetch("background", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texPath), textureName)
            table.insert(backgroundTextures, {
                text = display,
                value = textureName,
                isRadio = false,
            })
        end

        local areTextureSettingsExpanded = false
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
            {
                name = private.getLocalisation("expandTextureSettings"),
                expandedLabel = private.getLocalisation("collapseTextureSettings"),
                collapsedLabel = private.getLocalisation("expandTextureSettings"),
                desc = private.getLocalisation("textureSettingsDescription"),
                kind = LibEditMode.SettingType.Expander,
                default = areTextureSettingsExpanded,
                get = function()
                    return areTextureSettingsExpanded
                end,
                set = function(_, value)
                    areTextureSettingsExpanded = value
                end,
            },
            {
                name = private.getLocalisation("BrezTimerBackgroundTexture"),
                desc = private.getLocalisation("BrezTimerBackgroundTextureDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.brezTimer[layoutName].bgTexture
                end,
                set = function(layoutName, value)
                    private.db.global.brezTimer[layoutName].bgTexture = value
                    private.brezTimer:ApplySettings()
                end,
                default = "Blizzard Dialog Background",
                height = 300,
                values = backgroundTextures,
                hidden = function()
                    return not areTextureSettingsExpanded
                end,
            },
        })
        brezTimerHasBeenAddedToEditMode = true
    end
end

private.initializeBrezTimer = function()
    if not private.db.global.brezTimer then
        private.db.global.brezTimer = {}
    end
    if not private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            x = variables.position.x,
            y = variables.position.y,
            point = variables.position.point,
            bgTexture = "Blizzard Dialog Background",
            background = true,
        }
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        ToggleBrezTimer(true)
        private.brezTimer:StartTimer(true)
        SetupEditModeSettings(private.brezTimer.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.isInitialized then
        private.brezTimer:StartTimer(false)
        ToggleBrezTimer(shouldBrezTimerBeShown())
    end
end)
