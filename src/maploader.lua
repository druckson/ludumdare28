local Class = require "lib/hump/class"
local PrettyPrint = require "lib/lua-pretty-print/PrettyPrint"
require "lib/json"

local MapLoader = Class{
    init = function(self, engine)
        self.engine = engine
    end
}

function MapLoader:loadMap(file)
    local data = love.filesystem.read('maps/'..file..'.json')
    local map = json.decode(data)

    if map.prefabs then
        self.engine:addPrefabs(map.prefabs)
    end

    if map.entities then
        for _, data in pairs(map.entities) do
            self.engine:createEntity(data)
        end
    end

    if map.audio then
        for _, song in pairs(map.audio.songs) do
            self.engine:createEntity({
                sound = {
                    file = song
                },
                networking = {
                    type = "static"
                }
            })
        end
        --self.engine.systemsByName.sound:addSong
    end
end

return MapLoader
