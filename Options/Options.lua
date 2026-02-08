local appName, private = ...
local SharedMedia = LibStub("LibSharedMedia-3.0")
---@type AceConfigOptionsTable
private.options = {
  name = private.getLocalisation("addonOptions"),
  type = "group",
  args = {
    disableInitialMessage = {
      name = private.getLocalisation("disableInitialMessage"),
      desc = private.getLocalisation("disableInitialMessageDescription"),
      order = 0,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.disableInitialMessage = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .disableInitialMessage --Sets value of toggles depending on SavedVariables
      end
    },
    enableRepairReminder = {
      name = private.getLocalisation("enableRepairReminder"),
      desc = private.getLocalisation("enableRepairReminderDescription"),
      order = 10,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.enableRepairReminder = val
        private.CheckForRepair()
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .enableRepairReminder --Sets value of toggles depending on SavedVariables
      end
    },
    repairReminderSound = {
      name = private.getLocalisation("repairReminderSound"),
      desc = private.getLocalisation("repairReminderSoundDescription"),
      order = 11,
      width = "full",
      type = "select",
      style = "dropdown",
      hidden = function() return not private.db.profile.enableRepairReminder end,
      values = function()
        local sounds = {}
        for _, soundName in ipairs(SharedMedia:List("sound")) do
            sounds[soundName] = soundName
        end
        return sounds
      end,
      set = function(info, val)
        PlaySoundFile(SharedMedia:Fetch("sound", val), "Master")
        private.db.profile.repairReminderSound = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .repairReminderSound --Sets value of toggles depending on SavedVariables
      end
    },
    enableDeathReminder = {
      name = private.getLocalisation("enableDeathReminder"),
      order = 20,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.enableDeathReminder = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .enableDeathReminder --Sets value of toggles depending on SavedVariables
      end
    },
    deathReminderTexture = {
      name = private.getLocalisation("deathReminderTexture"),
      desc = private.getLocalisation("deathReminderTextureDescription"),
      order = 21,
      width = "full",
      type = "select",
      style = "dropdown",
      hidden = function() return not private.db.profile.enableDeathReminder end,
      values = function()
        local texture = {}
        for _, textureName in ipairs(SharedMedia:List("statusbar")) do
            local texturePath = SharedMedia:Fetch("statusbar", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texturePath), textureName)
            texture[textureName] = display
        end
        return texture
      end,
      set = function(info, val)
        private.db.profile.deathReminderTexture = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .deathReminderTexture --Sets value of toggles depending on SavedVariables
      end
    },
    deathReminderBackgroundTexture = {
      name = private.getLocalisation("deathReminderBackgroundTexture"),
      desc = private.getLocalisation("deathReminderBackgroundTextureDescription"),
      order = 22,
      width = "full",
      type = "select",
      style = "dropdown",
      hidden = function() return not private.db.profile.enableDeathReminder end,
      values = function()
        local texture = {}
        for _, textureName in ipairs(SharedMedia:List("background")) do
            local texturePath = SharedMedia:Fetch("background", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texturePath), textureName)
            texture[textureName] = display
        end
        return texture
      end,
      set = function(info, val)
        private.db.profile.deathReminderBackgroundTexture = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .deathReminderBackgroundTexture --Sets value of toggles depending on SavedVariables
      end
    },
     deathReminderBorderTexture = {
      name = private.getLocalisation("deathReminderBorderTexture"),
      desc = private.getLocalisation("deathReminderBorderTextureDescription"),
      order = 23,
      width = "full",
      type = "select",
      style = "dropdown",
      hidden = function() return not private.db.profile.enableDeathReminder end,
      values = function()
        local texture = {}
        for _, textureName in ipairs(SharedMedia:List("background")) do
            local texturePath = SharedMedia:Fetch("border", textureName) or ""
            local display = ("|T%s:16:128|t %s"):format(tostring(texturePath), textureName)
            texture[textureName] = display
        end
        return texture
      end,
      set = function(info, val)
        private.db.profile.deathReminderBorderTexture = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .deathReminderBorderTexture --Sets value of toggles depending on SavedVariables
      end
    },

  }
}