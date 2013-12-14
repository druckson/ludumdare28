local Engine = require "engine"
local MapLoader = require "maploader"
local Graphics = require "systems/graphics"
local Physics = require "systems/physics"
local Network = require "systems/network"

local engine = Engine()

local graphics = Graphics()
local network = Network()
local physics = Physics()

local mapLoader = MapLoader(engine)
function love.load()
    engine:addSystem("graphics", graphics)
    engine:addSystem("network", network)
    engine:addSystem("physics", physics)
    mapLoader:loadMap("level1")
end

function love.keypressed(key, repeating)
    if key == 'q' then
        love.event.quit()
    end
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
