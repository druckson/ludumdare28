local Class = require "lib/hump/class"
require "lib/frames"

local Control = Class{
    init = function(self)
        self.currentSong = 3
        self.state = STATE_TYPING
        self.typeBuffer = ''
    end
}

function Control:setup(engine)
    self.engine = engine
end

function Control:setPlayer(entity, player)
    self.player = player
end

function Control:update(dt)
end

return Control
