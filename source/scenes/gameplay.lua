import "CoreLibs/object"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics

local rows <const> = 8
local gridSize <const> = DISPLAY_HEIGHT / rows
local cols <const> = math.ceil(DISPLAY_WIDTH / gridSize)

local ticksPerRevolution <const> = 6

local map = {
  player = {},
  puzzle = {},
}

controls_default = {
  up = playdate.kButtonUp,
  down = playdate.kButtonDown,
  left = playdate.kButtonLeft,
  right = playdate.kButtonRight,
  addTop = 1,
  addBottom = -1,
  removeTop = playdate.kButtonB,
  removeBottom = playdate.kButtonA,
}

controls_swapped = {
  up = playdate.kButtonDown,
  down = playdate.kButtonUp,
  left = playdate.kButtonRight,
  right = playdate.kButtonLeft,
  addTop = -1,
  addBottom = 1,
  removeTop = playdate.kButtonA,
  removeBottom = playdate.kButtonB,
}

controls = {}

function init()
  controls = controls

  -- init the map for player and puzzle
  for i = 1, rows do
    map.player[i] = {}
    map.puzzle[i] = {}
    for j = 1, cols do
      map.player[i][j] = 0
      map.puzzle[i][j] = 0
    end
  end
  map.player[1][1] = 1

  -- printTable(map.player)
end

function drawGame()
  gfx.clear()
  playdate.graphics.setDrawOffset(-gridSize, -gridSize)
  for i = 1, rows do
    for j = 1, cols do
      if map.player[i][j] == 1 then
        gfx.fillRect(j * gridSize + 1, i * gridSize + 1, gridSize -2, gridSize -2)
      end
      if map.puzzle[i][j] == 1 then
        -- gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(j * gridSize + 1, i * gridSize + 1, gridSize -2, gridSize -2)
        -- gfx.setColor(gfx.kColorWhite)
        -- gfx.fillRect(j * gridSize + 1, i * gridSize + 1, gridSize -2, gridSize -2)
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

function updatePlayer(prevMap)
  local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

  if crankTicks == controls.addTop then
    i, j = getFirstMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if crankTicks == controls.addBottom then
    i, j = getLastMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if playdate.buttonJustPressed(controls.removeTop) then
    i, j = getFirstMatch(map.player, 1)
    if i and j then
      map.player[i][j] = 0
    end
  end
  --
  if playdate.buttonJustPressed(controls.removeBottom) then
    i, j = getLastMatch(map.player, 1)
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

local function updatePuzzle(prevMap)

end

local function update(dt)
  SaveData.playtime += dt
  local prevMap = table.deepcopy(map)

  updatePlayer(prevMap)
  updatePuzzle(prevMap)

  drawGame()

end

init()

local scene = {
  update = update,
}

return scene
