local ClassTimer = {}

function ClassTimer:new(pLoop)
  local timer = {current=0, delai=60 or 10, speed=60*6, loop=pLoop or true}

  function timer:setLoop(bool)
    if type(bool) == "boolean" then
      self.loop = bool
    else
      print("requiert un Booleen : true or false")
    end
  end
--

  function timer:update(dt)
    self.current = self.current + (self.speed * dt)
    if self.current >= self.delai then
      if self.loop then
        self.current = 0
      end
      return true
    end
    return false
  end
--

  function timer:reset()
    self.current = 0
  end
--


  function timer:setSpeed(speed)
    self.speed = speed
    -- speed == nb frame / seconde
  end
--

  return timer
end
--

return ClassTimer