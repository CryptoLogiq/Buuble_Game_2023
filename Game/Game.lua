local Game = {debug=false}

local BackGround = require("Game/BackGround")
local MapManager = require("Game/MapManager")

function Game:getDimensions()
  self.w, self.h = love.graphics.getDimensions()
end
--

--
function Game.load()
  Game:getDimensions()
  --
  BackGround:load()
  MapManager:load()
end
--

function Game.update(dt)
  Game:getDimensions()
  --
  BackGround:update(dt)
  MapManager:update(dt)
end
--

function Game.draw()
  love.graphics.print("Bubble Game 2023")
  --
  BackGround:draw()
  MapManager:draw()
end
--

return Game