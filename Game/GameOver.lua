local GameOver = {debug=false}

function GameOver:new()
end
--

function GameOver:load()
end
--

function GameOver:update(dt)
end
--

function GameOver:draw()
  love.graphics.print("GAME OVER", Game.ox, Game.oy, 0, 5,5)
end
--


function GameOver:keypressed(key)
end
--


function GameOver:mousepressed(x,y,button)
end
--

return GameOver
