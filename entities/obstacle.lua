local Object = require('entities.object')
local Obstacle = Class{__name = 'Obstacle', __includes = {Object}}

local WallGraphic = love.graphics.newImage('assets/images/wall.png')
local DoorGraphic = love.graphics.newImage('assets/images/door.png')
WallGraphic:setWrap('repeat', 'repeat')

function Obstacle.init(self, scene, x,y, w,h, hasDoors)
    Object.init(self, scene, x,y, w,h)
    self.hasDoors = hasDoors==nil and true or false

    self.doors = {}
    if self.hasDoors then
        for i=0, h>w and h/64 or w/64 do
            if h>w then
                for i=0, math.floor(h/64)-1 do
                    table.insert(self.doors, {
                        x = x-32,
                        y = y + (64*i)+32
                    })
                    table.insert(self.doors, {
                        x = x+96,
                        y = y + (64*i)+32,
                        r = true
                    })
                end
            end
        end
    end

    self.mesh = love.graphics.newMesh({
        {0,0,  0,0,  1,1,1,1},
        {w,0,  w/64,0,  1,1,1,1},
        {w,h,  w/64,h/64,  1,1,1,1},
        {0,h,  0,h/64,  1,1,1,1},
    }, 'fan')
    self.mesh:setTexture(WallGraphic)

    return self
end

function Obstacle.draw(self)
    love.graphics.setColor(1,1,1)
    local x,y = self.bounds['hitbox']:bbox()
    love.graphics.draw(self.mesh, x,y)
    
    for _,door in pairs(self.doors) do
        love.graphics.draw(DoorGraphic, door.x, door.y, door.r and math.pi or 0)
    end
end

function Obstacle.drawMap(self)
    love.graphics.setColor(0,0,0)
    self.bounds['hitbox']:draw('fill')
    love.graphics.setColor(1,1,1)
end

return Obstacle