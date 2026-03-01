Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    -- Movement Properties

    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0
    self.max_v = 100
    self.a = 100

    -- Shooting Properties
    self.attack_speed = 1

    self.timer:every(0.24 / self.attack_speed, function()
        print(self.attack_speed)
        self:shoot()
        self.attack_speed = random(1, 2)
    end)

    input:bind('f', function()
        self:die()
    end)
end

function Player:update(dt)
    Player.super.update(self, dt)
    if input:down('left') then
        self.r = self.r - self.rv * dt
    end
    if input:down('right') then
        self.r = self.r + self.rv * dt
    end

    self.v = math.min(self.v + self.a * dt, self.max_v)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    if self.x < 0 then
        self:die()
    end
    if self.y < 0 then
        self:die()
    end
    if self.x > gw then
        self:die()
    end
    if self.y > gh then
        self:die()
    end
end

function Player:draw()
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:shoot()
    local d = 1.2 * self.w
    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), {
        player = self,
        d = d
    })

    self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r), {
        r = self.r,
        v = 100
    })
end

function Player:die()
    slow(0.15, 1)
    flash(4)
    camera:shake(6, 60, 0.4)
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
    self.dead = true
end
