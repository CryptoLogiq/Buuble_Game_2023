local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.list = {}

Bubbles.images = {}

Bubbles.game = nil

Bubbles.readyLaunch = false

function Bubbles:newBubble(x, y, isPlayer, grid)
  local bub = {debug=true, isPlayer=isPlayer, grid=grid or nil, x=x, y=y, radius=32, ox=32, oy=32, speed=60, color=love.math.random(5)}
  --
  bub.img = Bubbles.images[bub.color]
  --
  bub.body = love.physics.newBody(World, bub.x, bub.y, "kinematic")
  bub.shape = love.physics.newCircleShape(bub.radius)
  bub.fixture = love.physics.newFixture(bub.body, bub.shape)
  --
  function bub:getGroup(x,y)
    for _, other in ipairs(Bubbles.list) do
      if other ~= self then
        local dist = math.dist(self.x, self.y, other.x, other.y)
        if dist <= 80 then
          if self.color == other.color then
            if not self.group then self.group = {} end
            table.insert(self.group, other)
          end
        end
      end
    end
  end
  --
  table.insert(Bubbles.list, bub)
  --
  return bub
end
--

function Bubbles:newBubblePlayer()

  if Game.isPlay then

    local bub = Bubbles:newBubble(Game.ox, Game.h, true)
    --
    Bubbles.game = bub
    --
    Bubbles.readyLaunch = true
    --
  end
end
--

function Bubbles:newMap(nbLig)
  Bubbles.list = {}
  --
  Game.isPlay = false
  --
  local yRef = -MapManager.current.cellH
  for l=nbLig, 1, -1 do
    for c=1, MapManager.current.col do
      local grid = MapManager.current[l][c]
      local bub = Bubbles:newBubble(grid.cx, yRef, false, grid)
    end
    yRef = yRef - MapManager.current.cellH
  end
end
--

function Bubbles:addLigne(nbLig)
  Game.isPlay = false
  --
  MapManager:changeOffset()
  --
  MapManager.current.nbGridOnScreen = MapManager.current.nbGridOnScreen + nbLig
  if MapManager.current.nbGridOnScreen <= MapManager.current.lig then
    -- attibute new coordinate for
    for _, bub in ipairs(Bubbles.list) do
      if bub.grid then
        bub.grid = MapManager.current[bub.grid.lig+nbLig][bub.grid.col]
      end
    end
    --
    local yRef = -MapManager.current.cellH
    for l=nbLig, 1, -1 do
      for c=1, MapManager.current.col do
        local grid = MapManager.current[l][c]
        local bub = Bubbles:newBubble(grid.cx, yRef, false, grid)
      end
      yRef = yRef - MapManager.current.cellH
    end
    --
  else
    Game.gameover = true
  end
end
--

function Bubbles:launchBubble(angle)
  if Bubbles.readyLaunch and Game.isPlay then
    --
    --
    Game.isPlay = false
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

function Bubbles:MoveGrid(dt)
  if not Game.isPlay then
    --
    local goplay = true -- ready to play ?
    --
    for _, bub in ipairs(Bubbles.list) do
      if bub.grid then
        bub.x, bub.y = bub.body:getPosition()
        if bub.y ~= bub.grid.cy then
          bub.y = bub.y + (bub.speed*dt)
          if math.max(bub.y,bub.grid.cy)-math.min(bub.y,bub.grid.cy) < 0.2 then
            bub.y = bub.grid.cy 
          end
          bub.body:setPosition(bub.x, bub.y)
          bub.x, bub.y = bub.body:getPosition()
          --
          goplay = false -- bub is not on position, not ready to play !
        end
      end
    end
    -- all bub's in at position to grid ?
    Game.isPlay = goplay
    --
    if goplay then -- on viens de creer/ajouter des bub's, on recreer les groupes de couleurs des bub's :
      Bubbles:createGroupColor()
    end
  end
end
--

function Bubbles:createGroupColor()
  -- On purge les bub's group's :
  for _, bub in ipairs(Bubbles.list) do
    if bub.group then bub.group = nil end
  end

  -- On attachs les bub's to group's de meme couleur qui sont a proximité :
  for _, bub in ipairs(Bubbles.list) do
    bub:getGroup()
  end
end
--

function Bubbles:update(dt)

  -- move bubbles ?
  Bubbles:MoveGrid(dt)

  -- Create a new bub player ?
  if Bubbles.game then
    Bubbles.game.x, Bubbles.game.y = Bubbles.game.body:getPosition()
  end
  --
  if not Bubbles.readyLaunch and Game.isPlay then
    Bubbles:newBubblePlayer()
  end
end
--

function Bubbles:draw()
  love.graphics.setColor(1,1,1,1)
  for _, bub in ipairs(Bubbles.list) do
    love.graphics.draw(bub.img.imgdata, bub.x, bub.y, 0,1,1, bub.ox, bub.oy)
    if bub.debug then
      if bub.group then
        love.graphics.setColor(1,0,0,1)
        for _, other in ipairs(bub.group) do
          love.graphics.line(bub.x, bub.y, other.x, other.y)
        end
        love.graphics.setColor(1,1,1,1)
      end
    end
  end
  if Bubbles.debug then
    local bub1 = Bubbles.list[1]
    local bub2 = Bubbles.list[19]
    local dist = math.dist(bub1.x, bub1.y, bub2.x, bub2.y)
    love.graphics.setColor(1,0,0,1)
    love.graphics.print(dist, 400,300)
    love.graphics.line(bub1.x, bub1.y, bub2.x, bub2.y)
    love.graphics.setColor(1,1,1,1)
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
