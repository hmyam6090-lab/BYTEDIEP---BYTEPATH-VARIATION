--[[
    EnemyProjectile.lua - Projectiles fired by enemies
]] --
EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)

    self.s = opts.s or 3.0
    self.v = opts.v or 150
    self.r = opts.r or 0

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
    self.collider:setObject(self)
    self.collider:setSensor(true)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.damage = opts.damage or 10
end

function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)

    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh

    if self.x < 0 or self.y < 0 or self.x > stage_w or self.y > stage_h then
        self:die()
    end

    -- Check collision with player
    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    for _, player in ipairs(players) do
        local dist = distance(self.x, self.y, player.x, player.y)
        if dist < self.s + player.w then
            if player.takeDamage then
                player:takeDamage(self.damage)
            end
            self:die()
        end
    end
end

function EnemyProjectile:draw()
    uiColor(enemy_bullet_color)
    love.graphics.circle('fill', self.x, self.y, self.s)
    uiColor(hp_color)
    love.graphics.circle('line', self.x, self.y, self.s + 1.6)
    uiColor(default_color)
    love.graphics.circle('line', self.x, self.y, self.s)
    love.graphics.line(self.x - self.s * 1.8, self.y, self.x + self.s * 1.8, self.y)
end

function EnemyProjectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
        color = enemy_bullet_color,
        w = 2.8 * self.s
    })
end
