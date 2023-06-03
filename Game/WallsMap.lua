local WallsMap = {debug=false, list={}}

function WallsMap:new(x,y,w,h)
  local w_grid = {x=x,y=y,w=w,h=h}
  w_grid.body = love.physics.newBody(WorldGrid, x, y, "static")
  w_grid.shape = love.physics.newRectangleShape(w,h)
  w_grid.fixture = love.physics.newFixture(w_grid.body, w_grid.shape)
  table.insert(self.list, w_grid)
  --
  local w_destroy = {x=x,y=y,w=w,h=h}
  w_destroy.body = love.physics.newBody(WorldDestroy, x, y, "static")
  w_destroy.shape = love.physics.newRectangleShape(w,h)
  w_destroy.fixture = love.physics.newFixture(w_destroy.body, w_destroy.shape)
  table.insert(self.list, w_destroy)
  --
  return w_grid, w_destroy
end
--

function WallsMap:load()
  local map = MapManager.current

  -- left :
  WallsMap.leftGrid, WallsMap.leftDestroy = WallsMap:new(map.x-5, Game.oy, 10, Game.h)

  -- right :
  WallsMap.rightGrid, WallsMap.rightDestroy  = WallsMap:new(map.x+map.w+5, Game.oy, 10, Game.h)

  -- up
  WallsMap.upGrid, WallsMap.upDestroy  = WallsMap:new(Game.ox, -5, map.w+10, 10)

  -- down
  WallsMap.downGrid, WallsMap.downDestroy = WallsMap:new(Game.ox, Game.h, map.w+10, 10)

-- down Grid OFF for collision :
  WallsMap.downGrid.body:setActive(false)

end
--

function WallsMap:newGame()
  for _, wall in ipairs(self.list) do
    wall.body:destroy()
    wall = nil
  end
  self.list={}
  --
  WallsMap:load()
end
--

function WallsMap:draw()
  if self.debug then
    for _, wall in ipairs(self.list) do
      love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
    end
  end
end
--

return WallsMap