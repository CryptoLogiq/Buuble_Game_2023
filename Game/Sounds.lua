local Sounds = {debug=false, list={}, current=nil}

local dirpathMusic = "ressources/musiques/"
local dirpathSfx = "ressources/sounds/"

Sounds.volumeMusic = 0.8
Sounds.volumeSfx = 1

function Sounds:newGame()
  Sounds:purgeList()
  --
  Sounds.musique:stop()
  Sounds.musique:play()
  Sounds.musique:setVolume(0)
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

function Sounds:load()
  Sounds.musique = love.audio.newSource(dirpathMusic.."PuzzleEnergy16Bit.ogg", "stream")  
  Sounds.musique:setLooping(true)
  --
  Sounds.counter={}
  for n=1, 3 do
    local counter = love.audio.newSource(dirpathSfx.."counter_"..n..".ogg", "stream")
    counter:setVolume(Sounds.volumeSfx)
    table.insert(Sounds.counter,  counter)
  end
  --
  Sounds.go = love.audio.newSource(dirpathSfx.."go.ogg", "stream")
  Sounds.go:setVolume(Sounds.volumeSfx)
  --
  Sounds.correct = love.audio.newSource(dirpathSfx.."correct.ogg", "stream")
  Sounds.correct:setVolume(Sounds.volumeSfx)
  --
  Sounds.levelup = love.audio.newSource(dirpathSfx.."level_up.ogg", "stream")
  Sounds.levelup:setVolume(Sounds.volumeSfx)
  --
  Sounds.newhightscore = love.audio.newSource(dirpathSfx.."new_highscore.ogg", "stream")
  Sounds.newhightscore:setVolume(Sounds.volumeSfx)
  --
  Sounds.gameover = love.audio.newSource(dirpathSfx.."game_over.ogg", "stream")
  Sounds.gameover:setVolume(Sounds.volumeSfx)
  --

  Sounds.launchBubble = love.audio.newSource(dirpathSfx.."ballon_launch.mp3", "stream")
  Sounds.launchBubble:setVolume(Sounds.volumeSfx)
  --
  Sounds.explodeBubble = {}
  for n=1, 2 do
    local explode = love.audio.newSource(dirpathSfx.."ballon_explode"..n..".mp3", "stream")
    explode:setVolume(Sounds.volumeSfx)
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
    if Sounds.musique:getVolume() < Sounds.volumeMusic then
      local volume = Sounds.musique:getVolume()+(dt*0.1)
      if volume > 1 then volume = 1 end
      Sounds.musique:setVolume(volume)
    end
    if not Sounds.musique:isPlaying() then
      Sounds.musique:play()
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
