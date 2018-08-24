local play = {}
play.canvas = love.graphics.newCanvas(256, 256)


function play.load() 

end


function play.quit()

end


function play.update(dt) 


end

function play.draw() 
    love.graphics.print('play', 0,0)
end

function play.keypressed(key, isrepeat)

end

return play