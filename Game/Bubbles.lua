local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.listGrid = {}

Bubbles.listDestroy = {}

Bubbles.images = {}

Bubbles.game = nil

Bubbles.readyLaunch = false

local colorsBubbles = {{1,0,1,1},{0,1,0,1},{0,0,1,1},{0,0,0,1},{1,0,0,1}}

function Bubbles:newBubble(x, y, isPlayer, World, grid)
  local bub = {world=World, debug=false, isPlayer=isPlayer, isDead=false, listWall={}, isWall=true, grid=grid or nil, x=x, y=y, radius=32, ox=32, oy=32, speed=60, colorID=love.math.random(5), isLaunch=false}
  --
  bub.color=colorsBubbles[bub.colorID]
  bub.img = Bubbles.images[bub.colorID]
  --
  bub.body = love.physics.newBody(World, bub.x, bub.y, "kinematic")
  bub.shape = love.physics.newCircleShape(bub.radius)
  bub.fixture = love.physics.newFixture(bub.body, bub.shape)
  bub.fixture:setRestitution(0.9)
  --
  bub.timer={current=0, delai=180, speed=love.math.random(60,180)}
  --
  Bubbles.getFunctions(bub)
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

function Bubbles.getFunctions(self)

  function self:getGroup()
    for _, other in ipairs(Bubbles.listGrid) do
      if other ~= self then
        local dist = math.dist(self.x, self.y, other.x, other.y)
        if dist <= 75 then
          if self.colorID == other.colorID then
            if not self.group then self.group = {} end
            table.insert(self.group, other)
          end
        end
      end
    end
  end
  --

  function self:getIsWalled()
    if self.grid and not self.isDead then -- not self.isPlayer and
      if self.grid.lig == 1 then
        self.isDestroyed = true
      end
      for _, other in ipairs(Bubbles.listGrid) do
        if other ~= self and not other.isDead then
          local dist = math.dist(self.x, self.y, other.x, other.y)
          if dist <= 80 then
            if self.isWall then
              other.isWall = true
            elseif other.isWall then
              self.isWall = true
            end
          end
        end
      end
    end
  end
--

  function self:changeWorld(toWorld)
    self.isDead = true
    self.body:destroy()
    --
    local new = Bubbles:newBubble(self.x, self.y, false, toWorld) -- x, y, isPlayer, World, grid
    new.colorID = self.colorID
    new.img = self.img
    new.group = Bubbles.listDestroy
    --
    new.body:setType("dynamic")
    new.body:applyForce(love.math.random(-150,150), love.math.random(510,660))
    --
    if toWorld == WorldDestroy then
      Game:incrementeScore(10)
      Bubbles:purgeMeOnList(self, Bubbles.listGrid)
    elseif toWorld == WorldGrid then
      Bubbles:purgeMeOnList(self, Bubbles.listDestroy)
    end
  end
--

  function self:update(dt)
    if not self.isDead then
      self.x, self.y = self.body:getPosition()
    end
    --
    if self.world == WorldGrid then
      if not self.isDead then 
        self:getIsWalled()
      else
        Bubbles:purgeMeOnList(self, Bubbles.listDestroy)
      end
    elseif self.world == WorldDestroy then
      if self:timerExplosion(dt) then
        Explosion:newExplosion(self.x, self.y)
        self.body:destroy()
        Bubbles:purgeMeOnList(self, Bubbles.listDestroy)
      end
    end
  end
--

  function self:timerExplosion(dt)
    self.timer.current = self.timer.current + (self.timer.speed * dt)
    if self.timer.current >= self.timer.delai then
      self.timer.current = 0
      return true
    end
    return false
  end
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

function Bubbles:createNewLigneBubbles(nbLig)
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
    bubble:changeWorld(WorldDestroy)-- tag isDead and create new bubble in WorldDestroy :
    Bubbles:purgeMeOnList(bubble, Bubbles.listGrid)
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
        Bubbles.game.isWall = true
        --
        Bubbles:createGroupColor()
        --
        Bubbles.readyLaunch = false
        --
        if Bubbles.game.group then
          local destroyBool, nbBubbles = Bubbles:impactGroup(Bubbles.game.x, Bubbles.game.y)
          if destroyBool then
            if nbBubbles >= 5 then
              Sounds.correct:play()
              local score = math.floor(nbBubbles * 1.7)
              Game:incrementeScore(score)
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
  for n=#Bubbles.listGrid, 1, -1 do
    local bub = Bubbles.listGrid[n]
    if bub.grid and bub.colorID == Bubbles.game.colorID then
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
  for n=#list, 1, -1 do
    list[n].body:destroy()
    table.remove(list, n)
  end
  --
  list = {}
end
--

function Bubbles:newGame()
  Bubbles:resetList(Bubbles.listGrid)
  Bubbles:resetList(Bubbles.listDestroy)
  --
  Bubbles:createNewLigneBubbles(MapManager.current.nbGridOnScreen)
end
--

function Bubbles:load()
  for n=1, 5 do
    table.insert(Bubbles.images, Core.ImageManager.newImage("ressources/images/bubble_"..n..".png"))
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
  for n=#Bubbles.listGrid, 1, -1 do
    local bub = Bubbles.listGrid[n]
    if bub.group then bub.group = nil end
  end

  -- On attachs les bub's to group's de meme couleur qui sont a proximité :
  for n=#Bubbles.listGrid, 1, -1 do
    local bub = Bubbles.listGrid[n]
    bub:getGroup()
  end
end
--


function Bubbles:purgeMeOnList(bubble, list)
  for n=#list, 1, -1 do
    local search = list[n]
    if search == bubble then
      table.remove(list, n)
      return true
    end
  end
end
--

function Bubbles.sortOrder(list)
  table.sort(list, function(a, b) return a.y < b.y end)
  table.sort(list, function(a, b) return a.x < b.x end)
end
--

function Bubbles:updateGetIsWalled()
  local map = MapManager.current
  local mapTest = {}
  for l=1, map.lig do mapTest[l]={} end

  for n=#Bubbles.listGrid, 1, -1 do
    local bubble = Bubbles.listGrid[n]
    bubble.isWall = false
    if not bubble.isPlayer and not bubble.isDead and bubble.grid then
      if bubble.grid.lig == 1 then
        bubble.isWall = true
      end
      table.insert(mapTest[bubble.grid.lig], bubble)
    end
  end

  for l=1, #mapTest do
    for index=1, #mapTest[l] do
      local bubble = mapTest[l][index]
      bubble:getIsWalled()
    end
  end

  mapTest = {}

end
--

function Bubbles:update(dt)

  -- isWall :
  Bubbles:updateGetIsWalled()


  -- in grid :
  Bubbles.sortOrder(Bubbles.listGrid)
  for n=#Bubbles.listGrid, 1, -1 do
    local bubble = Bubbles.listGrid[n]
    bubble:update(dt)
  end

  -- if not isWall ? ok go to change me to WorldDestroy :
  for n=#Bubbles.listGrid, 1, -1 do
    local bubble = Bubbles.listGrid[n]
    if not bubble.isWall and not bubble.isPlayer and not bubble.isDead then
      -- si il n'y pas de bubble a proximite alors :
      bubble:changeWorld(WorldDestroy)
    end
  end


  -- Purge Destroy list
  for n=#Bubbles.listGrid, 1, -1 do
    local bubble = Bubbles.listGrid[n]
    if self.isDead then
      if self.body then self.body:destroy() end
      table.remove(Bubbles.listGrid, n)
    end
  end

  -- update bubble get isDead ?
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
  if list == Bubbles.listGrid then
    love.graphics.setColor(1,1,1,1)
  elseif list == Bubbles.listDestroy then
    love.graphics.setColor(Game.colorFade)
  end
--
  for _, bub in ipairs(list) do
    love.graphics.draw(bub.img.imgdata, bub.x, bub.y, 0,1,1, bub.ox, bub.oy)
  end
  --
  love.graphics.setColor(1,1,1,1)
end
--

function Bubbles:drawDebug(list)
  --
  if Bubbles.debug then
    for _, bub in ipairs(list) do
      if bub.isWall then
        love.graphics.setColor(1,0,0,0.5)
        love.graphics.circle("fill",bub.x, bub.y, bub.radius/2)
        love.graphics.circle("line",bub.x, bub.y, bub.radius+1)
      end
      if bub.group then
        love.graphics.setColor(bub.color)
        for _, other in ipairs(bub.group) do
          love.graphics.line(bub.x, bub.y, other.x, other.y)
        end
      end
      -- center of bub
      love.graphics.setColor(1,0,1,1)
      love.graphics.circle("line",bub.x, bub.y, 1)
      love.graphics.setColor(1,1,1,1)
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
  Bubbles:drawDebug(Bubbles.listGrid)
  --
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