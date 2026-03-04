Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    -- Basic Properties
    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    -- Ship-specific - randomly choose a ship
    local ships = {'Fighter', 'Striker', 'Sentinel', 'Shadow', 'Titan', 'Viper', 'Specter', 'Tempest', 'Phoenix',
                   'Wraith', 'Nexus'}
    self.ship = ships[love.math.random(1, #ships)]
    self.polygons = {}

    if self.ship == 'Fighter' then
        -- Balanced fighter with dual rear thrusters
        self.polygons[1] = {self.w, 0, -- 1
        self.w / 2, -self.w / 2, -- 2
        -self.w / 2, -self.w / 2, -- 3
        -self.w, 0, -- 4
        -self.w / 2, self.w / 2, -- 5
        self.w / 2, self.w / 2 -- 6
        }

        self.polygons[2] = {self.w / 2, -self.w / 2, -- 7
        0, -self.w, -- 8
        -self.w - self.w / 2, -self.w, -- 9
        -3 * self.w / 4, -self.w / 4, -- 10
        -self.w / 2, -self.w / 2 -- 11
        }

        self.polygons[3] = {self.w / 2, self.w / 2, -- 12
        -self.w / 2, self.w / 2, -- 13
        -3 * self.w / 4, self.w / 4, -- 14
        -self.w - self.w / 2, self.w, -- 15
        0, self.w -- 16
        }

        self.base_max_v = 100
        self.a = 100
        self.trail_color = skill_point_color

    elseif self.ship == 'Striker' then
        -- Fast, narrow interceptor with pointed nose
        self.polygons[1] = {self.w * 1.5, 0, -- pointed nose
        0, -self.w / 2, -- 2
        0, self.w / 2 -- 3
        }

        self.polygons[2] = {0, -self.w / 2, -self.w, -self.w / 4, -self.w, 0}

        self.polygons[3] = {0, self.w / 2, -self.w, self.w / 4, -self.w, 0}

        self.base_max_v = 150
        self.a = 150
        self.trail_color = ammo_color

    elseif self.ship == 'Sentinel' then
        -- Large, defensive, angular ship
        self.polygons[1] = {self.w * 0.8, 0, -- 1
        self.w, -self.w * 0.7, -- 2
        self.w * 0.5, -self.w, -- 3
        -self.w * 0.5, -self.w, -- 4
        -self.w, -self.w * 0.7, -- 5
        -self.w, self.w * 0.7, -- 6
        -self.w * 0.5, self.w, -- 7
        self.w * 0.5, self.w, -- 8
        self.w, self.w * 0.7 -- 9
        }

        self.polygons[2] = {-self.w * 0.5, -self.w, -self.w * 0.8, -self.w * 1.2, -self.w, -self.w}

        self.polygons[3] = {-self.w * 0.5, self.w, -self.w * 0.8, self.w * 1.2, -self.w, self.w}

        self.base_max_v = 60
        self.a = 70
        self.trail_color = hp_color

    elseif self.ship == 'Shadow' then
        -- Sleek, curved interceptor for hit-and-run
        self.polygons[1] = {self.w * 1.2, 0, -- 1
        self.w * 0.6, -self.w * 0.6, -- 2
        0, -self.w * 0.8, -- 3
        -self.w * 0.8, -self.w * 0.4, -- 4
        -self.w, 0, -- 5
        -self.w * 0.8, self.w * 0.4, -- 6
        0, self.w * 0.8, -- 7
        self.w * 0.6, self.w * 0.6 -- 8
        }

        self.polygons[2] = {-self.w * 0.8, -self.w * 0.4, -self.w * 1.2, -self.w * 0.6, -self.w, 0}

        self.polygons[3] = {-self.w * 0.8, self.w * 0.4, -self.w * 1.2, self.w * 0.6, -self.w, 0}

        self.base_max_v = 140
        self.a = 130
        self.trail_color = boost_color

    elseif self.ship == 'Titan' then
        -- Massive heavy tank
        self.polygons[1] = {self.w * 0.6, 0, self.w * 0.8, -self.w * 0.8, self.w * 0.4, -self.w, -self.w * 0.6,
                            -self.w * 0.8, -self.w, -self.w * 0.6, -self.w, self.w * 0.6, -self.w * 0.6, self.w * 0.8,
                            self.w * 0.4, self.w, self.w * 0.8, self.w * 0.8}

        self.polygons[2] = {self.w * 0.4, -self.w, self.w * 0.2, -self.w * 1.3, -self.w * 0.2, -self.w * 1.3,
                            -self.w * 0.4, -self.w}

        self.polygons[3] = {self.w * 0.4, self.w, self.w * 0.2, self.w * 1.3, -self.w * 0.2, self.w * 1.3,
                            -self.w * 0.4, self.w}

        self.base_max_v = 40
        self.a = 50
        self.trail_color = hp_color

    elseif self.ship == 'Viper' then
        -- Highly agile, serpentine shape
        self.polygons[1] = {self.w * 1.8, 0, self.w * 0.8, -self.w * 0.3, self.w * 0.2, -self.w * 0.6, -self.w * 0.4,
                            -self.w * 0.5, -self.w, 0, -self.w * 0.4, self.w * 0.5, self.w * 0.2, self.w * 0.6,
                            self.w * 0.8, self.w * 0.3}

        self.polygons[2] = {-self.w * 0.4, -self.w * 0.5, -self.w * 0.8, -self.w, -self.w, -self.w * 0.6}

        self.polygons[3] = {-self.w * 0.4, self.w * 0.5, -self.w * 0.8, self.w, -self.w, self.w * 0.6}

        self.base_max_v = 170
        self.a = 140
        self.trail_color = ammo_color

    elseif self.ship == 'Specter' then
        -- Ghost-like, fading shape
        self.polygons[1] = {self.w * 0.9, 0, self.w * 0.3, -self.w * 0.4, -self.w * 0.3, -self.w * 0.4, -self.w * 0.9,
                            -self.w * 0.2, -self.w * 0.9, self.w * 0.2, -self.w * 0.3, self.w * 0.4, self.w * 0.3,
                            self.w * 0.4}

        self.polygons[2] = {-self.w * 0.3, -self.w * 0.4, -self.w * 0.6, -self.w * 0.7, -self.w * 0.9, -self.w * 0.2}

        self.polygons[3] = {-self.w * 0.3, self.w * 0.4, -self.w * 0.6, self.w * 0.7, -self.w * 0.9, self.w * 0.2}

        self.base_max_v = 110
        self.a = 90
        self.trail_color = skill_point_color

    elseif self.ship == 'Tempest' then
        -- Lightning-like zigzag design
        self.polygons[1] = {self.w * 1.3, 0, self.w * 0.3, -self.w * 0.7, -self.w * 0.2, -self.w * 0.3, -self.w * 0.5,
                            -self.w * 0.8, -self.w, -self.w * 0.2, -self.w * 0.5, self.w * 0.3, self.w * 0.3,
                            self.w * 0.7}

        self.polygons[2] = {-self.w * 0.5, -self.w * 0.8, -self.w * 0.7, -self.w * 1.1, -self.w * 0.2, -self.w * 0.8}

        self.polygons[3] = {-self.w * 0.5, self.w * 0.3, -self.w * 0.7, self.w * 0.8, -self.w * 0.2, self.w * 0.3}

        self.base_max_v = 160
        self.a = 160
        self.trail_color = boost_color

    elseif self.ship == 'Phoenix' then
        -- Majestic with large curved wings
        self.polygons[1] = {self.w, 0, self.w * 0.7, -self.w * 0.5, self.w * 0.4, -self.w * 0.9, -self.w * 0.3,
                            -self.w * 0.9, -self.w, -self.w * 0.3, -self.w, self.w * 0.3, -self.w * 0.3, self.w * 0.9,
                            self.w * 0.4, self.w * 0.9, self.w * 0.7, self.w * 0.5}

        self.polygons[2] = {self.w * 0.4, -self.w * 0.9, self.w * 0.6, -self.w * 1.2, self.w * 0.2, -self.w}

        self.polygons[3] = {self.w * 0.4, self.w * 0.9, self.w * 0.6, self.w * 1.2, self.w * 0.2, self.w}

        self.base_max_v = 95
        self.a = 95
        self.trail_color = hp_color

    elseif self.ship == 'Wraith' then
        -- Minimal, barely visible form
        self.polygons[1] = {self.w * 0.8, 0, 0, -self.w * 0.2, -self.w * 0.6, 0, 0, self.w * 0.2}

        self.polygons[2] = {-self.w * 0.6, 0, -self.w * 0.8, -self.w * 0.15}

        self.polygons[3] = {-self.w * 0.6, 0, -self.w * 0.8, self.w * 0.15}

        self.base_max_v = 135
        self.a = 125
        self.trail_color = ammo_color

    elseif self.ship == 'Nexus' then
        -- Complex geometric interceptor with hexagonal core and delta wings
        -- Central hexagonal core
        self.polygons[1] = {self.w * 0.7, 0, self.w * 0.35, -self.w * 0.6, -self.w * 0.35, -self.w * 0.6, -self.w * 0.7,
                            0, -self.w * 0.35, self.w * 0.6, self.w * 0.35, self.w * 0.6}

        -- Upper delta wing
        self.polygons[2] = {self.w * 0.35, -self.w * 0.6, self.w * 0.8, -self.w * 1.1, self.w * 0.2, -self.w * 0.8, 0,
                            -self.w * 0.7}

        -- Lower delta wing
        self.polygons[3] = {self.w * 0.35, self.w * 0.6, self.w * 0.8, self.w * 1.1, self.w * 0.2, self.w * 0.8, 0,
                            self.w * 0.7}

        -- Upper rear thruster cluster
        self.polygons[4] = {-self.w * 0.35, -self.w * 0.6, -self.w * 0.7, -self.w * 0.9, -self.w * 1.2, -self.w * 0.4,
                            -self.w * 0.9, -self.w * 0.3}

        -- Lower rear thruster cluster
        self.polygons[5] = {-self.w * 0.35, self.w * 0.6, -self.w * 0.7, self.w * 0.9, -self.w * 1.2, self.w * 0.4,
                            -self.w * 0.9, self.w * 0.3}

        self.base_max_v = 118
        self.a = 115
        self.trail_color = skill_point_color
    end

    -- Movement Properties
    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0

    self.max_v = self.base_max_v

    -- Shooting Properties
    self.attack_speed = 1

    self.timer:every(0.24 / self.attack_speed, function()
        print(self.attack_speed)
        self:shoot()
        self.attack_speed = random(1, 2)
    end)

    -- Tick Properties
    self.timer:every(5, function()
        self:tick()
    end)

    -- Trail
    self.timer:every(0.01, function()
        if self.ship == "Fighter" then
            -- Dual rear thrusters
            self.area:addGameObject('TrailParticle', self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.15, 0.25),
                color = self.trail_color
            })
            self.area:addGameObject('TrailParticle', self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w *
                math.cos(self.r + math.pi / 2), self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w *
                math.sin(self.r + math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.15, 0.25),
                color = self.trail_color
            })

        elseif self.ship == "Striker" then
            -- Thin center trail from pointed nose
            self.area:addGameObject('TrailParticle', self.x - 0.7 * self.w * math.cos(self.r),
                self.y - 0.7 * self.w * math.sin(self.r), {
                    parent = self,
                    r = random(1, 2),
                    d = random(0.15, 0.25),
                    color = self.trail_color
                })

        elseif self.ship == "Sentinel" then
            -- Wide triple exhaust trail
            for offset = -1, 1 do
                self.area:addGameObject('TrailParticle', self.x - self.w * math.cos(self.r) + offset * 0.4 * self.w *
                    math.cos(self.r - math.pi / 2), self.y - self.w * math.sin(self.r) + offset * 0.4 * self.w *
                    math.sin(self.r - math.pi / 2), {
                    parent = self,
                    r = random(3, 5),
                    d = random(0.2, 0.35),
                    color = self.trail_color
                })
            end

        elseif self.ship == "Shadow" then
            -- Curved side trails
            self.area:addGameObject('TrailParticle', self.x - 0.85 * self.w * math.cos(self.r) + 0.3 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.85 * self.w * math.sin(self.r) + 0.3 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 3),
                d = random(0.1, 0.2),
                color = self.trail_color
            })
            self.area:addGameObject('TrailParticle', self.x - 0.85 * self.w * math.cos(self.r) + 0.3 * self.w *
                math.cos(self.r + math.pi / 2), self.y - 0.85 * self.w * math.sin(self.r) + 0.3 * self.w *
                math.sin(self.r + math.pi / 2), {
                parent = self,
                r = random(2, 3),
                d = random(0.1, 0.2),
                color = self.trail_color
            })

        elseif self.ship == "Titan" then
            -- Heavy quad exhaust
            for offset = -1.5, 1.5, 1 do
                self.area:addGameObject('TrailParticle', self.x - self.w * 1.1 * math.cos(self.r) + offset * 0.3 *
                    self.w * math.cos(self.r - math.pi / 2), self.y - self.w * 1.1 * math.sin(self.r) + offset * 0.3 *
                    self.w * math.sin(self.r - math.pi / 2), {
                    parent = self,
                    r = random(4, 6),
                    d = random(0.25, 0.4),
                    color = self.trail_color
                })
            end

        elseif self.ship == "Viper" then
            -- Sinuous flowing trails
            self.area:addGameObject('TrailParticle', self.x - 1.2 * self.w * math.cos(self.r) + 0.25 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 1.2 * self.w * math.sin(self.r) + 0.25 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(1, 2),
                d = random(0.1, 0.15),
                color = self.trail_color
            })
            self.area:addGameObject('TrailParticle', self.x - 1.2 * self.w * math.cos(self.r) + 0.25 * self.w *
                math.cos(self.r + math.pi / 2), self.y - 1.2 * self.w * math.sin(self.r) + 0.25 * self.w *
                math.sin(self.r + math.pi / 2), {
                parent = self,
                r = random(1, 2),
                d = random(0.1, 0.15),
                color = self.trail_color
            })

        elseif self.ship == "Specter" then
            -- Fading ghost trail (sparse)
            if love.math.random() > 0.5 then
                self.area:addGameObject('TrailParticle', self.x - 0.8 * self.w * math.cos(self.r),
                    self.y - 0.8 * self.w * math.sin(self.r), {
                        parent = self,
                        r = random(1, 3),
                        d = random(0.2, 0.3),
                        color = self.trail_color
                    })
            end

        elseif self.ship == "Tempest" then
            -- Dual lightning trails with slight offset
            self.area:addGameObject('TrailParticle', self.x - 0.95 * self.w * math.cos(self.r) + 0.15 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.95 * self.w * math.sin(self.r) + 0.15 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.1, 0.2),
                color = self.trail_color
            })
            self.area:addGameObject('TrailParticle', self.x - 0.95 * self.w * math.cos(self.r) - 0.15 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.95 * self.w * math.sin(self.r) - 0.15 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.1, 0.2),
                color = self.trail_color
            })

        elseif self.ship == "Phoenix" then
            -- Majestic triple wing trails
            self.area:addGameObject('TrailParticle', self.x - self.w * math.cos(self.r),
                self.y - self.w * math.sin(self.r), {
                    parent = self,
                    r = random(2, 4),
                    d = random(0.15, 0.25),
                    color = self.trail_color
                })
            self.area:addGameObject('TrailParticle', self.x - 0.7 * self.w * math.cos(self.r) + 0.35 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.7 * self.w * math.sin(self.r) + 0.35 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.15, 0.25),
                color = self.trail_color
            })
            self.area:addGameObject('TrailParticle', self.x - 0.7 * self.w * math.cos(self.r) - 0.35 * self.w *
                math.cos(self.r - math.pi / 2), self.y - 0.7 * self.w * math.sin(self.r) - 0.35 * self.w *
                math.sin(self.r - math.pi / 2), {
                parent = self,
                r = random(2, 4),
                d = random(0.15, 0.25),
                color = self.trail_color
            })

        elseif self.ship == "Wraith" then
            -- Minimal wisp trail (very sparse)
            if love.math.random() > 0.7 then
                self.area:addGameObject('TrailParticle', self.x - 0.7 * self.w * math.cos(self.r),
                    self.y - 0.7 * self.w * math.sin(self.r), {
                        parent = self,
                        r = random(1, 2),
                        d = random(0.1, 0.15),
                        color = self.trail_color
                    })
            end

        elseif self.ship == "Nexus" then
            -- Hexagonal cluster trail from rear thrusters
            -- Center trail
            self.area:addGameObject('TrailParticle', self.x - 1.0 * self.w * math.cos(self.r),
                self.y - 1.0 * self.w * math.sin(self.r), {
                    parent = self,
                    r = random(2, 3),
                    d = random(0.15, 0.25),
                    color = self.trail_color
                })

            -- Upper clustered trails
            for i = 1, 2 do
                local angle_offset = (i - 1.5) * 0.4
                self.area:addGameObject('TrailParticle', self.x - (1.0 + i * 0.15) * self.w * math.cos(self.r) +
                    angle_offset * self.w * math.cos(self.r - math.pi / 2), self.y - (1.0 + i * 0.15) * self.w *
                    math.sin(self.r) + angle_offset * self.w * math.sin(self.r - math.pi / 2), {
                    parent = self,
                    r = random(1, 2),
                    d = random(0.1, 0.2),
                    color = self.trail_color
                })
            end

            -- Lower clustered trails
            for i = 1, 2 do
                local angle_offset = (i - 1.5) * 0.4
                self.area:addGameObject('TrailParticle', self.x - (1.0 + i * 0.15) * self.w * math.cos(self.r) -
                    angle_offset * self.w * math.cos(self.r - math.pi / 2), self.y - (1.0 + i * 0.15) * self.w *
                    math.sin(self.r) - angle_offset * self.w * math.sin(self.r - math.pi / 2), {
                    parent = self,
                    r = random(1, 2),
                    d = random(0.1, 0.2),
                    color = self.trail_color
                })
            end
        end
    end)

    -- Death
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

    self.max_v = self.base_max_v
    self.boosting = false

    if input:down('up') then
        self.boosting = true
        self.max_v = 1.5 * self.base_max_v
    end
    if input:down('down') then
        self.boosting = true
        self.max_v = 0.5 * self.base_max_v
    end

    -- Update trail color based on boost state
    if self.boosting then
        self.trail_color = boost_color
    else
        -- Reset to ship-specific color when not boosting
        if self.ship == 'Fighter' then
            self.trail_color = skill_point_color
        elseif self.ship == 'Striker' then
            self.trail_color = ammo_color
        elseif self.ship == 'Sentinel' then
            self.trail_color = hp_color
        elseif self.ship == 'Shadow' then
            self.trail_color = boost_color
        elseif self.ship == 'Titan' then
            self.trail_color = hp_color
        elseif self.ship == 'Viper' then
            self.trail_color = ammo_color
        elseif self.ship == 'Specter' then
            self.trail_color = skill_point_color
        elseif self.ship == 'Tempest' then
            self.trail_color = boost_color
        elseif self.ship == 'Phoenix' then
            self.trail_color = hp_color
        elseif self.ship == 'Wraith' then
            self.trail_color = ammo_color
        elseif self.ship == 'Nexus' then
            self.trail_color = skill_point_color
        end
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
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.r)
    love.graphics.setColor(default_color)
    for _, polygon in ipairs(self.polygons) do
        love.graphics.polygon('line', polygon)
    end
    love.graphics.pop()
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
        v = 150
    })
end

function Player:die()
    self.dead = true
    slow(0.15, 1)
    flash(4)
    camera:shake(6, 60, 0.4)

    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
end

function Player:tick()
    self.area:addGameObject('TickEffect', self.x, self.y, {
        parent = self
    })
end
