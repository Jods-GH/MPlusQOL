local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_BrezTimer"
local Version = 1
local variables = {
    frame_width = 125,
    frame_height = 35,
}
local greyCol = "|cFFAAAAAA"
local redCol = "|cFFB40000"
local whiteCol = "|cFFFFFFFF"

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
    local color = whiteCol
    if charges and charges.currentCharges < 1 then
        color = redCol
    else
        color = whiteCol
    end

    return greyCol .. "Battle ress:|r " .. color .. currentCharges .. "|r" .. greyCol .. "\nNext in:|r " .. time
end

local function StartTimer(widget)
    widget.frame:SetScript("OnUpdate", function(self, elapsed)
        self.BrezText:SetText(getText())
    end)
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
    frame.BrezText:SetPoint("CENTER", frame, "CENTER")
    frame.BrezText:SetText(private.getLocalisation("BrezTimer"))

    ---@class MQOL_BrezTimer : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        StartTimer = StartTimer,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
