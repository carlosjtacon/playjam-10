local SAVE_FILE <const> = "save"

-- default values, gets loaded in main.lua's init by calling LoadSaveData if
-- present on disk
SaveData = {
  playtime = 0.0, -- only updated in gameplay scene
  -- add more save data here
}

-- loads SaveData from disk
function LoadSaveData()
  local saveFileData = playdate.datastore.read(SAVE_FILE)
  if saveFileData then
    SaveData = saveFileData
  end
end

-- writes the SaveData table to disk
function SaveSaveData()
  playdate.datastore.write(SaveData, SAVE_FILE)
end
