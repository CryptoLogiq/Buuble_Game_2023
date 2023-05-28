local ImageManager = {debug=false}
local lg = love.graphics

local listImage = {}

local listImageSheet = {}

local listAnim = {}

local listAnimLayers = {}

function ImageManager.searchExist(pList, pfile)
  for _, image in ipairs(pList) do
    if image.file == pfile then
      print("Source existante retrouvée : "..image.file)
      return true, image
    end
  end
  return false
end
--

function ImageManager.newImage(pfile)
  local request, image = ImageManager.searchExist(listImage, pfile)
  if request then
    return image
  end
  --
  local new = {imgdata=lg.newImage(pfile), file=pfile}
  function new.getDimensions()
    new.w, new.h = new.imgdata:getDimensions()
    new.ox, new.oy = new.w/2, new.h/2
  end
  --
  new.getDimensions()
  --
  function new:draw(x,y)
    love.graphics.draw(self.imgdata, x or 0, y or 0)
  end
  --
  table.insert(listImage, new)
  --
  return new
end
--

function ImageManager.newImageSheet(pfile, pSizeW, pSizeH)
  local request, imagesheet = ImageManager.searchExist(listImageSheet ,pfile)
  if request then
    return imagesheet
  end
  --
  local newSheet = ImageManager.newImage(pfile)
  --
  newSheet.fileid = pfile
  --
  newSheet.sizeW = pSizeW
  newSheet.sizeH = pSizeH
  --
  newSheet.lig = newSheet.h / pSizeH
  newSheet.col = newSheet.w / pSizeW
  --
  local startx=0
  local starty=0
  local x, y = 0, 0
  for l=1, newSheet.lig do
    for c=1, newSheet.col do
      local newquad = {imgdata=newSheet.imgdata, quad=lg.newQuad(x, y, newSheet.sizeW, newSheet.sizeH, newSheet.w, newSheet.h)}
      table.insert(newSheet, newquad)
      x = x + newSheet.sizeW
    end
    x = startx
    y = y + newSheet.sizeH
  end
  --
  function newSheet.drawTileQuad()
    local startx=0
    local starty=0
    local x, y = 0, 0
    local id = 1
    for l=1, newSheet.lig do
      for c=1, newSheet.col do
        love.graphics.draw(newSheet.imgdata, newSheet[id].quad, x, y)
        x = x + newSheet.sizeW
        id = id + 1
      end
      x = startx
      y = y + newSheet.sizeH
    end
    --
    x, y = 0, 0
    id = 1
    for l=1, newSheet.lig do
      for c=1, newSheet.col do
        love.graphics.rectangle("line", x, y, newSheet.sizeW, newSheet.sizeH)
        x = x + newSheet.sizeW
        id = id + 1
      end
      x = startx
      y = y + newSheet.sizeH
    end
  end
  --
  table.insert(listImageSheet, newSheet)
  --
  return newSheet
end
--

function ImageManager.newAnim(pType, pCol, pLig, pStart, pEnd)
  if type(pType) == "string" then
    return ImageManager.newAnimFile(pType, pCol, pLig, pStart, pEnd)
  elseif type(pType) == "table" then
    return ImageManager.newAnimTable(pType, pCol, pLig, pStart, pEnd)
  else
    print("Echec creation Animation,  type inconnu :")
    print("With :" .. tostring(pType))
    love.event.quit()
  end
end
--

function ImageManager.newAnimFile(pFile, pCol, pLig, pStart, pEnd)

  local spr = ImageManager.newImage(pFile)
  local nbframes
  --
  spr.lig = pLig
  spr.col = pCol
  if not pStart or not pEnd then
    nbframes = spr.lig * spr.col
    pStart = 1
    pEnd = nbframes
  else
    nbframes = (pEnd - pStart) + 1
  end
  --
  spr.sizeW = spr.w / spr.col
  spr.sizeH = spr.h / spr.lig
  --
  local startx = 0
  local starty = 0
  local x, y = 0, 0
  local id = 1
  --
  local new = {imgdata=spr.imgdata, frame=1, lig=spr.lig, col=spr.col, nbframes=nbframes, w=spr.sizeW, h=spr.sizeH, ox=spr.sizeW/2, oy=spr.sizeH/2}
  --
  for l=1, new.lig do
    for c=1, new.col do
      if id >= pStart and id <= pEnd then
        local quad=lg.newQuad(x, y, new.w, new.h, spr.w, spr.h)
        local anim = {imgdata=new.imgdata, quad=quad, nbframes=nbframes, w=new.w, h=new.h, ox=new.ox, oy=new.oy}
        table.insert(new, anim)
      end
      id = id + 1
      x = x + new.w
    end
    x = startx
    y = y + new.h
  end
  --
  return new
end
--

function ImageManager.newAnimTable(pTable, pCol, pLig, pStart, pEnd)
  local new = ImageManager.newAnimFile(pTable[1], pCol, pLig, pStart, pEnd)
  new.layers = {}
  new.currentLayer = 1
  new.nbStylesLayers = #pTable-2
  new.outilsLayer = #pTable-1
  --
  for n=2, #pTable do
    table.insert(new.layers, ImageManager.newAnimFile(pTable[n], pCol, pLig, pStart, pEnd) )
  end
  return new
end
--

return ImageManager