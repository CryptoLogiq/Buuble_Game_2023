local Sounds = {debug=false, list={}, current=nil}

local dirpathMusic = "ressources/musiques/"
local dirpathSfx = "ressources/sounds/"

Sounds.Music = {volume=0.3,type="Music"}
Sounds.Sfx = {volume=0.2,type="Music"}

function Sounds:newGame()
  Sounds:purgeList()
  --
--  Sounds.musique:setVolume(0.5)
  --
  --Sounds:newCounter()
end
--

function Sounds:purgeList()
  for _, source in ipairs(Sounds.list) do
    source:stop()
    source:release()
  end
  Sounds.list={}
end
--

function Sounds:newCounter()
  for n=3, 1 do
    table.insert(Sounds.list, Sounds.counter[n]:clone())
  end
  table.insert(Sounds.list, Sounds.go:clone())
  --
end
--

function Sounds:setVolume(pRef)
  if pRef == Sounds.Music then -- musique
    Sounds.musique:setVolume(Sounds.Music.volume)
  elseif pRef == Sounds.Sfx then    -- Sfx
    for n=1, 3 do
      local counter = Sounds.counter[n]
      counter:setVolume(Sounds.Sfx.volume)
    end
    --
    Sounds.go:setVolume(Sounds.Sfx.volume)
    --
    Sounds.correct:setVolume(Sounds.Sfx.volume)
    --
    Sounds.levelup:setVolume(Sounds.Sfx.volume)
    --
    Sounds.newhightscore:setVolume(Sounds.Sfx.volume)
    --
    Sounds.gameover:setVolume(Sounds.Sfx.volume)
    --

    Sounds.launchBubble:setVolume(Sounds.Sfx.volume)
    --
    for n=1, 2 do
      local explode = Sounds.explodeBubble[n]
      explode:setVolume(Sounds.Sfx.volume)
    end
  end
end
--

function Sounds:load()
  Sounds.musique = love.audio.newSource(dirpathMusic.."PuzzleEnergy16Bit.ogg", "stream")  
  Sounds.musique:setLooping(true)
  Sounds.musique:setVolume(0)
  --
  Sounds.counter={}
  for n=1, 3 do
    local counter = love.audio.newSource(dirpathSfx.."counter_"..n..".ogg", "stream")
    counter:setVolume(Sounds.Sfx.volume)
    table.insert(Sounds.counter,  counter)
  end
  --
  Sounds.go = love.audio.newSource(dirpathSfx.."go.ogg", "stream")
  Sounds.go:setVolume(Sounds.Sfx.volume)
  --
  Sounds.correct = love.audio.newSource(dirpathSfx.."correct.ogg", "stream")
  Sounds.correct:setVolume(Sounds.Sfx.volume)
  --
  Sounds.levelup = love.audio.newSource(dirpathSfx.."level_up.ogg", "stream")
  Sounds.levelup:setVolume(Sounds.Sfx.volume)
  --
  Sounds.newhightscore = love.audio.newSource(dirpathSfx.."new_highscore.ogg", "stream")
  Sounds.newhightscore:setVolume(Sounds.Sfx.volume)
  --
  Sounds.gameover = love.audio.newSource(dirpathSfx.."game_over.ogg", "stream")
  Sounds.gameover:setVolume(Sounds.Sfx.volume)
  --

  Sounds.launchBubble = love.audio.newSource(dirpathSfx.."ballon_launch.mp3", "stream")
  Sounds.launchBubble:setVolume(Sounds.Sfx.volume)
  --
  Sounds.explodeBubble = {}
  for n=1, 2 do
    local explode = love.audio.newSource(dirpathSfx.."ballon_explode"..n..".mp3", "stream")
    explode:setVolume(Sounds.Sfx.volume)
    table.insert(Sounds.explodeBubble,  explode)
  end

end
--

function Sounds:musiqueUpdate(dt)
  if Game.isStop then
    Sounds.musique:setVolume(0)
    if Sounds.musique:isPlaying() then
      Sounds.musique:pause()
    end
  else
    if not Sounds.musique:isPlaying() then
      Sounds.musique:play()
    end
    if Sounds.musique:getVolume() < Sounds.Music.volume then
      Sounds.musique:setVolume(Sounds.musique:getVolume()+(dt/10))
    elseif Sounds.musique:getVolume() > Sounds.Music.volume then
      Sounds.musique:setVolume(Sounds.musique:getVolume()-(dt/10))
    end
    if math.floor(Sounds.musique:getVolume()*100) == Sounds.Music.volume then
      Sounds.musique:setVolume(Sounds.Music.volume)
    end
  end
end
--

function Sounds:listUpdate(dt)
  if #Sounds.list > 0 then
    --
    if not Sounds.currentPlay then
      Sounds.currentPlay = Sounds.list[1]
      Sounds.currentPlay:play()
    end
    --
    local source = Sounds.list[1]
    if source:isPlaying() == false then
      table.remove(Sounds.list, 1)
      if #Sounds.list > 1 then
        Sounds.currentPlay = Sounds.list[1]
        Sounds.currentPlay:play()
      else
        Sounds.currentPlay = nil
      end
    end
  end
end
--

function Sounds:update(dt)
  Sounds:musiqueUpdate(dt)
  --
  Sounds:listUpdate(dt)
end
--

function Sounds:draw()
end
--


function Sounds:keypressed(key)
end
--


function Sounds:mousepressed(x,y,button)
end
--

return Sounds
