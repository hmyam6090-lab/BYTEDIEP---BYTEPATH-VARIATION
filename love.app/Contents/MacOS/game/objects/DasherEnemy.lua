DasherEnemy = GameObject:extend()

function DasherEnemy:new(area, x, y, opts)
    DasherEnemy.super.new(self, area, x, y, opts)

    self.w = 9
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.is_enemy = true
    self.max_hp = 56
    self.hp = self.max_hp

    self.base_v = 40
    self.dash_v = 220
    self.vx, self.vy = 0, 0

    self.dash_cooldown = 2.0
    self.dash_timer = random(0.2, 1.0)
    self.dash_duration = 0.35
    self.dash_t = 0

    self.color = hp_color
    self.depth = 50
end

function DasherEnemy:update(dt)
    DasherEnemy.super.update(self, dt)

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    if #players > 0 then
        local player = players[1]
        local angle = math.atan2(player.y - self.y, player.x - self.x)

        if self.dash_t > 0 then
            self.dash_t = self.dash_t - dt
            self.vx = self.dash_v * math.cos(angle)
            self.vy = self.dash_v * math.sin(angle)

            if love.math.random() > 0.6 then
                self.area:addGameObject('TrailParticle', self.x, self.y, {
                    r = random(1, 2),
                    d = random(0.08, 0.16),
                    color = self.color
                })
            end
        else
            self.dash_timer = self.dash_timer - dt
            self.vx = self.base_v * math.cos(angle)
            self.vy = self.base_v * math.sin(angle)

            if self.dash_timer <= 0 then
                self.dash_t = self.dash_duration
                self.dash_timer = self.dash_cooldown
            end
        end

        self.collider:setLinearVelocity(self.vx, self.vy)

    end

    local margin = 32
    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh
    if self.x < -margin or self.x > stage_w + margin or self.y < -margin or self.y > stage_h + margin then
        self.dead = true
    end
end

function DasherEnemy:draw()
    pushRotate(self.x, self.y, math.atan2(self.vy, self.vx) + math.pi / 2)
    uiColor(self.color)
    love.graphics.polygon('fill',
        self.x, self.y - self.w,
        self.x + self.w * 0.85, self.y + self.w,
        self.x, self.y + self.w * 0.45,
        self.x - self.w * 0.85, self.y + self.w)
    uiColor(ui_dark)
    love.graphics.polygon('fill',
        self.x, self.y - self.w * 0.35,
        self.x + self.w * 0.3, self.y + self.w * 0.3,
        self.x - self.w * 0.3, self.y + self.w * 0.3)
    uiColor(default_color)
    love.graphics.polygon('line',
        self.x, self.y - self.w,
        self.x + self.w * 0.85, self.y + self.w,
        self.x, self.y + self.w * 0.45,
        self.x - self.w * 0.85, self.y + self.w)
    love.graphics.line(self.x, self.y - self.w, self.x, self.y + self.w * 0.35)
    love.graphics.line(self.x - self.w * 0.45, self.y + self.w * 0.5, self.x + self.w * 0.45, self.y + self.w * 0.5)
    love.graphics.pop()
    drawEnemyHpBar(self.x, self.y, self.w, self.hp, self.max_hp)
end

function DasherEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self:die()
    end
end

function DasherEnemy:die()
    self.dead = true
    for i = 1, 5 do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = self.color,
            d = random(0.15, 0.3)
        })
    end
end
