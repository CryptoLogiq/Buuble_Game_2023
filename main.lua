-- little debug for qui game with esacpe press
local debug = true

-- settings
--love.graphics.setDefaultFilter( 'nearest', 'nearest' )
--love.graphics.setDefaultFilter( 'nearest' )
love.physics.setMeter(64)
WorldGrid = love.physics.newWorld(0,0,false)
WorldDestroy = love.physics.newWorld(0,10*64,false)

-- requires Core modules
Core = require("CoreEngine/CoreLoader")

-- Gestion du tableau des scores
ScoreBoard = require("Game/ScoreBoard")

-- requires for Game
BackGround = require("Game/BackGround")
MapManager = require("Game/MapManager")
WallsMap = require("Game/WallsMap")
Bubbles  = require("Game/Bubbles")
Controllers  = require("Game/Controllers")
Sounds  = require("Game/Sounds")
Explosion  = require("Game/Explosion")
Gui = require("Game/Gui")
ScoreEffect = require("Game/ScoreEffect")
--
Screen = require("Game/Screen")


-- Many Scenes used (Intro/Menu/Game/etc.) :
Game = require("Game/Game")
Menu = require("Game/Menu")
GameOver = require("Game/GameOver")

-- add scenes to SceneManager
Core.Scene.newScene(Game, "Game")
Core.Scene.newScene(Menu, "Menu")
Core.Scene.newScene(GameOver, "GameOver")

function love.load()
  -- preload first
  Core.Scene.setScene(Menu)

  -- need first load for dependencies
  Sounds:load()
  ScoreEffect:load()
  Game:load() 

  --
  Bubbles:load()
  Explosion:load()
  --
  BackGround:load()
  MapManager:load()
  --
  WallsMap:load()
  Controllers:load()
  -- last :
  Game:newGame()

  -- other scenes
  Menu:load()

  -- end
  Screen:load()
end
--

function love.update(dt)
  WorldGrid:update(dt)
  WorldDestroy:update(dt)
  --
  Core.Scene.update(dt)
  Screen:update(dt)
end
--

function love.draw()
  Screen:draw(Core.Scene.draw)
end
--

function love.keypressed(key)
  Core.Scene.keypressed(key)
end
--

function love.mousepressed(x,y,button)
  Core.Scene.mousepressed(x,y,button)
end
--