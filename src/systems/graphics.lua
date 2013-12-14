local Class = require "../lib/hump/class"

local Graphics = Class{
    init = function(self)
        self.entities = {}
        love.graphics.setBackgroundColor(100, 100, 100)
    end
}

function Graphics:addEntity(entity, entityData, data)
    self.entities[entity] = entityData

    entityData.graphics = {
        width = data.width,
        height = data.height,
        image = love.graphics.newImage("assets/images/"..data.image)
    }
end

function Graphics:removeEntity(entity)
    self.entities[entity] = nil
end

function Graphics:draw()
    --love.graphics.clear()
    for _, entity in pairs(self.entities) do
        love.graphics.draw(entity.graphics.image, 0, 0)
    end
end

return Graphics
