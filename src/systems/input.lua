local Class = require "lib/hump/class"
require "lib/frames"

local STATE_PREGAME = 0
local STATE_GAMEPLAY = 1
local STATE_TYPING = 2

local Input = Class{
    init = function(self)
        self.currentSong = 3
        self.speed = 20
        self.state = STATE_TYPING
        self.typeBuffer = ''
    end
}

function Input:setup(engine)
    self.engine = engine
end

function Input:setPlayer(entity, player)
    self.player = player
end

function Input:keypressed(key, repeating)
    if self.state == STATE_TYPING then
        if key == 'return' then

            if string.sub(self.typeBuffer, 0, 7) == "connect" then
                local address = string.sub(self.typeBuffer, 9)
                print(address)
                self.engine.messaging:emit("connect", address)
                self.state = STATE_GAMEPLAY
            end

            self.typeBuffer = ''
        elseif key == 'backspace' then
            self.typeBuffer = string.sub(self.typeBuffer, 0, string.len(self.typeBuffer)-1)
        else
            self.typeBuffer = self.typeBuffer..key
        end
        self.engine.messaging:emit("type-buffer", self.typeBuffer)
    elseif self.state == STATE_GAMEPLAY then
        if key == 'q' then
            love.event.quit()
        elseif key == 'n' then
            self.engine.messaging:emit("next-song")
        elseif key == 'return' then
            
        end
    end
    loveframes.keypressed(key, repeating)
end

function Input:keyreleased(key)
    loveframes.keyreleased(key, repeating)
end

function Input:mousepressed(...)
    loveframes.mousepressed(...)
end

function Input:mousereleased(...)
    loveframes.mousereleased(...)
end

function Input:update(dt)
    if self.player then
        local mx = 0
        local my = 0
        if love.keyboard.isDown('w') then
            my = my - self.speed
        end
        if love.keyboard.isDown('s') then
            my = my + self.speed
        end
        if love.keyboard.isDown('a') then
            mx = mx - self.speed
        end
        if love.keyboard.isDown('d') then
            mx = mx + self.speed
        end
    
        self.engine.messaging:emit("move", mx, my, dt)
    end
end

return Input
