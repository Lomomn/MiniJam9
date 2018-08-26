local Vector = require('lib.hump.vector')

local Object = require('entities.object')
local Player = Class{__name = 'Player', __includes = {Object}}

local PlayerGraphic = love.graphics.newImage('assets/images/guy.png')

function Player.init(self, scene, x,y, w,h)
    Object.init(self, scene, x,y, w,h)
    self.speed = 40
    self.dir = math.pi*1.5 -- Up
    self.vel = Vector(self.speed,0)
end


function Player.update(self, dt)
    local left, right = love.keyboard.isDown(shared.left, 'left'),  love.keyboard.isDown(shared.right, 'right')
    
    if not left or not right then
        if left then
            self.dir = (self.dir - (math.pi/2)*dt) % (math.pi*2)
        elseif right then
            self.dir = (self.dir + (math.pi/2)*dt) % (math.pi*2)
        end
        local vel = self.vel:rotated(self.dir) * dt
        self.bounds['hitbox']:move(vel.x, vel.y)
        self.pos.x, self.pos.y = self.bounds['hitbox']:center()
    end
        

end


function Player.draw(self)
    -- self.bounds['hitbox']:draw('fill')

    local x,y = self.bounds['hitbox']:center()
    love.graphics.draw(PlayerGraphic, x,y, self.dir+math.pi/2, 1,1, self.w, self.h)
end

function Player.drawMap(self)
    self.bounds['hitbox']:draw('fill')
end

return Player