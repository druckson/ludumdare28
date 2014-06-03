local Class = require "lib/hump/class"
require "lib/frames"

local Stars = Class{
    init = function(self)
        self.m = math.pow(2, 64)
        self.a = 6364136223846793005
        self.c = 1442695040888963407
    end
}

function Stars:draw(px, py, scale, x1, y1, x2, y2)
    for x = x1, x2, 1 do
        for y = y1, y2, 1 do
            local seed = 10000*(x % 10000) + (y % 10000)
            --local rand = ((self.a * seed) + self.c) % self.m
            math.randomseed(seed)
            local rand = math.random()

            if rand < 0.01 then
                love.graphics.setColor(255, 255, 255, rand*rand/(0.01*0.01) * 100)
                love.graphics.rectangle("fill",
                    px - x*scale, py - y*scale,
                    scale, scale)
            end
        end
    end
end

return Stars
