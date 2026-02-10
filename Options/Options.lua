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
    enableResurrectionReminder = {
      name = private.getLocalisation("enableResurrectionReminder"),
      order = 30,
      width = "full",
      type = "toggle",
      set = function(info, val)
        private.db.profile.enableResurrectionReminder = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .enableResurrectionReminder --Sets value of toggles depending on SavedVariables
      end
    },
    resurrectionReminderSound = {
      name = private.getLocalisation("resurrectionReminderSound"),
      desc = private.getLocalisation("resurrectionReminderSoundDescription"),
      order = 31,
      width = "full",
      type = "select",
      style = "dropdown",
      hidden = function() return not private.db.profile.enableResurrectionReminder end,
      values = function()
        local sounds = {}
        for _, soundName in ipairs(SharedMedia:List("sound")) do
            sounds[soundName] = soundName
        end
        return sounds
      end,
      set = function(info, val)
        PlaySoundFile(SharedMedia:Fetch("sound", val), "Master")
        private.db.profile.resurrectionReminderSound = val
      end, --Sets value of SavedVariables depending on toggles
      get = function(info)
        return private.db.profile
            .resurrectionReminderSound --Sets value of toggles depending on SavedVariables
      end
    },

  }
}