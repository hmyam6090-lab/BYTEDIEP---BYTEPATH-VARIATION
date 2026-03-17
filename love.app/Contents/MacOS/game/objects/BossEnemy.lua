BossEnemy = GameObject:extend()

function BossEnemy:new(area, x, y, opts)
    BossEnemy.super.new(self, area, x, y, opts)

    self.wave = opts.wave or 5
    self.w = 34
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.is_enemy = true
    self.is_boss = true

    self.max_hp = 820 + math.max(0, (self.wave - 5)) * 115
    self.hp = self.max_hp

    self.speed = 30
    self.phase_t = 0
    self.fire_t = 0.8
    self.fire_cd = 0.85
    self.burst_t = 1.8
    self.burst_cd = 2.9

    self.contact_damage = 18
    self.contact_hit_interval = 0.2

    self.color = hp_color
    self.depth = 70
end

function BossEnemy:update(dt)
    BossEnemy.super.update(self, dt)

    self.phase_t = self.phase_t + dt
    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    if #players > 0 then
        local player = players[1]
        local dx = player.x - self.x
        local dy = player.y - self.y
        local angle = math.atan2(dy, dx)

        local desired_x = stage_w * 0.5 + math.cos(self.phase_t * 0.7) * 120
        local desired_y = stage_h * 0.28 + math.sin(self.phase_t * 1.0) * 46
        local steer_angle = math.atan2(desired_y - self.y, desired_x - self.x)

        self.collider:setLinearVelocity(self.speed * math.cos(steer_angle), self.speed * math.sin(steer_angle))

        self.fire_t = self.fire_t - dt
        if self.fire_t <= 0 then
            self:aimedVolley(angle)
            self.fire_t = self.fire_cd
        end

        self.burst_t = self.burst_t - dt
        if self.burst_t <= 0 then
            self:radialBurst()
            self.burst_t = self.burst_cd
        end
    end

    local margin = 120
    if self.x < -margin or self.x > stage_w + margin or self.y < -margin or self.y > stage_h + margin then
        self.x = math.max(40, math.min(stage_w - 40, self.x))
        self.y = math.max(30, math.min(stage_h - 30, self.y))
    end
end

function BossEnemy:aimedVolley(angle)
    playSfx('enemy_shoot', random(0.62, 0.76), 0.32)
    for i = -2, 2 do
        self.area:addGameObject('EnemyProjectile', self.x, self.y, {
            r = angle + i * 0.11,
            v = 170,
            s = 5.4,
            damage = 13
        })
    end
end

function BossEnemy:radialBurst()
    playSfx('enemy_shoot', random(0.52, 0.66), 0.34)
    local shots = 14
    for i = 1, shots do
        self.area:addGameObject('EnemyProjectile', self.x, self.y, {
            r = ((i - 1) / shots) * math.pi * 2 + self.phase_t,
            v = 140,
            s = 4.9,
            damage = 12
        })
    end
end

function BossEnemy:draw()
    local stage_w = (current_room and current_room.world_w) or gw
    uiColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.w)
    uiColor(enemy_bullet_color)
    love.graphics.circle('line', self.x, self.y, self.w + 5)
    uiColor(ui_dark)
    love.graphics.circle('fill', self.x, self.y, self.w * 0.42)
    uiColor(default_color)
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.line(self.x - self.w * 0.7, self.y, self.x + self.w * 0.7, self.y)
    love.graphics.line(self.x, self.y - self.w * 0.7, self.x, self.y + self.w * 0.7)

    local bar_w = 280
    local ratio = math.max(0, math.min(1, self.hp / self.max_hp))
    local bx = stage_w * 0.5 - bar_w * 0.5
    local by = 18
    uiColor(ui_dark)
    love.graphics.rectangle('fill', bx, by, bar_w, 10)
    uiColor(hp_color)
    love.graphics.rectangle('fill', bx, by, bar_w * ratio, 10)
    uiColor(default_color)
    love.graphics.rectangle('line', bx + 0.5, by + 0.5, bar_w - 1, 9)

    love.graphics.setFont(ui_font_xs)
    uiColor(enemy_bullet_color)
    love.graphics.printf('BOSS CORE', bx, by - 11, bar_w, 'center')
end

function BossEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self:die()
    end
end

function BossEnemy:die()
    self.dead = true
    camera:shake(9, 70, 0.35)
    flash(5)
    for i = 1, 24 do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = hp_color,
            s = random(3, 7),
            d = random(0.2, 0.5),
            v = random(70, 170)
        })
    end
end
