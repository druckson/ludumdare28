local Class = require "../lib/hump/class"
local vector = require "../lib/hump/vector"
local PrettyPrint = require "../lib/lua-pretty-print/PrettyPrint"

local Physics = Class{
    init = function(self)
        self.entities = {}
    end
}

function Physics:addEntity(entity, entityData, data)
    self.entities[entity] = entityData

    entityData.physics = {
        velocity = vector.new(10, 0)
    }
end

function Physics:update(dt)
    for _, entity in pairs(self.entities) do
        entity.physics.velocity = entity.physics.velocity + (vector.new(0, 1) * dt)
        entity.position = entity.position + (entity.physics.velocity * dt)
    end
end

return Physics
