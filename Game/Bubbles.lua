local Bubbles = {debug=false}

Bubbles.__index = Bubbles

Bubbles.listGrid = {}

Bubbles.listDestroy = {}

Bubbles.images = {}

Bubbles.game = nil

Bubbles.readyLaunch = false

local colorsBubbles = {{1,0,1,1},{0,1,0,1},{0,0,1,1},{0,0,0,1},{1,0,0,1}}

function Bubbles:newBubble(x, y, isPlayer, World, grid)
  local bub = {world=World, angle=math.rad(love.math.random(360)), debug=false, isPlayer=isPlayer, isDead=false, listWall={}, isWall=true, grid=grid or nil, x=x, y=y, rebounds=0, radius=32, restitution=0.9, ox=32, oy=32, speed=60, force=1200, colorID=love.math.random(5), isLaunch=false}

  -- if low bubbles in grid, make colors for player to match with last bubbles in grid :
  if isPlayer and #Bubbles.listGrid >= 1 then
    local colors = {}
    for _, bubble in ipairs(Bubbles.listGrid) do
      local add = true
      for _, color in ipairs(colors) do
        if color == bubble.colorID then
          add = false
        end
      end
      if add then
        table.insert(colors, bubble.colorID)
      end
    end
    bub.colorID = colors[love.math.random(#colors)]
  end
  --
  bub.color=colorsBubbles[bub.colorID]
  bub.img = Bubbles.images[bub.colorID]
  --
  bub.body = love.physics.newBody(World, bub.x, bub.y, "kinematic")
  bub.shape = love.physics.newCircleShape(bub.radius)
  bub.fixture = love.physics.newFixture(bub.body, bub.shape)
  bub.fixture:setRestitution(bub.restitution)
  --
  bub.mass = 0
  bub.body:setMass(bub.mass)
  --
  bub.timer={current=0, delai=180, speed=love.math.random(60,240)}
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
        self.isWall = true
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
      if self.isWall then
        return true
      else
        return false
      end
    end
  end
--

  function self:changeWorld(toWorld)
    -- Create new :
    local new = Bubbles:newBubble(self.x, self.y, false, toWorld) -- x, y, isPlayer, World, grid
    -- set's
    new.colorID = self.colorID
    new.img = self.img
    new.group = Bubbles.listDestroy
    -- physics
    new.body:setType("dynamic")
    --
    local angle = nil
    if not Game.gameover then
      angle = self.body:getAngularVelocity()
    else
      angle = math.rad( love.math.random(1, 360) )
    end
    local force = love.math.random(self.force*30, self.force*90)
    new.body:applyForce( math.cos(angle) * force, math.sin(angle) * force)
    --
    -- ## destroy self
    self.isDead = true
    self.body:destroy()
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
        self.body:setAngle(self.angle)

        if not self:getIsWalled() then
          return true
        end
      else
        Bubbles:purgeMeOnList(self, Bubbles.listDestroy)
      end
    elseif self.world == WorldDestroy then
      self.angle = self.body:getAngle()
      if self:timerExplosion(dt) then
        Explosion:newExplosion(self.x, self.y, self.body:getAngle())
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

  if Game.isPlay and not Game.gameover then

    local createnewbubble = true
    for _, bubble in ipairs(Bubbles.listGrid) do
      if bubble.isPlayer then createnewbubble = false end
    end

    if createnewbubble then

      Bubbles.game = Bubbles:newBubble(Game.ox, Game.h, true, WorldGrid) -- x, y, isPlayer, World, grid
      --
      Bubbles.readyLaunch = true

    end
    --
  end
end
--

function Bubbles:createNewLigneBubbles(nbLig, world)
  --
  Game.isPlay = false
  --
  local yRef = -MapManager.current.cellH
  for l=nbLig, 1, -1 do
    for c=1, MapManager.current.col do
      local grid = MapManager.current[l][c]

      Bubbles:newBubble(grid.cx, yRef, false, world, grid)-- x, y, isPlayer, World, grid
    end
    yRef = yRef - MapManager.current.cellH
  end
end
--

function Bubbles:addLigne(nbLig)
  if Game.isPlay   and not Game.gameover then
    --
    local map = MapManager.current
    --
    Game.isPlay = false
    --
    MapManager:changeOffset()
    --
    local gameover = false

    -- Move ref Grid if exist...
    for _, bub in ipairs(Bubbles.listGrid) do
      if bub.grid and not bub.isPlayer then
        --
        local lig = bub.grid.lig + nbLig
        local col = bub.grid.col
        --
        if lig <= map.lig then
          bub.grid = map[lig][col]
        else
          gameover = true
        end
      end
      --
    end
    --

    -- if one of all bubble's as no refGrid THEN it's gameover : go destroy all !
    if gameover then
      Bubbles:gameOver()
      Bubbles:createNewLigneBubbles(nbLig, WorldDestroy)
    else
      Bubbles:createNewLigneBubbles(nbLig, WorldGrid)
    end
    --
    Game.gameover = gameover
    --
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
  if Bubbles.readyLaunch and Game.isPlay and not Game.gameover then
    --
    Bubbles.readyLaunch = false
    --
    Bubbles.game.vx = math.cos(Mouse.angle)
    Bubbles.game.vy = math.sin(Mouse.angle)
    Bubbles.game.body:setLinearVelocity(Bubbles.game.vx*Bubbles.game.force, Bubbles.game.vy*Bubbles.game.force)
    Bubbles.game.body:setType("dynamic")
    Bubbles.game.isLaunch = true
    --
    Bubbles.game.fixture:destroy()
    Bubbles.game.shape = love.physics.newCircleShape(Bubbles.game.radius * 0.8)
    Bubbles.game.fixture = love.physics.newFixture(Bubbles.game.body, Bubbles.game.shape)
    Bubbles.game.fixture:setRestitution(Bubbles.game.restitution)
    --
    Game.isPlay = false
    --
    Sounds.launchBubble.source:play()
  end
end
--

function Bubbles:gameOver()
  for _, bub in ipairs(Bubbles.listGrid) do
    bub:changeWorld(WorldDestroy)
  end
  Bubbles:resetList(Bubbles.listGrid)
  --
  Bubbles.game = nil
end
--

function Bubbles:updateBubblePlayer(dt)
  if Bubbles.game then
    local bblaunch = Bubbles.game
    --
    bblaunch.x, bblaunch.y = bblaunch.body:getPosition()
    -- no friction only for bubble of gamer :
    bblaunch.body:setMass(bblaunch.mass) -- set mass to 0 for no friction with multiples rebounds.
    --
    if bblaunch.isLaunch then

      local isTouching = false

      -- VS bubbles :
      for _, other in pairs(Bubbles.listGrid) do
        if bblaunch.body:isTouching(other.body) then
          isTouching = true
          break
        end
      end

      -- VS Wall Up :
      if not isTouching then
        if bblaunch.body:isTouching(WallsMap.upGrid.body) then
          isTouching = true
        end
      end

      if isTouching then
        local grid = MapManager:getGrid(bblaunch.x, bblaunch.y)
        if grid then
          bblaunch.grid = grid
          bblaunch.body:setLinearVelocity(0,0)
          --
          bblaunch.fixture:destroy()
          bblaunch.shape = love.physics.newCircleShape(bblaunch.radius)
          bblaunch.fixture = love.physics.newFixture(bblaunch.body, bblaunch.shape)
          --
          bblaunch.x, bblaunch.y = bblaunch.grid.cx, bblaunch.grid.cy
          bblaunch.body:setPosition(bblaunch.x, bblaunch.y)
          bblaunch.isPlayer = false
          bblaunch.body:setType("kinematic")
          --
          bblaunch.angle = bblaunch.body:getAngle()
          --
          bblaunch.isWall = true
          --
          Bubbles:createGroupColor()
          --
          if bblaunch.group then
            local destroyBool, nbBubbles = Bubbles:impactGroup(bblaunch.x, bblaunch.y)
            if destroyBool then
              if nbBubbles >= 5 then
                Sounds:addPlayList(Sounds.impactGroup)
                Sounds:addPlayList(Sounds.correct)
                local score = math.floor(nbBubbles * 1.7)
                Game:incrementeScore(score)
              else
                Sounds:addPlayList(Sounds.impactGroup)
              end
            else
              Sounds:addPlayList(Sounds.impact)
            end
          else
            Sounds:addPlayList(Sounds.impact)
          end
          --
          Bubbles:newBubblePlayer()
          return true
        else
          -- not grid ! game over
          Game.gameover = true
          Bubbles.gameOver()
          return false
          --
        end
      end

      -- limit to 5 rebounds
      if bblaunch.body:isTouching(WallsMap.leftGrid.body) or bblaunch.body:isTouching(WallsMap.rightGrid.body) then
        bblaunch.rebounds = bblaunch.rebounds + 1
        if bblaunch.rebounds >= 5 then
          bblaunch:changeWorld(WorldDestroy)
          Bubbles.game = nil
          Bubbles:newBubblePlayer()
          return true
        else
          Sounds:addPlayList(Sounds.rebond)
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

function Bubbles:resetList(list)
  for n=#list, 1, -1 do
    list[n].body:destroy()
    table.remove(list, n)
  end
  --
  list = {}
end
--



function Bubbles:MoveGrid(dt)
  if not Game.isPlay and not Game.isStop then
    --
    local goplay = true -- ready to play ?
    --
    local dist = 999
    --
    for _, bub in ipairs(Bubbles.listGrid) do
      if bub.grid then
        bub.x, bub.y = bub.body:getPosition()
        if bub.y ~= bub.grid.cy then
          bub.y = bub.y + (bub.speed*dt)
          if math.dist(bub.x, bub.y, bub.grid.cx,bub.grid.cy) < 1 then
            bub.y = bub.grid.cy 
          end
          bub.body:setPosition(bub.x, bub.y)
          bub.x, bub.y = bub.body:getPosition()
          -- 
          if math.dist(bub.x, bub.y, bub.grid.cx,bub.grid.cy) < dist then
            dist = math.dist(bub.x, bub.y, bub.grid.cx,bub.grid.cy)
          end
          --
          goplay = false -- bub is not on position, not ready to play !
        end
      end
    end
    -- all bub's in at position to grid ?
    Game.isPlay = goplay

    -- Declenche le compte a rebours ?
    if Game.StartNewGame then
      if dist <= 120 then
        Game.StartNewGame = false
        Sounds:newCounter()
      end
    elseif not Game.StartNewGame then
      if dist <= 10 then
        if not Sounds.go.source:isPlaying() and #Sounds.list <= 0 then
          Sounds:addPlayList(Sounds.go)
        end
      end
    end

    -- les bubbles sont en places, si oui on creer les groupes de couleurs :
    if goplay then
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

function Bubbles:drawList(list)
  if list == Bubbles.listGrid then
    love.graphics.setColor(1,1,1,1)
  elseif list == Bubbles.listDestroy then
    love.graphics.setColor(Game.colorFade)
  end
--
  for _, bub in ipairs(list) do
--    love.graphics.draw(bub.img.imgdata, bub.x, bub.y, bub.body:getAngle(),1,1, bub.ox, bub.oy)
    love.graphics.draw(bub.img.imgdata, bub.x, bub.y, bub.angle,1,1, bub.ox, bub.oy)
  end
  --
  love.graphics.setColor(1,1,1,1)
end
--

function Bubbles:newGame()
  Bubbles.game = nil
  --
  Bubbles:resetList(Bubbles.listGrid)
  Bubbles:resetList(Bubbles.listDestroy)
  --
  Bubbles:createNewLigneBubbles(MapManager.current.nbGridOnScreen, WorldGrid)
  --
  Bubbles:newBubblePlayer()
end
--

function Bubbles:load()
  for n=1, 5 do
    table.insert(Bubbles.images, Core.ImageManager.newImage("ressources/images/bubble_"..n..".png"))
  end
end
--

function Bubbles:update(dt)
  -- #######START######### --
  -- ### Grid bubbles world ### --
  if Game.isPlay then -- 

    -- isWall :
    Bubbles:updateGetIsWalled()


    -- update algo isWall for bubbles in grid :
    Bubbles.sortOrder(Bubbles.listGrid)
    local nbBubblesFall = 0
    for n=#Bubbles.listGrid, 1, -1 do
      local bubble = Bubbles.listGrid[n]
      if bubble:update(dt) then
        nbBubblesFall = nbBubblesFall + 1
      end
    end

    if nbBubblesFall >= 3 then
      local add = true
      for _, sound in ipairs(Sounds.list) do
        if sound == Sounds.correct then
          add = false
        end
      end
      if add then
        Sounds:addPlayList(Sounds.correct)
      end
    end

  end

  -- if not isWall ? ok go to change me to WorldDestroy :
  for n=#Bubbles.listGrid, 1, -1 do
    local bubble = Bubbles.listGrid[n]
    if not bubble.isWall and not bubble.isPlayer and not bubble.isDead then
      -- si il n'y pas de bubble a proximite alors :
      bubble:changeWorld(WorldDestroy)
    end
  end

  -- move bubbles ?
  Bubbles:MoveGrid(dt)
  -- ########END########## --

  -- #######START######### --
  -- ### Player bubble ### --
  -- update pos for bub of player :
  Bubbles:updateBubblePlayer(dt)
  -- Create a new bub player ?
  Bubbles:newBubblePlayer()
  -- ########END########## --


  -- #######START######### --
  -- ### Destroy bubbles world ### --
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
  -- ########END########## --
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
    --
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
function Bubbles:mousepressed(x, y, button)
  if Game.isPlay then
    if Bubbles.game then
      if not Bubbles.game.isLaunch then
        local map = MapManager.current
        if CheckCollision(map.x, map.y, map.w, Game.h,   x,y,1,1) then
          Bubbles:launchBubble()
        end
      end
    end
  end
end
--

return Bubbles