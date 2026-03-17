FuelCell = GameObject:extend()

function FuelCell:new(area, x, y, opts)
    FuelCell.super.new(self, area, x, y, opts)

    self.w = 8
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setSensor(true)
    self.collider:setFixedRotation(false)
    self.collider:applyAngularImpulse(random(-16, 16))

    self.v = random(8, 18)
    self.r = random(0, 2 * math.pi)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.value = opts.value or 25
end

function FuelCell:update(dt)
    FuelCell.super.update(self, dt)

    local players = self.area:getGameObjects(function(go)
        return go.class == 'Player'
    end)

    for _, player in ipairs(players) do
        if distance(self.x, self.y, player.x, player.y) < self.w + player.w then
            if player.addFuel then
                player:addFuel(self.value)
            end
            playSfx('pickup', 0.95, 0.35)
            self.dead = true
            self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
                color = boost_color,
                w = 10
            })
            break
        end
    end
end

function FuelCell:draw()
    pushRotate(self.x, self.y, self.collider:getAngle())
    uiColor(boost_color)
    love.graphics.rectangle('fill', self.x - self.w, self.y - self.w * 0.65, 2 * self.w, 1.3 * self.w)
    uiColor(ui_dark)
    love.graphics.rectangle('fill', self.x - self.w * 0.72, self.y - self.w * 0.2, 1.44 * self.w, 0.4 * self.w)
    uiColor(default_color)
    love.graphics.circle('line', self.x - self.w * 0.55, self.y, self.w * 0.18)
    love.graphics.circle('line', self.x + self.w * 0.55, self.y, self.w * 0.18)
    uiColor(default_color)
    love.graphics.rectangle('line', self.x - self.w, self.y - self.w * 0.65, 2 * self.w, 1.3 * self.w)
    love.graphics.line(self.x, self.y - self.w * 0.9, self.x, self.y + self.w * 0.9)
    love.graphics.pop()
end

function FuelCell:destroy()
    FuelCell.super.destroy(self)
end
