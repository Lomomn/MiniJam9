local Level = Class{__name = 'Level'}

local COL = require('lib.COL.col')
local Player = require('entities.player')
local Bully = require('entities.bully')
local Obstacle = require('entities.obstacle')
local Goal = require('entities.goal')
local List = require('lib.loveHelper.list')
local Camera = require('lib.hump.camera')
local Shapes = require('lib.HC.shapes')

local MapGraphic = love.graphics.newImage('assets/images/map.png')
local TargetGraphic = love.graphics.newImage('assets/images/target.png')
local StartGraphic = love.graphics.newImage('assets/images/start.png')
local FloorGraphic = love.graphics.newImage('assets/images/floor.png')
FloorGraphic:setWrap('repeat', 'repeat')


function Level.init(self, die, win, time)
    self.die, self.win = die, win
    self.col = COL()
    self.obstacles = List()
    self.camera = Camera(0,0)
    self.resize(self, love.graphics.getDimensions())
    self.viewingMap = true
    self.mapViewingTime = time
    self.mapCanvas = love.graphics.newCanvas(256,256)
    self.goal = nil
    
    self.maxW, self.maxH = 456, 256
    self.floorMesh = love.graphics.newMesh({
        {0,0,  0,0,  1,1,1,1},
        {self.maxW,0,  self.maxW/64,0,  1,1,1,1},
        {self.maxW,self.maxH,  self.maxW/64,self.maxH/64,  1,1,1,1},
        {0,self.maxH,  0,self.maxH/64,  1,1,1,1},
    }, 'fan')
    self.floorMesh:setTexture(FloorGraphic)

    -- Spawn the player
    local ySpawn = 0 -- Alters first column spawn so that the player isn't trapped on spawn. 0 bottom, 1 top
    local xSpawn = 0 -- 0 left, 1 right
    local spawns = {
        [1] = function()
            -- Bottom left
            self.player = Player(self.col, 16, self.maxH-32, 16, 16)
            self.player.dir = math.pi*1.5 -- Up
        end,
        [2] = function()
            -- Top left
            self.player = Player(self.col, 16, 32, 16, 16)
            self.player.dir = math.pi/2 -- Down
            ySpawn = 1
        end,
        [3] = function()
            -- Bottom right
            self.player = Player(self.col, self.maxW-32, self.maxH-32, 16, 16)
            self.player.dir = math.pi*1.5 -- Up
            xSpawn = 1
        end,
        [4] = function()
            -- Top right
            self.player = Player(self.col, self.maxW-32, 16, 16, 16)
            self.player.dir = math.pi/2 -- Down
            ySpawn = 1
            xSpawn = 1
        end
    }
    spawns[love.math.random(1,4)]()

    local x, y  = 64, 0
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
                    local flip = xSpawn==0 and true or false
                    self.goal = Goal(self.col, 
                        flip and x+ow/2+2 or x-2,
                        love.math.random( 0, (math.floor( h/64 )-1) )*64+32+self.maxH-h + (flip and -oh/2 or 0),
                        ow/2,
                        oh/2,
                        flip
                    )
                    -- Add bully
                    self.bully = Bully(self.col,
                        flip and x+ow/2+36 or x-36,
                        self.goal.pos.y, 
                        16, 16
                    )
                end
            end
        end,
        
        [2] = function(args)
            -- Gap
            local a = love.math.random(-10,10)
            if a == 0 then a = 1 end
            local g = self.maxH/2 + (1/a)*(ow/2)+10 -- Where the gap starts

            local f = Obstacle(self.col, x,0, ow, g-oh/2)
            local s = Obstacle(self.col, x,g+oh/2, ow, self.maxH-g-oh/2)
            self.obstacles:register(f)
            self.obstacles:register(s)

            if not self.goal then
                if args.last or love.math.random(1,3)==1 then
                    -- Add the end goal
                    local flip = xSpawn==0 and true or false

                    self.goal = Goal(self.col, 
                        flip and x+ow/2+2 or x-2,
                        love.math.random(0, math.floor(
                            (love.math.random(0,1)==0 and (g-oh/2) or (self.maxH-g-oh/2))/64)-1)*64+32 + (flip and -oh/2 or 0),
                        ow/2,
                        oh/2,
                        flip
                    )
                    -- Add bully
                    self.bully = Bully(self.col,
                        flip and x+ow/2+36 or x-36,
                        self.goal.pos.y, 
                        16, 16
                    )
                end
            end
        end,

        [3] = function(args)
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
                    local flip = xSpawn==0 and true or false
                    self.goal = Goal(self.col, 
                        flip and x+ow/2+2 or x-2,
                        love.math.random( 0, (math.floor( (h-oh/2)/64 )-1) ) *64+32 + (flip and -oh/2 or 0),
                        ow/2,
                        oh/2,
                        flip
                    )
                    -- Add bully
                    self.bully = Bully(self.col, 
                        flip and x+ow/2+36 or x-36,
                        self.goal.pos.y, 
                        16, 16
                    )
                end
            end
            self.obstacles:register(ob)       
        end
    }

    -- Add the outer level bounds
    self.obstacles:register(Obstacle(self.col, -ow, -oh, ow, self.maxH+oh*2, false))
    self.obstacles:register(Obstacle(self.col, self.maxW, -oh, ow, self.maxH+oh*2, false))
    self.obstacles:register(Obstacle(self.col, -ow, -oh, self.maxW+oh*2, oh, false))
    self.obstacles:register(Obstacle(self.col, -ow, self.maxH, self.maxW+oh*2, oh, false))

    -- Add the columns of classrooms
    local current, columns = 0, 3
    while current < columns do
        local top, bottom = {1,2}, {2,3}
        genStyles[love.math.random(unpack(ySpawn == 1 and bottom or top))]({
            first = current == 0 and true or false,
            last  = current == columns-1
        })
        x = x + ow * 2

        current = current + 1
    end


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
        love.graphics.clear(0.9,0.9,1,1)
        -- Draw the normal view of the level for the player to navigate
        self.camera:lookAt(self.player.pos:unpack())
        self.camera.rot = -self.player.dir-math.pi/2
        
        self.camera:attach()
        love.graphics.draw(self.floorMesh, 0,0)
        
        self.player:draw()
        self.obstacles:draw()
        self.goal:draw()
        self.bully:draw()
            
        self.camera:detach()
        
        love.graphics.setColor(1,1,1)
        
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
        self.bully:update(dt)

        self.col:collisions(self.player, self.obstacles.alive, function(player, obstacle)
            -- Check if the inner circle bounds have collided
            local x,y,xx,yy = obstacle.bounds['hitbox']:bbox()
            local ob = Shapes.newPolygonShape(
                x,y,
                xx,y,
                xx,yy,
                x,yy
            )
            x,y,xx,yy = player.bounds['hitbox']:bbox()
            local pb = Shapes.newCircleShape(
                x,y,player.w
            )

            if ob:collidesWith(pb) then
                self.die()
            end            
        end)
        -- Lazy table collision, I should alter COL to allow two objects in flixel format
        self.col:collisions(self.player, {[self.goal]=true}, function(player, goal) 
            self.win()
        end)
        self.col:collisions(self.player, {[self.bully]=true}, function(player, bully) 
            self.die()
        end)
        self.col:collisions(self.bully, self.obstacles.alive, function(bully, obstacle) 
            bully.dir = bully.dir * -1
            bully.bounds['hitbox']:moveTo(bully.lastPos:unpack())
        end)
    end
end


function Level.resize(self, w, h)
    self.scale = h/shared.origH
    self.camera.scale = self.scale
end

return Level

