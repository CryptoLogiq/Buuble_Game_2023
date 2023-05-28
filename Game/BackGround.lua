local BackGround = {debug=false}

local listBG = {}
local listClouds = {}
--
local arriereplan = {}
local premierplan = {}

local listSpeed = {66,91,-47,-116,77,-82,-48,83,-30}

function BackGround:load()
  -- arriere plans
  for n=1, 2 do
    table.insert( listBG, Core.ImageManager.newImage("ressources/images/BG_plage_"..n..".png") )
  end
  arriereplan = listBG[1]
  premierplan = listBG[2]


  -- nuages
  for n=1, 9 do
    local cloud = Core.ImageManager.newImage("ressources/images/cloud"..n..".png")
    table.insert(listClouds, cloud)
    cloud.x = love.math.random(-Game.w,Game.w)
    cloud.y = love.math.random(0, cloud.h*2.5)
    --
    cloud.speed = listSpeed[n]
    --
    cloud.vx = math.sign(cloud.speed)
    cloud.vy = 0
    --
    cloud.sx = math.sign(cloud.speed)
    cloud.sy = 1
    print(cloud.speed)
  end

end
--

function BackGround:update(dt)
  for n=1, #listBG do
    local bg = listBG[n]
    bg.sx= Game.w / bg.w
    bg.sy= Game.h / bg.h
  end
  --
  for n=1, 9 do
    local cloud = listClouds[n]
    cloud.x = cloud.x + cloud.speed * dt
    if cloud.vx == 1 then
      if cloud.x > Game.w + (cloud.w*2) then cloud.x = (0-cloud.w) * 2 end
    else
      if cloud.x < (0-cloud.w) * 2 then cloud.x = Game.w + (cloud.w*2) end
    end
  end
end
--

function BackGround:draw()
  love.graphics.draw(arriereplan.imgdata,0,0,0,arriereplan.sx, arriereplan.sy)
  --
  for n=1, 9 do
    local cloud = listClouds[n]
    love.graphics.draw(cloud.imgdata,cloud.x,cloud.y)
  end
  --
  love.graphics.draw(premierplan.imgdata,0,0,0,premierplan.sx, premierplan.sy)
end
--

return BackGround
