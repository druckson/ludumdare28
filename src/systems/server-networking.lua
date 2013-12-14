require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"

local ServerNetworking = Class{
    init = function(self)
        self.host = enet.host_create("0.0.0.0:12345")
        self.nextClientID = 1
        self.clients = {}
        self.entities = {}
    end
}

function ServerNetworking:setup(engine)
    local this = self
    self.engine = engine
    self.engine.messaging:registerGlobal(function(messages)
        
    end)
end

function ServerNetworking:send()
    
end

function ServerNetworking:addEntity(entity, entityData, data)
    self.entities[entity] = entityData;
    entityData.networking = {
        type = data.type
    }
end

function ServerNetworking:removeEntity(entity)
    
end

function ServerNetworking:update(dt)
    while true do
        local event = self.host:service(0)
        if (event == nil) then
            break
        else
             if event.type == "connect" then
                local clientID = self.nextClientID
                self.nextClientID = self.nextClientID + 1
                self.clients[clientID] = event.peer
                self.engine:createEntity({
                    
                })

                local data = {
                    clientID = clientID,
                    sync = {}
                }

                for entity, entityData in pairs(self.entities) do
                    data.sync[entity] = self.engine:marshall(entity)
                end

                print("Send")
                --event.peer:send(mp.pack(data), 1, "reliable")
                event.peer:send(mp.pack(data))
             elseif event.type == "receive" then
                local data = mp.unpack(event.data)
                if data.messages then
                    --self.engine.messaging:addMessages(event.data.messages)
                    self.host:broadcast(mp.pack(data.messages))
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
            data.sync[entity] = self.engine:marshall(entity, 2, "unreliable")
        end
    end

    local mpData = mp.pack(data)

    self.host:broadcast(mpData)
end

return ServerNetworking
