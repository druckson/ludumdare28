require "enet"
local mp = require "lib/messagepack"
local Class = require "../../lib/hump/class"

local Channel = Class{
    init = function(self, host, peer)
        self.host = host
        self.peer = peer
    end
}

function Channel:send(message, data)
    local output = mp.pack(data)
end

function Channel:receive(callback)

end

return Channel
