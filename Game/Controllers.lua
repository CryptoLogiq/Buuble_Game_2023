local Controllers = {debug=false}

local dirCurseur = "ressources/images/crosshair"
local filesCurseur = love.filesystem.getDirectoryItems(dirCurseur)
local listCurseurs = {}
for _, file in pairs(filesCurseur) do
  table.insert(listCurseurs, Core.ImageManager.newImage(dirCurseur.."/"..file))
end
local curseur = {id=161, data=listCurseurs[161], color={0.15,0.25,0.8,1}}

local demicercleRail = Core.ImageManager.newImage("ressources/images/contour_viseur.png")
local ligneRail = Core.ImageManager.newImage("ressources/images/ligne viseur.png")

function curseur:setCurseur(number)
  if number then
    if number >=1 and number <= #listCurseurs then
      curseur.id = number
      return true
    end
  else
    curseur.id = curseur.id + 1
    if curseur.id > #listCurseurs then
      curseur.id = 1
    end
    return true
  end
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
  self.x = Game.ox
  self.y = Game.h
  self.rotate = math.angle(self.x,self.y,Mouse.x,Mouse.y)-- + math.rad(-90)
  self.distance = math.dist(self.x,self.y,Mouse.x,Mouse.y)
  --
  Mouse.angle = self.rotate
end
--




function ligneRail:draw()
  local nbcircles = 20
  local espace = self.distance/nbcircles
  --
  love.graphics.setColor(curseur.color[1],curseur.color[2],curseur.color[3],0.6)
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

function Controllers:load()
  Mouse.setVisible(false)
  Mouse:update()
end
--

function Controllers:update(dt)
  Mouse:update()
  demicercleRail:update(dt)
  ligneRail:update(dt)
end
--

function Controllers:draw()
  love.graphics.setColor(curseur.color)
  love.graphics.draw(curseur.data.imgdata, Mouse.x, Mouse.y, 0, 1, 1, curseur.data.ox, curseur.data.oy)
  love.graphics.setColor(1,1,1,1)

  if Game.isPlay then
    -- rail
    demicercleRail:draw()

    -- ligne rail
    ligneRail:draw()
  end
end
--


function Controllers:keypressed(key)
  if Game.isPlay then
    if key == "kp+" then
      curseur:setCurseur()
    end
  end
end
--


function Controllers:mousepressed(x,y,button)
  if Game.isPlay then
    Bubbles:launchBubble()
--    Bubbles:destroyMouse(x,y)
  end
end
--

return Controllers
