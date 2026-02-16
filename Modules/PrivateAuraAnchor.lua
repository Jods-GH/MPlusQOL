local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local variables = {
    position = {
        x = 240,
        point = "CENTER",
        y = -220,
    },
}
private.privateAuraAnchorIDs = {}
local function handleAnchor()
    if not private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT].enabled then
        return
    end
    if private.privateAuraAnchorIDs then
        for _, anchorID in ipairs(private.privateAuraAnchorIDs) do
            C_UnitAuras.RemovePrivateAuraAnchor(anchorID)
        end
        private.privateAuraAnchorIDs = {}
    end

    if not private.privateAuraAnchorFrame then
        private.privateAuraAnchorFrame = CreateFrame("Frame", "MQOL_PrivateAuraAnchorFrame", UIParent)
    end
    local size = private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT].size or private.PrivateAuraAnchorVariables.size
    private.privateAuraAnchorFrame:SetSize(size, size)
    private.privateAuraAnchorFrame:ClearAllPoints()
    if private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT] then
        local settings = private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT]
        private.privateAuraAnchorFrame:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y)
    else
        private.privateAuraAnchorFrame:SetPoint(variables.position.point, UIParent, variables.position.point, variables.position.x, variables.position.y)
    end
    for i = 1, 5 do
        local margin = private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT].margin or private.PrivateAuraAnchorVariables.margin
        local offset = (i - 1) * (private.privateAuraAnchorFrame:GetWidth() + margin)
        local privateAnchorArgs = {
            unitToken = "player",
            auraIndex = i,
            parent = private.privateAuraAnchorFrame,
            showCountdownFrame = true,
            showCountdownNumbers = true,
            iconInfo = {
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = private.privateAuraAnchorFrame,
                    relativePoint = "CENTER",
                    offsetX = offset,
                    offsetY = 0
                },
                iconWidth = private.privateAuraAnchorFrame:GetWidth(),
                iconHeight = private.privateAuraAnchorFrame:GetHeight()
            }
        }
        local anchorID = C_UnitAuras.AddPrivateAuraAnchor(privateAnchorArgs)
        table.insert(private.privateAuraAnchorIDs, anchorID)
    end
end

local function CreatePrivateAuraAnchor()
    local widget = AceGui:Create("MQOL_PrivateAuraAnchor")
    widget.frame:Show()
    return widget
end

local function ShowPrivateAuraAnchor()
    if not private.privateAuraAnchor then
        private.privateAuraAnchor = CreatePrivateAuraAnchor()
    end

    if not private.privateAuraAnchor.frame:IsShown() then
        private.privateAuraAnchor.frame:Show()
    end
end

local function HidePrivateAuraAnchor()
    if private.privateAuraAnchor then
        private.privateAuraAnchor.frame:Hide()
    end
end

local function TogglePrivateAuraAnchor(shouldShow)
    if shouldShow then
        ShowPrivateAuraAnchor()
    else
        HidePrivateAuraAnchor()
    end
    handleAnchor()
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.privateAuraAnchor = private.db.global.privateAuraAnchor or {}
    private.db.global.privateAuraAnchor[layoutName] = private.db.global.privateAuraAnchor[layoutName] or {}
    private.db.global.privateAuraAnchor[layoutName].x = x
    private.db.global.privateAuraAnchor[layoutName].y = y
    private.db.global.privateAuraAnchor[layoutName].point = point

    private.privateAuraAnchor.frame:ClearAllPoints()
    private.privateAuraAnchor.frame:SetPoint(point, UIParent, point, x, y)
    handleAnchor()
end

local hasBeenAddedToeditMode = false
local function SetupEditModeSettings(frame)
    if not hasBeenAddedToeditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, variables.position,
            "MPlus QOL - " .. private.getLocalisation("PrivateAuraAnchor"))


        LibEditMode:AddFrameSettings(frame, {
            {
                name = private.getLocalisation("EnablePrivateAuraAnchor"),
                desc = private.getLocalisation("EnablePrivateAuraAnchorDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.privateAuraAnchor[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.privateAuraAnchor[layoutName].enabled = value
                    handleAnchor()
                end,
            },
            {
                name = private.getLocalisation("privateAuraAnchorSize"),
                desc = private.getLocalisation("privateAuraAnchorSizeDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.PrivateAuraAnchorVariables.size,
                get = function(layoutName)
                    return private.db.global.privateAuraAnchor[layoutName].size
                end,
                set = function(layoutName, value)
                    private.db.global.privateAuraAnchor[layoutName].size = value
                    private.privateAuraAnchor:ApplySettings()
                    handleAnchor()
                end,
                minValue = 16,
                maxValue = 200,
                valueStep = 1,
            },
            {
                name = private.getLocalisation("iconMargin"),
                desc = private.getLocalisation("iconMarginDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.PrivateAuraAnchorVariables.margin,
                get = function(layoutName)
                    return private.db.global.privateAuraAnchor[layoutName].margin
                end,
                set = function(layoutName, value)
                    private.db.global.privateAuraAnchor[layoutName].margin = value
                    private.privateAuraAnchor:ApplySettings()
                    handleAnchor()
                end,
                minValue = 0,
                maxValue = 20,
                valueStep = 1,
            },
        })
        hasBeenAddedToeditMode = true
    end
end

private.initializePrivateAuraAnchor = function()
    if not private.db.global.privateAuraAnchor then
        private.db.global.privateAuraAnchor = {}
    end
    if not private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.privateAuraAnchor[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            x = variables.position.x,
            y = variables.position.y,
            point = variables.position.point,
            size = private.PrivateAuraAnchorVariables.size,
            margin = private.PrivateAuraAnchorVariables.margin,
        }
    end
    handleAnchor()
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        TogglePrivateAuraAnchor(true)
        SetupEditModeSettings(private.privateAuraAnchor.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.isInitialized then
        TogglePrivateAuraAnchor(false)
    end
end)
