local Class = require "../lib/hump/class"
local vector = require "../lib/hump/vector"
local PrettyPrint = require "../lib/lua-pretty-print/PrettyPrint"

local Physics = Class{
    init = function(self, worldScale)
        self.entities = {}
        self.worldScale = worldScale or 10
        self.world = love.physics.newWorld(0, 0, true)
        love.physics.setMeter(self.worldScale)
        self.world:setGravity(0, 1)
    end
}

function newShape(data)
    if data.type == "rect" then
        return love.physics.newRectangleShape(data.width, data.height)
    end
end

function Physics:marshall(entity, data)
    local entityData = self.entities[entity]
    data.physics = {
        velocity = {entityData.physics.body:getLinearVelocity()},
        shapes = entityData.physics.shapes
    }
end

function Physics:unmarshall(entity, data)
    local entityData = self.entities[entity]
    local body = love.physics.newBody(self.world, 
        entityData.transform.position.x,
        entityData.transform.position.y, data.type)

    entityData.physics = {
        body = body,
        shapes = data.shapes
    }

    for _, shape in pairs(data.shapes) do
        local fixture = love.physics.newFixture(entityData.physics.body, newShape(shape), data.density or 1)
    end

    if data.velocity then
        body:setLinearVelocity(unpack(data.velocity))
    end
end

function Physics:addEntity(entity, entityData, data)
    self.entities[entity] = entityData
    self:unmarshall(entity, data)
end

function Physics:update(dt)
    self.world:update(dt)

    for _, entity in pairs(self.entities) do
        entity.transform.position = vector.new(entity.physics.body:getPosition())
        entity.transform.rotation = entity.physics.body:getAngle()
    end
end

return Physics
