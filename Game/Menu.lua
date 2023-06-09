local Menu = {debug=false}

Menu.listButtons = {}

local ButtonPlay, ButtonQuit

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
  button.y = startY + (#Menu.listButtons * 210)
  --
  button.cx = button.x + button.ox
  button.cy = button.y + button.oy
  --
  table.insert(Menu.listButtons, button)

  return button
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
  if not Sounds.musique.source:isPlaying() then
    Sounds.musique.source:play()
  end
end
--

function Menu:load()
  ButtonPlay = Menu:newButton( 
    "Jouer",
    function()
      if Game.StartNewGame or Game.gameover then
        Game:newGame() 
      end
      if Game.isStop then
        Game.isStop = false
      end
      Core.Scene.setScene(Game)
    end 
  )
  ButtonPlay.colorDef = {0.42,0.557,0.137,1}
  ButtonPlay.colorSurvol = {0,1,0.498,1}
  ButtonQuit = Menu:newButton( "Quitter" , function() love.event.quit() end )
  ButtonQuit.colorDef = {0.647,0.165,0.165,1}
  ButtonQuit.colorSurvol = {0.863,0.078,0.235,1}
  --
  Menu:open()
  --
  Sounds.musique.source:setVolume(0)
end
--

function Menu:update(dt)
  if Sounds.musique.source:getVolume() < Sounds.Music.volume then
    Sounds.musique.source:setVolume(Sounds.musique.source:getVolume()+(dt/10))
  elseif Sounds.musique.source:getVolume() >= Sounds.Music.volume then
    Sounds.musique.source:setVolume(Sounds.musique.source:getVolume()-(dt/10))
  end
  if math.floor(Sounds.musique.source:getVolume()*100) == Sounds.Music.volume * 100 then
    Sounds.musique.source:setVolume(Sounds.Music.volume)
  end
  --
  Game:getDimensions()
  Menu:updateButtons(dt)
  --
  BackGround:update(dt)
  Controllers:update(dt)
--  Sounds:update(dt)
  Explosion:update(dt)
  --
  Gui:update(dt)
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
  Gui:draw()
  --
  Controllers:draw()
  --
  Sounds:draw()
  --
end
--

function Menu:keypressed(key)
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