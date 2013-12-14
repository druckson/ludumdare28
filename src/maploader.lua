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

    if map.entities then
        for _, data in pairs(map.entities) do
            print("Creating entity: ")
            PrettyPrint(data)
            self.engine:createEntity(data)
        end
    end
end

return MapLoader