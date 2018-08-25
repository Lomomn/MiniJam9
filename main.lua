Timer = require('lib.hump.timer') -- Global 
Class = require('lib.loveHelper.class') -- Global

local menuState = require('states.menu')
local playState = require('states.play')
local currentState = nil
shared = {
    changeState = false,    -- Should state change to the non active one?
    left = 'a',             -- Left control
    right = 'e',            -- Right control
    hiscore = 0,            -- The high score
    origW = 0,              -- Starting size of game window
    origH = 0
}


function love.load() 
    love.graphics.setDefaultFilter('nearest', 'nearest')
    shared.origW, shared.origH = love.graphics.getDimensions()
    
    currentState = playState
    currentState.load()
end


function love.update(dt)
    Timer.update(dt) -- Global timer update

    if shared.changeState then
        shared.changeState = false
        if currentState == menuState then
            currentState = playState
        else
            currentState = menuState
        end 
        currentState.load()
    end
    currentState.update(dt)
end


function love.draw() 
    currentState.draw()
end


function love.keypressed(key, isrepeat)
    if key == 'escape' then 
        love.event.quit()
    else
        currentState.keypressed(key, isrepeat)
    end
end

function love.resize(w, h)
    currentState.resize(w, h)
end