local Level = Class{__name = 'Level'}

local COL = require('lib.COL.col')
local Player = require('entities.player')
local Obstacle = require('entities.obstacle')
local List = require('lib.loveHelper.list')
local Camera = require('lib.hump.camera')


function Level.init(self)
    self.col = COL()
    self.obstacles = List()
    self.camera = Camera(0,0)


    self.maxW, self.maxH = 440, 256

    local x, y  = 48, 0
    local ow,oh = 64, 64

    local genStyles = {
        [1] = function(first)
            -- Bottom up, random size
            local h = self.maxH - love.math.random(oh/2, oh*2)
            local ob = Obstacle(self.col, x, self.maxH-h, ow, h)
            self.obstacles:register(ob)
        end,
        [2] = function(first)
            -- Top down, random size
            local h = 0
            if first then
                h = self.maxH - love.math.random(oh, oh*2)
            else
                h = self.maxH - love.math.random(oh/2, oh*2)
            end
            local ob = Obstacle(self.col, x, 0, ow, h)
            self.obstacles:register(ob)       
        end,
        [3] = function(first)
            -- Gap
            local g = love.math.random(oh, self.maxH-oh)

            local f = Obstacle(self.col, x,0, ow, g-oh/2)
            local s = Obstacle(self.col, x,g+oh/2, ow, self.maxH-g-oh/2)
            self.obstacles:register(f)
            self.obstacles:register(s)
        end
    }
    
    local current, columns = 0, 4
    while current < columns do
        genStyles[love.math.random(1,3)](current == 0 and true or false)
        x = x + ow * 1.75

        current = current + 1
    end

    self.player = Player(self.col, 16,self.maxH-32, 16,16)
end


function Level:drawMap()
    -- Draw the map view of the level
end


function Level:draw()
    -- Draw the normal view of the level for the player to navigate
    self.camera:lookAt(self.player.pos:unpack())
    self.camera.rot = -self.player.dir-math.pi/2
    
    self.camera:attach()
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle('line', 0,0, self.maxW, self.maxH)
    love.graphics.setColor(1,1,1)
    
    self.player:draw()
    self.obstacles:draw()
    self.camera:detach()

    love.graphics.print(self.player.dir, 0,0)
end


function Level.update(self, dt)
    self.player:update(dt)

    self.col:collisions(self.player, self.obstacles.alive, function(player, obstacle) 
        shared.changeState = true
    end)
end

return Level

