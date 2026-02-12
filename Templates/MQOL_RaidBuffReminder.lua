local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_RaidBuffReminder"
local Version = 1
private.RaidBuffReminderVariables = {
    position = {
        x = 428,
        point = "BOTTOM",
        y = 22,
    },
    size = 84
}

local function ApplySettings(widget)
    if private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT] then
        widget.frame:SetPoint(private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].point, UIParent,
            private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].point,
            private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].x,
            private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].y)
    else
        widget.frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    if private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].size then
        widget.frame:SetSize(private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].size, private.db.global.raidBuffReminder[private.ACTIVE_EDITMODE_LAYOUT].size)
    end
end


---@param self MQOL_RaidBuffReminder
local function OnAcquire(self)
    ApplySettings(self)
end

---@param self MQOL_RaidBuffReminder
local function OnRelease(self)

end
local function SetSpellID (widget, spellID)
    local spellInfo = C_Spell.GetSpellInfo(spellID)
    assert(spellInfo, "Invalid spell ID provided to MQOL_RaidBuffReminder:SetSpellID")
    widget.frame.Icon:SetTexture(spellInfo.iconID)
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_RaidBuffReminder_" .. count, UIParent)
    frame:SetSize(private.RaidBuffReminderVariables.size, private.RaidBuffReminderVariables.size)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame.Icon = frame:CreateTexture(nil, "OVERLAY")
    frame.Icon:SetAllPoints(frame)
    frame.Icon:SetTexture(237542)
    frame.AnimationGroup = frame:CreateAnimationGroup()
    frame.AnimationGroup:SetLooping("BOUNCE")
    frame.Animation = frame.AnimationGroup:CreateAnimation("Alpha")
    frame.Animation:SetFromAlpha(1)
    frame.Animation:SetToAlpha(0.5)
    frame.Animation:SetDuration(0.5)
    frame.AnimationGroup:Play()

    ---@class MQOL_RaidBuffReminder : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        SetSpellID = SetSpellID,
        ApplySettings = ApplySettings,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
