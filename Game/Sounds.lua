local Sounds = {debug=false, list={}, listMusic={}, listSfx={}, current=nil}

local dirpathMusic = "ressources/musiques/"
local dirpathSfx = "ressources/sounds/"

Sounds.Music = {volume=0.2,type="Music"}
Sounds.Sfx = {volume=0.4,type="Music"}


function Sounds:newGame()
  Sounds:purgeList()
end
--

function Sounds:purgeList()
  for n=#Sounds.list, 1, -1 do
    local sound = Sounds.list[n]
    sound:stop()
  end
  Sounds.list={}
end
--

function Sounds:newCounter()
  for n=3, 1, -1 do
    table.insert(Sounds.list, Sounds.counter[n].source:clone())
  end
  table.insert(Sounds.list, Sounds.go.source:clone())
end
--

function Sounds:addPlayList(sound)
  table.insert(Sounds.list, sound.source:clone())
end
--

function Sounds:listUpdate(dt)
  if #Sounds.list > 0 then
    if not Sounds.currentSource then
      Sounds.currentSource = Sounds.list[1]
      Sounds.currentSource:play()
    end
  end
  --
  if Sounds.currentSource then
    if Sounds.currentSource:isPlaying() == false then
--      Sounds.currentSource:release()
      table.remove(Sounds.list, 1)
      if #Sounds.list > 1 then
        Sounds.currentSource = Sounds.list[1]
        Sounds.currentSource:play()
      else
        Sounds.currentSource = nil
      end
    end
  end
end
--

function Sounds:musiqueUpdate(dt)
  if Game.isStop then
    Sounds.musique.source:setVolume(0)
    if Sounds.musique.source:isPlaying() then
      Sounds.musique.source:pause()
    end
  else
    if not Sounds.musique.source:isPlaying() then
      Sounds.musique.source:play()
    end
    if Sounds.musique.source:getVolume() < Sounds.Music.volume then
      Sounds.musique.source:setVolume(Sounds.musique.source:getVolume()+(dt/10))
    elseif Sounds.musique.source:getVolume() > Sounds.Music.volume then
      Sounds.musique.source:setVolume(Sounds.musique.source:getVolume()-(dt/10))
    end
    if math.floor(Sounds.musique.source:getVolume()*100) == Sounds.Music.volume then
      Sounds.musique.source:setVolume(Sounds.Music.volume)
    end
  end
end
--

function Sounds:setVolume(pRef)
  if pRef == Sounds.Music then -- musique
    for _, sound in ipairs(self.listMusic) do
      local volume = math.max(Sounds.Music.volume + sound.diffVolume, 0.05)
      sound.source:setVolume(volume)
    end
  elseif pRef == Sounds.Sfx then    -- Sfx
    for _, sound in ipairs(self.listSfx) do
      local volume = math.max(Sounds.Music.volume + sound.diffVolume, 0.05)
      sound.source:setVolume(volume)
    end
  end
end
--

function Sounds:newMusic(pFile, pDiffVolume)
  local new = {source=love.audio.newSource(dirpathMusic..pFile, "stream"), diffVolume = pDiffVolume or 0}
  new.source:setLooping(true)
  local volume = math.max(Sounds.Music.volume + new.diffVolume, 0.05)
  new.source:setVolume(volume)
  table.insert(self.listMusic, new)
  return new
end
--

function Sounds:newSfx(pFile, pDiffVolume)
  local new = {source=love.audio.newSource(dirpathSfx..pFile, "static"), diffVolume = pDiffVolume or 0}
  local volume = math.max(Sounds.Music.volume + new.diffVolume, 0.05)
  new.source:setVolume(volume)
  table.insert(self.listSfx, new)
  return new
end
--

function Sounds:load()
  Sounds.musique = Sounds:newMusic("PuzzleEnergy16Bit.ogg", 0)  
  Sounds.musique.source:setVolume(0)
  --
  Sounds.counter={}
  for n=1, 3 do
    local counter = Sounds:newSfx("counter_"..n..".ogg", 0.2)
    table.insert(Sounds.counter,  counter)
  end
  --
  Sounds.go = Sounds:newSfx("go.ogg", 0.2)
  Sounds.correct = Sounds:newSfx("correct.ogg", 0.3)
  Sounds.levelup = Sounds:newSfx("level_up.ogg", 0.4)
  Sounds.newhightscore = Sounds:newSfx("new_highscore.ogg", 0.4)
  Sounds.gameover = Sounds:newSfx("game_over.ogg", 0.2)
  Sounds.launchBubble = Sounds:newSfx("ballon_launch.mp3", 0.4)
  Sounds.rebond = Sounds:newSfx("rebond.wav", 0.5)
  Sounds.impact = Sounds:newSfx("impact.wav", 0)
  Sounds.impactGroup = Sounds:newSfx("impactGroup.wav", 0)
  --
  Sounds.explodeBubble = {}
  for n=1, 2 do
    local explode = Sounds:newSfx("ballon_explode"..n..".mp3", -0.1)
    table.insert(Sounds.explodeBubble,  explode)
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
