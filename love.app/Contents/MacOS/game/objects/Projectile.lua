Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 2.5
    self.v = opts.v or 200
    self.damage = opts.damage or 50
    self.pierce = opts.pierce or 1
    self.remaining_hits = self.pierce
    self.color = opts.color or default_color
    self.owner = opts.owner

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setSensor(true)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.timer:tween(0.5, self, {
        v = 400
    }, 'linear')
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)

    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh

    if self.x < 0 then
        self:die()
    end
    if self.y < 0 then
        self:die()
    end
    if self.x > stage_w then
        self:die()
    end
    if self.y > stage_h then
        self:die()
    end
end

function Projectile:draw()
    if type(self.color) == 'table' and self.color[1] then
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1)
    else
        love.graphics.setColor(default_color)
    end

    love.graphics.circle('line', self.x, self.y, self.s)
    love.graphics.line(self.x - self.s * 1.2, self.y, self.x + self.s * 1.2, self.y)
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
        color = self.color,
        w = 3 * self.s
    })
end
