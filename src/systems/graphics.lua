local Class = require "lib/hump/class"
require "lib/frames"

local Graphics = Class{
    init = function(self)
        self.entities = {}
        self.message = ''
        love.graphics.setFont(love.graphics.newFont("assets/fonts/electrolize.ttf", 20))
    end
}

function Graphics:setup(engine)
    local this = self
    engine.messaging:register("type-buffer", function(string)
        this.message = string
    end)
end

function Graphics:setPlayer(entity, player)
    self.player = player
end

function Graphics:marshall(entity, data)
    local entityData = self.entities[entity];

    if data.type == "rect" then
        data.graphics = {
            type = entity.graphics.type,
            width = entity.graphics.width,
            height = entity.graphics.image
        }
    elseif data.type == "image" then
        data.graphics = {
            type = entity.graphics.type,
            width = entity.graphics.width,
            height = entity.graphics.image,
            image = entity.graphics.imagePath
        }
    end
end

function Graphics:unmarshall(entity, data)
    local entityData = self.entities[entity];

    if data.type == "rect" then
        entityData.graphics = {
            type = data.type,
            width = data.width,
            height = data.height,
        }
    elseif data.type == "image" then
        entityData.graphics = {
            type = data.type,
            width = data.width,
            height = data.height,
            imagePath = data.image,
            image = love.graphics.newImage("assets/images/"..data.image)
        }
    end

    entityData.graphics.image:setFilter("nearest", "nearest", 1)
end

function Graphics:addEntity(entity, entityData, data)
    self.entities[entity] = entityData
    self:unmarshall(entity, data)
end

function Graphics:removeEntity(entity)
    self.entities[entity] = nil
end

function Graphics:update(dt)
    loveframes.update(dt)
end

function Graphics:draw()
    love.graphics.reset()
    love.graphics.setBackgroundColor(100, 100, 100)

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2,
                            love.graphics.getHeight()/2)
    love.graphics.scale(100, 100)
    if self.player then
        love.graphics.translate(
            -self.player.transform.position.x,
            -self.player.transform.position.y)
    end
    for _, entity in pairs(self.entities) do
        love.graphics.push()
        love.graphics.translate(entity.transform.position:unpack())
        love.graphics.rotate(entity.transform.rotation)

        if entity.graphics.type == "image" then
            love.graphics.draw(entity.graphics.image, 
                -entity.graphics.width/2,
                -entity.graphics.height/2,
                0,
                entity.graphics.width/entity.graphics.image:getWidth(),
                entity.graphics.height/entity.graphics.image:getHeight())
        elseif entity.graphics.type == "rect" then 
            love.graphics.rectangle(
                -entity.graphics.width/2,
                -entity.graphics.height/2,
                entity.graphics.width,
                entity.graphics.height)
        end

        love.graphics.pop()
    end
    love.graphics.pop()

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("> "..self.message, 10, 30)
    loveframes.draw()
end

return Graphics
