local Vector = require('lib.hump.vector')

local Object = require('entities.object')
local Bully = Class{__name = 'Bully', __includes = {Object}}

local BullyGraphic = love.graphics.newImage('assets/images/bully.png')

Bully.speed = 35

function Bully.init(self, scene, x,y, w,h)
    Object.init(self, scene, x,y, w,h)
    self.dir = math.pi*1.5 -- Up
    self.lastPos = self.pos:clone()
end


function Bully.update(self, dt)
    local vel = Vector(Bully.speed, 0):rotated(self.dir) * dt
    self.bounds['hitbox']:move(vel.x, vel.y)
    self.lastPos = self.pos:clone()
    self.pos.x, self.pos.y = self.bounds['hitbox']:center()
end


function Bully.draw(self)
    -- self.bounds['hitbox']:draw('fill')

    local x,y = self.bounds['hitbox']:center()
    love.graphics.draw(BullyGraphic, x,y, self.dir+math.pi/2, 1,1, self.w, self.h)
end

function Bully.drawMap(self)
    self.bounds['hitbox']:draw('fill')
end

return Bully