function TimerReset(self, dt)
  self.current = 0
end
--

function updateTimerNoLoop(self, dt)
  self.current = self.current + self.speed * dt
  if self.current >= self.delai then
    return true
  end
  return false
end
--

function updateTimerLoop(self, dt)
  self.current = self.current + self.speed * dt
  if self.current >= self.delai then
    self.current = 0
    return true
  end
  return false
end
--

function updateTimerRandomSpeed(self, dt)
  self.current = self.current + self.speed * dt
  if self.current >= self.delai then
    self.current = 0
    self.speed = love.math.random(self.speedMin, self.speedMax)
    return true
  end
  return false
end
--

Mouse = love.mouse
Mouse.w, Mouse.h = 1, 1

function Mouse:update()
  self.x, self.y = self:getPosition()
end
--

-- print table complete
function printTable(table, name, isStart)
  if not name then name = "table" end
  if not isStart then
    print("---------start---------------")
  end
  for k, v in pairs(table) do
    if type(v) == "table" then
      printTable(v, name.."."..k, true)
    else
      print(tostring(name).."."..tostring(k), tostring(v))
    end
  end
  if not isStart then
    print("----------end--------------")
  end
end
--

function math.sign(number)
  if number >= 0 then return 1 else return -1 end
end
--


local function updateTextDraw(self)
  self.w, self.h = self.text:getDimensions()
  self.ox, self.oy = self.w/2, self.h/2
end
--

function newNameDraw(self, pFont)
  if not pFont then pFont = love.graphics.getFont(8) end
  self.nameDraw = {text=love.graphics.newText(pFont, self.name), updateTextDraw=updateTextDraw}
  self.nameDraw:updateTextDraw(self)
end
--

-- Collision detection function;
-- Returns true if two boxes overlap, false if they don't;
-- x1,y1 are the top-left coords of the first box, while w1,h1 are its width and height;
-- x2,y2,w2 & h2 are the same, but for the second box.
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end
--

-- Averages an arbitrary number of angles (in radians).
function math.averageAngles(...)
  local x,y = 0,0
  for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
  return math.atan2(y, x)
end
--

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
-- Distance between two 3D points:
function math.dist3d(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end


-- Returns the angle between two vectors assuming the same origin.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end


-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end


-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end


-- Linear interpolation between two numbers.
function lerp(a,b,t) return (1-t)*a + t*b end
function lerp2(a,b,t) return a+(b-a)*t end

-- Cosine interpolation between two numbers.
function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end


-- Normalize two numbers.
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end


-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


-- Randomly returns either -1 or 1.
function math.rsign() return love.math.random(2) == 2 and 1 or -1 end


-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end


-- Gives a precise random decimal number given a minimum and maximum
function math.prandom(min, max) return love.math.random() * (max - min) + min end


-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
  local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
  return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end
--

-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
  local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
  local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
  local det,x,y = a1*b2 - a2*b1
  if det==0 then return false, "The lines are parallel." end
  x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
  if seg1 or seg2 then
    local min,max = math.min, math.max
    if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
    seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
      return false, "The lines don't intersect."
    end
  end
  return x,y
end
--
