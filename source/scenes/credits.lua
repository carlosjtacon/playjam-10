local gfx <const> = playdate.graphics
local md <const> = playdate.metadata
local MARGIN <const> = 10

local function update(_dt)
  if playdate.buttonJustPressed(playdate.kButtonB) then
    PlaySFX("B3")
    SwitchScene(SCENE.MAIN_MENU)
  end

  gfx.clear()

  SetFont(Fonts.asheville24Light)
  gfx.drawText("CREDITS", MARGIN, MARGIN)

  SetFont(Fonts.default)
  gfx.drawText("Made by " .. md.author, MARGIN, 58)
  gfx.drawText("Coded in Lua using the Sunny template", MARGIN, 82)
  gfx.drawText("Asheville font by Panic (CC BY 4.0)", MARGIN, 106)
end

local scene = {
  update = update,
}

return scene
