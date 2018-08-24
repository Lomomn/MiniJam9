local Vector = require('lib.hump.vector')

local Object = Class{__name = 'Object'}

function Object.init(self, scene, x,y, w,h)
    self.alive = true
    self.scene = scene or error('No scene provided')
    self.bounds = {
        ['hitbox'] = self:createBounds(x,y,w,h)
    }
    self.pos, self.w, self.h = Vector(x+w/2, y+h/2), w, h
end


function Object.update(dt)

end


function Object.draw()

end


function Object.kill(self)
    self.alive = false
    for k,v in pairs(self.bounds) do
        self.scene:remove(v)
        v.parent = nil
        self.bounds[k] = nil
    end
end


function Object.createBounds(self, x,y, w,h)
    local bounds = self.scene:rectangle(x,y,w,h)
    bounds.parent = self
    return bounds
end

return Object