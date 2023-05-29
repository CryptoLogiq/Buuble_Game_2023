local WallsMap = {debug=false, list={}}

function WallsMap:new(x,y,w,h)
  local new = {x=x,y=y,w=w,h=h}
  new.body = love.physics.newBody(WorldDestroy, x, y, "static")
  new.shape = love.physics.newRectangleShape(w,h)
  new.fixture = love.physics.newFixture(new.body, new.shape)
  table.insert(self.list, new)
end
--

function WallsMap:load()
  local map = MapManager.current

  -- left :
  WallsMap:new(map.x-5, Game.oy, 10, Game.h)

  -- right :
  WallsMap:new(map.x+map.w+5, Game.oy, 10, Game.h)

  -- down
  WallsMap:new(Game.ox, Game.h, map.w+10, 10)


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