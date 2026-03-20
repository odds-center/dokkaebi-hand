--- 효과음 시스템 v4 — WAV 파일 기반
--- assets/sfx/*.wav 로드

local SFX = {}

local sounds = {}
local master_volume = 0.3

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local SFX_DIR = "assets/sfx/"

local SOUND_LIST = {
    "card_select", "card_deselect", "button_click",
    "combo_none", "combo_normal", "combo_good", "combo_great", "combo_epic",
    "attack_hit", "attack_critical",
    "go_pressed", "stop_pressed",
    "boss_appear", "boss_defeat", "boss_rage",
    "damage_taken", "instant_death",
    "card_deal", "reward", "purchase",
    "gimmick", "round_start", "game_over",
    "rematch", "yeop_stolen",
}

function SFX.init()
    sounds = {}
    for _, name in ipairs(SOUND_LIST) do
        local path = SFX_DIR .. name .. ".wav"
        local ok, src = pcall(love.audio.newSource, path, "static")
        if ok and src then
            sounds[name] = src
        else
            print("[SFX] Failed to load: " .. path)
        end
    end
end

function SFX.play(name, volume)
    local src = sounds[name]
    if not src then return end
    local clone = src:clone()
    clone:setVolume((volume or 1.0) * master_volume)
    clone:play()
end

function SFX.set_volume(v)
    master_volume = clamp(v, 0, 1)
end

function SFX.get_volume()
    return master_volume
end

return SFX
