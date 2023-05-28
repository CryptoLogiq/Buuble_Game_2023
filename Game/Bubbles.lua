local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.list = {}

Bubbles.images = {}

function Bubbles:newBubble()

  local bubble = {isLaunch=false, radius=32, ox=32, oy=32, speed=60, color=love.math.random(5)}
  bubble.img = Bubbles.images[bubble.color]
  --
  bubble.x = Game.ox
  bubble.y = Game.h
  --
  bubble.body = love.physics.newBody(World, bubble.x, bubble.y, "kinematic")
  bubble.shape = love.physics.newCircleShape(bubble.radius)
  bubble.fixture = love.physics.newFixture(bubble.body, bubble.shape)
  --
  Bubbles.game = bubble
  --
  Game.isPlay = false
end
--

function Bubbles:newMap(nbLig)
  Bubbles.list = {}
  --
  local yRef = -MapManager.current.cellH
  for l=nbLig, 1, -1 do
    for c=1, MapManager.current.col do
      local grid = MapManager.current[l][c]
      local bubble = {x=grid.cx, y=yRef, radius=32, ox=32, oy=32, grid=grid, speed=60, color=love.math.random(5)}
      bubble.img = Bubbles.images[bubble.color]
      bubble.body = love.physics.newBody(World, grid.cx, yRef, "kinematic")
      bubble.shape = love.physics.newCircleShape(bubble.radius)
      bubble.fixture = love.physics.newFixture(bubble.body, bubble.shape)
      table.insert(Bubbles.list, bubble)
    end
    yRef = yRef - MapManager.current.cellH
  end
  --
  Game.isPlay = false
end
--

function Bubbles:addLigne(nbLig)
  MapManager.current.nbGridOnScreen = MapManager.current.nbGridOnScreen + nbLig
  --
  for _, bubble in ipairs(Bubbles.list) do
    bubble.grid = MapManager.current[bubble.lig+nbLig][bubble.col]
  end
  --
  Bubbles:newMap(nbLig)
  --
  Game.isPlay = false
end
--


function Bubbles:load()
  for n=1, 5 do
    local bubImg = Core.ImageManager.newImage("ressources/images/bubble_"..n..".png")
    table.insert(Bubbles.images, bubImg)
  end
end
--

function Bubbles:update(dt)
  if not Game.isPlay then
    local pause = true
    for _, bubble in ipairs(Bubbles.list) do
      bubble.x, bubble.y = bubble.body:getPosition()
      if bubble.y ~= bubble.grid.cy then
        bubble.y = bubble.y + (bubble.speed*dt)
        if math.max(bubble.y,bubble.grid.cy)-math.min(bubble.y,bubble.grid.cy) < 0.2 then
          bubble.y = bubble.grid.cy 
        end
        bubble.body:setPosition(bubble.x, bubble.y)
        bubble.x, bubble.y = bubble.body:getPosition()
        --
        pause = false
      end
    end
    --
    Game.isPlay = pause
  end
  --
  if Bubbles.game then
    Bubbles.game.x, Bubbles.game.y = Bubbles.game.body:getPosition()
  elseif not Bubbles.game and Game.isPlay then
    Bubbles:newBubble()
  end
end
--

function Bubbles:draw()
  love.graphics.setColor(1,1,1,1)
  for _, bubble in ipairs(Bubbles.list) do
--    love.graphics.circle("fill", bubble.x, bubble.y, bubble.radius)
    love.graphics.draw(bubble.img.imgdata, bubble.x, bubble.y, 0,1,1, bubble.ox, bubble.oy)
  end
  if Bubbles.game then
    love.graphics.draw(Bubbles.game.img.imgdata, Bubbles.game.x, Bubbles.game.y, 0,1,1, Bubbles.game.ox, Bubbles.game.oy)
  end
  love.graphics.setColor(1,1,1,1)
end
--

function Bubbles:keypressed(key)
  if key == "space" then
    Bubbles:addLigne(1)
  end
end
--

return Bubbles
