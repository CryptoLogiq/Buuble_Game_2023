local Game = {debug=false, isPlay=false}


World = love.physics.newWorld(0,0,false)

BackGround = require("Game/BackGround")
MapManager = require("Game/MapManager")
Bubbles  = require("Game/Bubbles")

function Game:getDimensions()
  self.w, self.h = love.graphics.getDimensions()
end
--

--
function Game:load()
  Game:getDimensions()
  --
  Bubbles:load()
  --
  BackGround:load()
  MapManager:load()
end
--

function Game:update(dt)
  Game:getDimensions(dt)
  --
  BackGround:update(dt)
  MapManager:update(dt)
  Bubbles:update(dt)
  if Game.isPlay then
    --Player:update(dt)
  end
end
--

function Game:draw()
  love.graphics.print("Bubble Game 2023")
  --
  BackGround:draw()
  MapManager:draw()
  Bubbles:draw()
end
--

function Game:keypressed(key)
  BackGround:keypressed(key)
  MapManager:keypressed(key)
  Bubbles:keypressed(key)
end
--

return Game