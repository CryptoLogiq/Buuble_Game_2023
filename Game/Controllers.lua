local Controllers = {debug=false}

local dirCurseur = "ressources/images/crosshair"
local filesCurseur = love.filesystem.getDirectoryItems(dirCurseur)
local listCurseurs = {}
for _, file in pairs(filesCurseur) do
  table.insert(listCurseurs, Core.ImageManager.newImage(dirCurseur.."/"..file))
end
local curseur = {id=14, x=0, y=0, isLimit=false, data=listCurseurs[14], color={0,0.749,1,1}, rotate=0}
local curseurGrid = {id=179, x=0, y=0, isLimit=false, data=listCurseurs[179], color={0.541,0.169,0.886,1}, rotate=0}

local demicercleRail = Core.ImageManager.newImage("ressources/images/contour_viseur.png")
local ligneRail = Core.ImageManager.newImage("ressources/images/ligne viseur.png")
ligneRail.maxdistance = 0


function curseur:setCurseur()
  local number = curseur.id+1
  if number > #listCurseurs then
    number = 1
  end
  curseur.id = number
  curseur.data=listCurseurs[number]
  print(number)
end
--

function Controllers:updateCurseurs(dt)
  curseur.rotate = (curseur.rotate + dt) % 360
end
--

function demicercleRail:update(dt)
  self.x = Game.ox
  self.y = Game.h - self.h
end
--

function demicercleRail:draw()
  love.graphics.draw(demicercleRail.imgdata, demicercleRail.x,demicercleRail.y,0,1,1,demicercleRail.ox,0)
end
--

function ligneRail:update(dt)
  if Game.isPlay then
    self.maxdistance = MapManager.current.ox - 5
  end
  --
  self.x = Game.ox
  self.y = Game.h
  self.rotate = math.angle(self.x,self.y,Mouse.x,Mouse.y)-- + math.rad(-90)
  self.distance = math.min(math.dist(self.x,self.y,Mouse.x,Mouse.y), self.maxdistance)
  if self.distance >= self.maxdistance then
    curseurGrid.isLimit = true
    curseurGrid.x = self.x + math.cos(self.rotate) * self.maxdistance
    curseurGrid.y = self.y + math.sin(self.rotate) * self.maxdistance
  else
    curseurGrid.isLimit = false
    curseurGrid.x = Mouse.x
    curseurGrid.y = Mouse.y
  end
  if not Game.isStop and curseurGrid.isLimit then
    if not Mouse.inMap then
      Mouse.setPosition(curseurGrid.x*Screen.sx, curseurGrid.y*Screen.sy)
      Mouse.inMap = true
    end
  end
  --
  Mouse.angle = self.rotate
end
--

function ligneRail:draw()
  local nbcircles = 20
  local espace = 0
  if curseurGrid.isLimit then
    espace = self.maxdistance/nbcircles
  else
    espace = self.distance/nbcircles
  end
  --
  love.graphics.setColor(curseurGrid.color)
  for n=1, nbcircles do
    local dec = (espace*(n-1))
    love.graphics.circle(
      "fill",
      self.x+(math.cos(self.rotate)*dec),
      self.y+(math.sin(self.rotate)*dec),
      math.max(15/n, 5)
    )
  end
  love.graphics.setColor(1,1,1,1)
end
--

function Controllers:MouseInMap()
  if Core.Scene.current == "Game" then
    local map = MapManager.current
    if CheckCollision(map.x, map.y, map.w, Game.h, Mouse.x, Mouse.y, Mouse.w, Mouse.h) then
      Mouse.inMap = true
    else
      Mouse.inMap = false
    end
  end
end
--

function Controllers:CursorDraw()
  if Core.Scene.current == "Game" then
    if Game.isPlay then
      if Bubbles.game then
        if not Bubbles.game.isLaunch then
          -- curseur in Grid
          love.graphics.setColor(curseurGrid.color)
          love.graphics.draw(curseurGrid.data.imgdata, curseurGrid.x, curseurGrid.y, curseurGrid.rotate, 1, 1, curseurGrid.data.ox, curseurGrid.data.oy)
        end
      end
    end

    -- curseur navigation
    if not Mouse.inMap then
      love.graphics.setColor(curseur.color)
      love.graphics.draw(curseur.data.imgdata, Mouse.x, Mouse.y, curseur.rotate, 1, 1, curseur.data.ox, curseur.data.oy)
      love.graphics.setColor(0.698,0.133,0.133,1)
      love.graphics.circle("fill", Mouse.x, Mouse.y, 1)
    end
  else
    love.graphics.setColor(curseur.color)
    love.graphics.draw(curseur.data.imgdata, Mouse.x, Mouse.y, curseur.rotate, 1, 1, curseur.data.ox, curseur.data.oy)
    love.graphics.setColor(0.698,0.133,0.133,1)
    love.graphics.circle("fill", Mouse.x, Mouse.y, 1)
  end
  love.graphics.setColor(1,1,1,1)
end
--

function Controllers:load()
  Mouse:update()
  Mouse.setVisible(false)
end
--

function Controllers:update(dt)
  Mouse:update()

  Controllers:MouseInMap()

  Controllers:updateCurseurs(dt)

  -- rail
  demicercleRail:update(dt)

  -- ligne rail
  ligneRail:update(dt)
end
--

function Controllers:draw()

  Controllers:CursorDraw()

  if Game.isPlay then
    if Bubbles.game then
      if not Bubbles.game.isLaunch then
        -- rail
        demicercleRail:draw()

        -- ligne rail
        ligneRail:draw()
      end
    end
  end
end
--

function Controllers:keypressed(key)
  if key == "f12" then
    love.window.setFullscreen(not love.window.getFullscreen())
  end
end
--

function Controllers:mousepressed(x,y,button)
end
--

return Controllers
