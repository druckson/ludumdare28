local Class = require "../lib/hump/class"
local vector = require "../lib/hump/vector"
local PrettyPrint = require "../lib/lua-pretty-print/PrettyPrint"

local Physics = Class{
    init = function(self, worldScale)
        self.entities = {}
        self.worldScale = worldScale or 10
        self.world = love.physics.newWorld(0, 0, true)
        love.physics.setMeter(self.worldScale)
        self.world:setGravity(0, 10)
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

    if not entityData.physics then
        entityData.physics = {}
        entityData.physics.body = love.physics.newBody(self.world,
            entityData.transform.position.x,
            entityData.transform.position.y, data.type)

        if data.shapes then
            for _, shape in pairs(data.shapes) do
                local fixture = love.physics.newFixture(entityData.physics.body, newShape(shape), data.density or 1)
                fixture:setRestitution(0.3)
            end
        end
    else
        --entityData.physics.body:setPosition(
        --    entityData.transform.position.x,
        --    entityData.transform.position.y)
    end
            
    entityData.physics.body:setAngle(entityData.transform.rotation)

    if data.velocity then
        entityData.physics.body:setLinearVelocity(unpack(data.velocity))
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
