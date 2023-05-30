local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.listGrid = {}

Bubbles.listDestroy = {}

Bubbles.images = {}

Bubbles.game = nil

Bubbles.readyLaunch = false

function Bubbles:newBubble(x, y, isPlayer, World, grid)
  local bub = {world=World, debug=false, isPlayer=isPlayer, isDestroy=false, grid=grid or nil, x=x, y=y, radius=32, ox=32, oy=32, speed=60, color=love.math.random(5), isLaunch=false}
  --
  bub.img = Bubbles.images[bub.color]
  --
  bub.body = love.physics.newBody(World, bub.x, bub.y, "kinematic")
  bub.shape = love.physics.newCircleShape(bub.radius)
  bub.fixture = love.physics.newFixture(bub.body, bub.shape)
  bub.fixture:setRestitution(0.9)
  --
  bub.timer={current=0, delai=180, speed=love.math.random(60,180)}
  --
  function bub:getGroup()
    for _, other in ipairs(Bubbles.listGrid) do
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
  function bub:getIsProx()
    if not self.isPlayer and self.isDestroy == false then
      if bub.grid.lig == 1 then
        return true
      end
      for _, other in ipairs(Bubbles.listGrid) do
        if other ~= self and not other.isDestroy then
          local dist = math.dist(self.x, self.y, other.x, other.y)
          if dist <= 80 then
            return true
          end
        end
      end
      -- si il n'y pas de bubble a proximite alors :
      bub:changeWorld(WorldDestroy)
    end
    return false
  end
  --
  function bub:changeWorld(world)
    bub.isDestroy = true
    bub.body:destroy()
    --
    local new = Bubbles:newBubble(bub.x, bub.y, false, world) -- x, y, isPlayer, World, grid
    new.color = bub.color
    new.img = Bubbles.images[bub.color]
    new.group = Bubbles.listDestroy
    --
    new.body:setType("dynamic")
    new.body:applyForce(love.math.random(-150,150), love.math.random(510,660))
  end
  --
  function bub:update(dt)
    if not bub.destroy then
      bub.x, bub.y = bub.body:getPosition()
    end
    --
    if not bub.destroy and bub.world == WorldGrid then
      bub:getIsProx()
    elseif bub.world == WorldDestroy then
      if bub:timerExplosion(dt) then
        Explosion:newExplosion(bub.x, bub.y)
        bub.body:destroy()
        Bubbles:purgeList(bub, Bubbles.listDestroy)
      end
    end
  end
  function bub:timerExplosion(dt)
    bub.timer.current = bub.timer.current + (bub.timer.speed * dt)
    if bub.timer.current >= bub.timer.delai then
      bub.timer.current = 0
      return true
    end
    return false
  end
  --
  if World == WorldGrid then
    table.insert(Bubbles.listGrid, bub)
  elseif World == WorldDestroy then
    table.insert(Bubbles.listDestroy, bub)
  end
  --
  return bub
end
--

function Bubbles:newBubblePlayer()

  if Game.isPlay then

    local bub = Bubbles:newBubble(Game.ox, Game.h, true, WorldGrid) -- x, y, isPlayer, World, grid
    --
    Bubbles.game = bub
    --
    Bubbles.readyLaunch = true
    --
  end
end
--

function Bubbles:newMap(nbLig)
  Bubbles.listGrid = {}
  Bubbles.listDestroy = {}
  --
  Game.isPlay = false
  --
  local yRef = -MapManager.current.cellH
  for l=nbLig, 1, -1 do
    for c=1, MapManager.current.col do
      local grid = MapManager.current[l][c]
      local bub = Bubbles:newBubble(grid.cx, yRef, false, WorldGrid, grid)-- x, y, isPlayer, World, grid
    end
    yRef = yRef - MapManager.current.cellH
  end
end
--

function Bubbles:destroyGroup(groupList)
  for _, bubble in ipairs(groupList) do
    bubble:changeWorld(WorldDestroy)-- tag isDestroy and create new bubble in WorldDestroy :
    Bubbles:purgeList(bubble, Bubbles.listGrid)
  end
end
--

function Bubbles:createGroupePurge(bub, destroyList)
  local list = destroyList or {}
  for _, other in pairs(bub.group) do
    if bub ~= other then
      if not Bubbles:getBubbleInList(other, list) then
        table.insert(list, other)
        list = Bubbles:createGroupePurge(other, list)
      end
    end
  end
  return list
end
--

function Bubbles:getBubbleInList(bub, list)
  for _, other in ipairs(list) do
    if bub == other then return true end
  end
  return false
end
--

function Bubbles:launchBubble()
  if Bubbles.readyLaunch and Game.isPlay then
    --
    local cos = math.cos(Mouse.angle)
    local sin = math.sin(Mouse.angle)
    Bubbles.game.body:setLinearVelocity(cos*Bubbles.game.speed*20, sin*Bubbles.game.speed*20)
    Bubbles.game.body:setType("dynamic")
    Bubbles.game.isLaunch = true
    --
    Game.isPlay = false
  end
end
--

function Bubbles:updateBubblePlayer(dt)
  if Bubbles.game then
    --
    Bubbles.game.x, Bubbles.game.y = Bubbles.game.body:getPosition()
    --
    if Bubbles.game.isLaunch then
      local isTouching = false
      for _, other in pairs(Bubbles.listGrid) do
        if Bubbles.game.body:isTouching(other.body) then
          isTouching = true
          break
        end
      end
      if not isTouching then
        if Bubbles.game.body:isTouching(WallsMap.upGrid.body) then
          isTouching = true
        end
      end
      if isTouching then
        Bubbles.game.body:setLinearVelocity(0,0)
        --
        Bubbles.game.grid = MapManager:getGrid(Bubbles.game.x, Bubbles.game.y)
        Bubbles.game.x, Bubbles.game.y = Bubbles.game.grid.cx, Bubbles.game.grid.cy
        Bubbles.game.body:setPosition(Bubbles.game.x, Bubbles.game.y)
        Bubbles.game.isPlayer = false
        Bubbles.game.body:setType("kinematic")
        --
        Bubbles:createGroupColor()
        --
        Bubbles.readyLaunch = false
        --
        if Bubbles.game.group then
          local destroy, nbBubbles = Bubbles:impactGroup(Bubbles.game.x, Bubbles.game.y)
          if destroy then
            if nbBubbles >= 5 then
              Sounds.correct:play()
            end
          end
        end
      end
    end
    --
  end
end
--

function Bubbles:impactGroup(x,y)

  --
  for _, bub in ipairs(Bubbles.listGrid) do
    if bub.grid and bub.color == Bubbles.game.color then
      local dist = math.dist(x, y, bub.x, bub.y)
      if dist <= 80 then
        if bub.group then
          local destroyList = {}
          destroyList = Bubbles:createGroupePurge(bub)
          if #destroyList >= 3 then
            Bubbles:destroyGroup(destroyList)
            return true, #destroyList
          end
          --
        end
      end
    end
  end
  return false
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
    for _, bub in ipairs(Bubbles.listGrid) do
      if bub.grid then
        bub.grid = MapManager.current[bub.grid.lig+nbLig][bub.grid.col]
      end
    end
    --
    local yRef = -MapManager.current.cellH
    for l=nbLig, 1, -1 do
      for c=1, MapManager.current.col do
        local grid = MapManager.current[l][c]
        local bub = Bubbles:newBubble(grid.cx, yRef, false, WorldGrid, grid)-- x, y, isPlayer, World, grid
      end
      yRef = yRef - MapManager.current.cellH
    end
    --
  else
    Game.gameover = true
  end
end
--

function Bubbles:resetList(list)
  for _, bubble in ipairs(list) do
    bubble:destroy()
  end
  --
  list = {}
end
--

function Bubbles:newGame()
  Bubbles:resetList(Bubbles.listGrid)
  Bubbles:resetList(Bubbles.listDestroy)
  --
  Bubbles:newMap(MapManager.current.nbGridOnScreen)
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
  if not Game.isPlay and not Game.isStop then
    --
    local goplay = true -- ready to play ?
    --
    for _, bub in ipairs(Bubbles.listGrid) do
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
  for _, bub in ipairs(Bubbles.listGrid) do
    if bub.group then bub.group = nil end
  end

  -- On attachs les bub's to group's de meme couleur qui sont a proximité :
  for _, bub in ipairs(Bubbles.listGrid) do
    bub:getGroup()
  end
end
--
function Bubbles:purgeList(bubble, list)
  for n=#list, 1, -1 do
    local search = list[n]
    if search == bubble then
      table.remove(list, n)
      return true
    end
  end
end
--

function Bubbles:update(dt)

  -- in grid :
  for _, bubble in ipairs(Bubbles.listGrid) do
    bubble:update(dt)
    if bubble.isDestroy then
      Bubbles:purgeList(bubble, Bubbles.listGrid)
    end
  end

  -- update bubble go destroy
  for _, bubble in ipairs(Bubbles.listDestroy) do
    bubble:update(dt)
  end

  -- move bubbles ?
  Bubbles:MoveGrid(dt)

  -- update pos for bub of player :
  Bubbles:updateBubblePlayer(dt)

  -- Create a new bub player ?
  if not Bubbles.readyLaunch and Game.isPlay then
    Bubbles:newBubblePlayer()
  end
end
--

function Bubbles:drawList(list)
  for _, bub in ipairs(list) do
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
end
--

function Bubbles:draw()
  love.graphics.setColor(1,1,1,1)
  --
  Bubbles:drawList(Bubbles.listGrid)
  --
  Bubbles:drawList(Bubbles.listDestroy)
  --
  if Bubbles.debug then
    local bub1 = Bubbles.listGrid[1]
    local bub2 = Bubbles.listGrid[19]
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
