local Class = require "../lib/hump/class"

local Graphics = Class{
    init = function(self)
        self.entities = {}
        love.graphics.setBackgroundColor(100, 100, 100)
    end
}

function Graphics:marshall(entity, data)
    local entityData = self.entities[entity];
    data.graphics = {
        width = entity.graphics.width,
        height = entity.graphics.image,
        image = entity.graphics.imagePath
    }
end

function Graphics:unmarshall(entity, data)
    local entityData = self.entities[entity];
    entityData.graphics = {
        width = data.width,
        height = data.height,
        imagePath = data.image,
        image = love.graphics.newImage("assets/images/"..data.image)
    }

    entityData.graphics.image:setFilter("nearest", "nearest", 0)
end

function Graphics:addEntity(entity, entityData, data)
    self.entities[entity] = entityData
    self:unmarshall(entity, data)
end

function Graphics:removeEntity(entity)
    self.entities[entity] = nil
end

function Graphics:draw()
    love.graphics.push()
    love.graphics.scale(5)
    for _, entity in pairs(self.entities) do
        love.graphics.draw(entity.graphics.image, entity.transform.position:unpack())
    end
    love.graphics.pop()
end

return Graphics
