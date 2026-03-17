Stage = Object:extend()

function Stage:new()
    self.area = Area()
    self.area:addPhysicsWorld()

    self.timer = Timer()
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.world_w = math.floor(gw * 1.8)
    self.world_h = math.floor(gh * 1.8)
    self.camera_zoom = 0.84

    self.player = self.area:addGameObject('Player', self.world_w / 2, self.world_h / 2)

    self.score = 0
    self.run_time = 0
    self.wave = 1
    self.enemies_spawned = 0
    self.enemies_per_wave = 5
    self.spawn_delay = 1.15
    self.spawn_timer = 0
    self.boss_wave = false

    self.resource_spawn_timer = 0
    self.resource_spawn_delay = 4
    self.ammo_spawn_timer = 0
    self.ammo_spawn_delay = 5

    self.game_over = false
    self.show_debug = false

    self.progression_active = false
    self.progression_queue = {}
    self.progression_choices = {}
    self.progression_selected = 1
    self.progression_type = nil
    self.pending_wave = nil
    self.progression_input_lock = false
    self.progression_mouse_lock = false
    self.progression_card_rects = {}

    self.timer:after(0.5, function()
        self.area:addGameObject('WaveStart', self.world_w / 2, self.world_h / 2, {wave = self.wave})
    end)

    input:bind('f3', function()
        if self.player then
            self.player.dead = true
            self.player = nil
        end
    end)

    input:bind('escape', function()
        gotoRoom('MainMenu')
    end)

    input:bind('f1', function()
        self.show_debug = not self.show_debug
    end)
end

function Stage:update(dt)
    camera.smoother = Camera.smooth.damped(5)

    local lock_x, lock_y = self.world_w / 2, self.world_h / 2
    if self.player and not self.player.dead then
        lock_x = self.player.x
        lock_y = self.player.y
    end

    local view_w = gw / self.camera_zoom
    local view_h = gh / self.camera_zoom
    lock_x = math.max(view_w * 0.5, math.min(self.world_w - view_w * 0.5, lock_x))
    lock_y = math.max(view_h * 0.5, math.min(self.world_h - view_h * 0.5, lock_y))

    camera:zoomTo(self.camera_zoom)
    camera:lockPosition(dt, lock_x, lock_y)

    self.timer:update(dt)

    if current_room ~= self or not self.area then
        return
    end

    if self.progression_active then
        self:updateProgressionInput()
        return
    end

    self.area:update(dt)

    if self.player and self.player.dead then
        self.game_over = true
    end

    if self.game_over then
        self.timer:after(1, function()
            gotoRoom('GameOver', self.score)
        end)
        self.game_over = false
    end

    self.spawn_timer = self.spawn_timer + dt
    self.resource_spawn_timer = self.resource_spawn_timer + dt
    self.ammo_spawn_timer = self.ammo_spawn_timer + dt
    self.run_time = self.run_time + dt

    local enemies = self.area:getGameObjects(function(go)
        return go.is_enemy == true
    end)

    if self.player and not self.player.dead then
        for _, enemy in ipairs(enemies) do
            enemy.contact_hit_timer = math.max(0, (enemy.contact_hit_timer or 0) - dt)
            local dist = distance(enemy.x, enemy.y, self.player.x, self.player.y)
            if dist < (enemy.w or 10) + self.player.w and enemy.contact_hit_timer <= 0 then
                if self.player.takeDamage then
                    self.player:takeDamage(enemy.contact_damage or 10)
                end
                enemy.contact_hit_timer = enemy.contact_hit_interval or 0.25
            end
        end
    end

    if self.spawn_timer >= self.spawn_delay and self.enemies_spawned < self.enemies_per_wave then
        self:spawnEnemy()
        self.enemies_spawned = self.enemies_spawned + 1
        self.spawn_timer = 0
    end

    if self.resource_spawn_timer >= self.resource_spawn_delay then
        self:spawnResource()
        self.resource_spawn_timer = 0
        self.resource_spawn_delay = random(3.5, 6.5)
    end

    if self.ammo_spawn_timer >= self.ammo_spawn_delay then
        self.area:addGameObject('Ammo', random(20, self.world_w - 20), random(20, self.world_h - 20), {
            value = love.math.random(20, 34)
        })
        self.ammo_spawn_timer = 0
        self.ammo_spawn_delay = random(4.5, 7.5)
    end

    if #enemies == 0 and self.enemies_spawned >= self.enemies_per_wave and self.enemies_spawned > 0 then
        self:startWaveRewards()
    end

    local projectiles = self.area:getGameObjects(function(go)
        return go.class == 'Projectile'
    end)

    for _, projectile in ipairs(projectiles) do
        if projectile.dead then
            goto continue_projectile
        end

        for _, enemy in ipairs(enemies) do
            local dist = distance(projectile.x, projectile.y, enemy.x, enemy.y)
            if dist < projectile.s + enemy.w then
                local was_dead = enemy.dead

                if enemy.takeDamage then
                    enemy:takeDamage(projectile.damage or 50)
                end

                self.area:addGameObject('ProjectileDeathEffect', projectile.x, projectile.y, {
                    color = hp_color,
                    w = 9
                })

                self.area:addGameObject('ExplodeParticle', projectile.x, projectile.y, {
                    color = hp_color,
                    s = random(2, 4),
                    d = random(0.1, 0.18),
                    v = random(45, 95)
                })
                playSfx('hit', random(0.9, 1.12), 0.26)

                if not was_dead and enemy.dead then
                    self.score = self.score + 10
                    if projectile.owner and projectile.owner.onEnemyKilled then
                        projectile.owner:onEnemyKilled()
                    end
                    self.area:addGameObject('Ammo', enemy.x, enemy.y, {
                        value = love.math.random(26, 42),
                        size_scale = 1.0
                    })
                    camera:shake(2.2, 42, 0.08)
                end

                projectile.remaining_hits = (projectile.remaining_hits or 1) - 1
                if projectile.remaining_hits <= 0 then
                    projectile:die()
                end
                break
            end
        end

        ::continue_projectile::
    end
end

function Stage:startWaveRewards()
    self.pending_wave = self.wave + 1
    self.progression_queue = {'upgrade'}

    if self.pending_wave % 5 == 0 and self.player and self.player.evolution_tier < 2 then
        table.insert(self.progression_queue, 'evolution')
    end

    self:openNextProgressionStep()
end

function Stage:openNextProgressionStep()
    local step = table.remove(self.progression_queue, 1)
    if not step then
        self.progression_active = false
        self:advanceToPendingWave()
        return
    end

    self.progression_active = true
    self.progression_type = step
    self.progression_selected = 1
    self.progression_input_lock = true
    self.progression_mouse_lock = true

    if step == 'upgrade' then
        self.progression_choices = self:generateUpgradeChoices(3)
    elseif step == 'evolution' and self.player then
        local evo = self.player:getEvolutionData(self.player.evolution_tier + 1)
        if evo then
            self.progression_choices = {
                {
                    title = evo.name,
                    description = evo.description,
                    apply = function()
                        self.player:applyEvolution(evo)
                    end
                }
            }
        else
            self.progression_choices = {}
            self:openNextProgressionStep()
            return
        end
    end
end

function Stage:generateUpgradeChoices(count)
    local pool = {
        {
            title = 'Overclocked Chambers',
            description = '+15% fire rate',
            apply = function(p)
                p.fire_rate_multiplier = p.fire_rate_multiplier + 0.15
            end
        },
        {
            title = 'Mag Driver',
            description = '+16% projectile speed',
            apply = function(p)
                p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.16
            end
        },
        {
            title = 'Flux Injector',
            description = '+18 max fuel',
            apply = function(p)
                p.max_fuel = p.max_fuel + 18
                p.fuel = p.fuel + 18
            end
        },
        {
            title = 'Ammo Lattice',
            description = '+24 max ammo',
            apply = function(p)
                p.max_ammo = p.max_ammo + 24
                p.ammo = p.ammo + 24
            end
        },
        {
            title = 'Reinforced Hull',
            description = '+16 max hp',
            apply = function(p)
                p.max_hp = p.max_hp + 16
                p.hp = p.hp + 16
            end
        },
        {
            title = 'Targeting AI',
            description = '+14% damage',
            apply = function(p)
                p.damage_multiplier = p.damage_multiplier + 0.14
            end
        },
        {
            title = 'Ammo Economizer',
            description = '-12% ammo cost',
            apply = function(p)
                p.ammo_cost_multiplier = p.ammo_cost_multiplier - 0.12
            end
        },
        {
            title = 'Vector Thrusters',
            description = '+16 max speed',
            apply = function(p)
                p.base_max_v = p.base_max_v + 16
            end
        }
    }

    if self.player then
        local class_pool = self:getClassUpgradePool(self.player.ship)
        for _, item in ipairs(class_pool) do
            table.insert(pool, item)
        end
    end

    local choices = {}
    local indices = {}

    while #choices < count and #indices < #pool do
        local idx = love.math.random(1, #pool)
        local exists = false
        for _, used in ipairs(indices) do
            if used == idx then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(indices, idx)
            table.insert(choices, pool[idx])
        end
    end

    return choices
end

function Stage:getClassUpgradePool(ship)
    local pools = {
        Fighter = {
            {title = 'Interceptor Gyro', description = '+1 rear support shot', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1 end},
            {title = 'Dogfight Core', description = '+18% fire rate, +8% speed', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.18; p.base_max_v = p.base_max_v + 8 end}
        },
        Striker = {
            {title = 'Rail Capacitor', description = '+28% rail damage', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.28 end},
            {title = 'Linebreaker', description = '+1 pierce, +12% proj speed', apply = function(p) p.pierce_bonus = p.pierce_bonus + 1; p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.12 end}
        },
        Sentinel = {
            {title = 'Bulwark Plating', description = '+24 max hp, +6% shield', apply = function(p) p.max_hp = p.max_hp + 24; p.hp = p.hp + 24; p.shield_chance = p.shield_chance + 0.06 end},
            {title = 'Guard Matrix', description = '+1 side shot, +4 hp on kill', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1; p.life_on_kill = p.life_on_kill + 4 end}
        },
        Shadow = {
            {title = 'Void Injector', description = '+22% fire rate, -10% ammo cost', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.22; p.ammo_cost_multiplier = p.ammo_cost_multiplier - 0.10 end},
            {title = 'Night Drift', description = '+18 speed, +6% shield', apply = function(p) p.base_max_v = p.base_max_v + 18; p.shield_chance = p.shield_chance + 0.06 end}
        },
        Titan = {
            {title = 'Siege Hull', description = '+32 max hp', apply = function(p) p.max_hp = p.max_hp + 32; p.hp = p.hp + 32 end},
            {title = 'Breach Shell', description = '+30% damage, +1 pierce', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.30; p.pierce_bonus = p.pierce_bonus + 1 end}
        },
        Viper = {
            {title = 'Venom Coil', description = '+1 extra projectile', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1 end},
            {title = 'Snap Accelerant', description = '+16% fire rate, +14 speed', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.16; p.base_max_v = p.base_max_v + 14 end}
        },
        Specter = {
            {title = 'Echo Chamber', description = '+1 pierce, +14% skill power', apply = function(p) p.pierce_bonus = p.pierce_bonus + 1; p.skill_power_multiplier = p.skill_power_multiplier + 0.14 end},
            {title = 'Fade Lattice', description = '-12% ammo cost, +6% shield', apply = function(p) p.ammo_cost_multiplier = p.ammo_cost_multiplier - 0.12; p.shield_chance = p.shield_chance + 0.06 end}
        },
        Tempest = {
            {title = 'Arc Reactor', description = '+2 extra projectiles', apply = function(p) p.extra_projectiles = p.extra_projectiles + 2 end},
            {title = 'Storm Relay', description = '+18% proj speed, +12% skill power', apply = function(p) p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.18; p.skill_power_multiplier = p.skill_power_multiplier + 0.12 end}
        },
        Phoenix = {
            {title = 'Heartflame Core', description = '+8 hp on kill', apply = function(p) p.life_on_kill = p.life_on_kill + 8 end},
            {title = 'Solar Feathers', description = '+20 max fuel, +14% damage', apply = function(p) p.max_fuel = p.max_fuel + 20; p.fuel = p.fuel + 20; p.damage_multiplier = p.damage_multiplier + 0.14 end}
        },
        Wraith = {
            {title = 'Umbra Spindle', description = '+2 pierce', apply = function(p) p.pierce_bonus = p.pierce_bonus + 2 end},
            {title = 'Ghost Trigger', description = '+20% fire rate, +10% skill power', apply = function(p) p.fire_rate_multiplier = p.fire_rate_multiplier + 0.20; p.skill_power_multiplier = p.skill_power_multiplier + 0.10 end}
        },
        Nexus = {
            {title = 'Lattice Fork', description = '+1 extra projectile, +10% speed', apply = function(p) p.extra_projectiles = p.extra_projectiles + 1; p.projectile_speed_multiplier = p.projectile_speed_multiplier + 0.10 end},
            {title = 'Core Fractal', description = '+18% skill power, +10% damage', apply = function(p) p.skill_power_multiplier = p.skill_power_multiplier + 0.18; p.damage_multiplier = p.damage_multiplier + 0.10 end}
        }
    }

    return pools[ship] or {
        {title = 'Combat Refinement', description = '+10% damage, +10% skill power', apply = function(p) p.damage_multiplier = p.damage_multiplier + 0.10; p.skill_power_multiplier = p.skill_power_multiplier + 0.10 end}
    }
end

function Stage:updateProgressionInput()
    local mx, my = love.mouse.getPosition()

    local hovered = nil
    for i, rect in ipairs(self.progression_card_rects) do
        if mx >= rect.x and mx <= rect.x + rect.w and my >= rect.y and my <= rect.y + rect.h then
            hovered = i
            break
        end
    end

    if hovered then
        self.progression_selected = hovered
    end

    local mouse_down = love.mouse.isDown(1)
    local key_1 = love.keyboard.isDown('1')
    local key_2 = love.keyboard.isDown('2')
    local key_3 = love.keyboard.isDown('3')
    local key_enter = love.keyboard.isDown('return') or love.keyboard.isDown('kpenter')

    local any_down = key_1 or key_2 or key_3 or key_enter

    if not self.progression_input_lock then
        if key_1 and #self.progression_choices >= 1 then
            self.progression_selected = 1
            self.progression_input_lock = true
        elseif key_2 and #self.progression_choices >= 2 then
            self.progression_selected = 2
            self.progression_input_lock = true
        elseif key_3 and #self.progression_choices >= 3 then
            self.progression_selected = 3
            self.progression_input_lock = true
        elseif key_enter and self.progression_choices[self.progression_selected] then
            local choice = self.progression_choices[self.progression_selected]
            if choice.apply and self.player then
                choice.apply(self.player)
            end

            playSfx('pickup', random(1.08, 1.2), 0.34)
            self.progression_input_lock = true
            self:openNextProgressionStep()
        end
    end

    if not self.progression_mouse_lock and mouse_down and hovered and self.progression_choices[hovered] then
        self.progression_selected = hovered
        local choice = self.progression_choices[self.progression_selected]
        if choice.apply and self.player then
            choice.apply(self.player)
        end
        playSfx('pickup', random(1.08, 1.2), 0.34)
        self.progression_mouse_lock = true
        self:openNextProgressionStep()
    end

    if not any_down then
        self.progression_input_lock = false
    end

    if not mouse_down then
        self.progression_mouse_lock = false
    end
end

function Stage:advanceToPendingWave()
    self.wave = self.pending_wave or (self.wave + 1)
    self.pending_wave = nil
    self.boss_wave = (self.wave % 5 == 0)

    self.enemies_spawned = 0
    if self.boss_wave then
        self.enemies_per_wave = 1
        self.spawn_delay = 0.8
    else
        self.enemies_per_wave = 5 + (self.wave - 1) * 2
        self.spawn_delay = math.max(0.3, 1.15 - (self.wave - 1) * 0.06)
    end
    self.spawn_timer = 0

    self.area:addGameObject('WaveStart', self.world_w / 2, self.world_h / 2, {wave = self.wave})
end

function Stage:spawnEnemy()
    if self.boss_wave then
        self.area:addGameObject('BossEnemy', self.world_w / 2, -40, {
            wave = self.wave
        })
        return
    end

    local spawn_x, spawn_y
    local side = love.math.random(1, 4)

    if side == 1 then
        spawn_x = random(0, self.world_w)
        spawn_y = -20
    elseif side == 2 then
        spawn_x = self.world_w + 20
        spawn_y = random(0, self.world_h)
    elseif side == 3 then
        spawn_x = random(0, self.world_w)
        spawn_y = self.world_h + 20
    else
        spawn_x = -20
        spawn_y = random(0, self.world_h)
    end

    local enemy_types = {'BasicEnemy', 'DasherEnemy', 'WeaverEnemy'}
    if self.wave >= 3 then
        table.insert(enemy_types, 'TurretEnemy')
    end

    local enemy_type = enemy_types[love.math.random(1, #enemy_types)]
    self.area:addGameObject(enemy_type, spawn_x, spawn_y)
end

function Stage:spawnResource()
    local x = random(20, self.world_w - 20)
    local y = random(20, self.world_h - 20)

    local r = love.math.random()
    if r < 0.42 then
        self.area:addGameObject('Ammo', x, y, {value = love.math.random(18, 32)})
    elseif r < 0.74 then
        self.area:addGameObject('FuelCell', x, y, {value = love.math.random(18, 30)})
    else
        self.area:addGameObject('RepairPack', x, y, {value = love.math.random(12, 22)})
    end
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
    self.area:draw()
    camera:detach()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')

    self:drawHUD()

    if self.progression_active then
        self:drawProgressionMenu()
    end
end

function Stage:drawHUD()
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()
    local enemies = self.area:getGameObjects(function(go)
        return go.is_enemy == true
    end)

    drawPixelPanel(8, 8, 248, 104, ui_mid, ui_accent)
    if self.player then
        drawPixelPanel(16, 16, 72, 72, ui_dark, default_color)
        love.graphics.push()
        love.graphics.translate(52, 52)
        love.graphics.rotate(-math.pi / 2)
        love.graphics.scale(1.25, 1.25)
        uiColor(skill_point_color)
        for _, polygon in ipairs(self.player.polygons or {}) do
            love.graphics.polygon('line', polygon)
        end
        love.graphics.pop()
    end

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf('SHIP', 96, 18, 64, 'left')
    love.graphics.printf('SCORE', 96, 38, 64, 'left')
    love.graphics.printf('WAVE', 96, 56, 64, 'left')
    love.graphics.printf('ENEMY', 96, 74, 64, 'left')

    uiColor(skill_point_color)
    love.graphics.setFont(ui_font_xs)
    love.graphics.printf((self.player and self.player.ship or '--'), 164, 20, 84, 'right')
    love.graphics.printf(tostring(self.score), 164, 39, 84, 'right')
    love.graphics.printf(tostring(self.wave), 164, 57, 84, 'right')
    if self.boss_wave then
        love.graphics.printf('BOSS', 164, 75, 84, 'right')
    else
        love.graphics.printf(tostring(#enemies), 164, 75, 84, 'right')
    end

    local mins = math.floor(self.run_time / 60)
    local secs = math.floor(self.run_time % 60)
    uiColor(ammo_color)
    love.graphics.printf(string.format('TIME %02d:%02d', mins, secs), 16, 94, 232, 'center')

    local hud_x = 18
    local hud_y = screen_h - 98
    local hp_w = 340
    local hp_h = 20
    drawPixelPanel(hud_x - 10, hud_y - 42, hp_w + 20, 88, ui_mid, default_color)

    local hp_ratio, fuel_ratio, ammo_ratio = 0, 0, 0
    if self.player and self.player.max_hp > 0 then
        hp_ratio = math.max(0, math.min(1, self.player.hp / self.player.max_hp))
        fuel_ratio = math.max(0, math.min(1, self.player.fuel / self.player.max_fuel))
        ammo_ratio = math.max(0, math.min(1, self.player.ammo / self.player.max_ammo))
    end

    uiColor(ui_dark)
    love.graphics.rectangle('fill', hud_x, hud_y, hp_w, hp_h)
    love.graphics.rectangle('fill', hud_x, hud_y + 26, hp_w, 12)

    uiColor(hp_color)
    love.graphics.rectangle('fill', hud_x, hud_y, hp_w * hp_ratio, hp_h)
    uiColor(boost_color)
    love.graphics.rectangle('fill', hud_x, hud_y + 26, hp_w * fuel_ratio, 12)

    uiColor(default_color)
    love.graphics.rectangle('line', hud_x + 0.5, hud_y + 0.5, hp_w - 1, hp_h - 1)
    love.graphics.rectangle('line', hud_x + 0.5, hud_y + 26.5, hp_w - 1, 11)

    love.graphics.setFont(ui_font_xs)
    if self.player then
        uiColor(default_color)
        love.graphics.printf('HP ' .. math.floor(self.player.hp) .. '/' .. self.player.max_hp, hud_x + 8, hud_y + 6, hp_w - 16,
            'left')
        love.graphics.printf('ENERGY ' .. math.floor(self.player.fuel) .. '/' .. self.player.max_fuel, hud_x + 8, hud_y + 28,
            hp_w - 16, 'left')

        uiColor(ammo_color)
        local ammo_text = math.floor(self.player.ammo) .. '/' .. self.player.max_ammo
        love.graphics.printf('AMMO ' .. ammo_text, hud_x + 118, hud_y - 18, hp_w - 118, 'left')
        for i = 0, 3 do
            local bx = hud_x + 12 + i * 12
            love.graphics.circle('line', bx, hud_y - 10, 4)
        end
        uiColor(ammo_color)
        love.graphics.rectangle('fill', hud_x, hud_y + 43, hp_w * ammo_ratio, 2)

        local skill_w = 280
        local skill_h = 30
        local skill_x = (screen_w - skill_w) / 2
        local skill_y = screen_h - 42
        local cooldown_ratio = 1
        if self.player.skill_cooldown and self.player.skill_cooldown > 0 then
            cooldown_ratio = 1 - math.max(0, math.min(1, self.player.skill_timer / self.player.skill_cooldown))
        end

        drawPixelPanel(skill_x - 8, skill_y - 8, skill_w + 16, skill_h + 16, ui_mid, default_color)
        uiColor(ui_dark)
        love.graphics.rectangle('fill', skill_x, skill_y, skill_w, skill_h)
        uiColor(skill_point_color)
        love.graphics.rectangle('fill', skill_x, skill_y, skill_w * cooldown_ratio, skill_h)
        uiColor(default_color)
        love.graphics.rectangle('line', skill_x + 0.5, skill_y + 0.5, skill_w - 1, skill_h - 1)

        love.graphics.setFont(ui_font_sm)
        if self.player.skill_timer <= 0 then
            uiColor(ui_dark)
            love.graphics.printf('SPACE  -  ' .. self.player.skill_name .. '  READY', skill_x, skill_y + 9, skill_w, 'center')
        else
            uiColor(default_color)
            love.graphics.printf(string.format('SPACE  -  %s  %.1fs', self.player.skill_name, self.player.skill_timer), skill_x,
                skill_y + 9, skill_w, 'center')
        end
    end

    drawPixelPanel(screen_w - 210, 8, 202, 124, ui_mid, default_color)
    uiColor(default_color)
    love.graphics.setFont(ui_font_xs)
    love.graphics.printf('ESC : MENU', screen_w - 202, 16, 186, 'right')
    love.graphics.printf('AUTO FIRE  |  SPACE : SKILL', screen_w - 202, 30, 186, 'right')

    if self.player then
        uiColor(skill_point_color)
        love.graphics.printf('SHIP : ' .. self.player.ship, screen_w - 202, 50, 186, 'left')
        love.graphics.printf('WEAPON : ' .. string.upper(self.player.weapon_mode), screen_w - 202, 64, 186, 'left')
        love.graphics.printf('EVOLVE : T' .. self.player.evolution_tier, screen_w - 202, 78, 186, 'left')
        uiColor(ammo_color)
        local cd_text = ''
        if self.player.skill_timer and self.player.skill_timer > 0 then
            cd_text = string.format(' [%.1fs]', self.player.skill_timer)
        end
        love.graphics.printf(self.player.skill_name .. cd_text, screen_w - 202, 94, 186, 'left')
        uiColor(default_color)
        love.graphics.printf('F1 : DEBUG', screen_w - 202, 108, 186, 'left')
    end

    if self.show_debug then
        drawPixelPanel(8, 184, 260, 74, ui_mid, ammo_color)
        uiColor(ammo_color)
        love.graphics.setFont(ui_font_xs)
        love.graphics.printf('FPS ' .. love.timer.getFPS(), 16, 194, 244, 'left')
        love.graphics.printf('MEM ' .. math.floor(collectgarbage('count')) .. ' KB', 16, 210, 244, 'left')
        love.graphics.printf('SPAWN ' .. self.enemies_spawned .. '/' .. self.enemies_per_wave, 16, 226, 244, 'left')
        love.graphics.printf('RESRC ' .. string.format('%.2f', self.resource_spawn_delay), 16, 242, 244, 'left')
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Stage:drawProgressionMenu()
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()

    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle('fill', 0, 0, screen_w, screen_h)

    local w, h = 620, 310
    local x = (screen_w - w) / 2
    local y = (screen_h - h) / 2

    drawPixelPanel(x, y, w, h, ui_mid, ui_accent)
    love.graphics.setFont(ui_font_lg)

    uiColor(skill_point_color)
    if self.progression_type == 'evolution' then
        love.graphics.printf('EVOLUTION AVAILABLE', x, y + 20, w, 'center')
    else
        love.graphics.printf('WAVE REWARD: CHOOSE UPGRADE', x, y + 20, w, 'center')
    end

    local card_w = 180
    local gap = 18
    local total_w = (#self.progression_choices * card_w) + ((#self.progression_choices - 1) * gap)
    local sx = x + (w - total_w) / 2

    self.progression_card_rects = {}
    for i, choice in ipairs(self.progression_choices) do
        local cx = sx + (i - 1) * (card_w + gap)
        local cy = y + 80
        local border = (i == self.progression_selected) and skill_point_color or default_color
        drawPixelPanel(cx, cy, card_w, 170, ui_dark, border)
        self.progression_card_rects[i] = {x = cx, y = cy, w = card_w, h = 170}

        uiColor((i == self.progression_selected) and skill_point_color or default_color)
        love.graphics.setFont(ui_font_sm)
        love.graphics.printf(i .. '. ' .. choice.title, cx + 8, cy + 10, card_w - 16, 'left')
        love.graphics.setFont(ui_font_xs)
        love.graphics.printf(choice.description, cx + 8, cy + 40, card_w - 16, 'left')
    end

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf('CLICK CARD OR PRESS 1/2/3 + ENTER', x, y + h - 30, w, 'center')
end

function resize(s)
    love.window.setMode(s * gw, s * gh)
    sx, sy = s, s
end

function Stage:destroy()
    self.area:destroy()
    self.area = nil
end
