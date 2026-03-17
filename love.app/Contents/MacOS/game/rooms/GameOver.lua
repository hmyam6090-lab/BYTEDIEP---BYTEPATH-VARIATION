--[[
    GameOver.lua - Game over screen
]] --
GameOver = Object:extend()

function GameOver:new(score)
    self.score = score or 0
    self.timer = Timer()
    self.pulse = 0
    self.scan = 0
end

function GameOver:update(dt)
    self.timer:update(dt)
    self.pulse = self.pulse + dt
    self.scan = self.scan + dt

    if input:pressed("menu_start") then
        gotoRoom('MainMenu')
    end

    if input:pressed("menu_quit") then
        love.event.quit()
    end
end

function GameOver:draw()
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()

    uiColor(ui_dark)
    love.graphics.rectangle('fill', 0, 0, screen_w, screen_h)

    for i = 0, 26 do
        local x = ((i * 42 + self.scan * 110) % (screen_w + 50)) - 25
        uiColor(hp_color, 0.08)
        love.graphics.line(x, 0, x - 70, screen_h)
    end

    for i = 1, 14 do
        local pulse = 0.18 + 0.12 * math.sin(self.scan * 2.6 + i * 0.8)
        uiColor(skill_point_color, pulse)
        love.graphics.circle('line', screen_w * 0.5, screen_h * 0.5, 70 + i * 16)
    end

    local panel_w = math.min(600, screen_w - 36)
    local panel_h = math.min(320, screen_h - 36)
    local panel_x = (screen_w - panel_w) / 2
    local panel_y = (screen_h - panel_h) / 2
    drawPixelPanel(panel_x, panel_y, panel_w, panel_h, ui_mid, hp_color)

    uiColor(hp_color)
    love.graphics.setFont(ui_font_xl)
    love.graphics.printf("GAME OVER", panel_x, panel_y + 28, panel_w, 'center')

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf("RUN TERMINATED", panel_x, panel_y + 74, panel_w, 'center')

    uiColor(skill_point_color)
    love.graphics.setFont(ui_font_lg)
    love.graphics.printf("SCORE " .. self.score, panel_x, panel_y + 118, panel_w, 'center')

    local pulse_alpha = 0.5 + 0.5 * math.sin(self.pulse * 4)
    uiColor(default_color, pulse_alpha)
    love.graphics.setFont(ui_font_md)
    love.graphics.printf("PRESS ENTER TO RETURN", panel_x, panel_y + 194, panel_w, 'center')

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf("ESC : QUIT", panel_x, panel_y + 236, panel_w, 'center')

    love.graphics.setColor(1, 1, 1, 1)
end

function GameOver:destroy()
    self.timer:destroy()
    self.timer = nil
end
