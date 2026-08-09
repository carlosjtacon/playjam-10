import "CoreLibs/object"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics

local rows <const> = 8
local gridSize <const> = (DISPLAY_HEIGHT-30) / rows
local cols <const> = math.ceil(DISPLAY_WIDTH / gridSize)

local ticksPerRevolution <const> = 6 -- crank speedometer
local updates = nil

local map = {}
local map_init = {
  player = {}, -- players's shape
  puzzle = {}, -- current puzzle shape, with offset applied
  puzzleTarget = {}, -- current puzzle shape, without offset
  puzzleLevel = 0, -- how hard the puzzle is this round, could drive the speed or might not use it for now
  puzzleLevelMax = 5, -- the hardest the puzzle should be this round
  puzzleOffset = cols, -- starts offscreen
  slowness = 30, -- every how many frames gets offset, starts at 1 update per second at 30fps
}

local mode = nil
local controls = {}
local controls_default = {
  up = playdate.kButtonUp,
  down = playdate.kButtonDown,
  left = playdate.kButtonLeft,
  right = playdate.kButtonRight,
  addTop = 1,
  addBottom = -1,
  removeTop = playdate.kButtonB,
  removeBottom = playdate.kButtonA,
}
local controls_swapped = {
  up = playdate.kButtonDown,
  down = playdate.kButtonUp,
  left = playdate.kButtonRight,
  right = playdate.kButtonLeft,
  addTop = -1,
  addBottom = 1,
  removeTop = playdate.kButtonA,
  removeBottom = playdate.kButtonB,
}

local function generatePuzzle()
  math.randomseed(playdate.getSecondsSinceEpoch())
  local level = 0
  local puzzle = {}
  local token = nil

  for i = 1, rows do
    puzzle[i] = {}
    for j = 1, cols do
      if j ~= 1 and puzzle[i][j-1] == 1 then
        token = 1 -- black row as soon as there is one black
      elseif i ~= 1 and puzzle[i-1][j] == 0 then
        token = math.floor(math.random() + 0.15) -- if the previous cell is white chances are less to become black
      else
        token = math.floor(math.random() + 0.5) -- default chance of black cell
      end

      if token == 0 then
        if level >= map.puzzleLevelMax then
          token = 1 -- black if we reached the maximum level
        else
          level += 1
        end
      end
      puzzle[i][j] = token
    end
  end

  map.puzzleLevel = level
  map.puzzleTarget = table.deepcopy(puzzle)
end

local function swapMode(mode_to)
  if mode_to == "default" then
    controls = controls_default
    playdate.display.setInverted(false)
  elseif mode_to == "swapped" then
    controls = controls_swapped
    playdate.display.setInverted(true)
  end

  mode = mode_to
  print("Setting mode to: ", mode)
end

local function newRound()
  score += 1

  map = table.deepcopy(map_init)
  for i = 1, rows do
    map.player[i] = {}
    map.puzzle[i] = {}
    for j = 1, cols do
      map.player[i][j] = 0
      map.puzzle[i][j] = 0
    end
  end
  map.player[1][1] = 1

  while map.puzzleLevel == 0 do
    generatePuzzle()
  end

  print("New round! ", score)
end

function init()
  print("Init Gameplay")

  score = -1
  time = 0
  updates = 0
  swapMode("default")
  playdate.graphics.setDrawOffset(-gridSize, -gridSize)

  newRound()
end

function close()
  playdate.graphics.setDrawOffset(0, 0)
end

function drawGame()
  updates += 1
  gfx.clear()


  playdate.graphics.drawText("" .. score, 35, 245)
  playdate.graphics.drawText(secondsToClock(time), 70, 245)

  if mode =="swapped" then
      playdate.graphics.drawText("Last chance! Controls swapped..", 175, 245)
  else
      playdate.graphics.drawText("Learn to control..", 290, 245)
  end

  for i = 1, rows do
    for j = 1, cols do
      -- draw our player
      if map.player[i][j] == 1 then
        gfx.fillRect(j * gridSize + 1, i * gridSize + 1, gridSize -2, gridSize -2)
      end
      -- draw our puzzle
      if map.puzzle[i][j] == 1 then
        gfx.fillRect(j * gridSize + 1, i * gridSize + 1, gridSize -2, gridSize -2)
      end
    end
  end

end

local function getFirstMatch(matrix, value)
  for j = 1, cols do
    for i = 1, rows do
      if matrix[i][j] == value then
        return i, j
      end
    end
  end
  return nil, nil
end

local function getLastMatch(matrix, value)
  for j = 1, cols do
    for i = rows, 1, -1 do
      if matrix[i][j] == value then
        return i, j
      end
    end
  end
  return nil, nil
end

local function updatePlayer(prevMap)
  local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

  if crankTicks == controls.addTop then
    local i, j = getFirstMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if crankTicks == controls.addBottom then
    local i, j = getLastMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if playdate.buttonJustPressed(controls.removeTop) then
    local i, j = getFirstMatch(map.player, 1)
    if i and j then
      map.player[i][j] = 0
    end
  end
  --
  if playdate.buttonJustPressed(controls.removeBottom) then
    local i, j = getLastMatch(map.player, 1)
    if i and j then
      map.player[i][j] = 0
    end
  end

  if playdate.buttonJustPressed(controls.left) then
    for i = 1, rows do
      for j = 1, cols do
        if j == #map.player[i] then
          map.player[i][j] = 0
        else
          map.player[i][j] = prevMap.player[i][j+1]
        end
      end
    end
  end

  if playdate.buttonJustPressed(controls.right) then
    for i = 1, rows do
      for j = 2, cols do
          map.player[i][j] = prevMap.player[i][j-1]
      end
    end
  end

  if playdate.buttonJustPressed(controls.up) then
    for i = 1, rows do
      for j = 1, cols do
        if i == #map.player then
          map.player[i][j] = 0
        else
          map.player[i][j] = prevMap.player[i+1][j]
        end
      end
    end
  end

  if playdate.buttonJustPressed(controls.down) then
    for i = 1, rows do
      for j = 1, cols do
        if i == 1 then
          map.player[i][j] = 0
        else
          map.player[i][j] = prevMap.player[i-1][j]
        end
      end
    end
  end

end

local function offsetPuzzle()
  if map.puzzleOffset < 0 then
    return
  end

  for i = 1, rows do
    map.puzzle[i] = {}
    for j = 1, cols do
      if j <= map.puzzleOffset then
        map.puzzle[i][j] = 0
      else
        map.puzzle[i][j] = map.puzzleTarget[i][j-map.puzzleOffset]
      end
    end
  end

  map.puzzleOffset -= 1
end

local function updatePuzzle()
  if updates % map.slowness == 0 then
    offsetPuzzle()
  end
end

local function lostRound()
  print("Lost the round ", mode) -- need to add the last chance swapped controls
  if mode == "default" then
    PlaySFX("B5")
    swapMode("swapped")
    newRound()
  elseif mode == "swapped" then
    if score > SaveData.high_score then
      SaveData.high_score = score
      end
    PlaySFX("B5")
    SwitchScene(SCENE.GAME_OVER)
  end
end

local function checkState()
  local won = true
  for i = 1, rows do
    for j = 1, cols do
      local cell = map.player[i][j] + map.puzzle[i][j]
      if cell == 2 then
        lostRound()
      elseif cell == 0 then
        won = false
      end
    end
  end

  if won then
    print("Won the round") -- no zeroes or twos means all ones
    swapMode("default")
    newRound()
  end

end

local function update(dt)
  time += dt
  SaveData.playtime += dt
  local prevMap = table.deepcopy(map)

  updatePlayer(prevMap)
  updatePuzzle()
  checkState()

  drawGame()
end

local scene = {
  update = update,
  close = close,
  init = init,
}

return scene
