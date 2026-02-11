local appName, private = ...
local AceLocale = LibStub ('AceLocale-3.0')
local L = AceLocale:NewLocale(appName, "enUS", true)

if L then
    L["AccessOptionsMessage"] = "Access the options via the editmode" 
    L["disableInitialMessage"] = "Disable Initial Message"
    L["disableInitialMessageDescription"] = "Disable the message that is shown when you first install the addon, which tells you how to access the options."
    L["addonOptions"] = "M+ QoL Options"
    L["MemberDiedBar"] = "Member Died Bar"
    L["enableMemberDiedBar"] = "Enable Member Died Bar"
    L["enableMemberDiedBarDescription"] = "Show a reminder when you or a group member dies."
    L["MemberDiedText"] = "died"
    L["enableResurrectionReminder"] = "Enable Resurrection Reminder"
    L["enableResurrectionReminderDescription"] = "Show a reminder when you have an incoming resurrection."
    L["resurrectionReminderSound"] = "Resurrection Reminder Sound"
    L["resurrectionReminderSoundDescription"] = "Sound played when you have an incoming resurrection."
    L["editModeHint"] = "Most of the options are accessed via the edit mode."

    -- edit mode settings
    L["expandTextureSettings"] = "Expand Texture Settings"
    L["collapseTextureSettings"] = "Collapse Texture Settings"
    L["textureSettingsDescription"] = "Expand to show options for customizing the textures."
    L["expandSizeSettings"] = "Expand Size Settings"
    L["collapseSizeSettings"] = "Collapse Size Settings"
    L["sizeSettingsDescription"] = "Expand to show options for customizing the size."
    -- member died bar
    L["deathReminderHeight"] = "Death Reminder Height"
    L["deathReminderHeightDescription"] = "The height of the death reminder bar."
    L["deathReminderWidth"] = "Death Reminder Width"
    L["deathReminderWidthDescription"] = "The width of the death reminder bar."
    L["deathReminderDuration"] = "Death Reminder Duration"
    L["deathReminderDurationDescription"] = "The duration the death reminder bar is shown."
    L["deathReminderTextureColor"] = "Death Reminder Bar Color"
    L["deathReminderTextureColorDescription"] = "The color of the death reminder bar."
    L["deathReminderBackgroundTexture"] = "Death Reminder Background Texture"
    L["deathReminderBackgroundTextureDescription"] = "The background texture of the death reminder bar."
    L["deathReminderTexture"] = "Death Reminder Bar Texture"
    L["deathReminderTextureDescription"] = "The texture of the death reminder bar."

    -- brez timer
    L["BrezTimer"] = "Battleress"
    L["BrezNextIn"] = "Next In"
    L["EnableBrezTimer"] = "Enable Brez Timer"
    L["EnableBrezTimerDescription"] = "Show a timer for battle ressurections in Mythic+ dungeons and raids."

    -- repair reminder
    L["RepairReminder"] = "Repair Reminder"
    L["RepairReminderText"] = "Repair!"
    L["repairReminderSoundDescription"] = "Sound played when you first enter a resting area and your durability is below the threshold."
    L["repairReminderSound"] = "Repair Reminder Sound"
    L["enableRepairReminder"] = "Enable Repair Reminder"
    L["enableRepairReminderDescription"] = "Show a reminder when you enter a resting area and your durability is below the threshold."
    L["repairReminderThreshhold"] = "Repair Reminder Threshold"
    L["repairReminderThreshholdDescription"] = "The durability percentage at which the repair reminder will be shown when you enter a resting area."
    
    
    private.localisation = L
end