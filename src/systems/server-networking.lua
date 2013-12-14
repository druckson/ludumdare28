require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"

local ServerNetworking = Class{
    init = function(self)
        self.host = enet.host_create("0.0.0.0:12345")
        self.clients = {}
        self.entities = {}
    end
}

function ServerNetworking:setup(engine)
    self.engine = engine
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
                print("Client connected!")
                table.insert(self.clients, event.peer)
             elseif event.type == "receive" then
                print(event.data)
             end
        end
    end

    local entityTransforms = {}

    for entity, entityData in pairs(self.entities) do
        entityTransforms[entity] = self.engine:marshall(entity)
    end

    local entityData = mp.pack(entityTransforms)

    for _, client in pairs(self.clients) do
        client:send(entityData)
    end
end

return ServerNetworking
