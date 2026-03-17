--[[
    WaveStart.lua - Visual effect and announcement for wave start
]] --
WaveStart = GameObject:extend()

function WaveStart:new(area, x, y, opts)
    WaveStart.super.new(self, area, x, y, opts)

    self.wave = opts.wave or 1
    self.duration = 2
    self.alpha = 1
    self.elapsed = 0

    playSfx('wave', 1, 0.32)
    
    self.timer:tween(self.duration, self, {
        alpha = 0
    }, 'in-cubic')
end

function WaveStart:update(dt)
    WaveStart.super.update(self, dt)

    self.elapsed = self.elapsed + dt
    if self.elapsed >= self.duration then
        self.dead = true
    end
end

function WaveStart:draw()
    love.graphics.setColor(skill_point_color[1], skill_point_color[2], skill_point_color[3], self.alpha)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.printf("WAVE " .. self.wave, 0, gh / 2 - 40, gw, "center")

    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf("Get ready!", 0, gh / 2 + 20, gw, "center")
end
