-- little debug for qui game with esacpe press
local debug = true

-- settings
love.graphics.setDefaultFilter( 'nearest', 'nearest' )

-- requires Core modules
Core = require("CoreEngine/CoreLoader")

-- Many Scenes used (Intro/Menu/Game/etc.) :
Game = require("Game/Game")

-- add scenes to SceneManager
Core.Scene.newScene(Game, "Game")

function love.load()
  Core.Scene.setScene(Game)
  --
  Core.Scene.loadScene()
end
--

function love.update(dt)
  Core.Scene.update(dt)
end
--

function love.draw()
  Core.Scene.draw()
end
--

function love.keypressed(key)
  Core.Scene.keypressed(key)
  if debug then
    if key == "escape" then
      love.event.quit()
    end
  end
end
--

function love.mousepressed(x,y,button)
  Core.Scene.mousepressed(x,y,button)
end
--