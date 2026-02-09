local addonName, private = ...
local LibEditMode = LibStub("LibEditMode")

LibEditMode:RegisterCallback('layout', function(layoutName)
    private.ACTIVE_EDITMODE_LAYOUT = layoutName
end)


LibEditMode:RegisterCallback('rename', function(oldLayoutName, newLayoutName)
    -- this will be called every time an Edit Mode layout is renamed
    if private.db.global.brezTimer and private.db.global.brezTimer[oldLayoutName] then
        local layout = CopyTable(private.db.global.brezTimer[oldLayoutName])
        private.db.global.brezTimer[newLayoutName] = layout
        private.db.global.brezTimer[oldLayoutName] = nil
    end
    if private.db.global.memberDiedBar and private.db.global.memberDiedBar[oldLayoutName] then
        local layout = CopyTable(private.db.global.memberDiedBar[oldLayoutName])
        private.db.global.memberDiedBar[newLayoutName] = layout
        private.db.global.memberDiedBar[oldLayoutName] = nil
    end
end)

LibEditMode:RegisterCallback('create', function(layoutName, layoutIndex, sourceLayoutName)
    if not private.db.global.brezTimer then
        private.db.global.brezTimer = {}
    end
    if not private.db.global.memberDiedBar then
        private.db.global.memberDiedBar = {}
    end
    

    if sourceLayoutName then
        if private.db.global.brezTimer[sourceLayoutName] then
            local layout = CopyTable(private.db.global.brezTimer[sourceLayoutName])
            private.db.global.brezTimer[layoutName] = layout
        end
        if private.db.global.memberDiedBar[sourceLayoutName] then
            local layout = CopyTable(private.db.global.memberDiedBar[sourceLayoutName])
            private.db.global.memberDiedBar[layoutName] = layout
        end
    end
end)

LibEditMode:RegisterCallback('delete', function(layoutName)
    if private.db.global.brezTimer and private.db.global.brezTimer[layoutName] then
        private.db.global.brezTimer[layoutName] = nil
    end
    if private.db.global.memberDiedBar and private.db.global.memberDiedBar[layoutName] then
        private.db.global.memberDiedBar[layoutName] = nil
    end
end)