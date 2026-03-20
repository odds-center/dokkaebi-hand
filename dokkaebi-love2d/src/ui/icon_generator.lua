--- icon_generator.lua
--- 도깨비의 패 — 픽셀아트 아이콘 생성기
--- 윈도우 아이콘, 앱 아이콘 등 모든 아이콘을 코드로 생성

local IconGenerator = {}

--- 도깨비 얼굴 픽셀맵 (16x16 기본)
--- 0=투명, 1=뿔(금), 2=머리(적), 3=눈(노), 4=입(흑), 5=이빨(백), 6=테두리(암적)
local DOKKAEBI_16 = {
    {0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0},
    {0,0,0,1,6,6,6,6,6,6,6,1,0,0,0,0},
    {0,0,6,2,2,2,2,2,2,2,2,2,6,0,0,0},
    {0,0,6,2,2,2,2,2,2,2,2,2,6,0,0,0},
    {0,0,2,2,3,3,2,2,2,3,3,2,2,0,0,0},
    {0,0,2,2,3,3,2,2,2,3,3,2,2,0,0,0},
    {0,0,2,2,2,2,2,2,2,2,2,2,2,0,0,0},
    {0,0,2,2,4,4,4,4,4,4,4,2,2,0,0,0},
    {0,0,2,2,4,5,4,5,4,5,4,2,2,0,0,0},
    {0,0,6,2,2,4,4,4,4,4,2,2,6,0,0,0},
    {0,0,0,6,2,2,2,2,2,2,2,6,0,0,0,0},
    {0,0,0,0,6,6,6,6,6,6,6,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
}

--- 화투패 심볼 (좌하단에 작은 화투패 모양)
local HWATU_ACCENT = {
    {0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7},
    {0,0,0,0,0,0,0,0,0,0,0,0,7,8,8,7},
    {0,0,0,0,0,0,0,0,0,0,0,0,7,8,8,7},
    {0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,7},
}

local PALETTE = {
    [0] = {0, 0, 0, 0},           -- 투명
    [1] = {0.90, 0.75, 0.15, 1},  -- 뿔 (금색)
    [2] = {0.70, 0.15, 0.10, 1},  -- 머리 (적색)
    [3] = {1.00, 0.85, 0.10, 1},  -- 눈 (노란)
    [4] = {0.10, 0.05, 0.05, 1},  -- 입 (흑)
    [5] = {0.95, 0.95, 0.90, 1},  -- 이빨 (백)
    [6] = {0.40, 0.08, 0.05, 1},  -- 테두리 (암적)
    [7] = {0.20, 0.15, 0.35, 1},  -- 화투 테두리 (암자)
    [8] = {0.85, 0.20, 0.15, 1},  -- 화투 안쪽 (적)
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

    -- 화투패 악센트 (우하단, 12~15열 / 12~15행 영역)
    for y = 1, #HWATU_ACCENT do
        for x = 1, #HWATU_ACCENT[y] do
            local idx = HWATU_ACCENT[y][x]
            if idx > 0 then
                local col = PALETTE[idx]
                local base_y = 12 + y - 1
                local base_x = x  -- HWATU_ACCENT는 이미 13~16 컬럼 기준
                -- 실제 좌표: HWATU_ACCENT의 x는 13~16열에 대응
                for sy = 0, scale-1 do
                    for sx = 0, scale-1 do
                        local px = (base_x + 11)*scale + sx  -- 13열부터
                        local py = (base_y - 1)*scale + sy
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
