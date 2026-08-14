local addonName, private = ...
local AceGUI = LibStub("AceGUI-3.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local Type = "MQOL_LustTimer"
local Version = 2

private.lustTimerVariables = {
    size = 64,
    position = {
        x = 0,
        y = 64,
        point = "BOTTOM",
    },
    sound = "None",
}


private.lustDebuffIds = {
    [57723] = true,          -- Exhaustion
    [57724] = true,          -- Sated
    [80354] = true,          -- Temporal Displacement
    [95809] = true,          -- Hunter Pet Insanity
    [160455] = true, [264689] = true, -- Hunter Pet Fatigued
    [390435] = true,         -- Exhaustion
}

private.lustBuffIds = {
    [2825] = true,   -- Bloodlust 
    [32182] = true,  -- Heroism 
    [80353] = true,  -- Time Warp 
    [90355] = true,  -- Ancient Hysteria
    [146555] = true, -- Drums of Rage
    [160452] = true, -- Netherwinds 
    [264667] = true, -- Primal Rage 
    [390386] = true, -- Fury of the Aspects 
    [466904] = true, -- Harrier's Cry
    [178207] = true, -- Drums of Fury
    [35476] = true,  -- Drums of Battle
    [230935] = true, -- Drums of the Mountain
    [256740] = true, -- Drums of the Maelstrom
    [292686] = true, -- Drums of Rage
    [309658] = true, -- Drums of Deathly Ferocity
    [381301] = true, -- Feral Hide Drums
    [441076] = true, -- Timeless Drums
    [444257] = true,  -- Thunderous Drums
}



---@param self MQOL_LustTimer
local function OnAcquire(self)
    self:ApplySettings()
end

---@param self MQOL_LustTimer
local function OnRelease(self)
    self:SetPreview(false)
end

local function ApplySettings(widget)
    local layout = private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT]
    widget.frame:ClearAllPoints()
    if layout then
        widget.frame:SetPoint(layout.point, UIParent, layout.point, layout.x, layout.y)
    else
        widget.frame:SetPoint("CENTER", UIParent, "CENTER")
    end

    local size = (layout and layout.size) or private.lustTimerVariables.size
    widget.frame:SetSize(size, size)
end

-- Edit mode preview. 
local PREVIEW_LOOP = 5
local function SetPreview(widget, show)
    local frame = widget.frame
    if show then
        frame.PreviewIcon:Show()
        frame.PreviewCooldown:SetCooldownDuration(PREVIEW_LOOP)
        frame.previewStart = GetTime()
        frame:SetScript("OnUpdate", function(self)
            if self.previewStart and GetTime() - self.previewStart >= PREVIEW_LOOP then
                self.PreviewCooldown:SetCooldownDuration(PREVIEW_LOOP)
                self.previewStart = GetTime()
            end
        end)
    else
        frame:SetScript("OnUpdate", nil)
        frame.previewStart = nil
        if frame.PreviewCooldown then
            frame.PreviewCooldown:Clear()
        end
        if frame.PreviewIcon then
            frame.PreviewIcon:Hide()
        end
    end
end

local function BuildAuraContainer(widget)
    local container = CreateFrame("AuraContainer", nil, widget.frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(widget.frame)
    container:SetUnit("player")
    container:SetEnabled(true)

    local function BuildIconAndCooldown(button)
        button:SetAllPoints(button:GetParent())

        local icon = button:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints(button)
        icon:SetTexture(136012)

        local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        cooldown:SetAllPoints(button)
        button:SetDurationCooldown(cooldown)
    end

    container:AddAuraSlot("cooldown", "HARMFUL", {
        candidateFilters = { includeSpellIDs = private.lustDebuffIds },
        initializeFrame = BuildIconAndCooldown,
    })

    container:AddAuraSlot("active", "HELPFUL", {
        candidateFilters = { includeSpellIDs = private.lustBuffIds },
        initializeFrame = function(button)
            BuildIconAndCooldown(button)
            
            button:SetFrameLevel(button:GetParent():GetFrameLevel() + 10)

            -- build proc glow alternative since we can't use libcustomglow
            local size = (private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT]
                and private.db.global.lustTimer[private.ACTIVE_EDITMODE_LAYOUT].size)
                or private.lustTimerVariables.size
            local pad = size * 0.35

            local glow = CreateFrame("Frame", nil, button)
            glow:SetPoint("TOPLEFT", button, "TOPLEFT", -pad, pad)
            glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", pad, -pad)

            glow.ProcLoop = glow:CreateTexture(nil, "OVERLAY")
            glow.ProcLoop:SetAllPoints(glow)
            glow.ProcLoop:SetAtlas("UI-HUD-ActionBar-Proc-Loop-Flipbook")

            local anim = glow:CreateAnimationGroup()
            anim:SetLooping("REPEAT")
            local flip = anim:CreateAnimation("FlipBook")
            flip:SetChildKey("ProcLoop")
            flip:SetDuration(1)
            flip:SetOrder(0)
            flip:SetFlipBookRows(6)
            flip:SetFlipBookColumns(5)
            flip:SetFlipBookFrames(30)
            anim:Play()
        end,
    })

    widget.container = container
end

local function Constructor()
    local count = AceGUI:GetNextWidgetNum(Type)
    local frame = CreateFrame("Frame", "MQOL_LustTimer_" .. count, UIParent)
    frame:SetSize(private.lustTimerVariables.size, private.lustTimerVariables.size)
    frame:SetPoint("CENTER", UIParent, "CENTER")

    -- Placement-only preview widgets (edit mode). Hidden during normal play.
    frame.PreviewIcon = frame:CreateTexture(nil, "ARTWORK")
    frame.PreviewIcon:SetAllPoints(frame)
    frame.PreviewIcon:SetTexture(136012)
    frame.PreviewIcon:Hide()
    frame.PreviewCooldown = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
    frame.PreviewCooldown:SetAllPoints(frame)

    ---@class MQOL_LustTimer : AceGUIWidget
    local widget = {
        OnAcquire = OnAcquire,
        OnRelease = OnRelease,
        type = Type,
        count = count,
        frame = frame,
        ApplySettings = ApplySettings,
        SetPreview = SetPreview,
    }

    BuildAuraContainer(widget)

    return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
