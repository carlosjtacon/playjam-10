local gfx <const> = playdate.graphics
local md <const> = playdate.metadata
local MARGIN <const> = 10

local control_a = playdate.graphics.image.new("images/playdate_button_a.png")
local control_b = playdate.graphics.image.new("images/playdate_button_b.png")
local control_menu = playdate.graphics.image.new("images/playdate_button_menu.png")
local control_crank = playdate.graphics.image.new("images/playdate_crank.png")
local control_dpad = playdate.graphics.image.new("images/playdate_dpad.png")

local function update(_dt)
  if playdate.buttonJustPressed(playdate.kButtonB) then
    PlaySFX("B3")
    SwitchScene(SCENE.MAIN_MENU)
  end

  gfx.clear()

  SetFont(Fonts.default)
  control_a:drawScaled(MARGIN, MARGIN, 0.5)
  gfx.drawText("Add a new block from the top.", MARGIN+45, MARGIN+6)
  control_b:drawScaled(MARGIN, MARGIN+45, 0.5)
  gfx.drawText("Add a new block from the bottom.", MARGIN+45, MARGIN+6+45)
  control_dpad:drawScaled(MARGIN, MARGIN+90, 0.5)
  gfx.drawText("Move, grow and shrink your blocks.", MARGIN+45, MARGIN+6+90)
  control_menu:drawScaled(MARGIN, MARGIN+135, 0.5)
  gfx.drawText("Settings and back to main menu.", MARGIN+45, MARGIN+6+135)
  control_crank:drawScaled(MARGIN, MARGIN+180, 0.5)
  gfx.drawText("Timeshift   |   Shuffle puzzle in Zen Mode.", MARGIN+45, MARGIN+6+180)

end

local function init()
  gfx.setBackgroundColor(gfx.kColorBlack)
  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
end

local function close()
  gfx.setBackgroundColor(gfx.kColorWhite)
  gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

local scene = {
  update = update,
  init = init,
  close = close,
}

return scene
