local Engine = require "engine"
local MapLoader = require "maploader"
local Graphics = require "systems/graphics"
local Physics = require "systems/physics"
local ClientNetworking = require "systems/client-networking"
local ServerNetworking = require "systems/server-networking"
local Sound = require "systems/sound"
local Input = require "systems/input"

local engine = Engine()
local mapLoader = MapLoader(engine)

function love.load(args)
    local physics = Physics()
    engine:addSystem("physics", physics)

    if args[2] == nil then
        local clientNetworking = ClientNetworking("localhost")
        local graphics = Graphics()
        local sound = Sound()

        sound:addSong('songs/aztek.mp3')
        sound:addSong('songs/credit.mp3')
        sound:addSong('songs/spastiche.mp3')
        sound:play()

        engine:addSystem("networking", clientNetworking)
        engine:addSystem("graphics", graphics)
        engine:addSystem("sound", sound)
    else
        local serverNetworking = ServerNetworking()
        engine:addSystem("networking", serverNetworking)
        mapLoader:loadMap("level1")
    end
end

function love.keypressed(key, repeating)
    if key == 'q' then
        love.event.quit()
    end
    if key == 'a' then
        engine.messaging:emit("next-song")
    end
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
