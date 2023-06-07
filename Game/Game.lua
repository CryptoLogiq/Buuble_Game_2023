local Game = {debug=false, isStop=false, isPlay=false, gameover=false, bestscore=false, StartNewGame=true}

Game.texts = {}

Game.colorFade = {1,1,1,0.8}

function Game:getDimensions()
  self.w = 1920
  self.h = 1080
  self.ox = self.w/2
  self.oy = self.h/2
end
--

function Game:newGame()
  Game.isStop = false
  Game.isPlay = false
  --
  Game.gameover=false
  --
  Game.StartNewGame=true
  --
  MapManager:newGame()
  Bubbles:newGame()
  Sounds:newGame()
  Explosion:newGame()
  WallsMap:newGame()
  ScoreEffect:newGame()
  --
  Gui:load()
end
--

function Game:updateBestScore(bestscore)
  Game.bestscore = false
  --
  local score = Gui.ScoreGame.score
  Gui.ScoreGame.score = 0
  --
  if score >= Gui.ScoreGame.bestscore then
    Gui.ScoreGame.bestscore = score
    Game.bestscore = true
  end
end
--

function Game:incrementeScore(score, px, py, pbonus)
  if not Game.gameover then
    Gui.ScoreGame.score = Gui.ScoreGame.score + score
    if px and py then
      ScoreEffect:new(score, px, py, pbonus)
    end
  end
end
--

function Game:checkUpdateNewLevel()
  --  -- if no bubbles in grid ? New Level !!!
  if  Game.isPlay and not Game.gameover then
    if  #Bubbles.listGrid <= 1 then
      MapManager.current.nbGridOnScreen = MapManager.current.nbGridOnScreen + 1
      Bubbles:createNewLigneBubbles(math.min(MapManager.current.nbGridOnScreen, MapManager.current.lig-1), WorldGrid)
      Game:incrementeScore(MapManager.current.nbGridOnScreen * 1000, Game.ox, Game.oy, true)
      Sounds.levelup.source:play()
    end
  end
end
--

function Game:checkGAmeOver()
  -- ### it's a Game Over ?' ### --
  if Game.gameover then
    if #Bubbles.listGrid <=0 and #Bubbles.listDestroy <= 0 then
      Core.Scene.setScene(GameOver)
    end
  end
end
--

--
function Game:load()
  Game:getDimensions()
  --
  Game.texts.isStop = {txtdata = love.graphics.newText(Font.Games[50], "WAITING")}
  Game.texts.isStop.w, Game.texts.isStop.h = Game.texts.isStop.txtdata:getDimensions()
  Game.texts.isStop.ox, Game.texts.isStop.oy = Game.texts.isStop.w/2, Game.texts.isStop.h/2
  Game.texts.isStop.color = {0,1,0,1}
end
--

function Game:update(dt)
  Gui:update(dt)
  --
  BackGround:update(dt)
  Controllers:update(dt)
  Sounds:update(dt)
  if not Game.isStop then
    WallsMap:update(dt)
    Explosion:update(dt)
    MapManager:update(dt)
    Bubbles:update(dt)
    Game:checkUpdateNewLevel()
    Game:checkGAmeOver()
    ScoreEffect:update(dt)
  end
end
--

function Game:draw()
  --
  BackGround:draw()
  --
  Gui:draw()
  Sounds:draw()
  --
  Controllers:draw()
  --
  WallsMap:draw()
  MapManager:draw()
  Bubbles:draw()
  Explosion:draw()
  ScoreEffect:draw()
  --
  if Game.isStop then
    love.graphics.setColor(Game.texts.isStop.color)
    love.graphics.draw(Game.texts.isStop.txtdata, Game.ox, Game.oy, 0, 1, 1, Game.texts.isStop.ox, Game.texts.isStop.oy)
    love.graphics.setColor(1,1,1,1)
  end
  --
  if Game.debug then
    local textDebugGame = ""
    for k, v in pairs(Game) do
      if type(v) ~= "table" and type(v) ~= "function" then
        textDebugGame = textDebugGame.."Game."..tostring(k).." : "..tostring(v).."\n"
      end
    end
    --
    textDebugGame = textDebugGame.."-------------------------".."\n"
    --
    for k, v in pairs(Bubbles) do
      if type(v) ~= "table" and type(v) ~= "function" then
        textDebugGame = textDebugGame.."Bubbles."..tostring(k).." : "..tostring(v).."\n"
      end
    end
    love.graphics.print(textDebugGame,10,10)
  end

end
--

function Game:keypressed(key)
  if key == "pause" then
    Game.isStop = not Game.isStop
  elseif key == "escape" then
    -- Menu
    if not Game.isStop then Game.isStop = true end
    Core.Scene.setScene(Menu)
  end
  BackGround:keypressed(key)
  MapManager:keypressed(key)
  Bubbles:keypressed(key)
  Sounds:keypressed(key)
  Controllers:keypressed(key)
end
--

function Game:mousepressed(x,y,button)
  Bubbles:mousepressed(x,y,button)
  --
  Controllers:mousepressed(x,y,button)
end
--

return Game