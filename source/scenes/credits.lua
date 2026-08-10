local gfx <const> = playdate.graphics
local md <const> = playdate.metadata
local MARGIN <const> = 20

local function update(_dt)
  if playdate.buttonJustPressed(playdate.kButtonB) then
    PlaySFX("B3")
    SwitchScene(SCENE.MAIN_MENU)
  end

  gfx.clear()

  SetFont(Fonts.title)
  gfx.drawText("CREDITS", MARGIN, MARGIN)

  SetFont(Fonts.default)
  gfx.drawText("Made by " .. md.author .. " for Playjam 10", MARGIN, 68)
  gfx.drawText("Coded in Lua using the Sunny template", MARGIN, 92)
  gfx.drawText("Asheville font by Panic (CC BY 4.0)", MARGIN, 116)
end

local scene = {
  update = update,
}

return scene
