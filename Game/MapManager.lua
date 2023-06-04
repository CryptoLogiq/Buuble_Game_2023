local MapManager = {debug=false, current=nil, lig=12, col=19}

local listMapManagers = {}

local listlines = {marge = 0, speedMin=60, speedMax=120, timer={update=updateTimerNoLoop, reset=TimerReset, current=0, delai=60, speed=120}, isCollide=false}


local colorsEletric = {}
table.insert(colorsEletric, {0,0.808,0.82,1})
table.insert(colorsEletric, {0,0.749,1,1})
table.insert(colorsEletric, {1,1,0,1})
table.insert(colorsEletric, {1,0.843,0,1})
table.insert(colorsEletric, {0,1,1,1})
table.insert(colorsEletric, {0.118,0.565,1,1})
table.insert(colorsEletric, {0.961,0.961,0.961,1})
table.insert(colorsEletric, {0.118,0.565,1,1})
table.insert(colorsEletric, {0,1,1,1})
table.insert(colorsEletric, {1,0.647,0,1})
--
function listlines:newTimerRandom()
  return {
    update=updateTimerRandomSpeed,
    current=0,
    delai=10,
    speed=love.math.random(listlines.speedMin, listlines.speedMax),
    speedMin=listlines.speedMin,
    speedMax=listlines.speedMax
  }
end
--
--
function listlines:load()
  for n=1, 10 do
    listlines[n]= {
      color=colorsEletric[love.math.random(#colorsEletric)],
      timer=listlines:newTimerRandom(),
      line={}
    }
    listlines:newLinePoints(n)
  end
  --
  self.marge = (Game.h - MapManager.current.h) / 3
  --
end
--
function listlines:newLinePoints(n)
  local m = MapManager.current
  --
  local start = {x = m.x, y = m.h}
  local finish = {x = m.x + m.w, y = m.h}
  local dist = (finish.x - start.x) / 10
  --
  listlines[n].line = {}
  listlines[n].color = colorsEletric[love.math.random(#colorsEletric)]
  --
  table.insert(listlines[n].line,  start.x )
  table.insert(listlines[n].line, start.y + love.math.random(-1, self.marge))
  for p=1, 8 do
    table.insert(listlines[n].line, start.x + (dist*p) + love.math.random(-self.marge, self.marge)) 
    table.insert(listlines[n].line, start.y+love.math.random(-1, self.marge))
  end
  table.insert(listlines[n].line, finish.x)
  table.insert(listlines[n].line, finish.y + love.math.random(-1, self.marge))
  --
end
--
function listlines:update(dt)
  for n=1, 10 do
    if listlines[n].timer:update(dt) then
      listlines:newLinePoints(n)
    end
  end
  if self.timer:update(dt) then
    self.isCollide = false
  end
end
--


function MapManager:newGame()
  MapManager.current = MapManager:new()
  MapManager.current.nbGridOnScreen = 3
  --
  listlines:load()
  --
end
--

function MapManager:new()
  local nbBubbles = 280 -- au plus proche possible de ce resultat
  local margeSafe = 64 + 32 -- 1 rangee de bubbles + la moitier d'un bubble (celui du player)
  local cellW = 64
  local cellH = 64
  local cellOX = 32
  local cellOY = 32
  --
--  local lig = math.floor( (Game.h- margeSafe) / cellH )
--  local col = math.floor(nbBubbles/lig)
  local lig = MapManager.lig
  local col = MapManager.col
  --
  if MapManager.debug then
    print("lig :",lig,", col :",  col, " soit :", lig*col, "bubbles.")
  end
  --
  local w = (cellW * col) + cellOX
  local h = cellH * lig
  local ox = w/2
  local oy = h/2
  --
  local startY = 0
  local startX = (Game.w/2)-(w/2)
  local startLeft = true
  --
  local decX = (Game.w-w) / 2
  local rectLeft = {mode="fill", x=0, y=0, w=decX, h=Game.h}
  local rectRight = {mode="fill", x=Game.w-decX, y=0, w=decX, h=Game.h}
  --
  local dec = true
  local x=startX+cellOX
  local y=startY
  --  --
  local map = {
    startLeft=startLeft,
    x=startX,
    y=startY,
    startX=startX,
    startY=startY,
    w=w,
    h=h,
    ox=ox,
    oy=oy,
    cellOX=cellOX,
    cellOY=cellOY,
    lig=lig,
    col=col,
    decX=decX,
    cellH=cellH,
    cellW=cellW,
    bordures={rectLeft,rectRight}
  }
  --
  for l=1, lig do
    map[l]={}
    for c=1, col do
      -- grid :
      map[l][c]= {isFree=true, x=x, y=y, w=w, h=h, cellOX=cellOX, cellOY=cellOY, cx=x+cellOX, cy=y+cellOY, lig=l, col=c}
      --
      x=x+cellW
    end
    dec = not dec
    if dec then
      x=startX+cellOX
    else
      x=startX
    end

    y=y+cellH
  end
  table.insert(listMapManagers, map)

  return map
end
--

function MapManager:changeOffset()
  local map = MapManager.current
  local pLeft = not map.startLeft
  --
  map.startLeft = not map.startLeft
  --
  local x = 0
  if pLeft then
    x = map.startX + map.cellOX
  else
    x = map.startX
  end
  --
  for l=1, map.lig do
    for c=1, map.col do
      local grid = map[l][c]
      grid.x = x + map.cellW
      grid.cx = x + map.cellOX
      x = x + map.cellW
    end
    pLeft = not pLeft
    if pLeft then
      x = map.startX + map.cellOX
    else
      x = map.startX
    end
  end
end
--

function MapManager:getGrid(x, y)
  local map = MapManager.current
  --
  if x >= map.x and x <= map.x+map.w and y >= map.y and y <= map.h then
    --
    local list = {}
    --
    for lig=1, map.lig do
      for col=1, map.col do
        local grid = map[lig][col]
        --
        local dist = math.dist(x,y, grid.cx, grid.cy)
        if dist <= 75 then
          --
          table.insert(list, {dist=dist, grid=grid} )
          --
        end
        --
      end
    end
    --
    if #list > 0 then
      table.sort(list, function(a, b) return a.dist < b.dist end)
      return list[1].grid
    else
      print("Bubble N'as pas trouver de grid")
      return false
    end
  else
    print("Bubble Hors Map")
    return false
  end
end
--

function MapManager:load()
  MapManager.current = MapManager:new(12, 18)
  MapManager.current.nbGridOnScreen = 3
  --
  listlines:load()
  --
end
--

function MapManager:update(dt)
  listlines:update(dt)
end
--

function MapManager:draw()
  -- fire line limit
  if Bubbles.game then
    local bub = Bubbles.game
    local m = self.current
    --
    local isCollide = CheckCollision(bub.x-bub.radius, bub.y-bub.radius, bub.radius*2, bub.radius*2, m.x, m.y+m.h, m.w, listlines.marge)
    --
    if isCollide then
      listlines.timer:reset()
      listlines.isCollide = true
      Sounds:addPlayListNoDoublon(Sounds.impact)
    else
      if not listlines.isCollide then
        for n=1, #listlines do
          love.graphics.setColor(listlines[n].color)
          love.graphics.line(listlines[n].line)
        end
      end
    end
  end
  love.graphics.setColor(1,1,1,1)
  --

  -- debug
  if MapManager.debug then
    -- grilles
    for l=1, MapManager.current.lig do
      for c=1, MapManager.current.col do
        local grid = MapManager.current[l][c]
        love.graphics.circle("line",grid.cx,grid.cy,grid.cellOX)
        love.graphics.print("l:"..grid.lig.."\n".."c:"..grid.col, grid.cx, grid.cy,0,1,1,0,12)
      end
    end
  end
end
--

function MapManager:keypressed(key)
end
--

return MapManager