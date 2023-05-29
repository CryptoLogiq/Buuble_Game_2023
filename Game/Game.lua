local Game = {debug=false, isStop=false, isPlay=false, gameover=false}

love.physics.setMeter(64)
WorldGrid = love.physics.newWorld(0,0,false)
WorldDestroy = love.physics.newWorld(0,10*64,false)

BackGround = require("Game/BackGround")
MapManager = require("Game/MapManager")
WallsMap = require("Game/WallsMap")
Bubbles  = require("Game/Bubbles")
Controllers  = require("Game/Controllers")
Sounds  = require("Game/Sounds")
Explosion  = require("Game/Explosion")

function Game:getDimensions()
  self.w, self.h = love.graphics.getDimensions()
  self.ox, self.oy = self.w/2, self.h/2
end
--

function Game:newGame()
  Game.gameover=false
  --

end
--

--
function Game:load()
  Game:getDimensions()
  --
  Bubbles:load()
  Sounds:load()
  Explosion:load()
  --
  BackGround:load()
  MapManager:load()
  --
  WallsMap:load()
  Controllers:load()
end
--

function Game:update(dt)
  WorldGrid:update(dt)
  WorldDestroy:update(dt)
  --
  Game:getDimensions(dt)
  BackGround:update(dt)
  Controllers:update(dt)
  Sounds:update(dt)
  Explosion:update(dt)
  if Game.isStop then
  else
    MapManager:update(dt)
    Bubbles:update(dt)
  end
end
--

function Game:draw()
  love.graphics.print("Bubble Game 2023")
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
    love.graphics.print("PAUSE", Game.ox, Game.oy, 0, 5, 5)
  end
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