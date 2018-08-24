local Camera = require('lib.hump.camera')

local menu = {}
local canvas = love.graphics.newCanvas(256, 256)
local font = love.graphics.newFont('assets/fonts/8bitOperatorPlus-Regular.ttf')
local text = love.graphics.newText(font, 'Super School Navigator')
local camera = Camera(text:getWidth()/2,text:getHeight()/2)
local tween = {}

function menu.load() 
    tween = Timer.script(function(wait)
        while true do
            Timer.tween(0.5, camera, {
                scale = love.math.random(4,8)*2/8,
                rot = love.math.random(-8, 8)*math.pi/64
            })
            wait(0.5)
        end
    end)
end


function menu.quit()

end


function menu.update(dt) 

end


function menu.draw()    
    camera:attach()
    
    love.graphics.draw(text, 0,0)
    
    camera:detach()
end


function menu.keypressed(key, isrepeat)
    shared.changeState = true
end


return menu