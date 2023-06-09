local Gui = {debug=false}

Gui.listButtons = {}

Gui.listSliders = {}

Gui.ScoreGame = nil

function Gui:newText(pText, pFont, x, y)
  local text = {textsource=pText, textdata=love.graphics.newText(pFont, pText), color={0.729,0.333,0.827,1}, x=x, y=y}
  text.w, text.h = text.textdata:getDimensions()
  text.ox, text.oy = text.w/2, text.h/2
  --
  return text
end
--

function Gui:SliderVolume(pText, pSound, pValueMin, pValueMax)
  --
  local rectRef = MapManager.current.bordures[2]
  --
  local h=10
  local w = rectRef.w * 0.8
  --
  local decx = (rectRef.w - w)/2
  local decy = 50
  --
  local x = rectRef.x + decx
  --
  local startY = 20
  local y = startY + ( h+decy * #Gui.listSliders )
  --
  local color={0.627,0.322,0.176,1}
  local colorSurvol={0.647,0.165,0.165,1}
  --
  local linebar = {x=x, y=y+(h/2), w=w, h=4, color={0.6,0.5,0.7,1}}
  --
  local button = {x=x, y=y-3, w=10, h=20, ox=5, oy=10, color=color, colorDef=color, colorSurvol=colorSurvol}
  --
  local text = Gui:newText(pText, Font.Games[22], x, y-25)
  --
  local slider = {sound= pSound, min=pValueMin, max=pValueMax}
  --
  slider.linebar=linebar
  slider.button=button
  slider.text=text
  --
  slider.getSliderPosition = Gui.getSliderPosition
  slider.setSliderVolume = Gui.setSliderVolume
  --
  slider:getSliderPosition()
  --
  table.insert(Gui.listSliders, slider)
end
--

function Gui.getSliderPosition(self)
  local value = self.sound.volume -- 0 to 1 (pourcentage)
  --
  self.button.x = self.linebar.x + (self.linebar.w * value)
  --
end
--

function Gui.setSliderVolume(self)
  if love.mouse.isDown(1) then
    if CheckCollision(self.linebar.x, self.linebar.y-self.button.oy, self.linebar.w,  self.button.h,  Mouse.x, Mouse.y,1,1) then
      --
      local posX = Mouse.x - self.linebar.x
      local pct = (posX * 100) / self.linebar.w

      -- move button to pos
      self:getSliderPosition()

      -- set Volunme is a Pct of value : 0 to 1
      -- volume at 100 % ? 100/100 = 1
      -- volume at 50 % ? 50/100 = 0.5
      pct = pct / 100
      self.sound.volume = pct
      --
      Sounds:setVolume(self.sound)
      --
      return true
    end
  end
  return false
end
--

function Gui:newScoreGame()
  --
  local rectRef = MapManager.current.bordures[1]
  --
  local h=10
  local w = rectRef.w * 0.8
  --
  local decx = (rectRef.w - w)/2
  local decy = 50
  --
  local x = rectRef.x + decx
  --
  local startY = 20
  local y = startY
  --
  local scoregame = {
    text=Gui:newText("Best: 0".."\n\n\n".."Score: 0", Font.CursedTimerULiL[25], x, y),
    score=0,
    bestscore=0,
    x=x, y=y, w=h, h=h }
  --
  function scoregame:update(dt)
    self.text.textdata:setf("Best: "..tostring(self.bestscore).."\n\n\n".."Score: "..tostring(self.score), love.graphics.getWidth(), "left")
  end
  --
  function scoregame:draw()
    love.graphics.setColor(self.text.color)
    love.graphics.draw( self.text.textdata, self.text.x, self.text.y )
    love.graphics.setColor(1,1,1,1)
  end
  --
  return scoregame
end
--

function Gui:load()
  if #Gui.listSliders <= 0 then
    Gui:SliderVolume("Volume Music", Sounds.Music, true, 0, 1) -- ptext, pSound
    Gui:SliderVolume("Volume Sfx", Sounds.Sfx, true, 0, 1) -- ptext, pSound
  end
  --
  Gui.ScoreGame = Gui:newScoreGame()
end
--

function Gui:update(dt)
  for _, slider in ipairs(Gui.listSliders) do
    slider:setSliderVolume()
  end
  --
  Gui.ScoreGame:update(dt)
end
--

function Gui:draw()
  -- bordures
  love.graphics.setColor(0,0,0,0.55)
  for n=1, #MapManager.current.bordures do
    local rect = MapManager.current.bordures[n]
    love.graphics.rectangle(rect.mode,rect.x,rect.y,rect.w,rect.h,5)
  end
  love.graphics.setColor(1,1,1,1)

  -- slider
  for _, slider in ipairs(Gui.listSliders) do
    -- text
    love.graphics.setColor(slider.text.color)
    love.graphics.draw(slider.text.textdata,slider.text.x, slider.text.y )
    -- linebar
    love.graphics.setColor(slider.linebar.color)
    love.graphics.rectangle("fill", slider.linebar.x, slider.linebar.y, slider.linebar.w, slider.linebar.h)
    -- button
    love.graphics.setColor(slider.button.color)
    love.graphics.rectangle("fill", slider.button.x, slider.button.y, slider.button.w, slider.button.h)
    -- reset color
    love.graphics.setColor(1,1,1,1)
  end

  -- scores
  Gui.ScoreGame:draw()
end
--


function Gui:keypressed(key)
end
--


function Gui:mousepressed(x,y,button)
end
--

return Gui