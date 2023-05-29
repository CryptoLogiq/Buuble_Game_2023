local Explosion = {debug=false, list={}}

local sensRot = {-1, 1}

function Explosion:createNewExplosion(x,y)
  local explo = {
    x=x,
    y=y,
    frame=1,
    sound=Sounds.explodeBubble[love.math.random(#Sounds.explodeBubble)]:clone(),
    rotate=sensRot[love.math.random(#sensRot)],
    timer={current=0, delai=30, speed=love.math.random(90,120)} -- ICI
  }
  --
  function explo:update(dt)
    explo.rotate = explo.rotate + (explo.timer.speed * dt)
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

function Explosion:newGame()
  Explosion.list={}
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
      if explo.frame == 2 then
        explo.sound:play()
      end
      if explo.frame > #Explosion.images then
        explo.isDestroy = true
        if not explo.sound:isPlaying() then
          table.remove(self.list, n)
        end
      end
    end
  end
end
--

function Explosion:draw()
  for _, explo in ipairs(Explosion.list) do
    if not explo.isDestroy then
      love.graphics.draw(Explosion.images.imgdata, Explosion.images[explo.frame].quad, explo.x, explo.y,0, 2,2)
    end
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
