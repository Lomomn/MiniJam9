local COL = require('lib.COL.col')
local List = require('lib.loveHelper.list')
local Level = require('entities.level')

local play = {}

local deadOrComplete = false
local level = {}

function play.load()
    level = Level()
end


function play.quit()

end


function play.update(dt) 
    level:update(dt)
end


function play.draw() 
    level:draw()
end


function play.keypressed(key, isrepeat)
    
end


return play