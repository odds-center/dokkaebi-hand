--- sprite_loader.lua
--- 생성된 픽셀아트 에셋을 로드하는 모듈
--- assets/sprites/ 폴더의 PNG 파일을 로드하고 캐싱

local SpriteLoader = {}
local cache = {}

local SPRITES_DIR = "assets/sprites/"

--- 카테고리별 기본 경로
local CATEGORIES = {
    boss              = "bosses/",
    companion         = "companions/",
    talisman          = "talismans/",
    card              = "card-illustrations/",
    background        = "backgrounds/",
    hud               = "hud-icons/",
    vfx               = "vfx/",
    ["ui-frames"]     = "ui-frames/",
    icon              = "icons/",
}

--- 크로마키 제거: ImageData에서 초록 배경 픽셀을 투명으로 처리
--- @param data love.ImageData
local function remove_chroma_key(data)
    local w, h = data:getWidth(), data:getHeight()
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b, a = data:getPixel(x, y)
            if a > 0 then
                -- 초록 지배 여부: G가 R/B 대비 현저히 높으면 크로마키
                local green_dominance = g - math.max(r, b)
                if green_dominance > 0.25 and g > 0.35 then
                    -- 완전 크로마키 픽셀 → 완전 투명
                    data:setPixel(x, y, r, g, b, 0)
                elseif green_dominance > 0.10 and g > 0.20 then
                    -- 가장자리 반투명 픽셀 → 알파 감쇠
                    local ratio = (green_dominance - 0.10) / 0.15
                    local new_a = a * math.max(0, 1 - ratio)
                    data:setPixel(x, y, r, g, b, new_a)
                end
            end
        end
    end
end

--- 이미지 로드 (캐싱, FilterMode.Point)
--- @param category string  카테고리 (boss, companion, talisman, card, background, hud, vfx)
--- @param name string      파일명 (확장자 제외)
--- @param chroma_key boolean  true이면 초록 크로마키 제거 적용
--- @return love.Image|nil
function SpriteLoader.get(category, name, chroma_key)
    local key = category .. "/" .. name
    if cache[key] then
        return cache[key]
    end

    local sub = CATEGORIES[category]
    if not sub then
        print("[SpriteLoader] 알 수 없는 카테고리: " .. category)
        return nil
    end

    local path = SPRITES_DIR .. sub .. name .. ".png"

    local info = love.filesystem.getInfo(path)
    if not info then
        return nil
    end

    local img
    if chroma_key then
        -- ImageData로 로드 → 크로마키 제거 → Image 생성
        local data = love.image.newImageData(path)
        remove_chroma_key(data)
        img = love.graphics.newImage(data)
    else
        img = love.graphics.newImage(path)
    end
    img:setFilter("nearest", "nearest")  -- 픽셀아트 필수!
    cache[key] = img
    return img
end

--- 보스 스프라이트 로드 (크로마키 자동 제거)
--- @param boss_id string  보스 ID (예: "glutton" 또는 "boss_glutton")
--- @return love.Image|nil
function SpriteLoader.getBoss(boss_id)
    local img = SpriteLoader.get("boss", boss_id, true)
    if not img and not boss_id:match("^boss_") then
        img = SpriteLoader.get("boss", "boss_" .. boss_id, true)
    end
    return img
end

--- 동료 스프라이트 로드 (크로마키 자동 제거)
function SpriteLoader.getCompanion(comp_id)
    return SpriteLoader.get("companion", comp_id, true)
end

--- 부적 아이콘 로드
function SpriteLoader.getTalisman(talisman_id)
    return SpriteLoader.get("talisman", talisman_id)
end

--- 카드 일러스트 로드
--- @param card_id string  카드 ID (예: "m01_gwang")
function SpriteLoader.getCard(card_id)
    return SpriteLoader.get("card", card_id)
end

--- 배경 로드
function SpriteLoader.getBackground(bg_id)
    return SpriteLoader.get("background", bg_id)
end

--- HUD 아이콘 로드
function SpriteLoader.getHUD(hud_id)
    return SpriteLoader.get("hud", hud_id)
end

--- VFX 이펙트 로드
function SpriteLoader.getVFX(vfx_id)
    return SpriteLoader.get("vfx", vfx_id)
end

--- 카테고리 내 모든 스프라이트 미리 로드
function SpriteLoader.preloadCategory(category)
    local sub = CATEGORIES[category]
    if not sub then return end

    local dir = SPRITES_DIR .. sub
    local items = love.filesystem.getDirectoryItems(dir)
    local count = 0
    for _, filename in ipairs(items) do
        if filename:match("%.png$") then
            local name = filename:gsub("%.png$", "")
            SpriteLoader.get(category, name)
            count = count + 1
        end
    end
    if count > 0 then
        print("[SpriteLoader] " .. category .. ": " .. count .. "개 로드")
    end
end

--- 전체 미리 로드
function SpriteLoader.preloadAll()
    for cat, _ in pairs(CATEGORIES) do
        SpriteLoader.preloadCategory(cat)
    end
end

--- 캐시 정보
function SpriteLoader.getCacheInfo()
    local count = 0
    for _ in pairs(cache) do count = count + 1 end
    return count
end

--- 캐시 초기화
function SpriteLoader.clearCache()
    cache = {}
end

return SpriteLoader
