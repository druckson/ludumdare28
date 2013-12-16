local Class = require "../lib/hump/class"
local vector = require "../lib/hump/vector"
local PrettyPrint = require "../lib/lua-pretty-print/PrettyPrint"
require "lib/json"

local Physics = Class{
    init = function(self, worldScale)
        self.entities = {}
        self.worldScale = worldScale or 1
        self.world = love.physics.newWorld(0, 0, true)
        love.physics.setMeter(self.worldScale)
        --self.world:setGravity(0, 1)
    end
}

function newShape(data)
    if data.type == "rect" then
        return love.physics.newRectangleShape(data.width, data.height)
    end
end

function Physics:setup(engine)
    local this = self
    self.engine = engine
    self.engine.messaging:register("move", function(x, y, dt)
        if this.player then
            this.player.physics.body:applyForce(x, y)
        end
    end)
    self.engine.messaging:register("player-motion", function(entity, x, y, dt)
        this.entities[entity].physics.body:applyForce(x, y)
    end)
end

function Physics:setPlayer(entity, player)
    self.player = player
end

function Physics:predict(entity, data, rtt)
    local entityData = self.entities[entity]
    if entityData then
        local serverPosition = vector.new(data[1], data[2])
        local serverRotation = data[3]
        local serverVelocity = vector.new(data[4], data[5])
        local serverAngularVelocity = data[6]
        local predictedPosition = serverPosition + serverVelocity * rtt
        local predictedAngle = serverRotation + serverAngularVelocity * rtt

        local velocityDirection = predictedPosition - vector.new(entityData.physics.body:getPosition())
        local angularVelocity = predictedAngle - entityData.physics.body:getAngle()

        --entityData.physics.body:setLinearVelocity((velocityDirection:normalized() * serverVelocity:len()):unpack())
        --entityData.physics.body:setAngularVelocity((velocityDirection:normalized() * serverVelocity:len()):unpack())

        entityData.physics.body:setLinearVelocity(serverVelocity:unpack())
        entityData.physics.body:setAngularVelocity(angularVelocity)
    end
end

function Physics:marshall(entity, data)
    local entityData = self.entities[entity]

    if entityData then
        if not data.physics then
            data.physics = {}
        end
        data.physics.velocity = {entityData.physics.body:getLinearVelocity()}
    end
    --data.physics = {
    --    shapes = entityData.physics.shapes
    --}
end

function Physics:unmarshall(entity, data)
    local entityData = self.entities[entity]

    if not entityData.physics then
        entityData.physics = {}
        local body = love.physics.newBody(self.world,
            entityData.transform.position.x,
            entityData.transform.position.y, data.type)

        entityData.physics.body = body

        if data.velocity then
            body:setLinearVelocity(unpack(data.velocity))
        end

        body:setLinearDamping(0.9)

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
