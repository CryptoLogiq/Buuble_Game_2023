local MapManager = {debug=true, current=nil}

local listMapManagers = {}

function MapManager:new(lig, col)
  local cellW = 64
  local cellH = 64
  local ox = 32
  local oy = 32
  local w = (cellW * col) + ox
  local h = cellH * lig
  --
  local startY = 0
  local startX = (Game.w/2)-(w/2)
  --
  local decX = (Game.w-w) / 2
  local rectLeft = {mode="fill", x=0, y=0, w=decX, h=Game.h}
  local rectRight = {mode="fill", x=Game.w-decX, y=0, w=decX, h=Game.h}
  --
  local dec = true
  local x=startX+ox
  local y=startY
  --  --
  local MapManager = {x=startX, y=startY, w=w, h=h, ox=ox, oy=oy, lig=lig, col=col, decX=decX, cellH=cellH,cellW=cellW, bordures={rectLeft,rectRight}}
  --
  for l=1, lig do
    MapManager[l]={}
    for c=1, col do
      local grid = {isFree=true, x=x, y=y, w=w, h=h, ox=ox, oy=oy, cx=x+ox, cy=y+oy, l=l, c=c}
      MapManager[l][c]=grid
      --
      x=x+cellW
    end
    dec = not dec
    if dec then
      x=startX+ox
    else
      x=startX
    end

    y=y+cellH
  end
  table.insert(listMapManagers, MapManager)

  return MapManager
end
--

function MapManager:load()
  MapManager.current = MapManager:new(12, 18)
  MapManager.current.nbGridOnScreen = 3
  --
  Bubbles:new(MapManager.current.nbGridOnScreen)
end
--

function MapManager:update(dt)
end
--

function MapManager:draw()
  -- bordures
  love.graphics.setColor(0,0,0,0.25)
  for n=1, #MapManager.current.bordures do
    local rect = MapManager.current.bordures[n]
    love.graphics.rectangle(rect.mode,rect.x,rect.y,rect.w,rect.h,5)
  end
  love.graphics.setColor(1,1,1,1)

  -- debug
  if Game.debug then
    -- grilles
    for l=1, MapManager.current.lig do
      for c=1, MapManager.current.col do
        local grid = MapManager.current[l][c]
        love.graphics.circle("line",grid.cx,grid.cy,grid.ox)
        love.graphics.print("l:"..grid.l.."\n".."c:"..grid.c, grid.cx, grid.cy,0,1,1,0,12)
      end
    end
  end
end
--

function MapManager:keypressed(key)
end
--

return MapManager