import "CoreLibs/ui"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local md <const> = playdate.metadata

local MARGIN = 20

local OPTION = {
  PLAY = 1,
  ZEN = 2,
  CONTROLS = 3,
  CREDITS = 4,
}
local options = {
  [OPTION.PLAY] = "Play",
  [OPTION.ZEN] = "Zen Mode",
  [OPTION.CONTROLS] = "Controls",
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
    elseif currentOption == OPTION.ZEN then
      SwitchScene(SCENE.ZEN)
    elseif currentOption == OPTION.CONTROLS then
      SwitchScene(SCENE.CONTROLS)
    elseif currentOption == OPTION.CREDITS then
      SwitchScene(SCENE.CREDITS)
    end
  end

  gfx.clear()

  SetFont(Fonts.title)

  gfx.setColor(gfx.kColorBlack)
  gfx.fillRect(0, 0, DISPLAY_WIDTH, 60)
  gfx.setColor(gfx.kColorWhite)
  gfx.drawLine(0, 58, DISPLAY_WIDTH, 58)
  gfx.setColor(gfx.kColorBlack)

  gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
  gfx.drawText(md.name, MARGIN, MARGIN)
  gfx.setImageDrawMode(gfx.kDrawModeCopy)

  SetFont(Fonts.subtitle)

  local menuStartY = 40
  local menuYSpacing = 40
  local menuHeight = 31
  local menuLength = DISPLAY_WIDTH - MARGIN - menuHeight - 5 - MARGIN
  for index, value in pairs(options) do
    if currentOption == index then
      -- text frame
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRoundRect(MARGIN, menuStartY-8 + menuYSpacing * index, menuLength, menuHeight, 3)
      gfx.setColor(gfx.kColorWhite)
      gfx.fillRoundRect(MARGIN+1, menuStartY-8+1 + menuYSpacing * index, menuLength-2, menuHeight-2, 3)
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRoundRect(MARGIN+1+1, menuStartY-8+1+1 + menuYSpacing * index, menuLength-2-2, menuHeight-2-2, 3)

      -- block
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRoundRect(MARGIN+menuLength+5, menuStartY-8 + menuYSpacing * index, menuHeight, menuHeight, 3)
      gfx.setColor(gfx.kColorWhite)
      gfx.fillRoundRect(MARGIN+menuLength+5+1, menuStartY-8+1 + menuYSpacing * index, menuHeight-2, menuHeight-2, 3)
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRoundRect(MARGIN+menuLength+5+1+1, menuStartY-8+1+1 + menuYSpacing * index, menuHeight-2-2, menuHeight-2-2, 3)

      -- text
      gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
      gfx.drawText(value, MARGIN + 10, menuStartY + (menuYSpacing * index))
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    else
      -- background
      gfx.setColor(gfx.kColorBlack)
      gfx.fillRoundRect(MARGIN, menuStartY-8 + menuYSpacing * index, menuLength+menuHeight+5, menuHeight, 3)

      -- pattern
      gfx.setColor(gfx.kColorWhite)
      for line = 1, menuHeight do
        if line % 2 == 0 then
          gfx.fillRect(MARGIN, menuStartY-8 + menuYSpacing * index+line, menuLength+menuHeight+5, 1)
        end
      end

      -- frame
      gfx.setColor(gfx.kColorBlack)
      gfx.drawRoundRect(MARGIN, menuStartY-8 + menuYSpacing * index, menuLength+menuHeight+5, menuHeight, 3)

      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      gfx.drawText(value, MARGIN + 10, menuStartY + (menuYSpacing * index))
      gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end
  end

  if playdate.isCrankDocked() then
    playdate.ui.crankIndicator:draw()
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
