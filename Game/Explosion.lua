local Explosion = {debug=false, list={}}

Explosion.images = {}

--local sensRot = {-1, 1}

function Explosion:createNewExplosion(x, y, angle)
  local explo = {
    x=x,
    y=y,
    frame=1,
    sound=Sounds.explodeBubble[love.math.random(#Sounds.explodeBubble)]:clone(),
    rotate= angle,
    rotateSens=math.cos(angle),
    speedRot=love.math.random(60,360),
    timer={current=0, delai=30, speed=love.math.random(90,240)} -- ICI
  }
  --
  function explo:update(dt)
    explo.rotate = explo.rotate + (explo.rotateSens * explo.speedRot * dt) -- radian + ( 1 or -1 * speed * dt)
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

function Explosion:newExplosion(x, y, angle)
  Explosion:createNewExplosion(x, y, angle)
  --
  for n=love.math.random(5), 1, -1 do
    Explosion:createNewExplosion(
      love.math.random(x-16,x+16),
      love.math.random(y-16,y+16),
      angle + ( math.cos(angle) + math.rad(love.math.random(360)) )
      )
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
  love.graphics.setColor(Game.colorFade)
  for _, explo in ipairs(Explosion.list) do
    if not explo.isDestroy then
      love.graphics.draw(Explosion.images.imgdata, Explosion.images[explo.frame].quad, explo.x, explo.y, math.rad(explo.rotate), 2,2, Explosion.images[explo.frame].ox, Explosion.images[explo.frame].oy )
    end
  end
  love.graphics.setColor(1,1,1,1)
end
--


function Explosion:keypressed(key)
end
--


function Explosion:mousepressed(x,y,button)
end
--

return Explosion
