local SETTINGS_FILE <const> = "settings"

SETTING = {
  PLAY_SFX = "playSFX",
}
-- default values, gets loaded in main.lua's init by calling LoadSettings if
-- present on disk
Settings = {
  [SETTING.PLAY_SFX] = true, -- whether or not to play sound effects
  -- add more settings here
}

-- loads Settings from disk
function LoadSettings()
  local settingsFileData = playdate.datastore.read(SETTINGS_FILE)
  if settingsFileData then
    Settings = settingsFileData
  end
end

local function saveSettings()
  playdate.datastore.write(Settings, SETTINGS_FILE)
end

-- writes the Settings table to disk, call this whenever you update a setting
function UpdateSetting(key, value)
  Settings[key] = value
  saveSettings()
end
