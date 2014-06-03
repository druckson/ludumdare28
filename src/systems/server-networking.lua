require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"
require "lib/json"

local ServerNetworking = Class{
    init = function(self)
        self.host = enet.host_create("0.0.0.0:12345")
        self.nextClientID = 1
        self.clients = {}
        self.entities = {}
        self.deleted = {}
    end
}

function ServerNetworking:setup(engine)
    local this = self
    self.engine = engine
end

function ServerNetworking:addEntity(entity, entityData, data)
    self.entities[entity] = entityData;
    entityData.networking = {
        type = data.type
    }
end

function ServerNetworking:removeEntity(entity)
    table.insert(self.deleted, entity)
end

function ServerNetworking:update(dt)
    while true do
        local event = self.host:service(0)
        if (event == nil) then
            break
        else
            if event.type == "connect" then
                print("Client Connected")
                local clientID = event.peer:connect_id()

                local data1 = {
                    clientID = clientID,
                    init = {}
                }

                for entity, entityData in pairs(self.entities) do
                    data1.init[entity] = self.engine:marshall(entity)
                end

                local player = self.engine:createPlayer({
                    transform = {
                        position = {0, 0},
                        rotation = 0
                    }
                })

                local data2 = {
                    init = {}
                }
                data2.init[player] = self.engine:marshall(player)

                self.clients[clientID] = {
                    entity = player,
                    player = self.engine.entities[player],
                    peer = event.peer
                }

                data1.player = player

                self.host:broadcast(mp.pack(data2), 0, "reliable")
                event.peer:send(mp.pack(data1), 0, "reliable")
            elseif event.type == "disconnect" then
                print("Client Disconnected")
                local clientID = event.peer:connect_id()
                print(self.clients[clientID])
                if self.clients[clientID] then
                    self.engine:deleteEntity(self.clients[clientID].entity)
                end
            elseif event.type == "receive" then
                local data = mp.unpack(event.data)
                if data.messages then
                    --self.engine.messaging:addMessages(event.data.messages)
                    self.host:broadcast(mp.pack(data.messages))
                end

                if data.jump then
                    local clientID = event.peer:connect_id()
                    local entity = self.clients[clientID].entity
                    self.engine.messaging:emit("jump", entity)
                end

                if data.force then
                    local clientID = event.peer:connect_id()
                    local entity = self.clients[clientID].entity
                    self.engine.messaging:emit("player-motion", entity, unpack(data.force))
                end

                if data.sync then
                    local clientID = event.peer:connect_id()
                    if self.clients[clientID] then
                        --local body = self.clients[clientID].player.physics.body
                        --body:setPosition(data.sync[1], data.sync[2])
                        --body:setAngle(data.sync[3])
                        --body:setLinearVelocity(data.sync[4], data.sync[5])
                        --body:setAngularVelocity(data.sync[6])
                    end
                end
            end
        end
    end

    local data = {
        sync = {},
        messages = {}
    }

    for entity, entityData in pairs(self.entities) do
        if entityData.networking.type == "dynamic" then
            local x, y = entityData.physics.body:getPosition()
            local vx, vy = entityData.physics.body:getLinearVelocity()
            data.sync[entity] = {
                x,
                y,
                entityData.physics.body:getAngle(),
                vx,
                vy,
                entityData.physics.body:getAngularVelocity()
            }
        end
    end

    self.host:broadcast(mp.pack(data), 0, "unreliable")

    if #self.deleted > 0 then
        print("Deleting entities") 
        data = {
            delete = self.deleted
        }
        self.deleted = {}
        self.host:broadcast(mp.pack(data), 0, "reliable")
    end
end

return ServerNetworking
