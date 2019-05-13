local love = _G.love
function love.conf(t)
	t.console          = true
	t.modules.event    = true
	t.modules.graphics = true
	t.modules.image    = true

	t.modules.audio    = false
	t.modules.data     = false
	t.modules.font     = false
	t.modules.joystick = false
	t.modules.keyboard = false
	t.modules.math     = false
	t.modules.mouse    = false
	t.modules.physics  = false
	t.modules.sound    = false
	t.modules.system   = false
	t.modules.thread   = false
	t.modules.timer    = false
	t.modules.touch    = false
	t.modules.video    = false
	t.modules.window   = false
end
