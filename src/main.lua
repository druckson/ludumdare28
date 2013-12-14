local Engine = require "engine"


local engine = Engine()

local graphics = Graphics()
--local graphics = Graphics()
function love.load()
    engine:addSystem("graphics", graphics)
end

function love.update(dt)
end

function love.draw()
end
