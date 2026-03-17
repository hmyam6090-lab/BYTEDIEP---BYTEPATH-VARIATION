default_color = {love.math.colorFromBytes(222, 222, 222)}
background_color = {love.math.colorFromBytes(16, 16, 16)}
ammo_color = {love.math.colorFromBytes(123, 200, 164)}
boost_color = {love.math.colorFromBytes(76, 195, 217)}
hp_color = {love.math.colorFromBytes(241, 103, 69)}
enemy_bullet_color = {love.math.colorFromBytes(255, 38, 38)}
skill_point_color = {love.math.colorFromBytes(255, 198, 93)}

ui_dark = {love.math.colorFromBytes(10, 10, 10)}
ui_mid = {love.math.colorFromBytes(28, 28, 28)}
ui_accent = {love.math.colorFromBytes(90, 150, 255)}

function uiColor(c, a)
	if a then
		love.graphics.setColor(c[1], c[2], c[3], a)
	else
		love.graphics.setColor(c[1], c[2], c[3])
	end
end

function initUiTheme()
	if ui_font_xs then
		return
	end

	ui_font_xs = love.graphics.newFont(8, 'mono')
	ui_font_sm = love.graphics.newFont(12, 'mono')
	ui_font_md = love.graphics.newFont(16, 'mono')
	ui_font_lg = love.graphics.newFont(24, 'mono')
	ui_font_xl = love.graphics.newFont(40, 'mono')
end

function drawPixelPanel(x, y, w, h, fill, border)
	uiColor(fill or ui_mid)
	love.graphics.rectangle('fill', x, y, w, h)
	uiColor(border or default_color)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle('line', x + 0.5, y + 0.5, w - 1, h - 1)
	love.graphics.rectangle('line', x + 2.5, y + 2.5, w - 5, h - 5)
end

function drawEnemyHpBar(x, y, radius, hp, max_hp)
	if not hp or not max_hp or max_hp <= 0 then
		return
	end

	local ratio = math.max(0, math.min(1, hp / max_hp))
	local bw = radius * 2.2
	local bh = 3
	local bx = x - bw * 0.5
	local by = y - radius - 8

	uiColor(ui_dark)
	love.graphics.rectangle('fill', bx, by, bw, bh)
	uiColor(hp_color)
	love.graphics.rectangle('fill', bx, by, bw * ratio, bh)
	uiColor(default_color)
	love.graphics.rectangle('line', bx + 0.5, by + 0.5, bw - 1, bh - 1)
end

function _audioTone(freq, duration, volume, wave)
	local sample_rate = 22050
	local samples = math.floor(sample_rate * duration)
	local data = love.sound.newSoundData(samples, sample_rate, 16, 1)

	for i = 0, samples - 1 do
		local t = i / sample_rate
		local v
		if wave == 'square' then
			v = (math.sin(2 * math.pi * freq * t) > 0) and 1 or -1
		elseif wave == 'triangle' then
			v = 2 * math.abs(2 * ((freq * t) - math.floor((freq * t) + 0.5))) - 1
		else
			v = math.sin(2 * math.pi * freq * t)
		end

		local env = 1 - (i / samples)
		data:setSample(i, v * volume * env)
	end

	return love.audio.newSource(data, 'static')
end

function _audioLoop(duration, mood)
	local sample_rate = 22050
	local samples = math.floor(sample_rate * duration)
	local data = love.sound.newSoundData(samples, sample_rate, 16, 1)

	for i = 0, samples - 1 do
		local t = i / sample_rate
		local base = (mood == 'menu') and 110 or 96
		local melody = (mood == 'menu') and 220 or 192
		local a = math.sin(2 * math.pi * base * t) * 0.18
		local b = math.sin(2 * math.pi * (base * 1.5) * t) * 0.1
		local c = math.sin(2 * math.pi * (melody + 18 * math.sin(t * 2.2)) * t) * 0.08
		local pulse = (math.sin(t * ((mood == 'menu') and 1.5 or 2.2)) * 0.5 + 0.5)
		data:setSample(i, (a + b + c) * (0.6 + 0.4 * pulse))
	end

	local src = love.audio.newSource(data, 'static')
	src:setLooping(true)
	return src
end

function initAudioTheme()
	if audio_theme then
		return
	end

	audio_theme = {
		sfx = {
			shoot = _audioTone(720, 0.06, 0.35, 'square'),
			enemy_shoot = _audioTone(300, 0.08, 0.28, 'triangle'),
			pickup = _audioTone(880, 0.10, 0.28, 'sine'),
			hit = _audioTone(180, 0.09, 0.30, 'square'),
			wave = _audioTone(520, 0.18, 0.30, 'triangle')
		},
		music = {
			menu = _audioLoop(8, 'menu'),
			stage = _audioLoop(8, 'stage')
		}
	}

	audio_current_music = nil
	audio_current_track = nil

	audio_theme.music.menu:setVolume(0.18)
	audio_theme.music.stage:setVolume(0.2)
end

function playSfx(name, pitch, volume)
	if not audio_theme or not audio_theme.sfx[name] then
		return
	end

	local src = audio_theme.sfx[name]:clone()
	if pitch then
		src:setPitch(pitch)
	end
	if volume then
		src:setVolume(volume)
	end
	src:play()
end

function setMusic(track)
	if not audio_theme or not audio_theme.music[track] then
		return
	end

	if audio_current_track == track then
		return
	end

	if audio_current_music then
		audio_current_music:stop()
	end

	audio_current_track = track
	audio_current_music = audio_theme.music[track]
	audio_current_music:play()
end
