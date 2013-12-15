require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"
local vector = require "lib/hump/vector"
require "lib/json"

local ClientNetworking = Class{
    init = function(self)
        self.host = enet.host_create()
        self.messages = {}
        self.entities = {}
        self.forceAverage = vector.new(0, 0)
        self.forceTime = 0
    end
}

function ClientNetworking:connect(server_ip)
    self.server = self.host:connect(server_ip..":12345")
end

function ClientNetworking:setPlayer(entity, player)
    self.player = player
end

function ClientNetworking:setup(engine)
    local this = self
    self.engine = engine
    self.engine.messaging:register('move', function(x, y, dt)
        this.forceAverage = (this.forceAverage * this.forceTime +
                             vector.new(x, y) * dt) / (this.forceTime + dt)
        this.forceTime = this.forceTime + dt
    end)
end

function ClientNetworking:addEntity(entity, entityData, data)
    self.entities[entity] = entityData
    entityData.networking = {
        type = data.type
    }
end

function ClientNetworking:removeEntity(entity)
    
end

function ClientNetworking:update(dt)
    while true do
        local event = self.host:service(0)
        if event == nil then
            break
        else
            if event.type == "connect" then
                print("Connected!")
                self.connected = true
            elseif event.type == "receive" then
                local data = mp.unpack(event.data)

                if data.init then
                    for entity, data in pairs(data.init) do
                        self.engine:unmarshall(entity, data)
                    end
                end

                if data.sync then
                    for entity, data in pairs(data.sync) do
                        self.engine.systemsByName.physics:predict(entity, data, self.server:round_trip_time()/1000)
                        --local body = self.engine.entities[entity].physics.body
                        --body:setPosition(data[1], data[2])
                        --body:setAngle(data[3])
                        --body:setLinearVelocity(data[4], data[5])
                        --body:setAngularVelocity(data[6])
                    end
                end

                if data.clientID then
                    self.clientID = data.clientID
                end

                if data.player then
                    self.engine:setPlayer(data.player)
                end

                if data.messages then
                    self.engine.messaging:addMessages(data.messages)
                end
            end
        end
    end

    if self.connected and self.player then
        local x, y = self.player.physics.body:getPosition()
        local vx, vy = self.player.physics.body:getLinearVelocity()
        local data = {
            force = {
                self.forceAverage.x,
                self.forceAverage.y,
                self.forceTime 
            },
            sync = {
                x,
                y,
                self.player.physics.body:getAngle(),
                vx,
                vy,
                self.player.physics.body:getAngularVelocity(),
            }
        }

        self.forceAverage = vector.new(0, 0)
        self.forceTime = 0

        self.server:send(mp.pack(data), 0, "unreliable")
    end
end

return ClientNetworking
