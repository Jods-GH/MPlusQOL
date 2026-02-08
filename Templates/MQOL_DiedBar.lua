local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_DiedBar"
local Version = 1
local variables = {
    bar_height = 40,
    bar_width = 600,
}

local function ApplySettings(widget)
    if private.db.profile.deathReminderTexture then
        widget.frame:SetStatusBarTexture(SharedMedia:Fetch("statusbar", private.db.profile.deathReminderTexture))
    end
    local bgTexture ="Interface\\DialogFrame\\UI-DialogBox-Background"
    local borderTexture = "Interface\\DialogFrame\\UI-DialogBox-Border"
    if private.db.profile.deathReminderBackgroundTexture then
        bgTexture = SharedMedia:Fetch("background", private.db.profile.deathReminderBackgroundTexture)
    end
    if private.db.profile.deathReminderBorderTexture then
        borderTexture = SharedMedia:Fetch("border", private.db.profile.deathReminderBorderTexture)
    end
    widget.frame:SetBackdrop({
        bgFile = bgTexture,
        edgeFile = borderTexture,
        tile = true,
        tileSize = 32,
        edgeSize = 4,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
end

---@param self MQOL_DiedBar
local function OnAcquire(self)
    self.frame:SetScript("OnUpdate", nil)
    self.frame:Show()
    ApplySettings(self)
end

---@param self MQOL_DiedBar
local function OnRelease(self)
    self.frame:SetScript("OnUpdate", nil)
    self.frame:Hide()
    self.frame:SetValue(0)
end

local MEMBER_DIED_DURATION = 5
local function SetGUIDAndStartTimer(widget, unitGUID)
    local name, realm = UnitNameFromGUID(unitGUID)
    local class, classFile, classID = UnitClassFromGUID(unitGUID)
    widget.frame.startTime = GetTime()
    widget.frame:SetScript("OnUpdate", function(self, elapsed)
        if self.startTime then
            local elapsedTime = GetTime() - self.startTime
            if elapsedTime < MEMBER_DIED_DURATION then
                self:SetValue(100 * elapsedTime / MEMBER_DIED_DURATION)
            else
                widget:Release()
            end
        end
    end)
    local color = C_ClassColor.GetClassColor(classFile)
    local NameText = C_ColorUtil.WrapTextInColor(name, color)
    widget.frame.Text:SetFormattedText("%s %s", NameText, private.getLocalisation("MemberDiedText"))
end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("StatusBar", "MQOL_DiedBar_" .. count, UIParent,"BackdropTemplate")
    frame:SetSize(variables.bar_width, variables.bar_height)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetMinMaxValues(0, 100)
    frame:SetValue(0)
    frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame:SetStatusBarColor(1, 0, 0, 1)
    frame:Show()
    -- Text above bar
    frame.Text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.Text:SetAllPoints(frame)
    frame.Text:SetTextColor(1, 1, 1)
    frame.Text:SetTextScale(2.0)

    ---@class MQOL_DiedBar : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        SetGUIDAndStartTime = SetGUIDAndStartTimer,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
