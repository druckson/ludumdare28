local Class = require "lib/hump/class"
local vector = require "lib/hump/vector"

local Engine = Class{
    init = function(self)
        self.systems = {}
        self.entities = {}
        self.nextEntity = 1
    end
}

function Engine:addSystem(name, system)
    table.insert(self.systems, system)
    self[name] = system

    if system.setup ~= nil then
        system:setup(self)
    end
end

function Engine:marshall(entity)
    local entityData = self.entities[entity]

    local data = entityData.archive;

    data.transform = {
        position = {entityData.transform.position:unpack()},
        rotation = entityData.transform.rotation
    }

    for _, system in pairs(self.systems) do
        if system.marshall ~= nil then
            system:marshall(entity, data)
        end
    end
    return data
end

function Engine:unmarshall(entity, data)
    if self.entities[entity] == nil then
       self.entities[entity] = {}
    end

    local entityData = self.entities[entity]
    if data.transform then
        entityData.transform = {
            position = vector.new(unpack(data.transform.position)),
            rotation = data.transform.rotation
        }
    else
        entityData.position = {
            position = vector.new(0, 0),
            rotation = 0
        }
    end

    for name, system in pairs(data) do
        if self[name] ~= nil and self[name].addEntity ~= nil then
            self[name]:addEntity(entity, entityData, system)
        end
    end
end

function Engine:createEntity(data)
    local entity = self.nextEntity
    self.nextEntity = self.nextEntity + 1

    local entityData = {}
    self.entities[entity] = entityData
    self:unmarshall(entity, data)

    entityData.archive = data
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
