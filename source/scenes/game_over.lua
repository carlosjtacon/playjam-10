local gfx <const> = playdate.graphics
local md <const> = playdate.metadata
local MARGIN <const> = 10

function secondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

local function update(_dt)
  playdate.graphics.setDrawOffset(0, 0)

  if playdate.buttonJustPressed(playdate.kButtonB) then
    PlaySFX("B3")
    SwitchScene(SCENE.MAIN_MENU)
  end

  if playdate.buttonJustPressed(playdate.kButtonA) then
    PlaySFX("A3")
    SwitchScene(SCENE.GAMEPLAY)
  end

  gfx.clear()

  SetFont(Fonts.asheville24Light)
  gfx.drawText("GAME OVER", MARGIN, MARGIN)

  SetFont(Fonts.default)
  gfx.drawText("Score: " .. score, MARGIN, 58)
  gfx.drawText("High Score: " .. SaveData.high_score, MARGIN, 82)
  gfx.drawText("Playtime: " .. secondsToClock(time), MARGIN, 106)
  gfx.drawText("Total Playtime: " .. secondsToClock(SaveData.playtime), MARGIN, 130)
  gfx.drawText("Press A to _Play Again_", MARGIN+200, 175)
  gfx.drawText("Press B for _Main Menu_", MARGIN+200, 200)
end

local scene = {
  update = update,
}

return scene
