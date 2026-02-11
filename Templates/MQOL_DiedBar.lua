local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local CustomNames = C_AddOns.IsAddOnLoaded("CustomNames") and LibStub("CustomNames")

local Type = "MQOL_DiedBar"
local Version = 1
private.diedBarVariables = {
    height = 40,
    width = 600,
    position = {
        point = 'TOP',
        y = -180,
        x = 0,
    },
    barColor = CreateColor(1, 0, 0, 1),
    duration = 3,
}

local function ApplySettings(widget)
    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].texture then
        widget.frame:SetStatusBarTexture(SharedMedia:Fetch("statusbar",
            private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].texture))
    end
    local bgTexture = "Interface\\DialogFrame\\UI-DialogBox-Background"
    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].bgTexture then
        bgTexture = SharedMedia:Fetch("background",
            private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].bgTexture)
    end
    widget.frame:SetBackdrop({
        bgFile = bgTexture,
        tile = false,
        tileSize = 32,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })

    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT] then
        widget.frame:SetPoint(private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].point, UIParent,
            private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].point,
            private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].x,
            private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].y)
    else
        widget.frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].width then
        widget.frame:SetWidth(private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].width)
    end
    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].height then
        widget.frame:SetHeight(private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].height)
    end

    if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].barColor then
        local color = private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].barColor
        widget.frame:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
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

local function SetGUIDAndStartTimer(widget, unitGUID)
    local name, realm = UnitNameFromGUID(unitGUID)
    local class, classFile, classID = UnitClassFromGUID(unitGUID)
    if CustomNames then
        local unitToken = UnitTokenFromGUID(unitGUID)
        name, realm = CustomNames.UnitName(unitToken)
    end
    widget.frame.startTime = GetTime()
    local duration = private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].duration or private.diedBarVariables.duration
    widget.frame:SetScript("OnUpdate", function(self, elapsed)
        if self.startTime then
            local elapsedTime = GetTime() - self.startTime
            if elapsedTime < duration then
                self:SetValue(100 * elapsedTime / duration)
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
    local frame = CreateFrame("StatusBar", "MQOL_DiedBar_" .. count, UIParent, "BackdropTemplate")
    frame:SetSize(private.diedBarVariables.width, private.diedBarVariables.height)
    frame:SetMinMaxValues(0, 100)
    frame:SetValue(0)
    frame:SetStatusBarColor(private.diedBarVariables.barColor:GetRGBA())
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
        SetGUIDAndStartTimer = SetGUIDAndStartTimer,
        ApplySettings = ApplySettings,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
