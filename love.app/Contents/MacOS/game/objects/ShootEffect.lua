ShootEffect = GameObject:extend()

function ShootEffect:new(area, x, y, opts)
    ShootEffect.super.new(self, area, x, y, opts)

    self.w = 8
    self.color = opts.color or default_color
    self.timer:tween(0.1, self, {
        w = 0
    }, 'in-out-cubic', function()
        self.dead = true
    end)
end

function ShootEffect:update(dt)
    ShootEffect.super.update(self, dt)

    if self.player then
        self.x = self.player.x + self.d * math.cos(self.player.r)
        self.y = self.player.y + self.d * math.sin(self.player.r)
    end
end

function ShootEffect:draw()
    if self.player then
        pushRotate(self.x, self.y, self.player.r + math.pi / 4)
    else
        pushRotate(self.x, self.y, math.pi / 4)
    end

    if type(self.color) == 'table' and self.color[1] then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1)
    else
        love.graphics.setColor(255, 255, 255, 1)
    end

    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    love.graphics.line(self.x - self.w, self.y, self.x + self.w, self.y)
    love.graphics.line(self.x, self.y - self.w, self.x, self.y + self.w)
    love.graphics.pop()
end

function ShootEffect:destroy()
    ShootEffect.super.destroy(self)
end
