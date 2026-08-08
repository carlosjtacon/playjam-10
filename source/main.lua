import("fonts")
import("save_data")
import("settings")
import("sound")

-- gets set to `true` when the pdxinfo version has the `-dev` suffix
IS_DEBUG = string.find(playdate.metadata.version, "-dev") ~= nil
DISPLAY_HEIGHT = playdate.display.getHeight()
DISPLAY_WIDTH = playdate.display.getWidth()

local FPS <const> = 30 -- change this to whatever target framerate you want; Playdate max FPS is 50

SCENE = {
  MAIN_MENU = 1,
  CREDITS = 2,
  GAMEPLAY = 3,
}

local scenes = {
  [SCENE.MAIN_MENU] = import("scenes/main_menu"),
  [SCENE.CREDITS] = import("scenes/credits"),
  [SCENE.GAMEPLAY] = import("scenes/gameplay"),
}

local currentScene = scenes[SCENE.MAIN_MENU]
local pendingScene = nil

-- Switch the active scene to the specified key from `SCENE`
function SwitchScene(key)
  if currentScene.close then
    currentScene.close()
  end

  pendingScene = scenes[key]
end

-- Called once when the game starts
local function init()
  playdate.display.setRefreshRate(FPS)

  -- seed the random number generator
  math.randomseed(playdate.getSecondsSinceEpoch())

  LoadSettings()
  LoadSaveData()

  local menu = playdate.getSystemMenu()
  menu:addMenuItem("main menu", function()
    SwitchScene(SCENE.MAIN_MENU)
  end)
  menu:addCheckmarkMenuItem("play sfx", Settings.playSFX, function(value)
    UpdateSetting(SETTING.PLAY_SFX, value)
  end)

  if currentScene.init then
    currentScene.init()
  end
end

local didInit = false

---@diagnostic disable-next-line: duplicate-set-field
function playdate.update()
  if didInit == false then
    init()
    didInit = true
  end

  local dt = playdate.getElapsedTime()
  playdate.resetElapsedTime()

  -- Set default font to prevent lingering setting from last frame
  SetFont(Fonts.default)

  if pendingScene then
    currentScene = pendingScene
    if currentScene.init then
      currentScene.init()
    end
    pendingScene = nil
  end

  currentScene.update(dt)

  if IS_DEBUG then
    playdate.drawFPS(DISPLAY_WIDTH - 18, 4)
  end
end

---@diagnostic disable-next-line: duplicate-set-field
function playdate.gameWillTerminate()
  SaveSaveData()
end

---@diagnostic disable-next-line: duplicate-set-field
function playdate.deviceWillSleep()
  SaveSaveData()
end
