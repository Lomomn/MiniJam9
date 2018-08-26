local Object = require('entities.object')
local Goal = Class{__name = 'Goal', __includes = {Object}}

local DoorGraphic = love.graphics.newImage('assets/images/door.png')

function Goal.init(self, scene, x,y, w,h)
    Object.init(self, scene, x,y, w,h)
end

function Goal.draw(self)
    love.graphics.setColor(1,1,0)
    self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)

    local x,y = self.bounds['hitbox']:bbox()
    love.graphics.draw(DoorGraphic, x-self.w+2, y)
end

function Goal.drawMap(self)
    love.graphics.setColor(0,0,0)
    self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)
end

return Goal