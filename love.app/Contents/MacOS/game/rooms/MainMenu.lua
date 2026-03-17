--[[
    MainMenu.lua - Main menu screen
]] --
MainMenu = Object:extend()

function MainMenu:new()
    self.timer = Timer()
    self.press_start_alpha = 0
    self.pulse = 0
    self.scan = 0
end

function MainMenu:update(dt)
    self.timer:update(dt)
    self.pulse = self.pulse + dt
    self.scan = self.scan + dt
    self.press_start_alpha = 0.5 + 0.5 * math.sin(self.pulse * 4)

    if input:pressed("menu_start") then
        gotoRoom('Stage')
    end

    if input:pressed("menu_quit") then
        love.event.quit()
    end
end

function MainMenu:draw()
    local screen_w = love.graphics.getWidth()
    local screen_h = love.graphics.getHeight()

    uiColor(ui_dark)
    love.graphics.rectangle('fill', 0, 0, screen_w, screen_h)

    for i = 0, 24 do
        local y = ((i * 28 + self.scan * 80) % (screen_h + 40)) - 20
        local alpha = 0.05 + 0.06 * math.sin(self.scan * 2 + i)
        uiColor(skill_point_color, alpha)
        love.graphics.line(0, y, screen_w, y)
    end

    for i = 1, 18 do
        local t = self.scan * (16 + i)
        local x = (screen_w * 0.5) + math.cos(t * 0.03 + i) * (120 + i * 10)
        local y = (screen_h * 0.5) + math.sin(t * 0.02 + i * 0.7) * (70 + i * 6)
        uiColor(ammo_color, 0.25)
        love.graphics.circle('fill', x, y, 1.2)
    end

    local panel_w = math.min(620, screen_w - 36)
    local panel_h = math.min(360, screen_h - 36)
    local panel_x = (screen_w - panel_w) / 2
    local panel_y = (screen_h - panel_h) / 2
    drawPixelPanel(panel_x, panel_y, panel_w, panel_h, ui_mid, ui_accent)

    uiColor(skill_point_color)
    love.graphics.setFont(ui_font_xl)
    love.graphics.printf("BYTEPATH", panel_x, panel_y + 28, panel_w, "center")

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf("REMIX PROTOCOL", panel_x, panel_y + 72, panel_w, "center")

    uiColor(ammo_color)
    love.graphics.setFont(ui_font_md)
    love.graphics.printf("AUTO-FIRE SURVIVAL // SHIP SKILLS ONLINE", panel_x, panel_y + 98, panel_w, "center")

    uiColor(default_color, self.press_start_alpha)
    love.graphics.setFont(ui_font_lg)
    love.graphics.printf("PRESS ENTER", panel_x, panel_y + 156, panel_w, "center")

    uiColor(default_color)
    love.graphics.setFont(ui_font_sm)
    love.graphics.printf("MOVE : FOLLOW MOUSE", panel_x, panel_y + 236, panel_w, "center")
    love.graphics.printf("FIRE : AUTO | SPACE : SHIP SKILL", panel_x, panel_y + 254, panel_w, "center")
    love.graphics.printf("AIM SKILLS : HOLD LMB | MENU : ESC", panel_x, panel_y + 272, panel_w, "center")
    love.graphics.printf("FULLSCREEN : F11 | DEBUG : F1", panel_x, panel_y + 290, panel_w, "center")

    uiColor(boost_color)
    love.graphics.setFont(ui_font_xs)
    love.graphics.printf("PROGRAMMER ART BUILD", panel_x, panel_y + panel_h - 18, panel_w, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

function MainMenu:destroy()
    self.timer:destroy()
    self.timer = nil
end
