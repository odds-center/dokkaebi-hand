function love.conf(t)
    t.identity = "dokkaebi-hand"
    t.version = "11.4"

    t.window.title = "도깨비의 패 — Dokkaebi's Hand"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.minwidth = 960
    t.window.minheight = 540
    t.window.vsync = 1

    t.modules.audio = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.keyboard = false  -- 마우스/터치 전용
    t.modules.mouse = true
    t.modules.timer = true
    t.modules.window = true
    t.modules.filesystem = true
    t.modules.math = true

    t.modules.joystick = false
    t.modules.physics = false
    t.modules.video = false
    t.modules.thread = false
end
