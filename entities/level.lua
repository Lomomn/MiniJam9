local Level = Class{__name = 'Level'}

local COL = require('lib.COL.col')
local Player = require('entities.player')
local Obstacle = require('entities.obstacle')
local Goal = require('entities.goal')
local List = require('lib.loveHelper.list')
local Camera = require('lib.hump.camera')

local MapGraphic = love.graphics.newImage('assets/images/map.png')
local TargetGraphic = love.graphics.newImage('assets/images/target.png')
local StartGraphic = love.graphics.newImage('assets/images/start.png')
local FloorGraphic = love.graphics.newImage('assets/images/floor.png')
FloorGraphic:setWrap('repeat', 'repeat')


    
function Level.init(self, die, win)
    self.die, self.win = die, win
    self.col = COL()
    self.obstacles = List()
    self.camera = Camera(0,0)
    self.resize(self, love.graphics.getDimensions())
    self.viewingMap = true
    self.mapViewingTime = 1
    self.mapCanvas = love.graphics.newCanvas(256,256)
    self.goal = nil
    
    self.maxW, self.maxH = 440, 256
    self.floorMesh = love.graphics.newMesh({
        {0,0,  0,0,  1,1,1,1},
        {self.maxW,0,  self.maxW/64,0,  1,1,1,1},
        {self.maxW,self.maxH,  self.maxW/64,self.maxH/64,  1,1,1,1},
        {0,self.maxH,  0,self.maxH/64,  1,1,1,1},
    }, 'fan')
    self.floorMesh:setTexture(FloorGraphic)

    local x, y  = 48, 0
    local ow,oh = 64, 64

    local genStyles = {
        [1] = function(args)
            -- Bottom up, random size
            local h = self.maxH - love.math.random(oh/2, oh*2)
            local ob = Obstacle(self.col, x, self.maxH-h, ow, h)
            self.obstacles:register(ob)

            if not self.goal then
                if args.last or love.math.random(1,3)==1 then
                    -- Add the end goal
                    self.goal = Goal(self.col, 
                        x-2,
                        love.math.random(self.maxH-h, self.maxH-oh),
                        ow/2,
                        oh/2
                    )
                end
            end
        end,
        [2] = function(args)
            -- Top down, random size
            local h = 0
            if args.first then
                h = self.maxH - love.math.random(oh, oh*2)
            else
                h = self.maxH - love.math.random(oh/2, oh*2)
            end
            
            local ob = Obstacle(self.col, x, 0, ow, h)

            if not self.goal then
                if args.last or love.math.random(1,3)==1 then
                    -- Add the end goal
                    self.goal = Goal(self.col, 
                        x-2,
                        love.math.random(0, h-oh/2),
                        ow/2,
                        oh/2
                    )
                end
            end

            self.obstacles:register(ob)       
        end,
        [3] = function(args)
            -- Gap
            local g = love.math.random(oh, self.maxH-oh) -- Where the gap starts

            local f = Obstacle(self.col, x,0, ow, g-oh/2)
            local s = Obstacle(self.col, x,g+oh/2, ow, self.maxH-g-oh/2)
            self.obstacles:register(f)
            self.obstacles:register(s)

            if not self.goal then
                if args.last or love.math.random(1,3)==1 then
                    -- Add the end goal
                    self.goal = Goal(self.col, 
                        x-2,
                        love.math.random(0, self.maxH-g-oh/2),
                        ow/2,
                        oh/2
                    )
                end
            end
        end
    }

    -- Add the outer level bounds
    self.obstacles:register(Obstacle(self.col, -ow, -oh, ow, self.maxH+oh*2))
    self.obstacles:register(Obstacle(self.col, self.maxW, -oh, ow, self.maxH+oh*2))
    self.obstacles:register(Obstacle(self.col, -ow, -oh, self.maxW+oh*2, oh))
    self.obstacles:register(Obstacle(self.col, -ow, self.maxH, self.maxW+oh*2, oh))

    -- Add the columns of classrooms
    local current, columns = 0, 3
    while current < columns do
        genStyles[love.math.random(1,3)]({
            first = current == 0 and true or false,
            last  = current == columns-1
        })
        x = x + ow * 2

        current = current + 1
    end

    self.player = Player(self.col, 16, self.maxH-32, 16, 16)

    -- Draw the map to the canvas which is shown at the beginning of the level
    self.camera.scale = love.graphics.getHeight()/self.maxW
    love.graphics.setCanvas(self.mapCanvas)
    love.graphics.clear(0,0,0,1)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(MapGraphic, 0,0)
        
        self.camera:lookAt(self.maxW/2, self.maxH/2)
        self.camera:zoom(0.7)
        self.camera:rotate(love.math.random(-8,8)*(math.pi/64))
        self.camera:attach()
        
        
        local px,py = self.player.bounds['hitbox']:bbox()
        love.graphics.draw(StartGraphic, px, py)
        
        for object,_ in pairs(self.obstacles.alive) do
            object:drawMap()
        end
        
        px,py = self.goal.bounds['hitbox']:bbox()
        love.graphics.draw(TargetGraphic, px, py)

        self.camera:detach()
    love.graphics.setCanvas()

    Timer.after(self.mapViewingTime, function()
        self.viewingMap = false
        self.camera:rotateTo(0) -- Reset rotation
        self:resize(love.graphics.getDimensions()) -- Going to change scale and stuff, reset back
    end)
end


function Level:draw()
    -- Black box vars which are also used to draw the max with offsets    
    local w,h = love.graphics.getDimensions()
    local size = w>h and w-h or 0 

    if self.viewingMap then
        love.graphics.draw(self.mapCanvas, size/2,0,0,self.scale, self.scale)
    else
        love.graphics.clear(1,1,1,1)
        -- Draw the normal view of the level for the player to navigate
        self.camera:lookAt(self.player.pos:unpack())
        self.camera.rot = -self.player.dir-math.pi/2
        
        self.camera:attach()
        love.graphics.draw(self.floorMesh, 0,0)
        
        self.player:draw()
        self.obstacles:draw()
        self.goal:draw()
            
        self.camera:detach()
        
        love.graphics.setColor(1,1,1)
        love.graphics.print(self.player.dir, 0,0)
        
        if w~=h then
            -- Only black box when w>h because zooming will make h>w unplayable :)
            love.graphics.setColor(0,0,0)
            
            -- Add black boxes to sides
            love.graphics.rectangle('fill', 0,0, size/2, h)
            love.graphics.rectangle('fill', w-size/2,0, size/2, h)
        end
        love.graphics.setColor(1,1,1)
    end
end


function Level.update(self, dt)
    if not self.viewingMap then
        -- Only allow player controls when the map isn't being viewed
        self.player:update(dt)

        self.col:collisions(self.player, self.obstacles.alive, function(player, obstacle) 
            self.die()
        end)
        -- Lazy table collision, I should alter COL to allow two objects in flixel format
        self.col:collisions(self.player, {[self.goal]=true}, function(player, goal) 
            self.win()
        end)
    end
end


function Level.resize(self, w, h)
    self.scale = h/shared.origH
    self.camera.scale = self.scale
end

return Level

