local Class = require "lib/hump/class"
require "lib/frames"

local Trees = Class{
    init = function(self)
        self.trees = {}   
        self:addTree("tree1.png")
        self:addTree("tree2.png")
    end
}

function Trees:addTree(treeFile)
    local image = love.graphics.newImage("assets/images/"..treeFile)
    image:setFilter("nearest", "nearest", 1)
    table.insert(self.trees, image)
end

function Trees:draw(scale, x1, x2)
    for x = x1, x2, 1 do
        if #self.trees > 0 then
            local seed = (x/0.3 % 10000)
            math.randomseed(seed)
            local tree = math.random(1, #self.trees)
            local image = self.trees[tree]
            

            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.push()
            love.graphics.translate(math.random()*0.7+x, 0)

            if math.random() > 0.5 then
                love.graphics.scale(-1, 1)
            end

            local s = scale * (0.8 + math.random()*0.4)
            love.graphics.draw(image,
                -s/2, -s, 0,
                s/image:getWidth(), 
                s/image:getHeight())
            love.graphics.pop()
        end
    end
end

return Trees
