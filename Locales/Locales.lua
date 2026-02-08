local appName, private = ...
local currentLocale = LibStub ('AceLocale-3.0'):GetLocale (appName, true)---@type MyAddonLocale
private.getLocalisation = function(Object)
      return currentLocale[Object]
end
