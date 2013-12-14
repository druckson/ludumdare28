local Class = require "../lib/hump/class"

local Input = Class{
    init = function(self)
        self.currentSong = 3
    end
}

function Input:setup(engine)
    self.engine = engine
end

function Input:update(dt)
    if love.keyboard.isDown('a') then
        
    end
    if love.keyboard.isDown('a') then

    end
    if love.keyboard.isDown('a') then

    end
    if love.keyboard.isDown('a') then

    end
end

return Input
