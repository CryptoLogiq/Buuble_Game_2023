local ScoreBoard = {}
-- Incluez la bibliothèque http pour faire des requêtes HTTP
local http = require('socket.http')
local https = require("ssl.https")

-- Incluez la bibliothèque ltn12 pour la manipulation des flux de données
local ltn12 = require('ltn12')

-- Incluez une bibliothèque pour manipuler du JSON, par exemple dkjson
local json = require('dkjson')

-- Définissez l'URL du service
local url = 'https://api.jsonbin.io/v3/b/647e48efb89b1e2299aa651d/'

-- Définissez les en-têtes nécessaires
local request_headers = {
  ['Content-Type'] = 'application/json',
  ['X-Master-Key'] = '$2b$10$EHuqoLZoT7XPcjdiF7eCjOWtQGtigb4LVFVPYcYirgKTpelVWLy.6',
  ['X-Access-Key'] = '$2b$10$AR/jNTA.kxDRTkaV5O.hDuV87qewhAaA5uyyyAqytxVhWUIddTW8m',
  ['X-Collection-Id'] = '647e3bb69d312622a36aeb21',
  ['X-Bin-Private'] = 'false',
  ['X-Bin-Name'] = 'BubbleGame2023'
}

-- Définissez le corps de la requête
local body = json.encode({
    {user = 'Antharuu', score = 5000},
    {user = 'Crypto', score = 400}
  })
--print(body) -- OK


-- Préparez un tableau pour stocker la réponse
local response_table = {}

-- Faites la requête HTTP
local max_redirects = 10 -- Maximum number of redirects to follow

for i = 1, max_redirects do
  local _, status, response_headers = http.request({
      url = url,
      method = 'PUT',
      headers = request_headers,
      source = ltn12.source.string(body),
      sink = ltn12.sink.table(response_table)
    })

  -- Vérifiez le résultat de la requête
  if status == 200 then
    -- La requête a réussi, faites quelque chose avec la réponse...
    print(table.concat(response_table))
  elseif status == 301 or status == 302 or status == 307 or status == 308 then
    url = response_headers.location
    print(url)
  else
    break
  end
  if status ~= 200 and i == 10 then
    -- La requête a échoué, affichez l'erreur...
    print("La requête a échoué,", response_headers.location, 'Erreur : ' .. status)
  end
end
--

return ScoreBoard