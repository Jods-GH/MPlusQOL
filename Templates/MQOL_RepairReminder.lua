local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_RepairReminder"
local Version = 1
local variables = {
    text_height = 20,
    text_width = 300,
}

---@param self MQOL_RepairReminder
local function OnAcquire(self)

end

---@param self MQOL_RepairReminder
local function OnRelease(self)

end

local function SetDurabilityPercent(self, lowestDurabilityPercent, durabilityPercent)
    self.frame.Text:SetText(string.format("%s: %.0f%% (avg %.0f%%)", private.getLocalisation("RepairReminderText"), lowestDurabilityPercent * 100, durabilityPercent * 100))
end



local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_RepairReminder_" .. count)
    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.Text:SetPoint("CENTER", frame, "CENTER")
    frame.Text:SetText(private.getLocalisation("RepairReminderText"))
    frame.Text:SetTextColor(1, 1, 1)
    frame.Text:SetTextScale(2)
    frame:SetSize(variables.text_width, variables.text_height)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame.AnimationGroup = frame:CreateAnimationGroup()
    frame.AnimationGroup:SetLooping("BOUNCE")
    frame.Animation = frame.AnimationGroup:CreateAnimation("Alpha")
    frame.Animation:SetFromAlpha(1)
    frame.Animation:SetToAlpha(0.5)
    frame.Animation:SetDuration(0.5)
    frame.AnimationGroup:Play()

    ---@class MQOL_RepairReminder : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        SetDurabilityPercent = SetDurabilityPercent,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
