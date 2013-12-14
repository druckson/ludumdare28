require "enet"
local Class = require "lib/hump/class"
local mp = require "lib/messagepack"

local ClientNetworking = Class{
    init = function(self, server_ip)
        print(server_ip)
        self.host = enet.host_create()
        self.server = self.host:connect(server_ip..":12345")
    end
}

function ClientNetworking:setup(engine)
    self.engine = engine
end

function ClientNetworking:send()
    
end

function ClientNetworking:addEntity(entity, entityData, data)
    
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
                self.server:send("Hello")
            elseif event.type == "receive" then
                for entity, entityData in pairs(mp.unpack(event.data)) do
                    self.engine:unmarshall(entity, entityData)
                end
            end
        end
    end
end

return ClientNetworking
