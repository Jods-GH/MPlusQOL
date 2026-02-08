local appName, private = ...
local AceGui = LibStub("AceGUI-3.0")


function private.Addon:UNIT_DIED(event, unitGUID)
    if not private.db.profile.enableDeathReminder then
        return
    end
    local isInGroup = IsGUIDInGroup(unitGUID)
    if issecretvalue(unitGUID) or not isInGroup and not UnitIsUnit(UnitNameFromGUID(unitGUID), "player") then
        return
    end
    local widget = AceGui:Create("MQOL_DiedBar")
    widget:SetGUIDAndStartTime(unitGUID)
    widget.frame:Show()

end

