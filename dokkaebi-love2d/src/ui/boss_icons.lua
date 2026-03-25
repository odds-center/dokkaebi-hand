--- boss_icons.lua
--- 보스 스프라이트: 파일이 있으면 PNG 로드, 없으면 32x32 도트 생성 폴백

local SpriteLoader = require("src.ui.sprite_loader")
local BossIcons = {}
local cache = {}
local SZ = 32

local function px(d, x, y, r, g, b, a)
    if x >= 0 and x < SZ and y >= 0 and y < SZ then
        d:setPixel(x, y, r, g, b, a or 1)
    end
end

local function rect(d, x0, y0, w, h, r, g, b, a)
    for y = y0, y0+h-1 do
        for x = x0, x0+w-1 do px(d, x, y, r, g, b, a or 1) end
    end
end

local function make(fn)
    local d = love.image.newImageData(SZ, SZ)
    fn(d)
    local t = love.graphics.newImage(d)
    t:setFilter("nearest", "nearest")
    return t
end

--- 32x32 도깨비 기본 뼈대 (더 디테일)
local function base(d, body, head, horn, eye, mouth)
    mouth = mouth or {0.15, 0.05, 0.05}
    local B, H, HR, E = body, head, horn, eye
    -- 뿔 (왼쪽 — 크고 휘어짐)
    rect(d, 7,  1, 3, 2, HR[1], HR[2], HR[3])
    rect(d, 6,  3, 2, 2, HR[1]*0.85, HR[2]*0.85, HR[3]*0.85)
    -- 뿔 (오른쪽)
    rect(d, 22, 1, 3, 2, HR[1], HR[2], HR[3])
    rect(d, 24, 3, 2, 2, HR[1]*0.85, HR[2]*0.85, HR[3]*0.85)
    -- 머리
    rect(d, 8,  5, 16, 6, H[1], H[2], H[3])
    rect(d, 9,  4, 14, 2, H[1]+0.05, H[2]+0.05, H[3]+0.05)
    -- 눈 (2x2)
    rect(d, 11, 7, 3, 3, 0.04, 0.02, 0.06) -- 눈구멍
    rect(d, 20, 7, 3, 3, 0.04, 0.02, 0.06)
    rect(d, 11, 7, 2, 2, E[1], E[2], E[3]) -- 눈동자
    rect(d, 20, 7, 2, 2, E[1], E[2], E[3])
    -- 눈 하이라이트
    px(d, 11, 7, math.min(E[1]+0.3,1), math.min(E[2]+0.3,1), math.min(E[3]+0.3,1))
    px(d, 20, 7, math.min(E[1]+0.3,1), math.min(E[2]+0.3,1), math.min(E[3]+0.3,1))
    -- 입
    rect(d, 12, 10, 8, 1, mouth[1], mouth[2], mouth[3])
    -- 이빨 (송곳니)
    px(d, 13, 10, 0.90, 0.88, 0.80)
    px(d, 14, 11, 0.90, 0.88, 0.80)
    px(d, 19, 10, 0.90, 0.88, 0.80)
    px(d, 18, 11, 0.90, 0.88, 0.80)
    -- 몸통
    rect(d, 7,  12, 18, 8, B[1], B[2], B[3])
    rect(d, 8,  11, 16, 2, B[1]+0.03, B[2]+0.03, B[3]+0.03)
    -- 팔
    rect(d, 5,  13, 3, 7, B[1]-0.04, B[2]-0.04, B[3]-0.04)
    rect(d, 24, 13, 3, 7, B[1]-0.04, B[2]-0.04, B[3]-0.04)
    -- 다리
    rect(d, 10, 20, 4, 6, B[1]-0.06, B[2]-0.06, B[3]-0.06)
    rect(d, 18, 20, 4, 6, B[1]-0.06, B[2]-0.06, B[3]-0.06)
    -- 발
    rect(d, 9,  25, 6, 2, B[1]-0.08, B[2]-0.08, B[3]-0.08)
    rect(d, 17, 25, 6, 2, B[1]-0.08, B[2]-0.08, B[3]-0.08)
    -- 배 (밝은)
    rect(d, 11, 14, 10, 5, B[1]+0.08, B[2]+0.08, B[3]+0.06)
end

-- ══════════════════════════════════════
-- 개별 보스 (32x32)
-- ══════════════════════════════════════

local function gen_glutton(d)
    base(d, {0.18,0.50,0.15}, {0.22,0.58,0.18}, {0.62,0.52,0.12}, {1.0,0.8,0.1})
    -- 뚱뚱한 배 강조
    rect(d, 6, 14, 20, 6, 0.22, 0.58, 0.22)
    rect(d, 8, 15, 16, 4, 0.28, 0.62, 0.25)
    -- 큰 입 (열린)
    rect(d, 10, 10, 12, 2, 0.12, 0.05, 0.05)
    px(d, 12, 10, 0.9, 0.9, 0.8); px(d, 15, 10, 0.9, 0.9, 0.8)
    px(d, 18, 10, 0.9, 0.9, 0.8); px(d, 20, 10, 0.9, 0.9, 0.8)
    -- 침
    px(d, 16, 12, 0.5, 0.7, 0.5, 0.5)
end

local function gen_trickster(d)
    base(d, {0.44,0.18,0.60}, {0.52,0.22,0.68}, {0.92,0.52,0.92}, {0.3,1.0,0.3})
    -- 삐뚤어진 눈 (한쪽 높게)
    rect(d, 11, 6, 3, 3, 0.04, 0.02, 0.06)
    rect(d, 11, 6, 2, 2, 0.3, 1.0, 0.3)
    -- 혀 내밀기
    rect(d, 14, 11, 4, 2, 0.75, 0.2, 0.3)
    px(d, 15, 13, 0.7, 0.18, 0.28)
end

local function gen_thief(d)
    base(d, {0.30,0.30,0.35}, {0.38,0.38,0.42}, {0.52,0.52,0.58}, {0.92,0.92,0.2})
    -- 눈 마스크 (검은 띠)
    rect(d, 8, 6, 16, 4, 0.06, 0.06, 0.08)
    rect(d, 11, 7, 2, 2, 0.92, 0.92, 0.2)
    rect(d, 20, 7, 2, 2, 0.92, 0.92, 0.2)
    -- 보따리 (등에)
    rect(d, 24, 8, 6, 7, 0.38, 0.28, 0.15)
    rect(d, 25, 7, 4, 2, 0.42, 0.32, 0.18)
end

local function gen_flame(d)
    base(d, {0.74,0.24,0.08}, {0.82,0.30,0.10}, {1.0,0.6,0.1}, {1.0,0.9,0.2})
    -- 불꽃 (머리 위)
    local fc = {{1.0,0.6,0.0},{1.0,0.4,0.0},{0.9,0.3,0.0}}
    for i, c in ipairs(fc) do
        px(d, 14, 4-i, c[1], c[2], c[3])
        px(d, 17, 4-i, c[1], c[2], c[3])
        px(d, 15, 3-i, c[1], c[2], c[3])
        px(d, 16, 3-i, c[1], c[2], c[3])
    end
    -- 몸 불꽃 파편
    px(d, 4, 14, 1.0, 0.5, 0.0, 0.7)
    px(d, 27, 15, 1.0, 0.4, 0.0, 0.7)
    px(d, 5, 18, 0.9, 0.4, 0.0, 0.5)
end

local function gen_shadow(d)
    base(d, {0.08,0.08,0.24}, {0.12,0.10,0.30}, {0.32,0.28,0.52}, {0.7,0.3,1.0})
    -- 빛나는 눈 글로우
    rect(d, 10, 6, 4, 4, 0.3, 0.1, 0.5, 0.4)
    rect(d, 19, 6, 4, 4, 0.3, 0.1, 0.5, 0.4)
    rect(d, 11, 7, 2, 2, 0.8, 0.4, 1.0)
    rect(d, 20, 7, 2, 2, 0.8, 0.4, 1.0)
    -- 그림자 번짐
    for x = 5, 26 do
        px(d, x, 27, 0.05, 0.05, 0.15, 0.5)
        px(d, x, 28, 0.04, 0.04, 0.12, 0.3)
    end
end

local function gen_gold(d)
    base(d, {0.74,0.60,0.14}, {0.82,0.68,0.18}, {1.0,0.86,0.02}, {1.0,0.2,0.1})
    -- 왕관
    rect(d, 8, 2, 16, 2, 1.0, 0.86, 0.02)
    px(d, 10, 1, 1.0, 0.86, 0.0); px(d, 14, 1, 1.0, 0.86, 0.0)
    px(d, 18, 1, 1.0, 0.86, 0.0); px(d, 22, 1, 1.0, 0.86, 0.0)
    -- 보석
    px(d, 12, 2, 0.9, 0.2, 0.1); px(d, 20, 2, 0.1, 0.4, 0.9)
    -- 금빛 광채
    px(d, 4, 5, 1.0, 0.9, 0.4, 0.3)
    px(d, 27, 5, 1.0, 0.9, 0.4, 0.3)
    px(d, 3, 10, 1.0, 0.85, 0.3, 0.2)
    px(d, 28, 10, 1.0, 0.85, 0.3, 0.2)
end

local function gen_volcano(d)
    base(d, {0.40,0.08,0.04}, {0.48,0.12,0.06}, {1.0,0.3,0.0}, {1.0,0.5,0.0})
    -- 용암 균열 (몸통)
    px(d, 10, 14, 1.0, 0.5, 0.0); px(d, 12, 16, 1.0, 0.4, 0.0)
    px(d, 15, 15, 1.0, 0.6, 0.0); px(d, 20, 14, 1.0, 0.4, 0.0)
    px(d, 18, 17, 0.9, 0.3, 0.0); px(d, 22, 16, 1.0, 0.5, 0.0)
    -- 연기
    px(d, 12, 0, 0.4, 0.3, 0.3, 0.4)
    px(d, 14, 1, 0.35, 0.28, 0.28, 0.3)
    px(d, 19, 0, 0.38, 0.30, 0.30, 0.35)
end

local function gen_yeomra(d)
    base(d, {0.12,0.10,0.10}, {0.16,0.12,0.12}, {1.0,0.86,0.02}, {1.0,0.0,0.0})
    -- 거대 왕관
    rect(d, 6, 0, 20, 3, 1.0, 0.86, 0.02)
    rect(d, 8, 0, 16, 1, 1.0, 0.88, 0.10)
    px(d, 10, 0, 1.0, 0.15, 0.1); px(d, 16, 0, 1.0, 0.15, 0.1); px(d, 22, 0, 1.0, 0.15, 0.1)
    -- 망토
    rect(d, 4, 12, 3, 14, 0.14, 0.10, 0.10)
    rect(d, 25, 12, 3, 14, 0.14, 0.10, 0.10)
    rect(d, 3, 15, 2, 10, 0.10, 0.08, 0.08)
    rect(d, 27, 15, 2, 10, 0.10, 0.08, 0.08)
    -- 금빛 옷 테두리
    rect(d, 7, 12, 1, 8, 0.88, 0.68, 0.12)
    rect(d, 24, 12, 1, 8, 0.88, 0.68, 0.12)
    -- 염라 도장 (배)
    rect(d, 13, 15, 6, 4, 0.70, 0.12, 0.08)
    rect(d, 14, 16, 4, 2, 0.90, 0.80, 0.20)
end

-- 재앙 보스 — 백골대장
local function gen_skeleton(d)
    local W = {0.88, 0.85, 0.78}
    local D = {0.08, 0.05, 0.05}
    -- 해골 머리
    rect(d, 9,  2, 14, 4, W[1], W[2], W[3])
    rect(d, 8,  5, 16, 6, W[1], W[2], W[3])
    rect(d, 10, 1, 12, 2, W[1]-0.05, W[2]-0.05, W[3]-0.05)
    -- 눈구멍 (크게)
    rect(d, 10, 5, 4, 3, D[1], D[2], D[3])
    rect(d, 18, 5, 4, 3, D[1], D[2], D[3])
    -- 코
    rect(d, 14, 8, 3, 2, D[1], D[2], D[3])
    -- 이빨 (톱니)
    rect(d, 10, 10, 12, 2, W[1], W[2], W[3])
    for x = 11, 21, 2 do px(d, x, 10, D[1], D[2], D[3]) end
    -- 갑옷 (갈빗대)
    rect(d, 9, 13, 14, 10, 0.42, 0.40, 0.35)
    for y = 14, 22, 2 do rect(d, 10, y, 12, 1, W[1]-0.15, W[2]-0.15, W[3]-0.15) end
    -- 부러진 뿔
    rect(d, 7, 1, 2, 3, 0.62, 0.58, 0.48)
    px(d, 6, 0, 0.62, 0.58, 0.48)
    rect(d, 23, 2, 2, 2, 0.62, 0.58, 0.48)
    -- 검
    rect(d, 26, 4, 2, 18, 0.60, 0.62, 0.68)
    rect(d, 25, 3, 4, 2, 0.65, 0.68, 0.72)
    -- 다리 뼈
    rect(d, 11, 23, 3, 5, W[1]-0.1, W[2]-0.1, W[3]-0.1)
    rect(d, 18, 23, 3, 5, W[1]-0.1, W[2]-0.1, W[3]-0.1)
end

-- 재앙 — 구미호 왕
local function gen_ninetail(d)
    local B = {0.80, 0.52, 0.14}
    local T = {0.92, 0.68, 0.22}
    base(d, B, {0.85,0.58,0.18}, {1.0,0.88,0.52}, {0.2,0.92,0.92})
    -- 여우 귀 (뿔 덮기)
    rect(d, 6, 1, 4, 4, T[1], T[2], T[3])
    rect(d, 22, 1, 4, 4, T[1], T[2], T[3])
    px(d, 5, 0, T[1], T[2], T[3]); px(d, 26, 0, T[1], T[2], T[3])
    -- 9개 꼬리 (우측 부채꼴)
    for i = 0, 8 do
        local ty = 10 + i
        local tx = 26 + (i % 3)
        px(d, tx, ty, T[1], T[2], T[3])
        px(d, tx+1, ty, T[1]-0.05, T[2]-0.05, T[3])
        if i < 6 then px(d, tx+2, ty+1, T[1]-0.1, T[2]-0.1, T[3]) end
    end
    -- 여의주
    rect(d, 14, 15, 4, 4, 0.2, 0.85, 0.85)
    rect(d, 15, 16, 2, 2, 0.5, 1.0, 1.0)
end

-- 재앙 — 이무기
local function gen_imugi(d)
    local B = {0.12, 0.30, 0.58}
    local S = {0.18, 0.38, 0.68}
    -- 용 머리
    rect(d, 8, 3, 16, 8, B[1]+0.05, B[2]+0.05, B[3]+0.05)
    rect(d, 9, 2, 14, 2, B[1]+0.08, B[2]+0.08, B[3]+0.08)
    -- 용뿔
    rect(d, 7, 0, 3, 3, 0.3, 0.6, 0.9)
    rect(d, 22, 0, 3, 3, 0.3, 0.6, 0.9)
    -- 눈 (위엄)
    rect(d, 10, 5, 4, 3, 0.02, 0.02, 0.04)
    rect(d, 18, 5, 4, 3, 0.02, 0.02, 0.04)
    rect(d, 11, 5, 2, 2, 1.0, 0.8, 0.1)
    rect(d, 19, 5, 2, 2, 1.0, 0.8, 0.1)
    -- 수염
    rect(d, 5, 6, 3, 1, 0.4, 0.6, 0.8)
    rect(d, 3, 7, 3, 1, 0.35, 0.55, 0.75)
    rect(d, 24, 6, 3, 1, 0.4, 0.6, 0.8)
    rect(d, 26, 7, 3, 1, 0.35, 0.55, 0.75)
    -- 비늘 몸통
    rect(d, 7, 12, 18, 10, B[1], B[2], B[3])
    for y = 12, 22, 2 do
        for x = 8, 24, 3 do
            px(d, x, y, S[1], S[2], S[3])
            px(d, x+1, y+1, S[1], S[2], S[3])
        end
    end
    -- 다리+발톱
    rect(d, 10, 22, 4, 5, B[1]-0.04, B[2]-0.04, B[3]-0.04)
    rect(d, 18, 22, 4, 5, B[1]-0.04, B[2]-0.04, B[3]-0.04)
    px(d, 9, 27, 0.8, 0.8, 0.2); px(d, 22, 27, 0.8, 0.8, 0.2)
end

-- 재앙 — 저승꽃
local function gen_flower(d)
    local B = {0.64, 0.24, 0.44}
    local P = {0.82, 0.38, 0.58}
    base(d, B, {0.70,0.28,0.48}, {0.92,0.52,0.72}, {1.0,0.4,0.6})
    -- 꽃잎 (머리 주위)
    local petals = {{10,0},{14,0},{18,0},{6,1},{22,1},{4,3},{26,3}}
    for _, p in ipairs(petals) do
        rect(d, p[1], p[2], 3, 2, P[1], P[2], P[3])
    end
    -- 덩굴
    px(d, 4, 16, 0.2, 0.48, 0.2); px(d, 3, 18, 0.2, 0.48, 0.2)
    px(d, 27, 17, 0.2, 0.48, 0.2); px(d, 28, 19, 0.2, 0.48, 0.2)
    -- 꽃 중심 (배)
    rect(d, 13, 15, 6, 4, 0.95, 0.85, 0.3)
end

-- ══════════════════════════════════════
-- 나머지 보스 — 색상 기반 자동 생성
-- base()를 보스의 body_color로 호출
-- ══════════════════════════════════════
local function gen_from_colors(body, head, horn, eye)
    return function(d) base(d, body, head, horn, eye) end
end

-- ══════════════════════════════════════
-- GENERATORS
-- ══════════════════════════════════════
local GENERATORS = {
    -- 고유 아이콘
    glutton          = gen_glutton,
    trickster        = gen_trickster,
    thief            = gen_thief,
    flame            = gen_flame,
    shadow           = gen_shadow,
    gold             = gen_gold,
    volcano          = gen_volcano,
    yeomra           = gen_yeomra,
    skeleton_general = gen_skeleton,
    ninetail_king    = gen_ninetail,
    imugi            = gen_imugi,
    underworld_flower= gen_flower,
}

--- 보스 ID로 아이콘 가져오기 (스프라이트 우선, 도형 폴백)
function BossIcons.get(boss_id, boss_data)
    if cache[boss_id] then return cache[boss_id] end

    -- 1) 생성된 스프라이트 PNG가 있으면 우선 사용
    local sprite = SpriteLoader.getBoss(boss_id)
    if sprite then
        cache[boss_id] = sprite
        return sprite
    end

    -- 2) 폴백: 도형으로 생성
    local gen = GENERATORS[boss_id]
    if gen then
        cache[boss_id] = make(gen)
    elseif boss_data and boss_data.body_color then
        cache[boss_id] = make(gen_from_colors(
            boss_data.body_color,
            boss_data.head_color or boss_data.body_color,
            boss_data.horn_color or {0.8, 0.7, 0.2},
            boss_data.eye_color or {1.0, 0.2, 0.1}
        ))
    else
        cache[boss_id] = make(gen_from_colors(
            {0.55, 0.15, 0.10}, {0.65, 0.20, 0.12},
            {0.80, 0.70, 0.20}, {1.0, 0.2, 0.1}
        ))
    end
    return cache[boss_id]
end

--- 아이콘 그리기
function BossIcons.draw(boss_id, x, y, size, boss_data)
    size = size or 64
    local tex = BossIcons.get(boss_id, boss_data)
    local scale = size / tex:getWidth()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tex, x, y, 0, scale, scale)
end

--- 프리로드
function BossIcons.preload()
    for id, _ in pairs(GENERATORS) do
        BossIcons.get(id)
    end
end

return BossIcons
