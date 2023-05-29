local Game = {debug=true, isStop=false, isPlay=false, gameover=false}


World = love.physics.newWorld(0,0,false)

BackGround = require("Game/BackGround")
MapManager = require("Game/MapManager")
Bubbles  = require("Game/Bubbles")
Controllers  = require("Game/Controllers")
Sounds  = require("Game/Sounds")

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
  --
  BackGround:load()
  MapManager:load()
  Controllers:load()
end
--

function Game:update(dt)
  Game:getDimensions(dt)
  BackGround:update(dt)
  Controllers:update(dt)
  Sounds:update(dt)
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
  MapManager:draw()
  Bubbles:draw()
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

return Game