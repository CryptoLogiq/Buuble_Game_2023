local Map = {debug=false, current=nil}

local listMaps = {}

function Map:new(lig, col)
  local cellW = 64
  local cellH = 64
  local ox = 32
  local oy = 32
  local w = cellW * col
  local h = cellH * lig
  --
  local startY = 0 - h
  local startX = (Game.w/2)-(w/2)
  --
  local decX = (Game.w-w) / 2
  local rectLeft = {mode="fill", x=0, y=0, w=decX, h=Game.h}
  local rectRight = {mode="fill", x=Game.w-decX, y=0, w=decX, h=Game.h}
  --
  local x=startX
  local y=0
  --
  local map = {x=startX, y=startY, w=w, h=h, ox=ox, oy=oy, lig=lig, col=col, decX=decX, bordures={rectLeft,rectRight}}
  --
  for l=1, lig do
    map[l]={}
    for c=1, col do
      local grid = {isFree=true, x=x, y=y, w=w, h=h, ox=ox, oy=oy, cx=x+ox, cy=y+oy}
      map[l][c]=grid
      --
      x=x+cellW
    end
    x=startX
    y=y+cellH
  end
  table.insert(listMaps, map)

  return map
end
--

function Map.load()
  Map.current = Map:new(12, 18)
end
--

function Map.update(dt)
end
--

function Map.draw()
  for l=1, Map.current.lig do
    for c=1, Map.current.col do
      local grid = Map.current[l][c]
      love.graphics.circle("line",grid.cx,grid.cy,grid.ox)
    end
  end
  love.graphics.setColor(0,0,0,0.25)
  for n=1, #Map.current.bordures do
    local rect = Map.current.bordures[n]
    love.graphics.rectangle(rect.mode,rect.x,rect.y,rect.w,rect.h,5)
  end
  love.graphics.setColor(1,1,1,1)
end
--

return Map
