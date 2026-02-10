local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_ResurrectionReminder"
local Version = 1
local variables = {
    icon_width = 300,
    icon_height = 300,
}

---@param self MQOL_ResurrectionReminder
local function OnAcquire(self)

end

---@param self MQOL_ResurrectionReminder
local function OnRelease(self)

end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_ResurrectionReminder_" .. count, UIParent)
    frame:SetSize(variables.icon_width, variables.icon_height)
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

    ---@class MQOL_ResurrectionReminder : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
