RepairPack = GameObject:extend()

function RepairPack:new(area, x, y, opts)
    RepairPack.super.new(self, area, x, y, opts)

    self.w = 8
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setSensor(true)
    self.collider:setFixedRotation(false)
    self.collider:applyAngularImpulse(random(-16, 16))

    self.v = random(8, 16)
    self.r = random(0, 2 * math.pi)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.value = opts.value or 20
end

function RepairPack:update(dt)
    RepairPack.super.update(self, dt)

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    for _, player in ipairs(players) do
        if distance(self.x, self.y, player.x, player.y) < self.w + player.w then
            if player.addHp then
                player:addHp(self.value)
            end
            playSfx('pickup', 0.85, 0.38)
            self.dead = true
            self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
                color = hp_color,
                w = 10
            })
            break
        end
    end
end

function RepairPack:draw()
    pushRotate(self.x, self.y, self.collider:getAngle())
    uiColor(hp_color)
    love.graphics.rectangle('fill', self.x - self.w, self.y - self.w, 2 * self.w, 2 * self.w)
    uiColor(enemy_bullet_color)
    love.graphics.rectangle('fill', self.x - self.w * 0.8, self.y - self.w * 0.8, 1.6 * self.w, 1.6 * self.w)

    local hx = self.x
    local hy = self.y + self.w * 0.06
    uiColor(default_color)
    love.graphics.circle('fill', hx - self.w * 0.2, hy - self.w * 0.2, self.w * 0.22)
    love.graphics.circle('fill', hx + self.w * 0.2, hy - self.w * 0.2, self.w * 0.22)
    love.graphics.polygon('fill', hx - self.w * 0.42, hy - self.w * 0.1, hx + self.w * 0.42, hy - self.w * 0.1, hx,
        hy + self.w * 0.5)

    uiColor(default_color)
    love.graphics.rectangle('line', self.x - self.w, self.y - self.w, 2 * self.w, 2 * self.w)
    love.graphics.rectangle('line', self.x - self.w * 0.8, self.y - self.w * 0.8, 1.6 * self.w, 1.6 * self.w)
    love.graphics.pop()
end

function RepairPack:destroy()
    RepairPack.super.destroy(self)
end
