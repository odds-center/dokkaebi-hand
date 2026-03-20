--- pixel_icons.lua
--- 모든 게임 아이콘을 16x16 도트로 직접 찍어 생성
--- love.image.newImageData로 픽셀 단위 제작

local PixelIcons = {}
local cache = {}

local function px(img, x, y, r, g, b, a)
    if x >= 0 and x < 16 and y >= 0 and y < 16 then
        img:setPixel(x, y, r, g, b, a or 1)
    end
end

local function fill_rect(img, x0, y0, w, h, r, g, b, a)
    for y = y0, y0+h-1 do
        for x = x0, x0+w-1 do
            px(img, x, y, r, g, b, a or 1)
        end
    end
end

local function make_icon(draw_fn)
    local img = love.image.newImageData(16, 16)
    draw_fn(img)
    local tex = love.graphics.newImage(img)
    tex:setFilter("nearest", "nearest")
    return tex
end

-- ═══════════════════════════════
-- 하트 (체력)
-- ═══════════════════════════════
function PixelIcons.heart()
    if cache.heart then return cache.heart end
    cache.heart = make_icon(function(d)
        local R = {0.85, 0.15, 0.12}
        local D = {0.55, 0.08, 0.05}
        -- 하트 모양
        local rows = {
            {5,6, 9,10},
            {4,5,6,7, 8,9,10,11},
            {3,4,5,6,7,8,9,10,11,12},
            {3,4,5,6,7,8,9,10,11,12},
            {3,4,5,6,7,8,9,10,11,12},
            {4,5,6,7,8,9,10,11},
            {5,6,7,8,9,10},
            {6,7,8,9},
            {7,8},
        }
        for y, cols in ipairs(rows) do
            for _, x in ipairs(cols) do
                local c = (y <= 3) and R or D
                px(d, x, y+3, c[1], c[2], c[3])
            end
        end
        -- 하이라이트
        px(d, 5, 5, 1, 0.5, 0.5)
        px(d, 10, 5, 1, 0.5, 0.5)
    end)
    return cache.heart
end

-- ═══════════════════════════════
-- 빈 하트 (잃은 체력)
-- ═══════════════════════════════
function PixelIcons.heart_empty()
    if cache.heart_empty then return cache.heart_empty end
    cache.heart_empty = make_icon(function(d)
        local E = {0.25, 0.12, 0.12}
        local rows = {
            {5,6, 9,10},
            {4,7, 8,11},
            {3,12},
            {3,12},
            {3,12},
            {4,11},
            {5,10},
            {6,9},
            {7,8},
        }
        for y, cols in ipairs(rows) do
            for _, x in ipairs(cols) do
                px(d, x, y+3, E[1], E[2], E[3])
            end
        end
    end)
    return cache.heart_empty
end

-- ═══════════════════════════════
-- 톱니바퀴 (설정)
-- ═══════════════════════════════
function PixelIcons.gear()
    if cache.gear then return cache.gear end
    cache.gear = make_icon(function(d)
        local G = {0.65, 0.65, 0.70}
        local H = {0.45, 0.45, 0.50}
        -- 톱니 외곽
        local pattern = {
            "    ####    ",
            "   ######   ",
            "  ##....##  ",
            " ##......## ",
            "###..  ..###",
            "###..  ..###",
            " ##......## ",
            "  ##....##  ",
            "   ######   ",
            "    ####    ",
        }
        for y, row in ipairs(pattern) do
            for x = 1, #row do
                local ch = row:sub(x,x)
                if ch == "#" then px(d, x+1, y+3, G[1], G[2], G[3])
                elseif ch == "." then px(d, x+1, y+3, H[1], H[2], H[3]) end
            end
        end
        -- 상하좌우 톱니 돌출
        fill_rect(d, 6, 1, 4, 2, G[1], G[2], G[3])
        fill_rect(d, 6, 13, 4, 2, G[1], G[2], G[3])
        fill_rect(d, 1, 6, 2, 4, G[1], G[2], G[3])
        fill_rect(d, 13, 6, 2, 4, G[1], G[2], G[3])
    end)
    return cache.gear
end

-- ═══════════════════════════════
-- 검 (공격/칩)
-- ═══════════════════════════════
function PixelIcons.sword()
    if cache.sword then return cache.sword end
    cache.sword = make_icon(function(d)
        local B = {0.7, 0.75, 0.85}  -- 칼날
        local H = {0.55, 0.35, 0.15} -- 손잡이
        local G = {0.9, 0.8, 0.2}    -- 가드
        -- 칼날 (대각선)
        for i = 0, 7 do px(d, 12-i, 2+i, B[1], B[2], B[3]) end
        for i = 0, 7 do px(d, 13-i, 2+i, B[1], B[2], B[3]) end
        -- 가드
        for i = 0, 3 do px(d, 3+i, 10, G[1], G[2], G[3]) end
        for i = 0, 3 do px(d, 3+i, 11, G[1], G[2], G[3]) end
        -- 손잡이
        px(d, 3, 12, H[1], H[2], H[3])
        px(d, 2, 13, H[1], H[2], H[3])
        px(d, 1, 14, H[1], H[2], H[3])
    end)
    return cache.sword
end

-- ═══════════════════════════════
-- 방패 (배수/방어)
-- ═══════════════════════════════
function PixelIcons.shield()
    if cache.shield then return cache.shield end
    cache.shield = make_icon(function(d)
        local O = {0.2, 0.4, 0.7}
        local I = {0.15, 0.3, 0.55}
        for y = 2, 12 do
            local hw = y <= 5 and 6 or math.max(1, 7 - (y-5))
            local cx = 7
            for x = cx-hw, cx+hw do
                local c = (x == cx-hw or x == cx+hw or y == 2 or y == 12) and O or I
                px(d, x, y, c[1], c[2], c[3])
            end
        end
        -- 십자 문양
        for y = 5, 9 do px(d, 7, y, 0.9, 0.8, 0.2) end
        for x = 5, 9 do px(d, x, 7, 0.9, 0.8, 0.2) end
    end)
    return cache.shield
end

-- ═══════════════════════════════
-- 물약 (체력 회복)
-- ═══════════════════════════════
function PixelIcons.potion()
    if cache.potion then return cache.potion end
    cache.potion = make_icon(function(d)
        local G = {0.5, 0.5, 0.55}   -- 유리
        local L = {0.8, 0.15, 0.15}   -- 액체
        local C = {0.65, 0.55, 0.35}  -- 코르크
        -- 코르크
        fill_rect(d, 6, 1, 4, 2, C[1], C[2], C[3])
        -- 병 목
        fill_rect(d, 6, 3, 4, 2, G[1], G[2], G[3])
        -- 병 몸체
        for y = 5, 13 do
            local hw = y <= 6 and 3 or 5
            local cx = 7
            for x = cx-hw, cx+hw do
                if x == cx-hw or x == cx+hw then
                    px(d, x, y, G[1], G[2], G[3])
                elseif y >= 8 then
                    px(d, x, y, L[1], L[2], L[3])
                end
            end
        end
        -- 바닥
        fill_rect(d, 3, 13, 10, 1, G[1], G[2], G[3])
        -- 하이라이트
        px(d, 4, 9, 1, 0.4, 0.4)
    end)
    return cache.potion
end

-- ═══════════════════════════════
-- 카드 팩
-- ═══════════════════════════════
function PixelIcons.card_pack()
    if cache.card_pack then return cache.card_pack end
    cache.card_pack = make_icon(function(d)
        local C1 = {0.15, 0.12, 0.30}
        local C2 = {0.20, 0.15, 0.35}
        local B  = {0.35, 0.25, 0.55}
        -- 뒤쪽 카드
        fill_rect(d, 4, 1, 9, 13, C1[1], C1[2], C1[3])
        -- 중간 카드
        fill_rect(d, 3, 2, 9, 13, C2[1], C2[2], C2[3])
        -- 앞쪽 카드
        fill_rect(d, 2, 3, 9, 13, B[1], B[2], B[3])
        -- 앞 카드 테두리
        for x = 2, 10 do px(d, x, 3, 0.5, 0.4, 0.7) end
        for x = 2, 10 do px(d, x, 15, 0.5, 0.4, 0.7) end
        for y = 3, 15 do px(d, 2, y, 0.5, 0.4, 0.7) end
        for y = 3, 15 do px(d, 10, y, 0.5, 0.4, 0.7) end
        -- 물음표
        fill_rect(d, 5, 6, 3, 1, 0.9, 0.8, 0.2)
        px(d, 7, 7, 0.9, 0.8, 0.2)
        px(d, 6, 8, 0.9, 0.8, 0.2)
        px(d, 6, 9, 0.9, 0.8, 0.2)
        px(d, 6, 11, 0.9, 0.8, 0.2)
    end)
    return cache.card_pack
end

-- ═══════════════════════════════
-- 거울 (복사 아이템)
-- ═══════════════════════════════
function PixelIcons.mirror()
    if cache.mirror then return cache.mirror end
    cache.mirror = make_icon(function(d)
        local F = {0.45, 0.35, 0.25}  -- 프레임
        local M = {0.55, 0.65, 0.75}  -- 거울면
        local H = {0.75, 0.85, 0.95}  -- 하이라이트
        -- 프레임
        for y = 1, 14 do
            local hw = y <= 3 and (y+2) or (y >= 12 and (16-y) or 6)
            for x = 7-hw, 7+hw do
                if x == 7-hw or x == 7+hw or y == 1 or y == 14 then
                    px(d, x, y, F[1], F[2], F[3])
                else
                    px(d, x, y, M[1], M[2], M[3])
                end
            end
        end
        -- 하이라이트
        px(d, 5, 4, H[1], H[2], H[3])
        px(d, 6, 4, H[1], H[2], H[3])
        px(d, 5, 5, H[1], H[2], H[3])
    end)
    return cache.mirror
end

-- ═══════════════════════════════
-- 실타래 (윤회의 실)
-- ═══════════════════════════════
function PixelIcons.thread()
    if cache.thread then return cache.thread end
    cache.thread = make_icon(function(d)
        local T = {0.7, 0.3, 0.8}   -- 실 색
        local S = {0.5, 0.2, 0.6}   -- 실 어두운
        -- 실타래 원형
        for y = 3, 12 do
            for x = 3, 12 do
                local dx, dy = x-7.5, y-7.5
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist < 5 and dist > 1.5 then
                    local c = ((x+y) % 2 == 0) and T or S
                    px(d, x, y, c[1], c[2], c[3])
                end
            end
        end
        -- 늘어진 실
        px(d, 10, 10, T[1], T[2], T[3])
        px(d, 11, 11, T[1], T[2], T[3])
        px(d, 12, 12, T[1], T[2], T[3])
        px(d, 13, 13, T[1], T[2], T[3])
    end)
    return cache.thread
end

-- ═══════════════════════════════
-- 엽전 (화폐)
-- ═══════════════════════════════
function PixelIcons.coin()
    if cache.coin then return cache.coin end
    cache.coin = make_icon(function(d)
        local G = {0.85, 0.70, 0.10}
        local D = {0.65, 0.50, 0.08}
        for y = 3, 12 do
            for x = 3, 12 do
                local dx, dy = x-7.5, y-7.5
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist < 5 then
                    local c = (dist < 2) and D or G
                    px(d, x, y, c[1], c[2], c[3])
                end
            end
        end
        -- 가운데 구멍 (사각)
        fill_rect(d, 6, 6, 3, 3, 0.03, 0.02, 0.06)
    end)
    return cache.coin
end

-- ═══════════════════════════════
-- 부적 (스크롤)
-- ═══════════════════════════════
function PixelIcons.talisman()
    if cache.talisman then return cache.talisman end
    cache.talisman = make_icon(function(d)
        local P = {0.80, 0.75, 0.55}  -- 종이
        local I = {0.15, 0.12, 0.08}  -- 잉크
        local R = {0.70, 0.15, 0.10}  -- 붉은 도장
        -- 종이
        fill_rect(d, 3, 1, 10, 14, P[1], P[2], P[3])
        -- 글씨 (가로줄)
        fill_rect(d, 5, 3, 6, 1, I[1], I[2], I[3])
        fill_rect(d, 5, 5, 6, 1, I[1], I[2], I[3])
        fill_rect(d, 5, 7, 4, 1, I[1], I[2], I[3])
        -- 붉은 도장
        fill_rect(d, 8, 9, 4, 4, R[1], R[2], R[3])
    end)
    return cache.talisman
end

-- ═══════════════════════════════
-- 해골 (보스/위험)
-- ═══════════════════════════════
function PixelIcons.skull()
    if cache.skull then return cache.skull end
    cache.skull = make_icon(function(d)
        local W = {0.85, 0.82, 0.75}
        local D = {0.10, 0.05, 0.05}
        -- 두개골 상단
        fill_rect(d, 4, 2, 8, 2, W[1], W[2], W[3])
        fill_rect(d, 3, 4, 10, 4, W[1], W[2], W[3])
        fill_rect(d, 4, 8, 8, 2, W[1], W[2], W[3])
        -- 눈구멍
        fill_rect(d, 4, 5, 3, 2, D[1], D[2], D[3])
        fill_rect(d, 9, 5, 3, 2, D[1], D[2], D[3])
        -- 코
        px(d, 7, 7, D[1], D[2], D[3])
        px(d, 8, 7, D[1], D[2], D[3])
        -- 턱/이빨
        fill_rect(d, 4, 10, 8, 1, W[1], W[2], W[3])
        fill_rect(d, 5, 11, 6, 2, W[1], W[2], W[3])
        -- 이빨 틈
        px(d, 6, 11, D[1], D[2], D[3])
        px(d, 8, 11, D[1], D[2], D[3])
        px(d, 10, 11, D[1], D[2], D[3])
    end)
    return cache.skull
end

-- ═══════════════════════════════
-- 넋 (영혼 조각)
-- ═══════════════════════════════
function PixelIcons.soul()
    if cache.soul then return cache.soul end
    cache.soul = make_icon(function(d)
        local S1 = {0.4, 0.7, 0.9}
        local S2 = {0.3, 0.5, 0.7}
        -- 불꽃 형태 영혼
        local rows = {
            [3]  = {7,8},
            [4]  = {6,7,8,9},
            [5]  = {5,6,7,8,9,10},
            [6]  = {5,6,7,8,9,10},
            [7]  = {4,5,6,7,8,9,10,11},
            [8]  = {4,5,6,7,8,9,10,11},
            [9]  = {5,6,7,8,9,10},
            [10] = {5,6,7,8,9,10},
            [11] = {6,7,8,9},
            [12] = {7,8},
            [13] = {7},
        }
        for y, cols in pairs(rows) do
            for _, x in ipairs(cols) do
                local c = ((x+y) % 3 == 0) and S2 or S1
                px(d, x, y, c[1], c[2], c[3])
            end
        end
        -- 눈
        px(d, 6, 7, 1, 1, 1)
        px(d, 9, 7, 1, 1, 1)
    end)
    return cache.soul
end

-- ═══════════════════════════════
-- 화살표들
-- ═══════════════════════════════
function PixelIcons.arrow_right()
    if cache.arrow_right then return cache.arrow_right end
    cache.arrow_right = make_icon(function(d)
        local C = {0.8, 0.8, 0.8}
        for i = 0, 5 do
            for y = 7-i, 8+i do px(d, 10-i, y, C[1], C[2], C[3]) end
        end
    end)
    return cache.arrow_right
end

function PixelIcons.arrow_left()
    if cache.arrow_left then return cache.arrow_left end
    cache.arrow_left = make_icon(function(d)
        local C = {0.8, 0.8, 0.8}
        for i = 0, 5 do
            for y = 7-i, 8+i do px(d, 5+i, y, C[1], C[2], C[3]) end
        end
    end)
    return cache.arrow_left
end

-- ═══════════════════════════════
-- 별 (광 카드)
-- ═══════════════════════════════
function PixelIcons.star()
    if cache.star then return cache.star end
    cache.star = make_icon(function(d)
        local G = {0.95, 0.80, 0.10}
        local pattern = {
            [2]  = {7,8},
            [3]  = {7,8},
            [4]  = {6,7,8,9},
            [5]  = {3,4,5,6,7,8,9,10,11,12},
            [6]  = {4,5,6,7,8,9,10,11},
            [7]  = {5,6,7,8,9,10},
            [8]  = {4,5,6,7,8,9,10,11},
            [9]  = {3,4,5,6,7,8,9,10,11,12},
            [10] = {6,7,8,9},
            [11] = {7,8},
            [12] = {7,8},
        }
        for y, cols in pairs(pattern) do
            for _, x in ipairs(cols) do
                px(d, x, y, G[1], G[2], G[3])
            end
        end
    end)
    return cache.star
end

-- ═══════════════════════════════
-- 도깨비 뿔 (보스)
-- ═══════════════════════════════
function PixelIcons.horn()
    if cache.horn then return cache.horn end
    cache.horn = make_icon(function(d)
        local H = {0.85, 0.70, 0.15}
        local D = {0.60, 0.45, 0.10}
        -- 왼쪽 뿔
        px(d, 3, 2, H[1], H[2], H[3])
        px(d, 4, 3, H[1], H[2], H[3])
        fill_rect(d, 4, 4, 2, 2, D[1], D[2], D[3])
        fill_rect(d, 4, 6, 3, 2, D[1], D[2], D[3])
        -- 오른쪽 뿔
        px(d, 12, 2, H[1], H[2], H[3])
        px(d, 11, 3, H[1], H[2], H[3])
        fill_rect(d, 10, 4, 2, 2, D[1], D[2], D[3])
        fill_rect(d, 9, 6, 3, 2, D[1], D[2], D[3])
        -- 머리
        fill_rect(d, 4, 8, 8, 6, 0.65, 0.15, 0.10)
        -- 눈
        px(d, 6, 10, 1, 0.9, 0.2)
        px(d, 10, 10, 1, 0.9, 0.2)
    end)
    return cache.horn
end

-- ═══════════════════════════════
-- 강화 관련 아이콘
-- ═══════════════════════════════
function PixelIcons.upgrade_chip()
    if cache.upgrade_chip then return cache.upgrade_chip end
    cache.upgrade_chip = make_icon(function(d)
        -- 화투패 모양
        local P = {0.20, 0.15, 0.35}
        local R = {0.72, 0.08, 0.08}
        fill_rect(d, 3, 1, 10, 14, P[1], P[2], P[3])
        -- 빨간 원 (홍단 느낌)
        for y = 4, 10 do
            for x = 5, 10 do
                local dx, dy = x-7.5, y-7
                if dx*dx + dy*dy < 10 then
                    px(d, x, y, R[1], R[2], R[3])
                end
            end
        end
        -- +5 표시
        px(d, 7, 6, 1, 1, 1)
        px(d, 6, 7, 1, 1, 1)
        px(d, 7, 7, 1, 1, 1)
        px(d, 8, 7, 1, 1, 1)
        px(d, 7, 8, 1, 1, 1)
    end)
    return cache.upgrade_chip
end

function PixelIcons.upgrade_mult()
    if cache.upgrade_mult then return cache.upgrade_mult end
    cache.upgrade_mult = make_icon(function(d)
        local B = {0.10, 0.25, 0.65}
        -- X 모양 (배수)
        fill_rect(d, 2, 2, 12, 12, B[1], B[2], B[3])
        for i = 0, 9 do
            px(d, 3+i, 3+i, 0.9, 0.8, 0.2)
            px(d, 12-i, 3+i, 0.9, 0.8, 0.2)
            px(d, 4+i, 3+i, 0.9, 0.8, 0.2)
            px(d, 11-i, 3+i, 0.9, 0.8, 0.2)
        end
    end)
    return cache.upgrade_mult
end

function PixelIcons.upgrade_life()
    if cache.upgrade_life then return cache.upgrade_life end
    cache.upgrade_life = PixelIcons.heart()
    return cache.upgrade_life
end

function PixelIcons.upgrade_yeop()
    if cache.upgrade_yeop then return cache.upgrade_yeop end
    cache.upgrade_yeop = PixelIcons.coin()
    return cache.upgrade_yeop
end

--- 모든 아이콘을 미리 생성 (love.load에서 호출)
function PixelIcons.preload()
    PixelIcons.heart()
    PixelIcons.heart_empty()
    PixelIcons.gear()
    PixelIcons.sword()
    PixelIcons.shield()
    PixelIcons.potion()
    PixelIcons.card_pack()
    PixelIcons.mirror()
    PixelIcons.thread()
    PixelIcons.coin()
    PixelIcons.talisman()
    PixelIcons.skull()
    PixelIcons.soul()
    PixelIcons.arrow_right()
    PixelIcons.arrow_left()
    PixelIcons.star()
    PixelIcons.horn()
    PixelIcons.upgrade_chip()
    PixelIcons.upgrade_mult()
end

--- 아이콘을 지정 크기로 그리기
function PixelIcons.draw(icon_fn, x, y, size)
    size = size or 16
    local tex = icon_fn()
    local scale = size / 16
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tex, x, y, 0, scale, scale)
end

return PixelIcons
