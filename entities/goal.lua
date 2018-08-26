local Object = require('entities.object')
local Goal = Class{__name = 'Goal', __includes = {Object}}

local DoorGraphic = love.graphics.newImage('assets/images/door.png')

function Goal.init(self, scene, x,y, w,h, r)
    Object.init(self, scene, x,y, w,h)
    self.r = r
end

function Goal.draw(self)
    love.graphics.setColor(1,1,0)
    -- self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)

end

function Goal.drawMap(self)
    love.graphics.setColor(0,0,0)
    self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)
end

return Goal