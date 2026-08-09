import "CoreLibs/object"
import "CoreLibs/crank"

local gfx <const> = playdate.graphics

local rows <const> = 6
local gridSize <const> = math.floor((DISPLAY_HEIGHT-30) / rows)
local cols <const> = math.ceil(DISPLAY_WIDTH / gridSize)

local ticksPerRevolution <const> = 1 -- crank speedometer
local score, time = 0, 0

local map = {}
local map_init = {
  player = {}, -- players's shape
  puzzle = {}, -- current puzzle shape, with offset applied
  puzzleTarget = {}, -- current puzzle shape, without offset
  puzzleLevel = 0, -- how hard the puzzle is this round, could drive the speed or might not use it for now
  puzzleOffset = cols, -- starts offscreen
}

local puzzleLevelMax = nil -- the hardest the puzzle should be this round

local controls = {
  up = playdate.kButtonUp,
  down = playdate.kButtonDown,
  left = playdate.kButtonLeft,
  right = playdate.kButtonRight,
  addTop = playdate.kButtonA,
  addBottom = playdate.kButtonB,
  forward = 1,
  rewind = -1,
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
        token = math.floor(math.random() + 0.50) -- default chance of black cell
      end

      if token == 0 then
        if level >= puzzleLevelMax then
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

local function updateDifficulty()
    puzzleLevelMax += 1
    if puzzleLevelMax > 15 then puzzleLevelMax = 15 end
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

local function newRound()
  playdate.wait(1000)
  score += 1
  updateDifficulty()

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

  for _ = 1, 8 do
   offsetPuzzle()
  end

  print("New round! ", score)
end

function init()
  print("Init Gameplay")

  score = -1
  time = 0
  puzzleLevelMax = 5

  newRound()
end

local function drawGame()
  gfx.clear()


  playdate.graphics.drawText("" .. score, 10, 220)
  playdate.graphics.drawText(secondsToClock(time), 45, 220)
  playdate.graphics.drawText("Learn to control..", 265, 220)

  playdate.graphics.setDrawOffset(-gridSize, -gridSize)
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
  playdate.graphics.setDrawOffset(0, 0)

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

  if crankTicks == controls.forward or crankTicks == controls.rewind then
    PlaySFX("E1")
    newRound()
    score -= 1
  end

  if playdate.buttonJustPressed(controls.addTop) then
    PlaySFX("A3")
    local i, j = getFirstMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if playdate.buttonJustPressed(controls.addBottom) then
    PlaySFX("B3")
    local i, j = getLastMatch(map.player, 0)
    if i and j then
      map.player[i][j] = 1
    end
  end

  if playdate.buttonJustPressed(controls.left) then
    PlaySFX("F2")
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
    PlaySFX("E2")
    for i = 1, rows do
      for j = 2, cols do
          map.player[i][j] = prevMap.player[i][j-1]
      end
    end
  end

  if playdate.buttonJustPressed(controls.up) then
    PlaySFX("G2")
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
    PlaySFX("D2")
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

local function lostRound()
  print("Lost the round ") -- need to add the last chance swapped controls
  newRound()
  score -= 1
  PlaySFX("C6")
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

  if not won and map.puzzleOffset == -1 then
    lostRound()
  end

  if won then
    print("Won the round") -- no zeroes or twos means all ones
    newRound()

    PlaySFX("C5")
  end

end

local function update(dt)
  time += dt
  SaveData.playtime += dt
  local prevMap = table.deepcopy(map)

  updatePlayer(prevMap)
  drawGame()

  checkState()

end

local scene = {
  update = update,
  init = init,
}

return scene
