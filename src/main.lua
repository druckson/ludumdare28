local Engine = require "engine"
local MapLoader = require "maploader"
local Graphics = require "systems/graphics"
local Physics = require "systems/physics"
local Network = require "systems/network"
local Sound = require "systems/sound"

local engine = Engine()

local graphics = Graphics()
local network = Network()
local physics = Physics()
local sound = Sound()

local mapLoader = MapLoader(engine)
function love.load()
    sound:addSong('songs/aztek.mp3')
    sound:addSong('songs/credit.mp3')
    sound:addSong('songs/spastiche.mp3')
    --sound:play()

    engine:addSystem("graphics", graphics)
    engine:addSystem("network", network)
    engine:addSystem("physics", physics)
    engine:addSystem("sound", sound)

    mapLoader:loadMap("level1")
end

function love.keypressed(key, repeating)
    if key == 'q' then
        love.event.quit()
    end
    if key == 'a' then
        sound:nextSong()
    end
end

function love.update(dt)
    engine:update(dt)
end

function love.draw()
    engine:draw()
end
