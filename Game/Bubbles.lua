local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.list = {}

Bubbles.images = {}

function Bubbles:new(nbLig)
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
  if Game.isPlay == false then
    local startPlay = true
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
        startPlay = false
      end
    end
    Game.isPlay = startPlay
  end
end
--

function Bubbles:draw()
  love.graphics.setColor(1,1,1,1)
  for _, bubble in ipairs(Bubbles.list) do
--    love.graphics.circle("fill", bubble.x, bubble.y, bubble.radius)
    love.graphics.draw(bubble.img.imgdata, bubble.x, bubble.y, 0,1,1, bubble.ox, bubble.oy)
  end
  love.graphics.setColor(1,1,1,1)
end
--

function Bubbles:keypressed(key)
end
--

return Bubbles
