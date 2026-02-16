local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")
local LibEditMode = LibStub("LibEditMode")
local SharedMedia = LibStub("LibSharedMedia-3.0")
local CustomNames = C_AddOns.IsAddOnLoaded("CustomNames") and LibStub("CustomNames")

local function HandleMemberDiedSound()
    local sound = SharedMedia:Fetch("sound", private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].sound)
    PlaySoundFile(sound, "Master")
end

function private.Addon:UNIT_DIED(event, unitGUID)
    if not private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].enabled then
        return
    end
    if issecretvalue(unitGUID) or not UnitTokenFromGUID(unitGUID) then
        return
    end
    local unit = UnitTokenFromGUID(unitGUID)
    if not UnitInParty(unit) and not UnitInRaid(unit) and not UnitIsUnit(unit, "player") then
        return
    end
    if not private.activeMemberDiedBar then
        private.activeMemberDiedBar = AceGui:Create("MQOL_DiedBar")
    end
    private.activeMemberDiedBar:SetGUIDAndStartTimer(unitGUID)
    private.activeMemberDiedBar.frame:Show()
    HandleMemberDiedSound()
end

local function onPositionChanged(frame, layoutName, point, x, y)
    -- from here you can save the position into a savedvariable
    private.db.global.memberDiedBar = private.db.global.memberDiedBar or {}
    private.db.global.memberDiedBar[layoutName] = private.db.global.memberDiedBar[layoutName] or {}
    private.db.global.memberDiedBar[layoutName].x = x
    private.db.global.memberDiedBar[layoutName].y = y
    private.db.global.memberDiedBar[layoutName].point = point

    private.memberDiedBar.frame:ClearAllPoints()
    private.memberDiedBar.frame:SetPoint(point, UIParent, point, x, y)
end

local memberDiedBarHasBeenAddedToEditMode = false
local function SetupEditModeSettings(frame)
    if not memberDiedBarHasBeenAddedToEditMode then
        LibEditMode:AddFrame(frame, onPositionChanged, private.diedBarVariables.position,
            "MPlus QOL - " .. private.getLocalisation("MemberDiedBar"))

        local statusbarTextures = {}
        for _, textureName in ipairs(SharedMedia:List("statusbar")) do
            local texPath = SharedMedia:Fetch("statusbar", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texPath), textureName)
            table.insert(statusbarTextures, {
                text = display,
                value = textureName,
                isRadio = false,
            })
        end

        local backgroundTextures = {}
        for _, textureName in ipairs(SharedMedia:List("background")) do
            local texPath = SharedMedia:Fetch("background", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texPath), textureName)
            table.insert(backgroundTextures, {
                text = display,
                value = textureName,
                isRadio = false,
            })
        end

        local soundOptions = {}
        for _, sound in ipairs(SharedMedia:List("sound")) do
            table.insert(soundOptions, {
                text = sound,
                value = sound,
                isRadio = false,
            })
        end

        local areSizeSettingsExpanded = false
        local areTextureSettingsExpanded = false
        LibEditMode:AddFrameSettings(frame, {
            {
                name = private.getLocalisation("enableMemberDiedBar"),
                desc = private.getLocalisation("enableMemberDiedBarDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].enabled
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].enabled = value
                end,
            },
            {
                name = private.getLocalisation("deathReminderDuration"),
                desc = private.getLocalisation("deathReminderDurationDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.diedBarVariables.duration,
                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].duration
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].duration = value
                    private.memberDiedBar:ApplySettings()
                end,
                minValue = 1,
                maxValue = 10,
                valueStep = 1,
            },
            {
                name = private.getLocalisation("expandSizeSettings"),
                expandedLabel = private.getLocalisation("collapseSizeSettings"),
                collapsedLabel = private.getLocalisation("expandSizeSettings"),
                desc = private.getLocalisation("sizeSettingsDescription"),
                kind = LibEditMode.SettingType.Expander,
                default = areSizeSettingsExpanded,
                get = function()
                    return areSizeSettingsExpanded
                end,
                set = function(_, value)
                    areSizeSettingsExpanded = value
                end,
            },
            {
                name = private.getLocalisation("deathReminderHeight"),
                desc = private.getLocalisation("deathReminderHeightDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.diedBarVariables.height,
                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].height
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].height = value
                    private.memberDiedBar:ApplySettings()
                end,
                minValue = 1,
                maxValue = 200,
                valueStep = 1,
                hidden = function()
                    return not areSizeSettingsExpanded
                end,
            },
            {
                name = private.getLocalisation("deathReminderWidth"),
                desc = private.getLocalisation("deathReminderWidthDescription"),
                kind = LibEditMode.SettingType.Slider,
                default = private.diedBarVariables.width,
                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].width
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].width = value
                    private.memberDiedBar:ApplySettings()
                end,
                minValue = 1,
                maxValue = 1200,
                valueStep = 1,
                hidden = function()
                    return not areSizeSettingsExpanded
                end,
            },
            {
                name = private.getLocalisation("expandTextureSettings"),
                expandedLabel = private.getLocalisation("collapseTextureSettings"),
                collapsedLabel = private.getLocalisation("expandTextureSettings"),
                desc = private.getLocalisation("textureSettingsDescription"),
                kind = LibEditMode.SettingType.Expander,
                default = areTextureSettingsExpanded,
                get = function()
                    return areTextureSettingsExpanded
                end,
                set = function(_, value)
                    areTextureSettingsExpanded = value
                end,
            },
            {
                name = private.getLocalisation("deathReminderTexture"),
                desc = private.getLocalisation("deathReminderTextureDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].texture
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].texture = value
                    private.memberDiedBar:ApplySettings()
                end,
                default = "Solid",
                height = 300,
                values = statusbarTextures,
                hidden = function()
                    return not areTextureSettingsExpanded
                end,
            },
            {
                name = private.getLocalisation("deathReminderTextureColor"),
                desc = private.getLocalisation("deathReminderTextureColorDescription"),
                kind = LibEditMode.SettingType.ColorPicker,

                get = function(layoutName)
                    local color = private.db.global.memberDiedBar[layoutName].barColor
                    if not color then
                        return private.diedBarVariables.barColor
                    end
                    return CreateColor(color.r, color.g, color.b, color.a)
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].barColor = value:GetRGBA()
                    private.memberDiedBar:ApplySettings()
                end,
                default = private.diedBarVariables.barColor,
                hidden = function()
                    return not areTextureSettingsExpanded
                end,
            },
            {
                name = private.getLocalisation("deathReminderBackgroundTexture"),
                desc = private.getLocalisation("deathReminderBackgroundTextureDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].bgTexture
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].bgTexture = value
                    private.memberDiedBar:ApplySettings()
                end,
                default = "Blizzard Dialog Background",
                height = 300,
                values = backgroundTextures,
                hidden = function()
                    return not areTextureSettingsExpanded
                end,
            },
            {
                name = private.getLocalisation("memberDiedSound"),
                desc = private.getLocalisation("memberDiedSoundDescription"),
                kind = LibEditMode.SettingType.Dropdown,

                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].sound
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].sound = value
                    HandleMemberDiedSound()
                end,
                default = private.diedBarVariables.sound,
                height = 300,
                values = soundOptions,
            },
             {
                name = private.getLocalisation("enableDeathInformation"),
                desc = private.getLocalisation("enableDeathInformationDescription"),
                kind = LibEditMode.SettingType.Checkbox,
                default = true,
                get = function(layoutName)
                    return private.db.global.memberDiedBar[layoutName].enableDeathInformation
                end,
                set = function(layoutName, value)
                    private.db.global.memberDiedBar[layoutName].enableDeathInformation = value
                end,
            },
        })
        memberDiedBarHasBeenAddedToEditMode = true
    end
end

private.initializeMemberDiedBar = function()
    if not private.db.global.memberDiedBar then
        private.db.global.memberDiedBar = {}
    end
    if not private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT] then
        private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT] = {
            enabled = true,
            duration = 3,
            bgTexture = "Blizzard Dialog Background",
            barColor = private.diedBarVariables.barColor,
            texture = "Solid",
            width = private.diedBarVariables.width,
            height = private.diedBarVariables.height,
            x = private.diedBarVariables.position.x,
            y = private.diedBarVariables.position.y,
            point = private.diedBarVariables.position.point,
            enableDeathInformation = true,
        }
    end
end

LibEditMode:RegisterCallback('enter', function(layoutName)
    if private.isInitialized then
        if not private.memberDiedBar then
            private.memberDiedBar = AceGui:Create("MQOL_DiedBar")
            private.memberDiedBar.frame:Show()
            private.memberDiedBar.frame.startTime = GetTime()
            private.memberDiedBar.frame:SetScript("OnUpdate", function(self, elapsed)
                if self.startTime then
                    local elapsedTime = GetTime() - self.startTime
                    if elapsedTime < 3 then
                        self:SetValue(100 * elapsedTime / 3)
                    else
                        self.startTime = GetTime()
                    end
                end
            end)
            private.memberDiedBar.frame:SetValue(50)
            if private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT] then
                private.memberDiedBar.frame:SetPoint(private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].point,
                    UIParent,
                    private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].point,
                    private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].x,
                    private.db.global.memberDiedBar[private.ACTIVE_EDITMODE_LAYOUT].y)
            else
                private.memberDiedBar.frame:SetPoint("CENTER", UIParent, "CENTER")
            end
            local name, realm = UnitName("player")
            if CustomNames then
                name, realm = CustomNames.UnitName("player")
            end
            local class, classFile, classID = UnitClass("player")
            local color = C_ClassColor.GetClassColor(classFile)
            local NameText = C_ColorUtil.WrapTextInColor(name, color)
            private.memberDiedBar.frame.Text:SetFormattedText("%s %s", NameText, private.getLocalisation("MemberDiedText"))
        end
        SetupEditModeSettings(private.memberDiedBar.frame)
    end
end)

LibEditMode:RegisterCallback('exit', function(layoutName)
    if private.memberDiedBar then
        private.memberDiedBar:Release()
        private.memberDiedBar = nil
    end
end)
