local Engine = require "engine"
local MapLoader = require "maploader"
local Graphics = require "systems/graphics"
local Network = require "systems/graphics"

local engine = Engine()

local graphics = Graphics()
local network = Network()
local mapLoader = MapLoader(engine)
function love.load()
    engine:addSystem("graphics", graphics)
    engine:addSystem("network", network)
    mapLoader:loadMap("level1")
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
