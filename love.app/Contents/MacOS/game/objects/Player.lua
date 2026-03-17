Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    -- Basic Properties
    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)

    -- Player Resources

    self.max_boost = 100
    self.boost = self.max_boost

    self.max_fuel = 100
    self.fuel = self.max_fuel

    self.max_ammo = 120
    self.ammo = 80

    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

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

    self.ship_profile = self:getShipProfile(self.ship)
    self.weapon_mode = self.ship_profile.weapon
    self.special_name = self.ship_profile.special_name
    self.special_description = self.ship_profile.special_description
    self.evolution_tier = 0

    self.skill_profile = self:getSkillProfile(self.ship)
    self.skill_name = self.skill_profile.name
    self.skill_description = self.skill_profile.description
    self.skill_cooldown = self.skill_profile.cooldown
    self.skill_timer = 0
    self.skill_aiming = false
    self.skill_aim_duration = 1.4
    self.skill_aim_elapsed = 0
    self.skill_power_multiplier = 1

    self.damage_multiplier = 1
    self.projectile_speed_multiplier = 1
    self.fire_rate_multiplier = 1
    self.ammo_cost_multiplier = 1
    self.extra_projectiles = 0
    self.pierce_bonus = 0
    self.shield_chance = 0
    self.life_on_kill = 0

    -- Movement Properties
    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0

    self.max_v = self.base_max_v

    -- Shooting Properties
    self.base_fire_interval = (self.ship_profile.fire_interval or 0.18) * 1.45
    self.fire_timer = 0

    -- Tick Properties
    self.timer:every(5, function()
        self:tick()
    end)

    -- Health System
    self.max_hp = 100
    self.hp = self.max_hp

    -- Death
    input:bind('f', function()
        self:die()
    end)

end

function Player:update(dt)
    Player.super.update(self, dt)

    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
    self.fuel = math.min(self.fuel + 10 * dt, self.max_fuel)
    self.ammo = math.min(self.ammo + 5 * dt, self.max_ammo)
    self.boost_timer = self.boost_timer + dt
    self.skill_timer = math.max(0, self.skill_timer - dt)

    local mx, my
    if camera and camera.getMousePosition then
        mx, my = camera:getMousePosition(sx, sy)
    else
        mx, my = love.mouse.getPosition()
        mx, my = mx / sx, my / sy
    end

    local dx, dy = mx - self.x, my - self.y
    local dist_to_cursor = math.sqrt(dx * dx + dy * dy)

    self.r = math.atan2(dy, dx)

    self.max_v = self.base_max_v
    self.boosting = false

    if dist_to_cursor > 80 and self.fuel > 0 then
        self.boosting = true
        self.max_v = 1.45 * self.base_max_v
        self.fuel = math.max(0, self.fuel - 28 * dt)
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

    local target_v = math.min(self.max_v, dist_to_cursor * 3.2)
    self.v = self.v + (target_v - self.v) * math.min(1, 8 * dt)

    if dist_to_cursor < 5 then
        self.v = 0
    end

    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    self.fire_timer = self.fire_timer - dt
    if self.fire_timer <= 0 and not self.skill_aiming then
        self:shoot()
        self.fire_timer = self.base_fire_interval / math.max(0.25, self.fire_rate_multiplier)
    end

    if self.skill_aiming then
        self.skill_aim_elapsed = self.skill_aim_elapsed + dt
        slow_amount = 0.2
        if input:down('shoot') or self.skill_aim_elapsed >= self.skill_aim_duration then
            self:executeAimedSkill()
        end
    elseif input:pressed('skill') and self.skill_timer <= 0 then
        self:activateSkill()
    end

    local stage_w = (current_room and current_room.world_w) or gw
    local stage_h = (current_room and current_room.world_h) or gh

    if self.x < 0 then
        self:die()
    end
    if self.y < 0 then
        self:die()
    end
    if self.x > stage_w then
        self:die()
    end
    if self.y > stage_h then
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

    if self.evolution_tier >= 1 then
        uiColor(ammo_color)
        love.graphics.circle('line', 0, 0, self.w * 1.4)
        love.graphics.line(-self.w * 1.2, 0, self.w * 1.2, 0)
    end

    if self.evolution_tier >= 2 then
        uiColor(skill_point_color)
        love.graphics.polygon('line', 0, -self.w * 1.8, self.w * 1.4, 0, 0, self.w * 1.8, -self.w * 1.4, 0)
        love.graphics.circle('line', 0, 0, self.w * 1.9)
    end

    love.graphics.pop()

    if self.skill_aiming then
        local mx, my
        if camera and camera.getMousePosition then
            mx, my = camera:getMousePosition(sx, sy)
        else
            mx, my = love.mouse.getPosition()
            mx, my = mx / sx, my / sy
        end
        local pulse = 0.45 + 0.35 * math.sin(love.timer.getTime() * 8)
        uiColor(skill_point_color, pulse)
        love.graphics.circle('line', mx, my, 16)
        love.graphics.line(mx - 10, my, mx + 10, my)
        love.graphics.line(mx, my - 10, mx, my + 10)
    elseif self.skill_timer > 0 then
        local t = 1 - math.min(1, self.skill_timer / math.max(0.01, self.skill_cooldown))
        uiColor(ammo_color, 0.7)
        love.graphics.arc('line', self.x, self.y, self.w * 1.6, -math.pi / 2, -math.pi / 2 + t * math.pi * 2)
    end
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:shoot()
    local ammo_cost = math.max(1, math.floor((self.ship_profile.ammo_cost or 2) * self.ammo_cost_multiplier))
    if self.ammo < ammo_cost then
        return
    end

    self.ammo = self.ammo - ammo_cost
    playSfx('shoot', random(0.95, 1.08), 0.28)
    local d = 1.2 * self.w
    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), {
        player = self,
        d = d,
        color = self.trail_color
    })

    local function fire(angle_offset, speed_mult, size_mult, damage_mult, pierce)
        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r + angle_offset),
            self.y + 1.5 * d * math.sin(self.r + angle_offset), {
                r = self.r + angle_offset,
                v = (150 * (speed_mult or 1)) * self.projectile_speed_multiplier,
                s = 2.5 * (size_mult or 1),
                damage = (22 * (damage_mult or 1)) * self.damage_multiplier,
                pierce = (pierce or 1) + self.pierce_bonus,
                color = self.trail_color,
                owner = self
            })
    end

    if self.weapon_mode == 'dual' then
        fire(-0.08, 1, 1, 0.8, 1)
        fire(0.08, 1, 1, 0.8, 1)

    elseif self.weapon_mode == 'rail' then
        fire(0, 1.8, 0.9, 1.4, 2)

    elseif self.weapon_mode == 'bastion' then
        fire(-0.18, 0.85, 1.2, 0.9, 1)
        fire(0, 0.85, 1.2, 0.9, 1)
        fire(0.18, 0.85, 1.2, 0.9, 1)

    elseif self.weapon_mode == 'burst' then
        fire(0, 1.1, 0.9, 0.7, 1)
        self.timer:after(0.04, function()
            if not self.dead then
                fire(0, 1.1, 0.9, 0.7, 1)
            end
        end)
        self.timer:after(0.08, function()
            if not self.dead then
                fire(0, 1.1, 0.9, 0.7, 1)
            end
        end)

    elseif self.weapon_mode == 'cannon' then
        fire(0, 0.75, 2.0, 2.3, 1)

    elseif self.weapon_mode == 'serpent' then
        fire(-0.24, 1.15, 0.9, 0.8, 1)
        fire(0.24, 1.15, 0.9, 0.8, 1)

    elseif self.weapon_mode == 'phase' then
        fire(-0.04, 1.35, 0.9, 1.0, 2)
        self.timer:after(0.06, function()
            if not self.dead then
                fire(0.04, 1.35, 0.9, 1.0, 2)
            end
        end)

    elseif self.weapon_mode == 'arc' then
        fire(random(-0.2, 0.2), 1.2, 0.9, 0.9, 1)
        fire(random(-0.2, 0.2), 1.2, 0.9, 0.9, 1)
        fire(random(-0.2, 0.2), 1.2, 0.9, 0.9, 1)

    elseif self.weapon_mode == 'flare' then
        fire(-0.15, 1, 1.1, 1.0, 1)
        fire(0, 1, 1.1, 1.2, 1)
        fire(0.15, 1, 1.1, 1.0, 1)

    elseif self.weapon_mode == 'phantom' then
        fire(0, 1.5, 0.8, 0.9, 3)

    elseif self.weapon_mode == 'hex' then
        fire(-0.24, 1.0, 0.9, 0.8, 1)
        fire(-0.12, 1.0, 0.9, 0.8, 1)
        fire(0, 1.0, 0.9, 0.8, 1)
        fire(0.12, 1.0, 0.9, 0.8, 1)
        fire(0.24, 1.0, 0.9, 0.8, 1)

    else
        fire(0, 1, 1, 1, 1)
    end

    for i = 1, self.extra_projectiles do
        fire(random(-0.15, 0.15), 1, 0.8, 0.6, 1)
    end

    if self.evolution_tier >= 1 then
        if self.ship == 'Fighter' then
            fire(math.pi, 0.9, 0.8, 0.6, 1)
        elseif self.ship == 'Striker' then
            fire(0, 2.3, 0.8, 1.2, 3)
        elseif self.ship == 'Sentinel' then
            fire(-0.35, 0.8, 1.0, 0.7, 1)
            fire(0.35, 0.8, 1.0, 0.7, 1)
        elseif self.ship == 'Shadow' then
            fire(random(-0.3, 0.3), 1.3, 0.8, 0.8, 1)
        elseif self.ship == 'Titan' then
            fire(0, 0.7, 2.4, 2.8, 2)
        elseif self.ship == 'Viper' then
            fire(-0.38, 1.25, 0.8, 0.7, 1)
            fire(0.38, 1.25, 0.8, 0.7, 1)
        elseif self.ship == 'Specter' then
            self.timer:after(0.08, function()
                if not self.dead then
                    fire(0, 1.2, 0.9, 0.9, 2)
                end
            end)
        elseif self.ship == 'Tempest' then
            for i = 1, 2 do
                fire(random(-0.4, 0.4), 1.4, 0.75, 0.7, 1)
            end
        elseif self.ship == 'Phoenix' then
            fire(math.pi, 1.0, 0.9, 0.7, 1)
        elseif self.ship == 'Wraith' then
            fire(0, 1.7, 0.75, 0.95, 3)
        elseif self.ship == 'Nexus' then
            fire(-0.3, 1.1, 0.8, 0.7, 1)
            fire(0.3, 1.1, 0.8, 0.7, 1)
        end
    end

    if self.evolution_tier >= 2 then
        if self.ship == 'Fighter' then
            fire(-0.45, 1.2, 0.75, 0.7, 1)
            fire(0.45, 1.2, 0.75, 0.7, 1)
        elseif self.ship == 'Striker' then
            self.timer:after(0.04, function()
                if not self.dead then
                    fire(0, 2.5, 0.75, 1.4, 4)
                end
            end)
        elseif self.ship == 'Sentinel' then
            fire(-0.52, 0.75, 1.1, 0.8, 1)
            fire(0.52, 0.75, 1.1, 0.8, 1)
        elseif self.ship == 'Shadow' then
            for i = 1, 2 do
                fire(random(-0.5, 0.5), 1.4, 0.75, 0.8, 1)
            end
        elseif self.ship == 'Titan' then
            fire(-0.2, 0.65, 2.0, 1.8, 1)
            fire(0.2, 0.65, 2.0, 1.8, 1)
        elseif self.ship == 'Viper' then
            fire(-0.55, 1.35, 0.7, 0.65, 1)
            fire(0.55, 1.35, 0.7, 0.65, 1)
        elseif self.ship == 'Specter' then
            self.timer:after(0.12, function()
                if not self.dead then
                    fire(0, 1.4, 0.8, 1.0, 3)
                end
            end)
        elseif self.ship == 'Tempest' then
            for i = 1, 3 do
                fire(random(-0.55, 0.55), 1.55, 0.7, 0.68, 1)
            end
        elseif self.ship == 'Phoenix' then
            fire(-0.3, 1.15, 0.85, 0.85, 1)
            fire(0.3, 1.15, 0.85, 0.85, 1)
            fire(math.pi, 1.05, 0.85, 0.8, 1)
        elseif self.ship == 'Wraith' then
            self.timer:after(0.05, function()
                if not self.dead then
                    fire(0, 1.9, 0.7, 1.05, 4)
                end
            end)
        elseif self.ship == 'Nexus' then
            fire(-0.45, 1.15, 0.75, 0.7, 1)
            fire(0.45, 1.15, 0.75, 0.7, 1)
            fire(math.pi, 1.0, 0.75, 0.65, 1)
        end
    end
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
function Player:takeDamage(amount)
    if self.shield_chance > 0 and love.math.random() < self.shield_chance then
        self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {
            color = boost_color,
            w = 14
        })
        return
    end

    if self.ship == 'Titan' then
        amount = amount * (self.evolution_tier >= 1 and 0.65 or 0.8)
    end

    self.hp = self.hp - amount
    playSfx('hit', random(0.92, 1.04), 0.35)
    flash(2)
    if self.hp <= 0 then
        self:die()
    end
end

function Player:addAmmo(amount)
    self.ammo = math.min(self.max_ammo, self.ammo + amount)
end

function Player:addFuel(amount)
    self.fuel = math.min(self.max_fuel, self.fuel + amount)
end

function Player:addHp(amount)
    self.hp = math.min(self.max_hp, self.hp + amount)
end

function Player:onEnemyKilled()
    if self.life_on_kill > 0 then
        self:addHp(self.life_on_kill)
    end

    if self.ship == 'Phoenix' and self.evolution_tier >= 1 then
        self:addFuel(2)
    end
end

function Player:spawnSkillProjectile(angle, config)
    config = config or {}
    local d = config.offset or (1.5 * self.w)
    self.area:addGameObject('Projectile', self.x + d * math.cos(angle), self.y + d * math.sin(angle), {
        r = angle,
        v = (config.v or 220) * self.projectile_speed_multiplier,
        s = config.s or 3.2,
        damage = (config.damage or 80) * self.damage_multiplier * self.skill_power_multiplier,
        pierce = (config.pierce or 1) + self.pierce_bonus,
        color = config.color or skill_point_color,
        owner = self
    })
end

function Player:activateSkill()
    if self.skill_timer > 0 then
        return
    end

    if self.skill_profile.aimed then
        self.skill_aiming = true
        self.skill_aim_elapsed = 0
        playSfx('wave', random(1.05, 1.15), 0.24)
        return
    end

    self:executeSkillPattern(self.r)
    self.skill_timer = self.skill_cooldown
end

function Player:executeAimedSkill()
    if not self.skill_aiming then
        return
    end

    self.skill_aiming = false
    self.skill_aim_elapsed = 0
    slow_amount = 1

    local mx, my
    if camera and camera.getMousePosition then
        mx, my = camera:getMousePosition(sx, sy)
    else
        mx, my = love.mouse.getPosition()
        mx, my = mx / sx, my / sy
    end
    local angle = math.atan2(my - self.y, mx - self.x)
    self:executeSkillPattern(angle)
    self.skill_timer = self.skill_cooldown
end

function Player:executeSkillPattern(angle)
    local enemies = self.area:getGameObjects(function(go)
        return go.is_enemy == true
    end)

    playSfx('wave', random(0.95, 1.08), 0.34)
    flash(2)
    camera:shake(3.2, 56, 0.12)

    local evo_bonus = self.evolution_tier

    if self.ship == 'Fighter' then
        for i = 0, 7 + evo_bonus do
            self:spawnSkillProjectile(angle + i * (math.pi / 4), {v = 240, s = 3.0, damage = 62, pierce = 1, color = ammo_color})
        end

    elseif self.ship == 'Striker' then
        self:spawnSkillProjectile(angle, {v = 380, s = 4.0, damage = 220, pierce = 6, color = skill_point_color})
        self:spawnSkillProjectile(angle - 0.03, {v = 340, s = 3.0, damage = 120, pierce = 3, color = default_color})
        self:spawnSkillProjectile(angle + 0.03, {v = 340, s = 3.0, damage = 120, pierce = 3, color = default_color})

    elseif self.ship == 'Sentinel' then
        self:addHp(16)
        for _, enemy in ipairs(enemies) do
            if distance(self.x, self.y, enemy.x, enemy.y) < 120 and enemy.takeDamage then
                enemy:takeDamage(95 * self.damage_multiplier * self.skill_power_multiplier)
            end
        end
        for i = 1, 6 do
            self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = boost_color, w = 24 + i * 4})
        end

    elseif self.ship == 'Shadow' then
        self.fire_rate_multiplier = self.fire_rate_multiplier + 0.45
        self.timer:after(2.4, function()
            if not self.dead then
                self.fire_rate_multiplier = self.fire_rate_multiplier - 0.45
            end
        end)
        for i = 1, 5 do
            self:spawnSkillProjectile(angle + random(-0.45, 0.45), {v = 260, s = 2.8, damage = 70, pierce = 2, color = boost_color})
        end

    elseif self.ship == 'Titan' then
        for _, enemy in ipairs(enemies) do
            if distance(self.x, self.y, enemy.x, enemy.y) < 150 and enemy.takeDamage then
                enemy:takeDamage(160 * self.damage_multiplier * self.skill_power_multiplier)
            end
        end
        self:spawnSkillProjectile(angle, {v = 220, s = 5.6, damage = 260, pierce = 4, color = hp_color})

    elseif self.ship == 'Viper' then
        for i = -3, 3 do
            self:spawnSkillProjectile(angle + i * 0.12, {v = 280, s = 2.6, damage = 72, pierce = 1, color = ammo_color})
        end

    elseif self.ship == 'Specter' then
        for i = 1, 4 do
            self.timer:after(i * 0.08, function()
                if not self.dead then
                    self:spawnSkillProjectile(angle, {v = 300, s = 3.2, damage = 86, pierce = 4, color = skill_point_color})
                end
            end)
        end

    elseif self.ship == 'Tempest' then
        for i = 1, 12 do
            self:spawnSkillProjectile(random(-math.pi, math.pi), {v = 270, s = 2.4, damage = 56, pierce = 1, color = boost_color})
        end

    elseif self.ship == 'Phoenix' then
        self:addHp(20)
        self:addFuel(24)
        for i = 0, 9 do
            self:spawnSkillProjectile(angle + i * (math.pi / 5), {v = 230, s = 3.5, damage = 74, pierce = 2, color = hp_color})
        end

    elseif self.ship == 'Wraith' then
        self:spawnSkillProjectile(angle, {v = 420, s = 3.2, damage = 180, pierce = 8, color = skill_point_color})
        self.timer:after(0.05, function()
            if not self.dead then
                self:spawnSkillProjectile(angle, {v = 420, s = 2.8, damage = 140, pierce = 6, color = default_color})
            end
        end)

    elseif self.ship == 'Nexus' then
        for i = 0, 5 do
            self:spawnSkillProjectile(angle + i * (math.pi / 3), {v = 250, s = 3.0, damage = 66, pierce = 2, color = skill_point_color})
        end
        self:spawnSkillProjectile(angle, {v = 320, s = 3.8, damage = 130, pierce = 4, color = ammo_color})

    else
        self:spawnSkillProjectile(angle, {v = 260, s = 3.0, damage = 90, pierce = 2, color = skill_point_color})
    end

    for i = 1, 6 do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {
            color = skill_point_color,
            s = random(2, 5),
            d = random(0.15, 0.28),
            v = random(50, 120)
        })
    end
end

function Player:getSkillProfile(ship)
    local profiles = {
        Fighter = {name = 'Orbit Barrage', description = 'Burst ring around ship', cooldown = 6.5, aimed = false},
        Striker = {name = 'Piercing Spear', description = 'Aimed rail strike', cooldown = 8.0, aimed = true},
        Sentinel = {name = 'Bulwark Pulse', description = 'AoE blast + self repair', cooldown = 9.0, aimed = false},
        Shadow = {name = 'Ambush Drive', description = 'Rapid-fire frenzy', cooldown = 7.5, aimed = false},
        Titan = {name = 'Siege Breaker', description = 'Heavy shockwave shell', cooldown = 10.0, aimed = false},
        Viper = {name = 'Fang Fan', description = 'Aimed venom spread', cooldown = 7.0, aimed = true},
        Specter = {name = 'Echo Lances', description = 'Delayed phasing shots', cooldown = 7.5, aimed = true},
        Tempest = {name = 'Storm Burst', description = 'Chaotic all-angle spray', cooldown = 7.0, aimed = false},
        Phoenix = {name = 'Solar Nova', description = 'Self-heal radial flare', cooldown = 9.0, aimed = false},
        Wraith = {name = 'Abyss Rail', description = 'Aimed high-pierce beam', cooldown = 8.5, aimed = true},
        Nexus = {name = 'Lattice Overrun', description = 'Hex burst + center lance', cooldown = 8.0, aimed = true}
    }

    return profiles[ship] or {name = 'Pulse', description = 'Combat burst', cooldown = 7.0, aimed = false}
end

function Player:getShipProfile(ship)
    local profiles = {
        Fighter = {
            weapon = 'dual', fire_interval = 0.16, ammo_cost = 2,
            special_name = 'Interceptor Frame',
            special_description = 'Balanced dual-fire platform',
            evolutions = {
                {name = 'Fighter Mk-II', description = '+fire rate, +damage', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.2; p.damage_multiplier = p.damage_multiplier + 0.1 end},
                {name = 'Fighter Overdrive', description = 'extra shots + pierce', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1; p.pierce_bonus = p.pierce_bonus + 1 end}
            }
        },
        Striker = {
            weapon = 'rail', fire_interval = 0.22, ammo_cost = 3,
            special_name = 'Rail Lance',
            special_description = 'High-speed piercing rails',
            evolutions = {
                {name = 'Striker Hyperline', description = '+proj speed, +pierce', apply = function(p) p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.25; p.pierce_bonus = p.pierce_bonus + 1 end},
                {name = 'Striker Cataclysm', description = '+damage, +fire rate', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.35; p.fire_rate_multiplier = p.fire_rate_multiplier + 0.15 end}
            }
        },
        Sentinel = {
            weapon = 'bastion', fire_interval = 0.24, ammo_cost = 3,
            special_name = 'Bastion Spread',
            special_description = 'Wide suppressive volleys',
            evolutions = {
                {name = 'Sentinel Guard', description = '+max hp, +shield chance', apply = function(p) p.max_hp = p.max_hp + 25; p.hp = p.hp + 25; p.shield_chance = p.shield_chance + 0.08 end},
                {name = 'Sentinel Fortress', description = '+shield chance, +extra shot', apply = function(p) p.shield_chance = p.shield_chance + 0.1; p.extra_projectiles = p.extra_projectiles + 1 end}
            }
        },
        Shadow = {
            weapon = 'burst', fire_interval = 0.27, ammo_cost = 2,
            special_name = 'Ambush Burst',
            special_description = 'Multi-shot burst weapon',
            evolutions = {
                {name = 'Shadow Reaper', description = '+fire rate, +ammo efficiency', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.25; p.ammo_cost_multiplier = p.ammo_cost_multiplier - 0.15 end},
                {name = 'Shadow Voidstep', description = '+speed, +shield chance', apply = function(p) p.base_max_v = p.base_max_v + 35; p.shield_chance = p.shield_chance + 0.08 end}
            }
        },
        Titan = {
            weapon = 'cannon', fire_interval = 0.34, ammo_cost = 4,
            special_name = 'Siege Cannon',
            special_description = 'Heavy impact rounds',
            evolutions = {
                {name = 'Titan Juggernaut', description = '+hp, +damage reduction', apply = function(p) p.max_hp = p.max_hp + 40; p.hp = p.hp + 40 end},
                {name = 'Titan Dreadnought', description = '+damage, +pierce', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.45; p.pierce_bonus = p.pierce_bonus + 1 end}
            }
        },
        Viper = {
            weapon = 'serpent', fire_interval = 0.17, ammo_cost = 2,
            special_name = 'Serpent Weave',
            special_description = 'Curved flanking fire',
            evolutions = {
                {name = 'Viper Coil', description = '+speed, +fire rate', apply = function(p) p.base_max_v = p.base_max_v + 30; p.fire_rate_multiplier = p.fire_rate_multiplier + 0.2 end},
                {name = 'Viper Venom', description = '+damage, +extra shots', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.2; p.extra_projectiles = p.extra_projectiles + 1 end}
            }
        },
        Specter = {
            weapon = 'phase', fire_interval = 0.2, ammo_cost = 2,
            special_name = 'Phase Pulse',
            special_description = 'Delayed phasing strikes',
            evolutions = {
                {name = 'Specter Echo', description = '+pierce, +shield chance', apply = function(p) p.pierce_bonus = p.pierce_bonus + 1; p.shield_chance = p.shield_chance + 0.06 end},
                {name = 'Specter Phantom', description = '+ammo efficiency, +fire rate', apply = function(p) p.ammo_cost_multiplier = p.ammo_cost_multiplier - 0.2; p.fire_rate_multiplier = p.fire_rate_multiplier + 0.15 end}
            }
        },
        Tempest = {
            weapon = 'arc', fire_interval = 0.18, ammo_cost = 2,
            special_name = 'Storm Arc',
            special_description = 'Chaotic lightning-like spread',
            evolutions = {
                {name = 'Tempest Surge', description = '+fire rate, +proj speed', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.2; p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.2 end},
                {name = 'Tempest Supercell', description = '+extra shots, +damage', apply = function(p) p.extra_projectiles = p.extra_projectiles + 2; p.damage_multiplier = p.damage_multiplier + 0.15 end}
            }
        },
        Phoenix = {
            weapon = 'flare', fire_interval = 0.21, ammo_cost = 3,
            special_name = 'Solar Flare',
            special_description = 'Tri-flare combustion volleys',
            evolutions = {
                {name = 'Phoenix Emberheart', description = 'heal on kill + fuel gain', apply = function(p) p.life_on_kill = p.life_on_kill + 2 end},
                {name = 'Phoenix Supernova', description = '+damage, +extra shot', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.3; p.extra_projectiles = p.extra_projectiles + 1 end}
            }
        },
        Wraith = {
            weapon = 'phantom', fire_interval = 0.15, ammo_cost = 1,
            special_name = 'Phantom Rail',
            special_description = 'Low-cost piercing sniper fire',
            evolutions = {
                {name = 'Wraith Umbral', description = '+pierce, +speed', apply = function(p) p.pierce_bonus = p.pierce_bonus + 1; p.base_max_v = p.base_max_v + 20 end},
                {name = 'Wraith Oblivion', description = '+fire rate, +shield chance', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.25; p.shield_chance = p.shield_chance + 0.08 end}
            }
        },
        Nexus = {
            weapon = 'hex', fire_interval = 0.24, ammo_cost = 3,
            special_name = 'Hex Array',
            special_description = 'Multi-vector combat lattice',
            evolutions = {
                {name = 'Nexus Lattice', description = '+extra projectiles, +speed', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1; p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.15 end},
                {name = 'Nexus Singularity', description = '+damage, +pierce, +shield', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.25; p.pierce_bonus = p.pierce_bonus + 1; p.shield_chance = p.shield_chance + 0.05 end}
            }
        }
    }

    return profiles[ship] or profiles.Fighter
end

function Player:getEvolutionData(next_tier)
    if not self.ship_profile or not self.ship_profile.evolutions then
        return nil
    end
    return self.ship_profile.evolutions[next_tier]
end

function Player:applyEvolution(evo_data)
    if not evo_data then
        return
    end

    self.evolution_tier = self.evolution_tier + 1
    if evo_data.apply then
        evo_data.apply(self)
    end

    self.skill_power_multiplier = self.skill_power_multiplier + 0.2
    self.skill_cooldown = math.max(3.0, self.skill_cooldown - 0.75)
    self.skill_aim_duration = math.max(0.8, self.skill_aim_duration - 0.2)

    self.fire_timer = 0
end