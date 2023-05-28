
local CoreLoader = {debug=false}

--
local Core = {}

--
local dirpath = "CoreEngine/CoreModules/"
local filesTable = love.filesystem.getDirectoryItems(dirpath)

function CoreLoader:load()
  -- For All
  require(dirpath.."Globals")

  -- Libs independante
  Core.Gamera = require(dirpath.."Gamera")

  -- Prio order require for work
  Core.Timer = require(dirpath.."Timer")
  Core.Scene = require(dirpath.."SceneManager")

  -- Class dependantes
  Core.ImageManager = require(dirpath.."ImageManager")

  --
  for _, Module in pairs(Core) do
    if type(Module) == "table" then
      if Module.load then
        Module.load()
      end
    end
  end
end
--

CoreLoader:load()

if CoreLoader.debug then
  for k, v in pairs(Core) do
    print( "Core."..tostring(k) .. " : " .. tostring(v) )
  end
end
--

return Core