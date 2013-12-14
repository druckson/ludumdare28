local Class = require "lib/hump/class"

local Engine = Class{
    init = function(self)
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
    for name, system in pairs(data) do
        if self[name] ~= nil then
            self[name]:addEntity(entity, entityData, system)
        end
    end
end

function Engine:removeEntity(entity)
    for name, system in pairs(self.systems) do
        system:removeEntity(entity)
    end
end

function Engine:update(dt)
    for _, system in pairs(self.systems) do
        if system.update ~= nil then
            system:update(dt)
        end
    end
end

function Engine:draw()
    for _, system in pairs(self.systems) do
        if system.draw ~= nil then
            system:draw()
        end
    end
end

return Engine
