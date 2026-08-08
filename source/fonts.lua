local gfx <const> = playdate.graphics

-- Loaded fonts you can use, like: SetFont(Fonts.asheville)
Fonts = {
  asheville14Bold = gfx.font.new("/System/Fonts/Asheville-Sans-14-Bold.pft"),
  asheville24Light = gfx.font.new("/System/Fonts/Asheville-Sans-24-Light.pft"),
  -- Uncomment the fonts system fonts below to make them available
  -- roobert10Bold = gfx.font.new("/System/Fonts/Roobert-10-Bold.pft"),
  -- roobert11Bold = gfx.font.new("/System/Fonts/Roobert-11-Bold.pft"),
  -- roobert11Medium = gfx.font.new("/System/Fonts/Roobert-11-Medium.pft"),
  -- roobert20Medium = gfx.font.new("/System/Fonts/Roobert-20-Medium.pft"),
  -- roobert24Medium = gfx.font.new("/System/Fonts/Roobert-24-Medium.pft"),
}

Fonts.default = Fonts.asheville14Bold

-- Sets the font to draw for future `playdate.graphics.drawText` calls; gets
-- reset to `default` at the start of each frame
function SetFont(font)
  gfx.setFont(font)
end
