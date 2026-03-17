--[[
    BasicEnemy.lua - A simple enemy that patrols and shoots at the player
]] --
BasicEnemy = GameObject:extend()

function BasicEnemy:new(area, x, y, opts)
    BasicEnemy.super.new(self, area, x, y, opts)

    self.w, self.h = 10, 10
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    self.max_v = 60
    self.a = 100

    self.max_hp = 70
    self.hp = self.max_hp
    self.is_enemy = true

    self.shoot_cooldown = 1.5
    self.shoot_timer = 0

    self.color = hp_color
    self.depth = 50

    self.vx, self.vy = 0, 0
end

function BasicEnemy:update(dt)
    BasicEnemy.super.update(self, dt)

    -- Find the player
    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    if #players > 0 then
        local player = players[1]
        local dx = player.x - self.x
        local dy = player.y - self.y
        local dist = distance(self.x, self.y, player.x, player.y)

        -- Chase player
        if dist > 20 then
            local angle = math.atan2(dy, dx)
            self.vx = self.a * math.cos(angle)
            self.vy = self.a * math.sin(angle)
        else
            self.vx = 0
            self.vy = 0
        end

        -- Cap velocity
        local v = distance(0, 0, self.vx, self.vy)
        if v > self.max_v then
            self.vx = (self.vx / v) * self.max_v
            self.vy = (self.vy / v) * self.max_v
        end

        self.collider:setLinearVelocity(self.vx, self.vy)

        -- Shoot at player
        self.shoot_timer = self.shoot_timer - dt
        if self.shoot_timer < 0 and dist < 200 then
            self:shoot(player)
            self.shoot_timer = self.shoot_cooldown
        end
    end

    -- Check bounds (allow off-screen spawn margin so enemies don't die instantly)
    local margin = 32
    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh
    if self.x < -margin or self.x > stage_w + margin or self.y < -margin or self.y > stage_h + margin then
        self.dead = true
    end
end

function BasicEnemy:shoot(target)
    local dx = target.x - self.x
    local dy = target.y - self.y
    local dist = distance(self.x, self.y, target.x, target.y)

    if dist > 0 then
        local angle = math.atan2(dy, dx)
        playSfx('enemy_shoot', random(0.85, 0.98), 0.24)
        self.area:addGameObject('EnemyProjectile', self.x, self.y, {
            r = angle,
            v = 150,
            s = 3.2,
            damage = 11
        })
        self.area:addGameObject('ShootEffect', self.x, self.y, {
            color = self.color
        })
    end
end

function BasicEnemy:draw()
    uiColor(self.color)
    love.graphics.polygon('fill',
        self.x, self.y - self.w,
        self.x + self.w, self.y,
        self.x, self.y + self.w,
        self.x - self.w, self.y)
    uiColor(ui_dark)
    love.graphics.circle('fill', self.x, self.y, self.w * 0.35)
    uiColor(default_color)
    love.graphics.polygon('line',
        self.x, self.y - self.w,
        self.x + self.w, self.y,
        self.x, self.y + self.w,
        self.x - self.w, self.y)
    love.graphics.line(self.x - self.w * 0.6, self.y, self.x + self.w * 0.6, self.y)
    love.graphics.line(self.x, self.y - self.w * 0.6, self.x, self.y + self.w * 0.6)
    drawEnemyHpBar(self.x, self.y, self.w, self.hp, self.max_hp)
end

function BasicEnemy:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.dead = true
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = hp_color,
            v_min = 50,
            v_max = 150,
            lifetime = 0.5,
            v = 100
        })
    end
end
