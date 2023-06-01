local Menu = {debug=false}

Menu.listButtons = {}

function Menu:newButton(text, func)
  local startY = Game.oy - 200
  local color={0.627,0.322,0.176,1}
  local colorSurvol={0.647,0.165,0.165,1}
  --
  local button = {x=Game.ox-200,y=startY,w=400,h=100, ox=200, oy=50, execute=func,color=color, colorDef=color, colorSurvol=colorSurvol}
  button.text = {textsource=text, txtdata=love.graphics.newText(Font.Games[40], text)}
  button.text.w, button.text.h = button.text.txtdata:getDimensions()
  button.text.ox, button.text.oy = button.text.w/2, button.text.h/2
  button.text.color={0.1,0.2,0.3,0.8}
  --
  button.y = startY + ((#Menu.listButtons +1) * 110)
  --
  button.cx = button.x + button.ox
  button.cy = button.y + button.oy
  --
  table.insert(Menu.listButtons, button)
end
--

function Menu:updateButtons(dt)
  for _, button in ipairs(self.listButtons) do
    if CheckCollision(button.x,button.y,button.w,button.h, Mouse.x,Mouse.y,1,1) then
      button.color = button.colorSurvol
    else
      button.color = button.colorDef
    end
  end
end
--

function Menu:drawButtons()
  for _, button in ipairs(self.listButtons) do
    love.graphics.setColor(button.color)
    love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 10)
    --
    love.graphics.setColor(button.text.color)
    love.graphics.draw(button.text.txtdata, button.cx, button.cy,0, 1, 1, button.text.ox, button.text.oy)
    --
    love.graphics.setColor(1,1,1,1)
  end
end
--

function Menu:open()
  Game.isStop = true
  --
  if not Sounds.musique:isPlaying() then
    Sounds.musique:play()
  end
end
--

function Menu:load()
  Menu:newButton( "Jouer" , function() Game:newGame() ; Core.Scene.setScene(Game) end )
  Menu:newButton( "Quitter" , function() love.event.quit() end )
  --
  Menu:open()
  --
  Sounds.musique:setVolume(0)
end
--

function Menu:update(dt)
  if Sounds.musique:getVolume() < Sounds.Music.volume then
    Sounds.musique:setVolume(Sounds.musique:getVolume()+(dt/10))
  elseif Sounds.musique:getVolume() >= Sounds.Music.volume then
    Sounds.musique:setVolume(Sounds.musique:getVolume()-(dt/10))
  end
  if math.floor(Sounds.musique:getVolume()*100) == Sounds.Music.volume * 100 then
    Sounds.musique:setVolume(Sounds.Music.volume)
  end
  --
  Game:getDimensions()
  Menu:updateButtons(dt)
  --
  BackGround:update(dt)
  Controllers:update(dt)
--  Sounds:update(dt)
  Explosion:update(dt)
end
--

function Menu:draw()
  --
  BackGround:draw()
  --
  Bubbles:draw()
  Explosion:draw()
  --
  Menu:drawButtons()
  --
  Controllers:draw()
  --
  Sounds:draw()
  --
end
--

function Menu:keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
--

function Menu:mousepressed(x,y,button)
  for _, button in ipairs(self.listButtons) do
    if CheckCollision(button.x,button.y,button.w,button.h, Mouse.x,Mouse.y,1,1) then
      button:execute()
      return true
    end
  end
end
--

return Menu