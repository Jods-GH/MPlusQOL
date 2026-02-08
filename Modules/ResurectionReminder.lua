local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

local function CreateResurrectionReminder()
    local widget = AceGui:Create("MQOL_ResurrectionReminder")
    widget.frame:Show()
    return widget
end

local function HandleReminderSound()
    local sound = SharedMedia:Fetch("sound", private.db.profile.resurrectionReminderSound)
    PlaySoundFile(sound, "Master")
end

local function ShowResurrectionReminder()
    if not private.resurrectionReminder then
        private.resurrectionReminder = CreateResurrectionReminder()
        HandleReminderSound()
    end
    
    if not private.resurrectionReminder.frame:IsShown() then
        private.resurrectionReminder.frame:Show()
        HandleReminderSound()
    end
end

local function HideResurrectionReminder()
    if private.resurrectionReminder then
        private.resurrectionReminder.frame:Hide()
    end
end

local function ToggleResurrectionReminder(shouldShow)
    if shouldShow then
        ShowResurrectionReminder()
    else
        HideResurrectionReminder()
    end
end


function private.Addon:INCOMING_RESURRECT_CHANGED(event, unit)
    if not private.db.profile.enableResurrectionReminder or unit ~= "player" or not UnitHasIncomingResurrection("player") then
        ToggleResurrectionReminder(false)
        return
    end
    if private.db.profile.resurrectionReminderSound then
        PlaySoundFile(SharedMedia:Fetch("sound", private.db.profile.resurrectionReminderSound), "Master")
    end
    ToggleResurrectionReminder(true)
end

function private.Addon:PLAYER_ALIVE(event)
    ToggleResurrectionReminder(false)
end

function private.Addon:PLAYER_UNGHOST(event)
    ToggleResurrectionReminder(false)
end

