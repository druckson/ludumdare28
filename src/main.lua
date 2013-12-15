local Engine = require "engine"
local MapLoader = require "maploader"
local Graphics = require "systems/graphics"
local Physics = require "systems/physics"
local ClientNetworking = require "systems/client-networking"
local ServerNetworking = require "systems/server-networking"
local Sound = require "systems/sound"
local Input = require "systems/input"
local Messaging = require "utils/messaging"

local input = Input()
local messaging = Messaging()
local engine = Engine(messaging)
local mapLoader = MapLoader(engine)

function love.load(args)

    if args[2] == nil then
        local clientNetworking = ClientNetworking()
        local physics = Physics()
        local graphics = Graphics()
        local sound = Sound()

        engine:addSystem("input", input)
        engine:addSystem("networking", clientNetworking, 1)
        engine:addSystem("physics", physics)
        engine:addSystem("graphics", graphics)
        engine:addSystem("sound", sound)

        --mapLoader:loadMap("level1")
        --engine:setPlayer(1)

        --clientNetworking:connect("65.100.3.69")

        engine.messaging:register("connect", function(ip)
            clientNetworking:connect(ip)
        end)
    else
        local serverNetworking = ServerNetworking()
        local physics = Physics()
        engine:addSystem("physics", physics)
        engine:addSystem("networking", serverNetworking, 1)
        mapLoader:loadMap("level1")
    end
end

function love.mousepressed(...)
    input:mousepressed(...)
end

function love.mousereleased(...)
    input:mousereleased(...)
end

function love.keypressed(...)
    input:keypressed(...)
end

function love.keyreleased(...)
    input:keyreleased(...)
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
