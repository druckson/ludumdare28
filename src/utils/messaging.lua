local Class = require "lib/hump/class"

local Messaging = Class{
    init = function(self)
        self.outbox = {}
        self.messageHandlers = {}
        self.globalHandlers = {}
    end
}

function Messaging:addMessages(messages)
    for _, message in pairs(messages) do
        table.insert(self.outbox, message)
    end
end

function Messaging:registerGlobal(callback)
    table.insert(self.globalHandlers, callback)
end

function Messaging:register(message, callback)
    if self.messageHandlers[message] == nil then
        self.messageHandlers[message] = {}
    end
    table.insert(self.messageHandlers[message], callback)
end

function Messaging:emit(message, ...)
    local messaging = self
    if self.messageHandlers[message] then
        table.insert(self.outbox, {
            message = message,
            args = {...}
        })
    end
end

function Messaging:flush()
    for _, callback in pairs(self.globalHandlers) do
        callback(self.outbox)
    end

    while #self.outbox > 0 do
        local item = table.remove(self.outbox, 1)
        for _, callback in pairs(self.messageHandlers[item.message]) do
            callback(unpack(item.args))
        end
    end
end

return Messaging
