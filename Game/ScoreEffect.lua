local ScoreEffect = {debug=false}

local size = {normal=30, bonus=80}

-- liste des elements a afficher
local listEffects = {}

function ScoreEffect:new(score, px, py, pbonus)
  local new
  if not pbonus then
    new = newText(Font.KidPixies[size.normal], score)
    new.color={0.545,0.271,0.075,1}
    new.speedMove = -10
  else
    new = newText(Font.KidPixies[size.bonus], score)
    new.color={1,0.843,0,1}
    new.speedMove = -5
  end
  --
  new.timer = newTimer(10)
  new.x=px
  new.y=py
  --
  table.insert(listEffects, new)
end
--

function ScoreEffect:newGame()
  listEffects = {}
end
--

function ScoreEffect:load()
  listEffects = {}
end
--

function ScoreEffect:update(dt)
  for n=#listEffects, 1, -1 do
    local effect = listEffects[n]
    if effect.timer:update(dt) then
      effect.text:release()
      table.remove(listEffects, n)
    else
      effect.y = effect.y + ( effect.speedMove * dt )
    end
  end
end
--

function ScoreEffect:draw()
  for n=#listEffects, 1, -1 do
    local effect = listEffects[n]
    love.graphics.setColor(effect.color)
    love.graphics.draw(effect.text, effect.x, effect.y, 0, Screen.sx, Screen.sy, effect.ox, effect.oy)
  end
  love.graphics.setColor(1,1,1,1)
end
--


function ScoreEffect:keypressed(key)
end
--


function ScoreEffect:mousepressed(x,y,button)
end
--

return ScoreEffect
