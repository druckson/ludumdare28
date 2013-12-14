require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"
require "lib/json"

local ClientNetworking = Class{
    init = function(self, server_ip)
        self.host = enet.host_create()
        self.server = self.host:connect(server_ip..":12345")
        self.messages = {}
        self.entities = {}
    end
}

function ClientNetworking:setup(engine)
    local this = self
    self.engine = engine
    self.engine.messaging:registerGlobal(function(messages)
        if #messages > 0 then
            this.server:send(mp.pack({
                messages = messages
            }))
        end
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
            elseif event.type == "receive" then
                print("Got Message")
                print(event.data)
                local data = mp.unpack(event.data)
                if data.sync then
                    for entity, entityData in pairs(data.sync) do
                        print(entityData)
                        print(json.encode(entityData))
                        self.engine:unmarshall(entity, entityData)
                    end
                end

                if data.clientID then
                    self.clientID = data.clientID
                end

                if data.messages then
                    self.engine.messaging:addMessages(data.messages)
                end
            end
        end
    end
end

return ClientNetworking
