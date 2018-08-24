local Vector = require('lib.hump.vector')

local Object = require('entities.object')
local Player = Class{__name = 'Player', __includes = {Object}}

function Player.init(self, scene, x,y, w,h)
    Object.init(self, scene, x,y, w,h)
    self.speed = 40
    self.dir = -math.pi/2 -- Up
    self.vel = Vector(self.speed,0)
end


function Player.update(self, dt)
    if love.keyboard.isDown(shared.left) then
        self.dir = self.dir - math.pi*dt
    elseif love.keyboard.isDown(shared.right) then
        self.dir = self.dir + math.pi*dt
    end


    local vel = self.vel:rotated(self.dir) * dt
    self.bounds['hitbox']:move(vel.x, vel.y)
    self.pos.x, self.pos.y = self.bounds['hitbox']:center()
end


function Player.draw(self)
    self.bounds['hitbox']:draw('fill')
end

return Player