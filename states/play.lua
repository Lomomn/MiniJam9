local COL = require('lib.COL.col')
local List = require('lib.loveHelper.list')
local Level = require('entities.level')


local play = {}


function play.load()
    -- Create a new level every time this state is accessed.
    -- The level code could have gone here, but I think it's neater to 
    -- put it into its own class even though it's not really needed.
    play.level = Level(function() 
        if shared.score > shared.hiscore then
            shared.hiscore = shared.score
            love.filesystem.write('save.txt', tostring(shared.hiscore))
        end
        shared.score = 0
        shared.changeState = true
    end, function()
        shared.score = shared.score + 1
        play.load()
    end)
end


function play.quit()

end


function play.update(dt) 
    play.level:update(dt)
end


function play.draw() 
    play.level:draw()
end


function play.keypressed(key, isrepeat)
    
end


function play.resize(w, h)
    play.level:resize(w, h)
end


return play