local Class = require "lib/hump/class"
require "lib/frames"

local STATE_PREGAME = 0
local STATE_GAMEPLAY = 1
local STATE_TYPING = 2

local Input = Class{
    init = function(self)
        self.currentSong = 3
        self.state = STATE_TYPING
        self.typeBuffer = ''
    end
}

function Input:setup(engine)
    self.engine = engine
end

function Input:setPlayer(entity, player)
    self.playerEntity = entity
    self.player = player
end

function Input:keypressed(key, repeating)
    if self.state == STATE_TYPING then
        love.keyboard.setKeyRepeat(true)
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
        love.keyboard.setKeyRepeat(false)
        if key == 'q' then
            self.engine:tearDown()
            love.event.quit()
        elseif key == 'n' then
            self.engine.messaging:emit("next-song")
        elseif key == 'return' then
            
        elseif key == 'f' then
            self.engine.messaging:emit("fullscreen")
        elseif key == 'w' then
            if self.playerEntity then
                self.engine.messaging:emit("jump", self.playerEntity)
            end
        elseif key == ' ' then
            if self.playerEntity then
                self.engine.messaging:emit("shoot", self.playerEntity, 1)
            end
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
    if self.player and self.state == STATE_GAMEPLAY then
        local mx = 0
        local my = 0

        if love.keyboard.isDown('a') then
            mx = mx + 1
        end
        if love.keyboard.isDown('d') then
            mx = mx - 1
        end
    
        self.engine.messaging:emit("move", mx, my, dt)
    end
end

return Input
