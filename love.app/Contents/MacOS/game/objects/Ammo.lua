Ammo = GameObject:extend()

function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)

    local size_scale = opts.size_scale or 1
    self.w, self.h = 7 * size_scale, 7 * size_scale
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setSensor(true)
    self.collider:setFixedRotation(false)
    self.r = random(0, 2 * math.pi)
    self.v = random(10, 20)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
    self.collider:applyAngularImpulse(random(-24, 24))

    self.value = opts.value or 24
end

function Ammo:update(dt)
    Ammo.super.update(self, dt)

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    for _, player in ipairs(players) do
        if distance(self.x, self.y, player.x, player.y) < self.w + player.w then
            if player.addAmmo then
                player:addAmmo(self.value)
            end
            playSfx('pickup', 1.05, 0.35)
            self.dead = true
            self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
                color = ammo_color,
                w = 10
            })
            break
        end
    end
end

function Ammo:draw()
    pushRotate(self.x, self.y, self.collider:getAngle())
    uiColor(ui_dark)
    love.graphics.rectangle('fill', self.x - self.w * 1.15, self.y - self.h * 0.62, self.w * 2.3, self.h * 1.24)
    uiColor(default_color)
    love.graphics.rectangle('line', self.x - self.w * 1.15, self.y - self.h * 0.62, self.w * 2.3, self.h * 1.24)

    local cy = self.y + self.h * 0.04
    for i = -1, 1 do
        local cx = self.x + i * (self.w * 0.7)
        uiColor(ammo_color)
        love.graphics.rectangle('fill', cx - self.w * 0.18, cy - self.h * 0.32, self.w * 0.36, self.h * 0.64)
        uiColor(ui_dark)
        love.graphics.circle('fill', cx, cy - self.h * 0.32, self.w * 0.16)
        uiColor(default_color)
        love.graphics.rectangle('line', cx - self.w * 0.18, cy - self.h * 0.32, self.w * 0.36, self.h * 0.64)
        love.graphics.circle('line', cx, cy - self.h * 0.32, self.w * 0.16)
    end

    uiColor(default_color)
    love.graphics.line(self.x - self.w * 0.95, self.y + self.h * 0.28, self.x + self.w * 0.95, self.y + self.h * 0.28)
    love.graphics.pop()
end

function Ammo:destroy()
    Ammo.super.destroy(self)
end
