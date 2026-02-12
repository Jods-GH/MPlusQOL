local appName, private = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
---@class MyAddon : AceAddon-3.0, AceConsole-3.0, AceConfig-3.0, AceGUI-3.0, AceConfigDialog-3.0
private.Addon = LibStub("AceAddon-3.0"):NewAddon("MPlusQOL", "AceConsole-3.0", "AceEvent-3.0")

function private.Addon:OnInitialize()
    -- Called when the addon is loaded
    
    private.Addon:RegisterEvent("PLAYER_ENTERING_WORLD")
    private.Addon:RegisterEvent("PLAYER_UPDATE_RESTING")
    private.Addon:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    private.Addon:RegisterEvent("UNIT_DIED")
    private.Addon:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    private.Addon:RegisterEvent("PLAYER_ALIVE")
    private.Addon:RegisterEvent("PLAYER_UNGHOST")
    private.Addon:RegisterEvent("CHALLENGE_MODE_START")
    private.Addon:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    private.Addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    private.Addon:RegisterEvent("ENCOUNTER_START")
    private.Addon:RegisterEvent("ENCOUNTER_END")

    private.db = LibStub("AceDB-3.0"):New("MPlusQOL", private.OptionDefaults, true) -- Generates Saved Variables with default Values (if they don't already exist)
    local OptionTable = {
        type = "group",
        args = {
            profile = AceDBOptions:GetOptionsTable(private.db),
            other = private.options
        }
    }
    AceConfig:RegisterOptionsTable(appName, OptionTable) --
    AceConfigDialog:AddToBlizOptions(appName, appName)
    self:RegisterChatCommand("mplusqol", "SlashCommand")
    self:RegisterChatCommand("MPLUSQOL", "SlashCommand")
    if not private.db.profile.disableInitialMessage then
        private.Addon:Print(private.getLocalisation("AccessOptionsMessage"))
    end
end

function private.Addon:OnEnable()
    private.initializeBrezTimer()
    private.initializeMemberDiedBar()
    private.initializeRepairReminder()
    private.isInitialized = true
end

function private.Addon:OnDisable()
end

function MPlusQOL_AddonCompartmentFunction()
    private.Addon:SlashCommand("AddonCompartmentFrame")
end

function private.Addon:SlashCommand(msg) -- called when slash command is used
    if msg == "testres" then
        private.Addon:INCOMING_RESURRECT_CHANGED(nil, "player")
        return
    elseif msg == "testaccept" then
        private.Addon:PLAYER_ALIVE()
        return
    elseif msg == "testtimer" then
        private.Addon:CHALLENGE_MODE_START()
        return
    elseif msg == "testdeath" then
        private.Addon:UNIT_DIED(nil, UnitGUID("player"))
        return
    elseif msg == "testbrez" then
        private.testResurrectionReminder()
        return
    end
    AceConfigDialog:Open(appName)
end