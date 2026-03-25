--- 도깨비의 패 앱 아이콘 생성기 (순수 Lua → PPM → PNG 변환)
--- 32x32 도깨비 도트 아이콘
--- 사용법: lua generate_icon.lua → icon_32x32.ppm 생성 후 변환

local SIZE = 32

-- 팔레트 (RGB)
local C = {
    _  = {0, 0, 0, 0},           -- 투명
    K  = {26, 26, 46},           -- 먹빛 배경 (#1A1A2E)
    R  = {196, 30, 58},          -- 핏빛 (#C41E3A)
    B  = {0, 212, 255},          -- 도깨비불 (#00D4FF)
    G  = {255, 215, 0},          -- 금빛 (#FFD700)
    W  = {232, 232, 232},        -- 흰색
    D  = {45, 45, 68},           -- 어두운 회색 (#2D2D44)
    O  = {255, 107, 53},         -- 주황 (#FF6B35)
    P  = {107, 45, 91},          -- 자주 (#6B2D5B)
    S  = {80, 80, 100},          -- 피부색 (회갈색)
    H  = {140, 100, 50},        -- 뿔 색
}

-- 32x32 도깨비 아이콘 (도트 매트릭스)
-- 화투 카드 위에 도깨비 얼굴
local icon = {
-- 1234567890123456789012345678901 2
  "________________________________", -- 1
  "________________________________", -- 2
  "________KKKKKKKKKKKKKKKK________", -- 3  카드 윤곽
  "_______KRRRRRRRRRRRRRRRRK_______", -- 4  카드 상단 (빨강)
  "_______KRRRRRRRRRRRRRRRRK_______", -- 5
  "_______KKKKKKKKKKKKKKKKKKK______", -- 6
  "_______KDDDDDDDDDDDDDDDDK______", -- 7  카드 본체
  "_______KD____HHHH____DDK________", -- 8  뿔
  "_______KD___H____H___DDK________", -- 9
  "_______KD__H______H__DDK________", -- 10
  "_______KD_HSSSSSSSSSH_DK________", -- 11 머리 시작
  "_______KDSSSSSSSSSSSSSDDK________", -- 12
  "_______KDSSBSSSSSSSBSSDDK_______", -- 13 눈 (B=도깨비불)
  "_______KDSSBSSSSSSSBSSDDK_______", -- 14
  "_______KDSSSSSSSSSSSSSDDK_______", -- 15
  "_______KDSSSSOOOOSSSSSDDK_______", -- 16 입 (O=주황 이빨)
  "_______KDSSSSOWWOSSSSSDDK_______", -- 17
  "_______KDSSSSOOOOSSSSSDDK_______", -- 18
  "_______KDSSSSSSSSSSSSSDDK_______", -- 19
  "_______KDD_SSSSSSSS_DDDK________", -- 20
  "_______KDDDD_SSSS_DDDDK_________", -- 21
  "_______KDDDDDDDDDDDDDK_________", -- 22
  "_______KDDDDDDDDDDDDDDK________", -- 23
  "_______KKKKKKKKKKKKKKKKK________", -- 24 카드 하단
  "________KGGGGGGGGGGGGGGK________", -- 25 금색 하단 띠
  "________KGGGGGGGGGGGGGGK________", -- 26
  "________KKKKKKKKKKKKKKKK________", -- 27
  "________________________________", -- 28
  "______BB________________BB______", -- 29 도깨비불 (양 옆)
  "_____BBBB______________BBBB_____", -- 30
  "______BB________________BB______", -- 31
  "________________________________", -- 32
}

-- PPM 형식으로 출력
local ppm = string.format("P6\n%d %d\n255\n", SIZE, SIZE)
local pixels = {}

for y = 1, SIZE do
    local row = icon[y] or string.rep("_", SIZE)
    for x = 1, SIZE do
        local ch = row:sub(x, x)
        local color = C[ch] or C["_"]
        if color[4] == 0 then
            -- 투명 → 먹빛 배경
            color = C.K
        end
        pixels[#pixels+1] = string.char(color[1], color[2], color[3])
    end
end

local f = io.open("icon_32x32.ppm", "wb")
f:write(ppm)
f:write(table.concat(pixels))
f:close()
print("icon_32x32.ppm 생성 완료!")
print("변환: sips -s format png icon_32x32.ppm --out icon.png")
