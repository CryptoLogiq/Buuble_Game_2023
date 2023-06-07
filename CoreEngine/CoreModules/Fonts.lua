Font = {}

Font.Games = {}
for  n=1, 100 do
  table.insert(Font.Games , love.graphics.newFont("ressources/fonts/Games.ttf", n) )
end
--

Font.CursedTimerULiL = {}
for  n=1, 100 do
  table.insert(Font.CursedTimerULiL , love.graphics.newFont("ressources/fonts/CursedTimerULiL.ttf", n) )
end
--

Font.KidPixies = {}
for  n=1, 100 do
  table.insert(Font.KidPixies , love.graphics.newFont("ressources/fonts/KidPixies.ttf", n) )
end
--

local function textGetDimensions(self)
  self.w, self.h = self.text:getDimensions()
  self.ox, self.oy = self.w/2, self.h/2
end
--

function newText(pFont, pText)
  local newText = {textSource=pText, text=love.graphics.newText(pFont, pText), getDimensions=textGetDimensions}
  newText:getDimensions()
  return newText
end
--