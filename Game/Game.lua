local Game = {debug=false, isStop=false, isPlay=false, gameover=false}

Game.texts = {}
Game.font = {}

function Game:getDimensions()
  self.w, self.h = love.graphics.getDimensions()
  self.ox, self.oy = self.w/2, self.h/2
end
--

function Game:newGame()
  Game.isStop = false
  --
  Game.gameover=false
  --
  MapManager:newGame()
  Bubbles:newGame()
  Sounds:newGame()
  Explosion:newGame()
end
--

--
function Game:load()
  Game:getDimensions()
  --
  for  n=1, 100 do
  table.insert(Game.font , love.graphics.newFont("ressources/fonts/Games.ttf", n) )
  end
  Game.texts.isStop = {txtdata = love.graphics.newText(Game.font[50], "WAITING")}
  Game.texts.isStop.w, Game.texts.isStop.h = Game.texts.isStop.txtdata:getDimensions()
  Game.texts.isStop.ox, Game.texts.isStop.oy = Game.texts.isStop.w/2, Game.texts.isStop.h/2
  Game.texts.isStop.color = {0,1,0,1}
end
--

function Game:update(dt)

  Game:getDimensions(dt)
  BackGround:update(dt)
  Controllers:update(dt)
  Sounds:update(dt)
  if Game.isStop then
  else
    Explosion:update(dt)
    MapManager:update(dt)
    Bubbles:update(dt)
  end
end
--

function Game:draw()
  --
  BackGround:draw()
  --
  Controllers:draw()
  WallsMap:draw()
  MapManager:draw()
  Bubbles:draw()
  Explosion:draw()
  --
  Sounds:draw()
  --
  if Game.isStop then
    love.graphics.setColor(Game.texts.isStop.color)
    love.graphics.draw(Game.texts.isStop.txtdata, Game.ox, Game.oy, 0, 1, 1, Game.texts.isStop.ox, Game.texts.isStop.oy)
    love.graphics.setColor(1,1,1,1)
  end
  --
  if Game.debug then
    local textDebugGame = ""
    for k, v in pairs(Game) do
      if type(v) ~= "table" and type(v) ~= "function" then
        textDebugGame = textDebugGame.."Game."..tostring(k).." : "..tostring(v).."\n"
      end
    end
    --
    textDebugGame = textDebugGame.."-------------------------".."\n"
    --
    for k, v in pairs(Bubbles) do
      if type(v) ~= "table" and type(v) ~= "function" then
        textDebugGame = textDebugGame.."Bubbles."..tostring(k).." : "..tostring(v).."\n"
      end
    end
    love.graphics.print(textDebugGame,10,10)
  end
end
--

function Game:keypressed(key)
  if key == "pause" then
    Game.isStop = not Game.isStop
  elseif key == "escape" then
    love.event.quit()
  end
  BackGround:keypressed(key)
  MapManager:keypressed(key)
  Bubbles:keypressed(key)
  Sounds:keypressed(key)
end
--

function Game:mousepressed(x,y,button)
  Controllers:mousepressed(x,y,button)
end
--

return Game