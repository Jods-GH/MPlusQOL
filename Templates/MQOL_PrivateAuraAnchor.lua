local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_PrivateAuraAnchor"
local Version = 1
private.PrivateAuraAnchorVariables = {
    size = 84,
    margin = 5,
}

local function ApplySettings(widget)
    if private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT].size then
        local size = private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT].size
        widget.frame:SetSize(size, size)
    end
    if private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT] then
        local settings = private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT]
        widget.frame:ClearAllPoints()
        widget.frame:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y)
    end
end

---@param self MQOL_PrivateAuraAnchor
local function OnAcquire(self)
    ApplySettings(self)
end

---@param self MQOL_PrivateAuraAnchor
local function OnRelease(self)

end


local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_PrivateAuraAnchor_" .. count, UIParent)
    frame:SetSize(private.PrivateAuraAnchorVariables.size, private.PrivateAuraAnchorVariables.size)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame.Icon = frame:CreateTexture(nil, "OVERLAY")
    frame.Icon:SetAllPoints(frame)
    frame.Icon:SetTexture(615100)

    ---@class MQOL_PrivateAuraAnchor : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        ApplySettings = ApplySettings,
    }

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
