Rectangle = GameObject:extend()

function Rectangle:new(area, x, y, opts)
    Rectangle.super.new(self, area, x, y, opts)
end

function Rectangle:update(dt)
    Rectangle.super.update(self, dt)
end

function Rectangle:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x, self.y or 0, 200, 50)
end
