local COL = require('lib.COL.col')
local List = require('lib.loveHelper.list')
local Level = require('entities.level')
local Camera = require('lib.hump.camera')

local play = {}

local mapCanvas = love.graphics.newCanvas(256, 256)
local canvas = love.graphics.newCanvas(256, 256)
local deadOrComplete = false
local level = {}
local camera = Camera(0,0)

function play.load()
    level = Level()
end


function play.quit()

end


function play.update(dt) 
    level:update(dt)
end


function play.draw() 
    camera:lookAt(level.player.pos:unpack())

    camera:attach()
    level:draw()
    camera:detach()
    
    love.graphics.print('play', 0,0)
end


function play.keypressed(key, isrepeat)
    
end


return play