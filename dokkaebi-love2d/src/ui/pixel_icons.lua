--- pixel_icons.lua
--- 16×16 픽셀아트 아이콘 통일 스타일
--- 규칙: 짙은 아웃라인(OL) + 메인 컬러 + 좌상단 하이라이트 1~2px

local PixelIcons = {}
local cache = {}

-- ─────────────────────────────────────────────
-- 기본 유틸
-- ─────────────────────────────────────────────
local function px(d, x, y, r, g, b, a)
    if x >= 0 and x < 16 and y >= 0 and y < 16 then
        d:setPixel(x, y, r, g, b, a or 1)
    end
end

local function fill(d, x0, y0, w, h, r, g, b, a)
    for y = y0, y0+h-1 do for x = x0, x0+w-1 do
        px(d, x, y, r, g, b, a or 1)
    end end
end

-- 통일 아웃라인 색
local OL = {0.12, 0.08, 0.06}

-- 그린 픽셀 주변 1px 아웃라인 자동 추가
local function outline(d)
    local m = {}
    for y = 0, 15 do m[y] = {} for x = 0, 15 do
        local _,_,_,a = d:getPixel(x,y); m[y][x] = a > 0.1
    end end
    for y = 0, 15 do for x = 0, 15 do
        if not m[y][x] then
            for _, o in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
                local nx, ny = x+o[1], y+o[2]
                if nx >= 0 and nx < 16 and ny >= 0 and ny < 16 and m[ny] and m[ny][nx] then
                    d:setPixel(x, y, OL[1], OL[2], OL[3], 1); break
                end
            end
        end
    end end
end

local function make_icon(fn)
    local d = love.image.newImageData(16, 16)
    fn(d)
    local t = love.graphics.newImage(d)
    t:setFilter("nearest", "nearest")
    return t
end

-- ─────────────────────────────────────────────
-- 하트 (체력)
-- ─────────────────────────────────────────────
function PixelIcons.heart()
    if cache.heart then return cache.heart end
    cache.heart = make_icon(function(d)
        local R = {0.88, 0.18, 0.14}
        local D = {0.58, 0.08, 0.06}
        local H = {1.00, 0.55, 0.55}
        local rows = {
            {5,6,  9,10},
            {4,5,6,7, 8,9,10,11},
            {3,4,5,6,7,8,9,10,11,12},
            {3,4,5,6,7,8,9,10,11,12},
            {3,4,5,6,7,8,9,10,11,12},
            {4,5,6,7,8,9,10,11},
            {5,6,7,8,9,10},
            {6,7,8,9},
            {7,8},
        }
        for yi, cols in ipairs(rows) do
            for _, x in ipairs(cols) do
                local c = (yi <= 3) and R or D
                px(d, x, yi+3, c[1], c[2], c[3])
            end
        end
        px(d, 5, 5, H[1], H[2], H[3])
        px(d, 10, 5, H[1], H[2], H[3])
        outline(d)
    end)
    return cache.heart
end

-- ─────────────────────────────────────────────
-- 빈 하트 (잃은 체력)
-- ─────────────────────────────────────────────
function PixelIcons.heart_empty()
    if cache.heart_empty then return cache.heart_empty end
    cache.heart_empty = make_icon(function(d)
        local E = {0.30, 0.12, 0.12}
        local rows = {
            {5,6,  9,10},
            {4,7,  8,11},
            {3,12},
            {3,12},
            {3,12},
            {4,11},
            {5,10},
            {6,9},
            {7,8},
        }
        for yi, cols in ipairs(rows) do
            for _, x in ipairs(cols) do
                px(d, x, yi+3, E[1], E[2], E[3])
            end
        end
        outline(d)
    end)
    return cache.heart_empty
end

-- ─────────────────────────────────────────────
-- 톱니바퀴 (설정) — 수학 기반 8톱니 + 투명 구멍
-- ─────────────────────────────────────────────
function PixelIcons.gear()
    if cache.gear then return cache.gear end
    cache.gear = make_icon(function(d)
        local cx, cy   = 7.5, 7.5
        local G  = {0.70, 0.70, 0.75}   -- 메인 회색
        local H  = {0.88, 0.88, 0.93}   -- 하이라이트
        local Sh = {0.44, 0.44, 0.50}   -- 음영
        local Oc = {0.20, 0.20, 0.22}   -- 내부 아웃라인 (구멍 테두리)

        local BODY_R  = 4.6
        local OUTER_R = 6.4
        local HOLE_R  = 1.7
        local N       = 8

        for y = 0, 15 do
            for x = 0, 15 do
                local dx, dy = x - cx, y - cy
                local r = math.sqrt(dx*dx + dy*dy)
                local angle = math.atan2(dy, dx)
                local t = ((angle + math.pi) / (2*math.pi) * N) % 1
                local in_tooth = t < 0.40 or t > 0.60
                local eff_r = in_tooth and OUTER_R or BODY_R

                if r < HOLE_R then
                    -- 중앙 구멍 = 투명 (아무것도 안 그림)

                elseif r < HOLE_R + 1.0 then
                    -- 구멍 테두리
                    px(d, x, y, Oc[1], Oc[2], Oc[3])

                elseif r < eff_r then
                    -- 기어 몸통 & 이빨 내부
                    local col
                    if dx < -0.5 and dy < -0.5 then
                        col = H
                    elseif dx > 0.5 and dy > 0.5 then
                        col = Sh
                    else
                        col = G
                    end
                    px(d, x, y, col[1], col[2], col[3])

                elseif r < eff_r + 0.9 then
                    -- 외곽 아웃라인
                    px(d, x, y, OL[1], OL[2], OL[3])
                end
            end
        end
    end)
    return cache.gear
end

-- ─────────────────────────────────────────────
-- 검 (공격/칩)
-- ─────────────────────────────────────────────
function PixelIcons.sword()
    if cache.sword then return cache.sword end
    cache.sword = make_icon(function(d)
        local B = {0.78, 0.82, 0.92}   -- 칼날
        local BH= {0.95, 0.97, 1.00}   -- 칼날 하이라이트
        local Gd= {0.90, 0.80, 0.20}   -- 가드 (금)
        local Hd= {0.55, 0.35, 0.15}   -- 손잡이 (갈색)
        -- 칼날 (2px 굵기 대각선)
        for i = 0, 8 do
            px(d, 13-i, 1+i, BH[1], BH[2], BH[3])
            px(d, 12-i, 1+i, B[1],  B[2],  B[3] )
            px(d, 13-i, 2+i, B[1],  B[2],  B[3] )
        end
        -- 가드 (2×4 가로)
        fill(d, 2, 9, 5, 2, Gd[1], Gd[2], Gd[3])
        -- 손잡이
        fill(d, 3, 11, 2, 4, Hd[1], Hd[2], Hd[3])
        outline(d)
    end)
    return cache.sword
end

-- ─────────────────────────────────────────────
-- 방패 (배수/방어)
-- ─────────────────────────────────────────────
function PixelIcons.shield()
    if cache.shield then return cache.shield end
    cache.shield = make_icon(function(d)
        local O  = {0.22, 0.45, 0.80}   -- 외곽
        local I  = {0.15, 0.30, 0.58}   -- 내부
        local G  = {0.90, 0.78, 0.18}   -- 금 문양
        -- 방패 형태
        local shape = {
            {4,11}, {3,12}, {3,12}, {3,12}, {3,12},
            {4,11}, {5,10}, {6,9}, {7,8}
        }
        for row = 2, 13 do
            local idx = row - 1
            local hw = ({6,7,7,7,7,7,7,6,5,4,3,2})[idx] or 2
            for x = 8-hw, 8+hw do
                local is_edge = (x==8-hw or x==8+hw or row==2 or row==13)
                local c = is_edge and O or I
                px(d, x, row, c[1], c[2], c[3])
            end
        end
        -- 십자 금 문양
        for y = 5, 10 do px(d, 8, y, G[1], G[2], G[3]) end
        for x = 6, 10 do px(d, x, 7, G[1], G[2], G[3]) end
        outline(d)
    end)
    return cache.shield
end

-- ─────────────────────────────────────────────
-- 물약 (체력 회복)
-- ─────────────────────────────────────────────
function PixelIcons.potion()
    if cache.potion then return cache.potion end
    cache.potion = make_icon(function(d)
        local Gl = {0.55, 0.55, 0.62}   -- 유리
        local Lq = {0.85, 0.18, 0.18}   -- 빨간 액체
        local Ck = {0.65, 0.52, 0.32}   -- 코르크
        local Hl = {0.85, 0.85, 0.92}   -- 하이라이트
        -- 코르크
        fill(d, 6, 1, 4, 2, Ck[1], Ck[2], Ck[3])
        -- 목
        fill(d, 6, 3, 4, 2, Gl[1], Gl[2], Gl[3])
        -- 병 몸체 — 바깥
        for y = 5, 13 do
            local hw = y <= 6 and 3 or 5
            for x = 8-hw, 8+hw do
                local is_edge = (x == 8-hw or x == 8+hw)
                if is_edge then
                    px(d, x, y, Gl[1], Gl[2], Gl[3])
                elseif y >= 8 then
                    px(d, x, y, Lq[1], Lq[2], Lq[3])
                end
            end
        end
        fill(d, 3, 13, 10, 1, Gl[1], Gl[2], Gl[3])
        -- 하이라이트
        px(d, 4,  8, Hl[1], Hl[2], Hl[3])
        px(d, 4,  9, Hl[1], Hl[2], Hl[3])
        outline(d)
    end)
    return cache.potion
end

-- ─────────────────────────────────────────────
-- 카드 팩
-- ─────────────────────────────────────────────
function PixelIcons.card_pack()
    if cache.card_pack then return cache.card_pack end
    cache.card_pack = make_icon(function(d)
        local C1 = {0.18, 0.14, 0.34}   -- 뒤
        local C2 = {0.25, 0.18, 0.42}   -- 중간
        local Cf = {0.38, 0.28, 0.58}   -- 앞
        local Br = {0.52, 0.42, 0.72}   -- 앞 테두리
        local Ql = {0.92, 0.82, 0.22}   -- 물음표
        -- 뒤쪽 카드
        fill(d, 5, 1, 8, 12, C1[1], C1[2], C1[3])
        -- 중간 카드
        fill(d, 3, 2, 8, 12, C2[1], C2[2], C2[3])
        -- 앞 카드
        fill(d, 2, 4, 8, 11, Cf[1], Cf[2], Cf[3])
        -- 앞 테두리
        for x = 2, 9 do px(d, x, 4, Br[1], Br[2], Br[3]); px(d, x, 14, Br[1], Br[2], Br[3]) end
        for y = 4, 14 do px(d, 2, y, Br[1], Br[2], Br[3]); px(d, 9, y, Br[1], Br[2], Br[3]) end
        -- 물음표
        fill(d, 5, 6, 2, 1, Ql[1], Ql[2], Ql[3])
        px(d, 6, 7, Ql[1], Ql[2], Ql[3])
        px(d, 5, 8, Ql[1], Ql[2], Ql[3])
        px(d, 5, 9, Ql[1], Ql[2], Ql[3])
        px(d, 5, 11, Ql[1], Ql[2], Ql[3])
        outline(d)
    end)
    return cache.card_pack
end

-- ─────────────────────────────────────────────
-- 거울 (복사 아이템)
-- ─────────────────────────────────────────────
function PixelIcons.mirror()
    if cache.mirror then return cache.mirror end
    cache.mirror = make_icon(function(d)
        local Fr = {0.48, 0.36, 0.24}   -- 프레임 (나무)
        local Ms = {0.55, 0.68, 0.80}   -- 거울면 (청회)
        local Hl = {0.78, 0.90, 1.00}   -- 하이라이트
        -- 타원형 거울 프레임
        for y = 1, 14 do
            local hw = math.max(0, math.floor(6 - math.abs(y - 7.5) * 0.7))
            for x = 8-hw, 8+hw do
                local is_edge = (x == 8-hw or x == 8+hw or y == 1 or y == 14)
                px(d, x, y, is_edge and Fr[1] or Ms[1],
                             is_edge and Fr[2] or Ms[2],
                             is_edge and Fr[3] or Ms[3])
            end
        end
        -- 손잡이
        fill(d, 7, 14, 2, 2, Fr[1], Fr[2], Fr[3])
        -- 반사 하이라이트 (좌상단 사선)
        px(d, 5, 3, Hl[1], Hl[2], Hl[3])
        px(d, 6, 3, Hl[1], Hl[2], Hl[3])
        px(d, 5, 4, Hl[1], Hl[2], Hl[3])
        outline(d)
    end)
    return cache.mirror
end

-- ─────────────────────────────────────────────
-- 실타래 (윤회의 실)
-- ─────────────────────────────────────────────
function PixelIcons.thread()
    if cache.thread then return cache.thread end
    cache.thread = make_icon(function(d)
        local T  = {0.72, 0.28, 0.85}   -- 실 (보라)
        local Td = {0.50, 0.18, 0.62}   -- 실 어두운
        local Tl = {0.88, 0.55, 1.00}   -- 실 밝은
        -- 실타래 원형 (도넛)
        for y = 2, 13 do for x = 2, 13 do
            local dx, dy = x-7.5, y-7.5
            local r = math.sqrt(dx*dx+dy*dy)
            if r > 2.2 and r < 5.8 then
                local c = ((x+y) % 3 == 0) and Td or ((x+y) % 3 == 1) and Tl or T
                px(d, x, y, c[1], c[2], c[3])
            end
        end end
        -- 늘어진 실 꼬리
        px(d, 10, 10, T[1], T[2], T[3])
        px(d, 11, 11, T[1], T[2], T[3])
        px(d, 12, 12, T[1], T[2], T[3])
        px(d, 13, 13, Td[1], Td[2], Td[3])
        outline(d)
    end)
    return cache.thread
end

-- ─────────────────────────────────────────────
-- 엽전 (화폐)
-- ─────────────────────────────────────────────
function PixelIcons.coin()
    if cache.coin then return cache.coin end
    cache.coin = make_icon(function(d)
        local G  = {0.88, 0.72, 0.12}   -- 금
        local D  = {0.62, 0.48, 0.06}   -- 금 어두운
        local Hl = {0.98, 0.92, 0.55}   -- 하이라이트
        for y = 2, 13 do for x = 2, 13 do
            local dx, dy = x-7.5, y-7.5
            local r = math.sqrt(dx*dx+dy*dy)
            if r < 5.5 then
                local c = (r < 2.5) and D or (dx < -0.5 and dy < -0.5) and Hl or G
                px(d, x, y, c[1], c[2], c[3])
            end
        end end
        -- 사각 구멍 (엽전 특징)
        fill(d, 6, 6, 3, 3, 0.04, 0.02, 0.06)
        outline(d)
    end)
    return cache.coin
end

-- ─────────────────────────────────────────────
-- 부적 (스크롤)
-- ─────────────────────────────────────────────
function PixelIcons.talisman()
    if cache.talisman then return cache.talisman end
    cache.talisman = make_icon(function(d)
        local P  = {0.82, 0.76, 0.54}   -- 한지
        local Pk = {0.92, 0.88, 0.70}   -- 한지 밝은
        local Ink= {0.16, 0.12, 0.08}   -- 먹
        local Rd = {0.75, 0.14, 0.10}   -- 주홍 도장
        -- 말린 위아래 (롤 표현)
        fill(d, 3, 1, 10, 1, P[1],  P[2],  P[3])
        fill(d, 4, 2, 8,  1, Pk[1], Pk[2], Pk[3])
        fill(d, 3, 3, 10, 9, P[1],  P[2],  P[3])
        fill(d, 4, 12, 8, 1, Pk[1], Pk[2], Pk[3])
        fill(d, 3, 13, 10, 1, P[1], P[2],  P[3])
        -- 먹 글씨 (가로줄 3개)
        fill(d, 5, 4, 6, 1, Ink[1], Ink[2], Ink[3])
        fill(d, 5, 6, 6, 1, Ink[1], Ink[2], Ink[3])
        fill(d, 5, 8, 4, 1, Ink[1], Ink[2], Ink[3])
        -- 주홍 도장
        fill(d, 8, 9, 4, 3, Rd[1], Rd[2], Rd[3])
        outline(d)
    end)
    return cache.talisman
end

-- ─────────────────────────────────────────────
-- 해골 (보스/위험)
-- ─────────────────────────────────────────────
function PixelIcons.skull()
    if cache.skull then return cache.skull end
    cache.skull = make_icon(function(d)
        local W = {0.88, 0.84, 0.76}   -- 뼈
        local Wh= {0.98, 0.96, 0.90}   -- 하이라이트
        local Dk= {0.06, 0.04, 0.04}   -- 눈구멍/어둠
        -- 두개골 (둥근 상단)
        fill(d, 4, 2, 8, 2, W[1], W[2], W[3])
        fill(d, 3, 4, 10, 4, W[1], W[2], W[3])
        fill(d, 4, 8, 8, 2, W[1], W[2], W[3])
        -- 하이라이트 (좌상단)
        px(d, 4, 3, Wh[1], Wh[2], Wh[3])
        px(d, 5, 3, Wh[1], Wh[2], Wh[3])
        px(d, 4, 4, Wh[1], Wh[2], Wh[3])
        -- 눈구멍
        fill(d, 4, 5, 3, 2, Dk[1], Dk[2], Dk[3])
        fill(d, 9, 5, 3, 2, Dk[1], Dk[2], Dk[3])
        -- 코 (작은 구멍)
        px(d, 7, 7, Dk[1], Dk[2], Dk[3])
        px(d, 8, 7, Dk[1], Dk[2], Dk[3])
        -- 턱/이빨
        fill(d, 4, 10, 8, 1, W[1], W[2], W[3])
        fill(d, 5, 11, 6, 2, W[1], W[2], W[3])
        -- 이빨 사이 틈
        px(d, 6,  11, Dk[1], Dk[2], Dk[3])
        px(d, 8,  11, Dk[1], Dk[2], Dk[3])
        px(d, 10, 11, Dk[1], Dk[2], Dk[3])
        outline(d)
    end)
    return cache.skull
end

-- ─────────────────────────────────────────────
-- 넋 (영혼 조각)
-- ─────────────────────────────────────────────
function PixelIcons.soul()
    if cache.soul then return cache.soul end
    cache.soul = make_icon(function(d)
        local S1 = {0.38, 0.68, 0.92}   -- 영혼 파랑
        local S2 = {0.25, 0.48, 0.72}   -- 어두운 파랑
        local Sl = {0.68, 0.88, 1.00}   -- 밝은 파랑
        local Ey = {1.00, 1.00, 1.00}   -- 눈 흰
        -- 불꽃 형태
        local rows = {
            [2]  = {7,8},
            [3]  = {6,7,8,9},
            [4]  = {5,6,7,8,9,10},
            [5]  = {5,6,7,8,9,10},
            [6]  = {4,5,6,7,8,9,10,11},
            [7]  = {4,5,6,7,8,9,10,11},
            [8]  = {5,6,7,8,9,10},
            [9]  = {5,6,7,8,9,10},
            [10] = {6,7,8,9},
            [11] = {7,8},
            [12] = {7},
        }
        for y, cols in pairs(rows) do
            for _, x in ipairs(cols) do
                local c = ((x+y)%3==0) and S2 or ((x+y)%3==1) and Sl or S1
                px(d, x, y, c[1], c[2], c[3])
            end
        end
        -- 눈
        px(d, 6, 7, Ey[1], Ey[2], Ey[3])
        px(d, 9, 7, Ey[1], Ey[2], Ey[3])
        -- 입 (작은 미소)
        px(d, 6, 9, S2[1], S2[2], S2[3])
        px(d, 9, 9, S2[1], S2[2], S2[3])
        outline(d)
    end)
    return cache.soul
end

-- ─────────────────────────────────────────────
-- 화살표 (우/좌)
-- ─────────────────────────────────────────────
function PixelIcons.arrow_right()
    if cache.arrow_right then return cache.arrow_right end
    cache.arrow_right = make_icon(function(d)
        local C = {0.82, 0.82, 0.85}
        for i = 0, 5 do
            for y = 7-i, 8+i do px(d, 10-i, y, C[1], C[2], C[3]) end
        end
        outline(d)
    end)
    return cache.arrow_right
end

function PixelIcons.arrow_left()
    if cache.arrow_left then return cache.arrow_left end
    cache.arrow_left = make_icon(function(d)
        local C = {0.82, 0.82, 0.85}
        for i = 0, 5 do
            for y = 7-i, 8+i do px(d, 5+i, y, C[1], C[2], C[3]) end
        end
        outline(d)
    end)
    return cache.arrow_left
end

-- ─────────────────────────────────────────────
-- 별 (광 카드)
-- ─────────────────────────────────────────────
function PixelIcons.star()
    if cache.star then return cache.star end
    cache.star = make_icon(function(d)
        local G  = {0.96, 0.82, 0.12}
        local Gl = {1.00, 0.96, 0.60}   -- 하이라이트
        local pattern = {
            [2]  = {7,8},
            [3]  = {7,8},
            [4]  = {6,7,8,9},
            [5]  = {3,4,5,6,7,8,9,10,11,12},
            [6]  = {5,6,7,8,9,10},
            [7]  = {6,7,8,9},
            [8]  = {5,6,7,8,9,10},
            [9]  = {3,4,5,6,7,8,9,10,11,12},
            [10] = {6,7,8,9},
            [11] = {7,8},
            [12] = {7,8},
        }
        for y, cols in pairs(pattern) do
            for _, x in ipairs(cols) do
                local c = (x==7 and y<=6) and Gl or G
                px(d, x, y, c[1], c[2], c[3])
            end
        end
        outline(d)
    end)
    return cache.star
end

-- ─────────────────────────────────────────────
-- 도깨비 뿔 (보스)
-- ─────────────────────────────────────────────
function PixelIcons.horn()
    if cache.horn then return cache.horn end
    cache.horn = make_icon(function(d)
        local H  = {0.88, 0.72, 0.14}   -- 뿔 (금)
        local Hd = {0.62, 0.46, 0.08}   -- 뿔 어두운
        local Sk = {0.68, 0.16, 0.10}   -- 피부 (붉은)
        local Ey = {1.00, 0.92, 0.20}   -- 눈 (황)
        -- 왼쪽 뿔
        px(d, 3,  2, H[1],  H[2],  H[3])
        px(d, 4,  3, H[1],  H[2],  H[3])
        fill(d, 4, 4, 2, 2, Hd[1], Hd[2], Hd[3])
        fill(d, 4, 6, 2, 2, Hd[1], Hd[2], Hd[3])
        -- 오른쪽 뿔
        px(d, 12, 2, H[1],  H[2],  H[3])
        px(d, 11, 3, H[1],  H[2],  H[3])
        fill(d, 10, 4, 2, 2, Hd[1], Hd[2], Hd[3])
        fill(d, 10, 6, 2, 2, Hd[1], Hd[2], Hd[3])
        -- 머리
        fill(d, 4, 8, 8, 6, Sk[1], Sk[2], Sk[3])
        -- 눈
        px(d, 6,  10, Ey[1], Ey[2], Ey[3])
        px(d, 7,  10, Ey[1], Ey[2], Ey[3])
        px(d, 9,  10, Ey[1], Ey[2], Ey[3])
        px(d, 10, 10, Ey[1], Ey[2], Ey[3])
        -- 입 (일직선)
        fill(d, 6, 12, 5, 1, Hd[1], Hd[2], Hd[3])
        outline(d)
    end)
    return cache.horn
end

-- ─────────────────────────────────────────────
-- 강화 아이콘들
-- ─────────────────────────────────────────────
function PixelIcons.upgrade_chip()
    if cache.upgrade_chip then return cache.upgrade_chip end
    cache.upgrade_chip = make_icon(function(d)
        local P  = {0.22, 0.16, 0.38}   -- 카드 배경
        local Rd = {0.88, 0.22, 0.14}   -- 홍단 헤더
        local Br = {0.45, 0.35, 0.65}   -- 테두리
        local G  = {0.38, 0.92, 0.42}   -- 초록 화살표
        -- 카드 몸체
        fill(d, 2, 3, 8, 11, P[1], P[2], P[3])
        fill(d, 2, 3, 8, 3,  Rd[1], Rd[2], Rd[3])
        for y = 3, 13 do
            px(d, 2, y, Br[1], Br[2], Br[3])
            px(d, 9, y, Br[1], Br[2], Br[3])
        end
        for x = 2, 9 do
            px(d, x, 3,  Br[1], Br[2], Br[3])
            px(d, x, 13, Br[1], Br[2], Br[3])
        end
        -- 위쪽 화살표
        px(d,  13, 4, G[1], G[2], G[3])
        fill(d, 12, 5, 3, 1, G[1], G[2], G[3])
        fill(d, 11, 6, 5, 1, G[1], G[2], G[3])
        fill(d, 12, 7, 3, 5, G[1], G[2], G[3])
        outline(d)
    end)
    return cache.upgrade_chip
end

function PixelIcons.upgrade_mult()
    if cache.upgrade_mult then return cache.upgrade_mult end
    cache.upgrade_mult = make_icon(function(d)
        local Bg = {0.16, 0.10, 0.32}   -- 배경 원
        local X  = {0.92, 0.52, 0.12}   -- × 주황
        local G  = {0.38, 0.92, 0.42}   -- 초록 화살표
        -- 배경 원
        for y = 2, 12 do for x = 1, 11 do
            local dx, dy = x-6, y-7
            if dx*dx+dy*dy < 26 then px(d, x, y, Bg[1], Bg[2], Bg[3]) end
        end end
        -- × 기호
        for i = 0, 4 do
            px(d, 3+i, 4+i, X[1], X[2], X[3])
            px(d, 4+i, 4+i, X[1], X[2], X[3])
            px(d, 9-i, 4+i, X[1], X[2], X[3])
            px(d, 8-i, 4+i, X[1], X[2], X[3])
        end
        -- 위쪽 화살표
        px(d,  13, 4, G[1], G[2], G[3])
        fill(d, 12, 5, 3, 1, G[1], G[2], G[3])
        fill(d, 11, 6, 5, 1, G[1], G[2], G[3])
        fill(d, 12, 7, 3, 5, G[1], G[2], G[3])
        outline(d)
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

-- ─────────────────────────────────────────────
-- 미리 로드
-- ─────────────────────────────────────────────
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

-- 지정 크기로 그리기
function PixelIcons.draw(icon_fn, x, y, size)
    size = size or 16
    local tex = icon_fn()
    local scale = size / 16
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(tex, x, y, 0, scale, scale)
end

return PixelIcons
