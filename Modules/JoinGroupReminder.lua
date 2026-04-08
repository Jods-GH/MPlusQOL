local appName, private = ...

function private.Addon:LFG_LIST_APPLICATION_STATUS_UPDATED(event, searchResultID, newStatus, oldStatus, groupName)
    if newStatus == "inviteaccepted" then
        local searchResultInfo = C_LFGList.GetSearchResultInfo(searchResultID)
        local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityIDs[1])
        if activityInfo.isMythicPlusActivity then
            local message = string.format("You have joined a group %s %s!", searchResultInfo.name, activityInfo.fullName)
            print(message)
        end
    end
end