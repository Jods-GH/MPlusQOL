local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

local function CreateRepairReminder()
    local widget = AceGui:Create("MQOL_RepairReminder")
    widget.frame:Show()
    return widget
end

local function HandleReminderSound()
    local sound = SharedMedia:Fetch("sound", private.db.profile.repairReminderSound)
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
    if not private.db.profile.enableRepairReminder then
        return
    end
    local shouldShow = false
    local totalCurrentDurability, totalMaxDurability = 0, 0
    local lowestDurabilityPercent = 1
    for i=1,18 do
        local current, maximum=GetInventoryItemDurability(i)
        if current and maximum then
            totalCurrentDurability = totalCurrentDurability + current
            totalMaxDurability = totalMaxDurability + maximum
            if (current/maximum) < lowestDurabilityPercent then
                lowestDurabilityPercent = current/maximum
            end
            if (current/maximum) < private.db.profile.repairReminderThreshold then
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
