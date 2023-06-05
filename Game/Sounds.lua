local Sounds = {debug=false, playlist={}, listClone={}, listMusic={}, listSfx={}, current=nil}

local dirpathMusic = "ressources/musiques/"
local dirpathSfx = "ressources/sounds/"

Sounds.Music = {volume=0.2,type="Music"}
Sounds.Sfx = {volume=0.4,type="Music"}


function Sounds:newGame()
  self:purgePlayList()
end
--

function Sounds:purgePlayList()
  for n=#self.listClone, 1, -1 do
    local sound = self.listClone[n]
    sound:stop()
  end
  self.playlist={}
  self.listClone={}
end
--

function Sounds:newCounter()
  for n=3, 1, -1 do
    self:addPlayListNoDoublon(self.counter[n])
  end
  self:addPlayListNoDoublon(self.go)
end
--

function Sounds:addPlayList(sound)
  table.insert(self.playlist, sound)
  table.insert(self.listClone, sound.source:clone())
end
--

function Sounds:addPlayListNoDoublon(sound)
  for _, search in ipairs(self.playlist)do
    if sound == search then
      return
    end
  end
  self:addPlayList(sound)
end
--

function Sounds:listUpdate(dt)
  if #self.playlist > 0 then
    if not self.currentSource then
      self.currentSource = self.listClone[1]
      self.currentSource:play()
    end
  end
  --
  if self.currentSource then
    if self.currentSource:isPlaying() == false then
      table.remove(self.playlist, 1)
      table.remove(self.listClone, 1)
      if #self.playlist > 1 then
        self.currentSource = self.listClone[1]
        self.currentSource:play()
      else
        self.currentSource = nil
        self.playlist={}
        self.listClone={}
      end
    end
  end
end
--

function Sounds:musiqueUpdate(dt)
  if Game.isStop then
    self.musique.source:setVolume(0)
    if self.musique.source:isPlaying() then
      self.musique.source:pause()
    end
  else
    if not self.musique.source:isPlaying() then
      self.musique.source:play()
    end
    if self.musique.source:getVolume() < self.Music.volume then
      self.musique.source:setVolume(self.musique.source:getVolume()+(dt/10))
    elseif self.musique.source:getVolume() > self.Music.volume then
      self.musique.source:setVolume(self.musique.source:getVolume()-(dt/10))
    end
    if math.floor(self.musique.source:getVolume()*100) == self.Music.volume then
      self.musique.source:setVolume(self.Music.volume)
    end
  end
end
--

function Sounds:setVolume(pRef)
  if pRef == self.Music then -- musique
    for _, sound in ipairs(self.listMusic) do
      local volume = math.max(self.Music.volume + sound.diffVolume, 0.05)
      sound.source:setVolume(volume)
    end
  elseif pRef == self.Sfx then    -- Sfx
    for _, sound in ipairs(self.listSfx) do
      local volume = math.max(self.Music.volume + sound.diffVolume, 0.05)
      sound.source:setVolume(volume)
    end
  end
end
--

function Sounds:newMusic(pFile, pDiffVolume)
  local new = {source=love.audio.newSource(dirpathMusic..pFile, "stream"), diffVolume = pDiffVolume or 0}
  new.source:setLooping(true)
  local volume = math.max(self.Music.volume + new.diffVolume, 0.05)
  new.source:setVolume(volume)
  table.insert(self.listMusic, new)
  return new
end
--

function Sounds:newSfx(pFile, pDiffVolume)
  local new = {source=love.audio.newSource(dirpathSfx..pFile, "static"), diffVolume = pDiffVolume or 0}
  local volume = math.max(self.Music.volume + new.diffVolume, 0.05)
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
  self:musiqueUpdate(dt)
  --
  self:listUpdate(dt)
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
