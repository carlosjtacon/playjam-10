local gfx <const> = playdate.graphics
local md <const> = playdate.metadata

local version = md.version
local VERSION_TEXT_WIDTH = Fonts.asheville14Bold:getTextWidth(version)
local ASHEVILLE14_HEIGHT = Fonts.asheville14Bold:getHeight()
local MARGIN = 10

local OPTION = {
  PLAY = 1,
  CREDITS = 2,
}
local options = {
  [OPTION.PLAY] = "Play",
  [OPTION.CREDITS] = "Credits",
}
local currentOption = 1

local function update(_dt)
  if playdate.buttonJustPressed(playdate.kButtonUp) then
    PlaySFX("B4")
    currentOption -= 1
    if currentOption <= 0 then
      currentOption = #options
    end
  end

  if playdate.buttonJustPressed(playdate.kButtonDown) then
    PlaySFX("C4")
    currentOption += 1
    if currentOption > #options then
      currentOption = 1
    end
  end

  if playdate.buttonJustPressed(playdate.kButtonA) then
    PlaySFX("A3")

    if currentOption == OPTION.PLAY then
      SwitchScene(SCENE.GAMEPLAY)
    elseif currentOption == OPTION.CREDITS then
      SwitchScene(SCENE.CREDITS)
    end
  end

  gfx.clear()

  SetFont(Fonts.asheville24Light)
  gfx.drawText(md.name, MARGIN, MARGIN)

  SetFont(Fonts.default)
  gfx.drawText("by " .. md.author, 10, DISPLAY_HEIGHT - ASHEVILLE14_HEIGHT - MARGIN)
  gfx.drawText(version, DISPLAY_WIDTH - VERSION_TEXT_WIDTH - MARGIN, DISPLAY_HEIGHT - ASHEVILLE14_HEIGHT - MARGIN)

  local menuStartY = 80
  local menuYSpacing = 32
  local menuDotSize = 6
  for index, value in pairs(options) do
    gfx.drawText(value, MARGIN + 10, menuStartY + (menuYSpacing * index))

    if currentOption == index then
      gfx.fillRect(MARGIN, menuStartY + 5 + menuYSpacing * index, menuDotSize, menuDotSize)
    end
  end
end

local function init()
  print("Main Menu initialized!")
end

local function close()
  print("Main Menu closed!")
end

local scene = {
  update = update,
  close = close,
  init = init,
}

return scene
