local Class = require "../lib/hump/class"
require "lib/json"

local Damage = Class{
    init = function(self)
        self.entities = {}
    end
}

function Damage:setup(engine)
    local this = self
    self.engine = engine
    engine.messaging:register("apply-damage", function(entity, amount)
        local damage = this.entities[entity].damage
        damage.health = math.max(damage.health - amount, 0)
    end)
end

function Damage:addEntity(entity, entityData, data)
    entityData.damage = {
        max_health: data.max_health,
        health: data.max_health
    }
    self.entities[entity] = entityData

function Damage:update(dt)

end

return Damage
