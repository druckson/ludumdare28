local Class = require "../lib/hump/class"

local Sound = Class{
    init = function(self)
        self.songs = {}
        self.currentSong = 3
    end
}

function Sound:setup(engine)
    local this = self
    self.engine = engine
    engine.messaging:register("next-song", function()
        this:nextSong()
    end)
end

function Sound:addSong(file)
    table.insert(self.songs, love.audio.newSource('assets/audio/'..file))
end

function Sound:nextSong(file)
    self:stop()
    self.currentSong = self.currentSong + 1
    if self.currentSong > #self.songs then
        self.currentSong = 1
    end
    self:play()
end

function Sound:stop()
    self.songs[self.currentSong]:stop()
end

function Sound:play()
    self.songs[self.currentSong]:play()
end

function Sound:update(dt)

end

return Sound
