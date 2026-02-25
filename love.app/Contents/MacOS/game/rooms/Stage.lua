Stage = Object:extend()

function Stage:tenRect()
    for i = 1, 10 do
        self.area:addGameObject('Rectangle', random(0, 800), random(0, 600))
    end
end

function Stage:new()
    self.area = Area()
    self.timer = Timer()
end

function Stage:update(dt)
    self.area:update(dt)
    self.timer:update(dt)

    if next(self.area.game_objects) == nil then
        self:tenRect()
    end

    if input:pressed('delete') then
        self.area.game_objects[1].dead = true
    end
end

function Stage:draw()
    self.area:draw()
end
