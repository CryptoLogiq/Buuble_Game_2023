local Explosion = {debug=false, list={}}

function Explosion:createNewExplosion(x,y)
  local explo = {x=x, y=y, frame=1, timer={current=0, delai=30, speed=love.math.random(120,300)}}
  --
  function explo:update(dt)
    explo.timer.current = explo.timer.current + (explo.timer.speed * dt)
    if explo.timer.current >= explo.timer.delai then
      explo.timer.current = 0
      return true
    end
    return false
  end
  --
  table.insert(Explosion.list, explo)
  --
end
--

function Explosion:newExplosion(x,y)
  Explosion:createNewExplosion(x,y)
  --
  for n=love.math.random(5), 1, -1 do
    Explosion:createNewExplosion(love.math.random(x-16,x+16),love.math.random(y-16,y+16))
  end
end
--

function Explosion:load()
  Explosion.images = Core.ImageManager.newAnimFile("ressources/images/explosion.png", 3, 3)
end
--

function Explosion:update(dt)
  local map = MapManager.current
  --
  for n=#Explosion.list, 1, -1 do
    local explo = Explosion.list[n]
    if explo:update(dt) then
      explo.frame = explo.frame + 1
      if explo.frame > #Explosion.images then
        explo.frame = 1
        table.remove(self.list, n)
      end
    end
  end
end
--

function Explosion:draw()
  for _, explo in ipairs(Explosion.list) do
    love.graphics.draw(Explosion.images.imgdata, Explosion.images[explo.frame].quad, explo.x, explo.y)
  end
end
--


function Explosion:keypressed(key)
end
--


function Explosion:mousepressed(x,y,button)
end
--

return Explosion
