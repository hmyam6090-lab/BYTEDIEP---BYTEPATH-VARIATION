TurretEnemy = GameObject:extend()

function TurretEnemy:new(area, x, y, opts)
    TurretEnemy.super.new(self, area, x, y, opts)

    self.w = 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.is_enemy = true
    self.max_hp = 110
    self.hp = self.max_hp

    self.move_r = random(0, 2 * math.pi)
    self.move_t = 0
    self.fire_t = random(0.3, 1.2)
    self.fire_cd = 1.5

    self.color = hp_color
    self.depth = 55
end

function TurretEnemy:update(dt)
    TurretEnemy.super.update(self, dt)

    self.move_t = self.move_t + dt
    local drift_v = 20
    self.collider:setLinearVelocity(drift_v * math.cos(self.move_r), drift_v * math.sin(self.move_r))

    self.fire_t = self.fire_t - dt
    if self.fire_t <= 0 then
        self:burst()
        self.fire_t = self.fire_cd
    end

    local margin = 32
    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh
    if self.x < -margin or self.x > stage_w + margin or self.y < -margin or self.y > stage_h + margin then
        self.dead = true
    end
end

function TurretEnemy:burst()
    playSfx('enemy_shoot', random(0.72, 0.86), 0.24)
    local shots = 6
    for i = 1, shots do
        local angle = (i / shots) * 2 * math.pi + self.move_t
        self.area:addGameObject('EnemyProjectile', self.x, self.y, {
            r = angle,
            v = 120,
            s = 3.3,
            damage = 12
        })
    end

    self.area:addGameObject('ShootEffect', self.x, self.y, {
        d = 0
    })
end

function TurretEnemy:draw()
    uiColor(self.color)
    love.graphics.polygon('fill',
        self.x - self.w * 0.7, self.y - self.w,
        self.x + self.w * 0.7, self.y - self.w,
        self.x + self.w, self.y - self.w * 0.7,
        self.x + self.w, self.y + self.w * 0.7,
        self.x + self.w * 0.7, self.y + self.w,
        self.x - self.w * 0.7, self.y + self.w,
        self.x - self.w, self.y + self.w * 0.7,
        self.x - self.w, self.y - self.w * 0.7)
    uiColor(ui_dark)
    love.graphics.circle('fill', self.x, self.y, self.w * 0.35)
    uiColor(default_color)
    love.graphics.polygon('line',
        self.x - self.w * 0.7, self.y - self.w,
        self.x + self.w * 0.7, self.y - self.w,
        self.x + self.w, self.y - self.w * 0.7,
        self.x + self.w, self.y + self.w * 0.7,
        self.x + self.w * 0.7, self.y + self.w,
        self.x - self.w * 0.7, self.y + self.w,
        self.x - self.w, self.y + self.w * 0.7,
        self.x - self.w, self.y - self.w * 0.7)
    love.graphics.circle('line', self.x, self.y, self.w * 0.52)
    love.graphics.line(self.x - self.w * 0.5, self.y, self.x + self.w * 0.5, self.y)
    drawEnemyHpBar(self.x, self.y, self.w, self.hp, self.max_hp)
end

function TurretEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self:die()
    end
end

function TurretEnemy:die()
    self.dead = true
    for i = 1, 7 do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = self.color,
            d = random(0.2, 0.35)
        })
    end
end
