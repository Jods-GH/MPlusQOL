local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local LibEditMode = LibStub("LibEditMode")

local variables = {
    position = {
        point = 'CENTER',
        y = 0,
        x = -50,
    },
    threshhold = 0.95,
    sound = "None",
}

local function CreateRepairReminder()
    local widget = AceGui:Create("MQOL_RepairReminder")
    widget.frame:Show()
    return widget
end

local function HandleReminderSound()
    local sound = SharedMedia:Fetch("sound", private.db.global.repairReminder[private.ACTIVE_EDITMODE_LAYOUT].sound)
    PlaySoundFile(sound, "Master")
end

local function ShowRepairReminder(lowestDurabilityPercent, durabilityPercent)
    if not private.repairReminder then
        private.repairReminder = CreateRepairReminder()
        HandleReminderSound()
    end
    private.repairReminder:SetDurabilityPercent(lowestDurabilityPercent, durabilityPercent)

    if not private.repairReminder.frame:IsShown() then
        private.repairReminder.frame:Show()
        HandleReminderSound()
    end
end

local function HideRepairReminder()
    if private.repairReminder then
        private.repairReminder.frame:Hide()
    end
end

local function ToggleRepairReminder(shouldShow, lowestDurabilityPercent, durabilityPercent)
    if shouldShow then
        ShowRepairReminder(lowestDurabilityPercent, durabilityPercent)
    else
        HideRepairReminder()
    end
end

function private.CheckForRepair()
    if not private.db.global.repairReminder[private.ACTIVE_EDITMODE_LAYOUT].enabled then
        return
    end
    local shouldShow = false
    local totalCurrentDurability, totalMaxDurability = 0, 0
    local lowestDurabilityPercent = 1
    for i = 1, 18 do
        local current, maximum = GetInventoryItemDurability(i)
        if current and maximum then
            totalCurrentDurability = totalCurrentDurability + current
            totalMaxDurability = totalMaxDurability + maximum
            if (current / maximum) < lowestDurabilityPercent then
                lowestDurabilityPercent = current / maximum
            end
            if (current / maximum) < private.db.global.repairReminder[private.ACTIVE_EDITMODE_LAYOUT].threshhold then
                shouldShow = true
            end
        end
    end
    local durabilityPercent = totalCurrentDurability / totalMaxDurability
    ToggleRepairReminder(shouldShow, lowestDurabilityPercent, durabilityPercent)
end

function private.Addon:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
    if IsResting() then
        private.CheckForRepair()
    else
        ToggleRepairReminder(false)
    end
end

function private.Addon:PLAYER_UPDATE_RESTING(event, eventInfo, initialState)
    if IsResting() then
        private.CheckForRepair()
    else
        ToggleRepairReminder(false)
    end
end

function private.Addon:UPDATE_INVENTORY_DURABILITY()
    if IsResting() then
        private.CheckForRepair()
    else
        ToggleRepairReminder(false)
    end
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.repairReminder = private.db.global.repairReminder or {}
    private.db.global.repairReminder[layoutName] = private.db.global.repairReminder[layoutName] or {}
    private.db.global.repairReminder[layoutName].x = x
    private.db.global.repairReminder[layoutName].y = y
    private.db.global.repairReminder[layoutName].point = point

    private.repairReminder.frame:ClearAllPoints()
    private.repairReminder.frame:SetPoint(point, UIParent, point, x, y)
end

local repairReminderHasBeenAddedToEditMode = false
local function SetupEditModeSettings(frame)
    if not repairReminderHasBeenAddedToEditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, variables.position,
            "MPlus QOL - " .. private.getLocalisation("RepairReminder"))

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
                name = private.getLocalisation("enableRepairReminder"),
                desc = private.getLocalisation("enableRepairReminderDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.repairReminder[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.repairReminder[layoutName].enabled = value
                end,
            },
            {
                name = private.getLocalisation("repairReminderSound"),
                desc = private.getLocalisation("repairReminderSoundDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.repairReminder[layoutName].sound
                end,
                set = function(layoutName, value)
                    private.db.global.repairReminder[layoutName].sound = value
                    HandleReminderSound()
                end,
                default = variables.sound,
                height = 300,
                values = soundOptions,
            },
            {
                name = private.getLocalisation("repairReminderThreshhold"),
                desc = private.getLocalisation("repairReminderThreshholdDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = variables.threshhold,
                get = function(layoutName)
                    return private.db.global.repairReminder[layoutName].threshhold
                end,
                set = function(layoutName, value)
                    private.db.global.repairReminder[layoutName].threshhold = value
                end,
                minValue = 0,
                maxValue = 1,
                valueStep = 0.05,
                formatter = function(value)
                    return string.format("%.0f%%", value * 100)
                end,
            },
        })
        repairReminderHasBeenAddedToEditMode = true
    end
end

private.initializeRepairReminder = function()
    if not private.db.global.repairReminder then
        private.db.global.repairReminder = {}
    end
    if not private.db.global.repairReminder[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.repairReminder[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            x = variables.position.x,
            y = variables.position.y,
            point = variables.position.point,
            threshhold = variables.threshhold,
            sound = variables.sound,
        }
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        ToggleRepairReminder(true, 0.8, 0.85)
        SetupEditModeSettings(private.repairReminder.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.isInitialized then
        private.CheckForRepair()
    end
end)
