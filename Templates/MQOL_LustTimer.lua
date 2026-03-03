local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_LustTimer"
local Version = 1
private.lustTimerVariables = {
    size = 64,
    position = {
        x = 0,
        y = 64,
        point = "BOTTOM",
    },
    sound = "None",
}

---@param self MQOL_LustTimer
local function OnAcquire(self)
    self:ApplySettings()
end

---@param self MQOL_LustTimer
local function OnRelease(self)
    self.frame.Cooldown:Clear()
    private.StopGlow(self.frame)
end

private.REMAINING_SATED_AFTER_LUST = 560
local lastLustActivationTime = GetTime()
local function TriggerLust(self, remainingTime)
    if remainingTime and remainingTime > private.REMAINING_SATED_AFTER_LUST then
        self.frame.Cooldown:SetCooldownDuration(remainingTime - private.REMAINING_SATED_AFTER_LUST)
        C_Timer.After(remainingTime - private.REMAINING_SATED_AFTER_LUST, function()
            self.frame.Cooldown:SetCooldownDuration(private.REMAINING_SATED_AFTER_LUST)
        end)
        private.EnableGlow(self.frame, private.GlowTypes.BUTTON, remainingTime - private.REMAINING_SATED_AFTER_LUST)
        if lastLustActivationTime + private.REMAINING_SATED_AFTER_LUST < GetTime() then
            lastLustActivationTime = GetTime()
            private.HandleLustSound()
        end
    elseif not remainingTime or remainingTime == 0 then
        self.frame.Cooldown:Clear()
        private.StopGlow(self.frame)
    else
        self.frame.Cooldown:SetCooldownDuration(remainingTime)
    end
end

local function ApplySettings(widget)

    if private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT] then
        widget.frame:SetPoint(private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].point, UIParent,
            private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].point,
            private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].x,
            private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].y)
    else
        widget.frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    if private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].size then
        widget.frame:SetSize(private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].size, private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].size)
    end
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_LustTimer_" .. count, UIParent)
    frame:SetSize(private.lustTimerVariables.size, private.lustTimerVariables.size)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame.Icon = frame:CreateTexture(nil, "OVERLAY")
    frame.Icon:SetAllPoints(frame)
    frame.Icon:SetTexture(136012)
    frame.Cooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.Cooldown:SetAllPoints(frame)

    ---@class MQOL_LustTimer : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        TriggerLust = TriggerLust,
        ApplySettings = ApplySettings,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
