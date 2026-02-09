local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_BrezTimer"
local Version = 1
local variables = {
    frame_width = 125,
    frame_height = 35,
}
local greyCol = "FFAAAAAA"
local redCol = "FFB40000"
local whiteCol = "FFFFFFFF"

local function GetTexts(charges, timer)
    local color = whiteCol
    if charges and charges < 1 then
        color = redCol
    else
        color = whiteCol
    end
    local brezText = string.format("|c%s %s: |r |c%s %i |r", greyCol, private.getLocalisation("BrezTimer"), color, charges)
    local timerText = string.format("|c%s %s: |r |c%s %s|r", greyCol, private.getLocalisation("BrezNextIn"), color, timer)
    return brezText,  timerText
end

-- timer based on https://wago.io/notaraidtool aka http://www.mmo-champion.com/threads/1686033-Weak-Auras-Battle-Res-Monitor-Looking-for-feedback!
local function getText()
    local charges = C_Spell.GetSpellCharges(20484)
    local currentCharges = 0
    local time = ""

    -- get time until next available ress
    if charges and charges.cooldownStartTime then
        local timer = charges.cooldownDuration - (GetTime() - charges.cooldownStartTime)
        time = ("%d:%02d"):format(floor(timer / 60), mod(timer, 60))
    end
    -- print(charges)
    if not charges or charges.currentCharges == nil then
        currentCharges = 0
    else
        currentCharges = charges.currentCharges
    end


    return GetTexts(currentCharges, time)
end

local LOOP_DURATION = 10
local TIME_THRESHHOLD = 5
local FAKE_DURATION_ADDITION = 425
local function StartTimer(widget, isDebug)
    if isDebug then
        local startTime = GetTime()
        widget.frame:SetScript("OnUpdate", function(self, elapsed)
            if GetTime() - startTime > LOOP_DURATION then
                startTime = GetTime()
            end
            local elapsedDuration = GetTime() - startTime
            local remainingDuration = TIME_THRESHHOLD - elapsedDuration
            local currentCharges = 0
            if elapsedDuration > TIME_THRESHHOLD then
                remainingDuration = FAKE_DURATION_ADDITION - elapsedDuration
                currentCharges = 1
            end
            local brezText, nextInText = GetTexts(currentCharges, ("%d:%02d"):format(floor(remainingDuration / 60), mod(remainingDuration, 60)))
            self.BrezText:SetText(brezText)
            self.NextInText:SetText(nextInText)
        end)
    else
        widget.frame:SetScript("OnUpdate", function(self, elapsed)
            local brezText, nextInText = getText()
            self.BrezText:SetText(brezText)
            self.NextInText:SetText(nextInText)
        end)
    end
end

---@param self MQOL_BrezTimer
local function OnAcquire(self)

end

---@param self MQOL_BrezTimer
local function OnRelease(self)

end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_BrezTimer_" .. count, UIParent, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    frame:SetSize(variables.frame_width, variables.frame_height)
    if private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT] then
        frame:SetPoint(private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT].point, UIParent,
            private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT].point,
            private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT].x,
            private.db.global.brezTimer[private.ACTIVE_EDITMODE_LAYOUT].y)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER")
    end
    frame.BrezText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.BrezText:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.BrezText:SetPoint("BOTTOMRIGHT", frame, "RIGHT", -5, 5)
    frame.BrezText:SetText(private.getLocalisation("BrezTimer"))

    frame.NextInText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.NextInText:SetPoint("TOPLEFT", frame, "LEFT", 5, -5)
    frame.NextInText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
    frame.NextInText:SetText(private.getLocalisation("BrezNextIn"))
    

    ---@class MQOL_BrezTimer : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        StartTimer = StartTimer,
        GetTexts = GetTexts,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
