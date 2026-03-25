--- icon_generator.lua
--- 도깨비의 패 — 픽셀아트 아이콘 생성기
--- 윈도우 아이콘, 앱 아이콘 등 모든 아이콘을 코드로 생성

local IconGenerator = {}

--- 도깨비 얼굴 + 화투패 아이콘 (16x16)
--- 0=투명, 1=뿔(금), 2=피부(진녹), 3=눈(도깨비불 청), 4=입(흑)
--- 5=이빨(백), 6=윤곽(암흑), 7=화투(한지), 8=화투띠(적), 9=도깨비불
local DOKKAEBI_16 = {
    {0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0},  -- 뿔 (비대칭, 도깨비답게)
    {0,0,1,1,0,0,0,0,0,0,1,1,1,0,0,0},
    {0,0,1,6,6,6,6,6,6,6,6,6,1,0,0,0},  -- 머리 윤곽
    {0,0,6,2,2,2,2,2,2,2,2,2,6,0,0,0},
    {0,6,2,2,3,3,2,2,2,3,3,2,2,6,0,0},  -- 눈 (도깨비불 파랑)
    {0,6,2,2,3,3,2,2,2,3,3,2,2,6,0,0},
    {0,6,2,2,2,2,2,6,2,2,2,2,2,6,0,0},  -- 코
    {0,6,2,4,4,4,4,4,4,4,4,4,2,6,0,0},  -- 입 (크게 벌린)
    {0,6,2,4,5,4,5,4,5,4,5,4,2,6,0,0},  -- 이빨 (들쭉날쭉)
    {0,0,6,2,4,4,4,4,4,4,4,2,6,0,0,0},
    {0,0,6,2,2,2,2,2,2,2,2,2,6,0,0,0},  -- 턱
    {0,0,0,6,6,2,2,2,2,2,6,6,0,0,0,0},
    {9,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0},  -- 도깨비불 (양 옆)
    {9,9,0,7,7,7,7,7,7,0,0,0,9,9,9,0},  -- 화투패 (하단)
    {0,9,0,7,8,8,8,8,7,0,0,0,0,9,0,0},
    {0,0,0,7,7,7,7,7,7,0,0,0,0,0,0,0},
}

local PALETTE = {
    [0] = {0, 0, 0, 0},           -- 투명
    [1] = {1.00, 0.84, 0.00, 1},  -- 뿔 (순금)
    [2] = {0.15, 0.45, 0.12, 1},  -- 피부 (진녹색, 전통 도깨비)
    [3] = {0.00, 0.83, 1.00, 1},  -- 눈 (도깨비불 청색)
    [4] = {0.08, 0.04, 0.04, 1},  -- 입 (흑)
    [5] = {0.95, 0.95, 0.90, 1},  -- 이빨 (백)
    [6] = {0.06, 0.20, 0.06, 1},  -- 윤곽 (암녹)
    [7] = {0.96, 0.90, 0.79, 1},  -- 화투 한지 (베이지)
    [8] = {0.77, 0.12, 0.23, 1},  -- 화투 홍단 (핏빛)
    [9] = {0.00, 0.83, 1.00, 0.7},-- 도깨비불 (반투명 청)
}

--- 32x32 도깨비 아이콘 (더 디테일)
local DOKKAEBI_32 = {}

--- 16x16 픽셀맵을 ImageData로 변환
---@param size number 출력 크기 (16, 32, 64, 128, 256)
---@return love.ImageData
function IconGenerator.create_icon(size)
    local img = love.image.newImageData(size, size)
    local scale = size / 16

    -- 도깨비 얼굴 그리기
    for y = 1, 16 do
        for x = 1, 16 do
            local idx = DOKKAEBI_16[y][x]
            local col = PALETTE[idx]
            if col[4] > 0 then
                -- 스케일링: 각 픽셀을 scale x scale 블록으로
                for sy = 0, scale-1 do
                    for sx = 0, scale-1 do
                        local px = (x-1)*scale + sx
                        local py = (y-1)*scale + sy
                        if px < size and py < size then
                            img:setPixel(px, py, col[1], col[2], col[3], col[4])
                        end
                    end
                end
            end
        end
    end

    return img
end

--- 윈도우 아이콘 설정 (love.window.setIcon)
function IconGenerator.set_window_icon()
    local icon_data = IconGenerator.create_icon(32)
    love.window.setIcon(icon_data)
    return icon_data
end

--- PNG 파일로 저장 (Steam/OS용)
---@param size number
---@param filename string
function IconGenerator.save_png(size, filename)
    local img = IconGenerator.create_icon(size)
    local file_data = img:encode("png")
    love.filesystem.write(filename, file_data)
    return true
end

--- 모든 크기의 아이콘 일괄 생성 & 저장
function IconGenerator.export_all()
    local sizes = {16, 32, 64, 128, 256}
    for _, sz in ipairs(sizes) do
        IconGenerator.save_png(sz, string.format("icon_%dx%d.png", sz, sz))
    end
end

return IconGenerator
