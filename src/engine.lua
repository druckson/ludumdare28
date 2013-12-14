local Class = require "lib/hump/class"

local Engine = Class{
    init = function(self)
        self.entities = {}
        self.systems = {}
        self.nextEntity = 1
    end
}

function Engine:addSystem(name, system)
    table.insert(self.systems, system)
    self[name] = system
    system.init(self)
end

function Engine:createEntity(data)
    local entity = self.nextEntity
    self.nextEntity = self.nextEntity + 1
    local entityData = {}
    for name, system in pairs(systems) do
        if data[system] ~= nil then
            system:addEntity(entity, data[system])
        end
    end
end

function Engine:update(dt)
    for _, system in pairs(systems) do
    end
end

return Engine
