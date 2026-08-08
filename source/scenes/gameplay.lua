local gfx <const> = playdate.graphics

local player = {
  x = 10,
  y = 10,
  w = 16,  -- width
  h = 16,  -- height
  s = 200, -- speed in px/s
}

local function update(dt)
  SaveData.playtime += dt

  if playdate.buttonIsPressed(playdate.kButtonLeft) then
    player.x -= player.s * dt
  end
  if playdate.buttonIsPressed(playdate.kButtonRight) then
    player.x += player.s * dt
  end
  if playdate.buttonIsPressed(playdate.kButtonUp) then
    player.y -= player.s * dt
  end
  if playdate.buttonIsPressed(playdate.kButtonDown) then
    player.y += player.s * dt
  end

  if playdate.buttonJustPressed(playdate.kButtonB) then
    PlaySFX("B3")
    SwitchScene(SCENE.MAIN_MENU)
  end

  gfx.clear()
  gfx.fillRect(player.x, player.y, player.w, player.h)
end

local scene = {
  update = update,
}

return scene
