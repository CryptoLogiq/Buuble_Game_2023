local MapManager = {debug=true, current=nil}

local listMapManagers = {}

function MapManager:newGame()
  MapManager.current = MapManager:new(13, 15)
  MapManager.current.nbGridOnScreen = 3
end
--

function MapManager:new(lig, col)
  local cellW = 64
  local cellH = 64
  local cellOX = 32
  local cellOY = 32
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
end
--

function MapManager:update(dt)
end
--

function MapManager:draw()
  -- debug
  if Game.debug then
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