local Class = require "lib/hump/class"
local vector = require "lib/hump/vector"
local Messaging = require "utils/messaging"
local merge = (require "utils/diff").merge
require "lib/json"

local Engine = Class{
    init = function(self, messaging)
        self.systems = {}
        self.systemData = {}
        self.systemsByName = {}
        self.entities = {}
        self.nextEntity = 1
        self.messaging = messaging
        self.prefabs = {}
    end
}

function Engine:prefab(data)
    local out = {}
    if data.prefab then
            if self.prefabs[data.prefab] then
            local prefab = data.prefab
            out = self:prefab(self.prefabs[prefab])
        else
            print("Missing prefab: "..data.prefab)
        end
    end

    return merge(out, data)
end

function Engine:addPrefabs(prefabs)
    for name, value in pairs(prefabs) do
        self.prefabs[name] = value
    end
end

function Engine:addSystem(name, system, updateInterval)
    table.insert(self.systems, system)
    self.systemsByName[name] = system
    system._name = name

    self.systemData[name] = {
        age = 0 
    }
    if updateInterval then
        self.systemData[name].updateInterval = updateInterval
    else
        self.systemData[name].updateInterval = 1
    end

    if system.setup ~= nil then
        system:setup(self)
    end
end

function Engine:setPlayer(entity)
    for _, system in pairs(self.systems) do
        if system.setPlayer then
            system:setPlayer(entity, self.entities[entity])
        end
    end
end

function Engine:marshall(entity)
    local entityData = self.entities[entity]

    local data = entityData.archive;

    if entityData.transform then
        data.transform = {
            position = {entityData.transform.position:unpack()},
            rotation = entityData.transform.rotation
        }
    end

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
    end

    for name, systemData in pairs(data) do
        if name ~= "prefab" then
            local system = self.systemsByName[name]
            if system ~= nil and system.addEntity ~= nil then
                system:addEntity(entity, entityData, systemData)
            end
        end
    end
end

function Engine:createEntity(data)
    local entity = self.nextEntity
    self.nextEntity = self.nextEntity + 1

    data = self.prefab(self, data)

    local entityData = {}
    entityData.archive = data
    self.entities[entity] = entityData
    self:unmarshall(entity, data)

    return entity
end

function Engine:deleteEntity(entity)
    for _, system in pairs(self.systems) do
        if system.removeEntity then
            system:removeEntity(entity)
        end
    end
end

function Engine:update(dt)
    self.messaging:flush()
    for _, system in pairs(self.systems) do
        if system.update ~= nil then
            local systemData = self.systemData[system._name]
            systemData.age = systemData.age - 1
            if systemData.age <= 0 then
                systemData.age = systemData.updateInterval
                system:update(dt)
            end
        end
    end
end

function Engine:tearDown()
    for _, system in pairs(self.systems) do
        if system.tearDown ~= nil then
            system:tearDown()
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
