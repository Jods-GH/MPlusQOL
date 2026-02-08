local appName, private = ...
local AceLocale = LibStub ('AceLocale-3.0')
local L = AceLocale:NewLocale(appName, "enUS", true)

if L then
    L["AccessOptionsMessage"] = "Access the options via /mplusqol"
    L["RepairReminderText"] = "Repair!"
    L["repairReminderSoundDescription"] = "Sound played when you first enter a resting area and your durability is below the threshold."
    L["repairReminderSound"] = "Repair Reminder Sound"
    L["enableRepairReminder"] = "Enable Repair Reminder"
    L["enableRepairReminderDescription"] = "Show a reminder when you enter a resting area and your durability is below the threshold."
    L["disableInitialMessage"] = "Disable Initial Message"
    L["disableInitialMessageDescription"] = "Disable the message that is shown when you first install the addon, which tells you how to access the options."
    L["addonOptions"] = "M+ QoL Options"
    L["enableDeathReminder"] = "Enable Death Reminder"
    L["enableDeathReminderDescription"] = "Show a reminder when you or a group member dies."
    L["MemberDiedText"] = "= Noob"
    L["deathReminderBackgroundTexture"] = "Death Reminder Background Texture"
    L["deathReminderBackgroundTextureDescription"] = "The background texture of the death reminder bar."
    L["deathReminderBorderTexture"] = "Death Reminder Border Texture"
    L["deathReminderBorderTextureDescription"] = "The border texture of the death reminder bar."
    L["deathReminderTexture"] = "Death Reminder Bar Texture"
    L["deathReminderTextureDescription"] = "The texture of the death reminder bar."
    L["enableResurrectionReminder"] = "Enable Resurrection Reminder"
    L["enableResurrectionReminderDescription"] = "Show a reminder when you have an incoming resurrection."
    L["resurrectionReminderSound"] = "Resurrection Reminder Sound"
    L["resurrectionReminderSoundDescription"] = "Sound played when you have an incoming resurrection."
    L["BrezTimer"] = "Brez Timer"
    L["EnableBrezTimer"] = "Enable Brez Timer"
    L["EnableBrezTimerDescription"] = "Show a timer for battle ressurections in Mythic+ dungeons and raids."
    private.localisation = L
end