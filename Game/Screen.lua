local Screen = {debug=false}

local canvas = nil

function Screen:getDimensions()
  self.w, self.h = love.graphics.getDimensions()
  self.ox, self.oy = self.w/2, self.h/2
  --
  self.sx = math.min(Game.w, self.w) / math.max(Game.w, self.w)
  self.sy = math.min(Game.h, self.h) / math.max(Game.h, self.h)
end
--

function Screen:load()
  self.w=1920
  self.h=1080
  self.ox, self.oy = self.w/2, self.h/2
  self.sx=1
  self.sy=1
  --
  self:getDimensions()
  --
  canvas = love.graphics.newCanvas(self.w, self.h)
end
--

function Screen:update(dt)
  Screen:getDimensions()
end
--

function Screen:draw(scene)
  love.graphics.scale(self.sx, self.sy)
  scene()
end
--


function Screen:keypressed(key)
end
--


function Screen:mousepressed(x,y,button)
end
--

return Screen
