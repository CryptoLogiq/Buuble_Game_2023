local Sounds = {debug=false}

local dirpath = "ressources/musiques/"

Sounds.volumeMusic = 0.8

function Sounds:load()
  Sounds.musique = love.audio.newSource(dirpath.."PuzzleEnergy16Bit.ogg", "stream")  
  Sounds.musique:play()
  Sounds.musique:setVolume(0)
  Sounds.musique:setLooping(true)
end
--

function Sounds:update(dt)
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
