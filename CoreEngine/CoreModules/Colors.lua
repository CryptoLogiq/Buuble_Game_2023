local Colors = require("coreEngine/Colors/data")
Colors.listNameColor = require("coreEngine/Colors/name")
--

function Colors:getName(pIndex)
  if pIndex >=1 and pIndex <= #Colors then
    return self.listNameColor[pIndex]
  else
    return "Index inconnu"
  end
end
--

function Colors:getIndex(pName)
  local id = 1
  for index, name in ipairs(Colors) do
    if pName == name then
      return name
    end
  end
end
--

for n=1, #Colors do
Colors[Colors.listNameColor[n]] = Colors[n]
end
--

return Colors