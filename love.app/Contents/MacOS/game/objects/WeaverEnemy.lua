WeaverEnemy = GameObject:extend()

function WeaverEnemy:new(area, x, y, opts)
    WeaverEnemy.super.new(self, area, x, y, opts)

    self.w = 10
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.is_enemy = true
    self.max_hp = 64
    self.hp = self.max_hp

    self.speed = 70
    self.weave_t = random(0, 2 * math.pi)
    self.shoot_t = random(0.1, 0.8)
    self.shoot_cd = 0.9

    self.color = hp_color
    self.depth = 52
end

function WeaverEnemy:update(dt)
    WeaverEnemy.super.update(self, dt)

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    if #players > 0 then
        local player = players[1]
        local angle_to_player = math.atan2(player.y - self.y, player.x - self.x)

        self.weave_t = self.weave_t + dt * 6
        local weave = math.sin(self.weave_t) * 0.9
        local move_angle = angle_to_player + weave

        self.collider:setLinearVelocity(self.speed * math.cos(move_angle), self.speed * math.sin(move_angle))

        self.shoot_t = self.shoot_t - dt
        if self.shoot_t <= 0 then
            playSfx('enemy_shoot', random(0.95, 1.08), 0.2)
            self.area:addGameObject('EnemyProjectile', self.x, self.y, {
                r = angle_to_player,
                v = 180,
                s = 3.0,
                damage = 10
            })
            self.shoot_t = self.shoot_cd
        end
    end

    local margin = 32
    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh
    if self.x < -margin or self.x > stage_w + margin or self.y < -margin or self.y > stage_h + margin then
        self.dead = true
    end
end

function WeaverEnemy:draw()
    local pulse = 0.2 * math.sin(self.weave_t * 1.5)
    local r1 = self.w * (1 + pulse)
    local r2 = self.w * 0.5
    uiColor(self.color)
    love.graphics.circle('fill', self.x, self.y, self.w * 0.9)
    uiColor(ui_dark)
    love.graphics.circle('fill', self.x, self.y, self.w * 0.35)
    uiColor(default_color)
    love.graphics.line(self.x - r1, self.y, self.x - r2, self.y - r2)
    love.graphics.line(self.x - r2, self.y - r2, self.x, self.y - r1)
    love.graphics.line(self.x, self.y - r1, self.x + r2, self.y - r2)
    love.graphics.line(self.x + r2, self.y - r2, self.x + r1, self.y)
    love.graphics.line(self.x + r1, self.y, self.x + r2, self.y + r2)
    love.graphics.line(self.x + r2, self.y + r2, self.x, self.y + r1)
    love.graphics.line(self.x, self.y + r1, self.x - r2, self.y + r2)
    love.graphics.line(self.x - r2, self.y + r2, self.x - r1, self.y)
    love.graphics.circle('line', self.x, self.y, self.w * 0.35)
    drawEnemyHpBar(self.x, self.y, self.w, self.hp, self.max_hp)
end

function WeaverEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self:die()
    end
end

function WeaverEnemy:die()
    self.dead = true
    for i = 1, 6 do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = self.color,
            d = random(0.15, 0.3)
        })
    end
end
