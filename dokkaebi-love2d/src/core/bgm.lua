--- BGM 매니저
--- 게임 상태에 따라 배경 음악을 자동 전환 (크로스페이드)

local BGM = {}

local tracks = {}
local current_track = nil
local current_name = nil
local next_track = nil
local next_name = nil
local master_volume = 0.1
local fade_duration = 1.0  -- 크로스페이드 시간 (초)
local fade_timer = 0
local fading = false

-- 트랙 목록 (파일명 → 경로)
local track_files = {
    menu       = "assets/bgm/dream_ambience.mp3",
    battle     = "assets/bgm/dark_theme.ogg",
    boss_rage  = "assets/bgm/menace.ogg",
    dungeon    = "assets/bgm/dark_shrine_loop.ogg",
    dark       = "assets/bgm/forgotten_tomb.mp3",
}

-- 게임 상태 → 트랙 매핑
local state_map = {
    main_menu        = "menu",
    settings         = "menu",
    collection       = "menu",
    blessing_select  = "dungeon",
    in_round         = "battle",
    go_stop          = "battle",
    attack           = "boss_rage",
    post_round       = "dungeon",
    upgrade_select   = "dungeon",
    shop             = "dungeon",
    event            = "dark",
    gate             = "dark",
    game_over        = "dark",
    upgrade_tree     = "menu",
}

function BGM.init()
    for name, path in pairs(track_files) do
        local ok, src = pcall(love.audio.newSource, path, "stream")
        if ok then
            src:setLooping(true)
            src:setVolume(0)
            tracks[name] = src
        end
    end
end

function BGM.update(dt)
    if not fading then return end

    fade_timer = fade_timer + dt
    local progress = math.min(fade_timer / fade_duration, 1)

    -- 현재 트랙 페이드아웃
    if current_track then
        current_track:setVolume(master_volume * (1 - progress))
    end

    -- 다음 트랙 페이드인
    if next_track then
        next_track:setVolume(master_volume * progress)
    end

    -- 전환 완료
    if progress >= 1 then
        if current_track then
            current_track:stop()
        end
        current_track = next_track
        current_name = next_name
        next_track = nil
        next_name = nil
        fading = false
    end
end

--- 게임 상태에 따라 자동 트랙 선택
function BGM.update_state(state)
    local target = state_map[state]
    if not target then return end
    if target == current_name and not fading then return end
    if target == next_name and fading then return end
    BGM.play(target)
end

--- 특정 트랙 재생 (크로스페이드)
function BGM.play(name)
    if name == current_name and not fading then return end

    local src = tracks[name]
    if not src then return end

    -- 이미 페이드 중이면 현재 페이드 대상을 즉시 정리
    if fading and next_track then
        next_track:stop()
    end

    next_track = src
    next_name = name
    next_track:setVolume(0)
    next_track:play()

    fade_timer = 0
    fading = true
end

--- 볼륨 설정 (0~1)
function BGM.set_volume(v)
    master_volume = math.max(0, math.min(1, v))
    if current_track and not fading then
        current_track:setVolume(master_volume)
    end
end

function BGM.get_volume()
    return master_volume
end

--- 즉시 정지
function BGM.stop()
    if current_track then current_track:stop() end
    if next_track then next_track:stop() end
    current_track = nil
    current_name = nil
    next_track = nil
    next_name = nil
    fading = false
end

return BGM
