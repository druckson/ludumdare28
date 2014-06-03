local Class = require "lib/hump/class"
local Stars = require "utils/stars"
local Trees = require "utils/trees"
local vector = require "lib/hump/vector"
require "lib/frames"

local Graphics = Class{
    init = function(self)
        self.entities = {}
        self.message = ''
        love.graphics.setFont(love.graphics.newFont("assets/fonts/electrolize.ttf", 20))
        self.stars = Stars()
        self.trees = Trees()
        self.camera_position = vector(0, 100)
        self.fullscreen = false
    end
}

function Graphics:setup(engine)
    local this = self
    engine.messaging:register("type-buffer", function(string)
        this.message = string
    end)
    engine.messaging:register("fullscreen", function()
        self.fullscreen = not self.fullscreen
        love.window.setFullscreen(self.fullscreen)
    end)
end

function Graphics:setPlayer(entity, player)
    self.player = player
    self.camera_position.x = self.player.transform.position.x
end

function Graphics:marshall(entity, data)
    local entityData = self.entities[entity];

    if data.type == "rect" then
        data.graphics = {
            type = entity.graphics.type,
            color = entity.graphics.color,
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
            color = data.color,
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

        entityData.graphics.image:setFilter("nearest", "nearest", 1)
    end
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
    love.graphics.setBackgroundColor(1, 16, 19)

    local scale = 60

    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth()/2,
                            3*love.graphics.getHeight()/4)

    if self.player then
        local x = self.player.transform.position.x
        local y = self.player.transform.position.y

        if self.camera_position.x < (x - 3) then self.camera_position.x = x - 3 end
        if self.camera_position.x > (x + 3) then self.camera_position.x = x + 3 end
        if self.camera_position.y < (y - 5) then self.camera_position.y = y - 5 end
        if self.camera_position.y > (y + 1) then self.camera_position.y = y + 1 end

        --self.camera_position.x = x
        --self.camera_position.y = y
    end
    
    if self.player then
        local x, y = self.camera_position:unpack()
        love.graphics.push()
        local s = 4
        self.stars:draw(
            x*scale, y*scale, s,
            math.floor(x*scale/s - love.graphics.getWidth()/s/2),
            math.floor(y*scale/s - love.graphics.getHeight()/s/4), 
            math.ceil( x*scale/s + love.graphics.getWidth()/s/2), 
            math.ceil( y*scale/s + 3*love.graphics.getHeight()/s/4))
        love.graphics.pop()
        love.graphics.setColor(255, 255, 255, 255)
    end

    love.graphics.scale(scale, scale)
    love.graphics.translate(
        self.camera_position.x,
        self.camera_position.y)

    -- Render trees
    if self.player then
        local x = self.camera_position.x
        local width = love.graphics.getWidth()/scale
        --self.trees:draw(3, math.floor(x - width/2), math.ceil(x + width/2))
        self.trees:draw(6, math.floor(-x - width/2), math.ceil(-x + width/2))
    end

    -- Render entities
    for _, entity in pairs(self.entities) do
        love.graphics.push()
        local x, y = entity.transform.position:unpack()
        love.graphics.translate(-x, -y)
        love.graphics.rotate(entity.transform.rotation)

        if entity.graphics.flip then
            love.graphics.scale(-1, 1)
        end
        
        if entity.graphics.type == "image" then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(entity.graphics.image, 
                -entity.graphics.width/2,
                -entity.graphics.height/2,
                0,
                entity.graphics.width/entity.graphics.image:getWidth(),
                entity.graphics.height/entity.graphics.image:getHeight())
        elseif entity.graphics.type == "rect" then 
            love.graphics.setColor(unpack(entity.graphics.color))
            love.graphics.rectangle("fill",
                -entity.graphics.width/2,
                -entity.graphics.height/2,
                entity.graphics.width,
                entity.graphics.height)
        end

        love.graphics.pop()
    end
    love.graphics.pop()


    love.graphics.setColor(100, 100, 100)
    love.graphics.print("FPS: "..love.timer.getFPS(), 10, 10)
    love.graphics.print("> "..self.message, 10, 30)
    loveframes.draw()
end

return Graphics
