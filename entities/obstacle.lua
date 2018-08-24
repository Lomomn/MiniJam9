local Object = require('entities.object')
local Obstacle = Class{__name = 'Obstacle', __includes = {Object}}

function Obstacle.init(self, scene, x,y, w,h)
    Object.init(self, scene, x,y, w,h)
end

function Obstacle.draw(self)
    love.graphics.setColor(1,0,0)
    self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)
end

return Obstacle