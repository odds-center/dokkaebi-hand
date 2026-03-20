--- 세이브 시스템: JSON 기반 로컬 파일 저장
--- Love2D에서는 love.filesystem, 순수 Lua에서는 io 사용
local json = require("lib.json")

local SAVE_KEY = "dokkaebi_save"
local SAVE_VERSION = "0.2.0"

local SaveSystem = {}
SaveSystem.__index = SaveSystem

function SaveSystem.new()
    return setmetatable({}, SaveSystem)
end

-- ============================================================
-- 저장소 백엔드 (love.filesystem 우선, fallback io)
-- ============================================================
local function get_filename()
    return SAVE_KEY .. ".json"
end

local function get_backup_filename()
    return SAVE_KEY .. ".json.bak"
end

--- love.filesystem 사용 가능 여부
local function has_love_filesystem()
    return love ~= nil and love.filesystem ~= nil
end

--- 파일 쓰기
local function write_file(filename, content)
    if has_love_filesystem() then
        local success, err = love.filesystem.write(filename, content)
        return success, err
    else
        local f, err = io.open(filename, "w")
        if not f then return false, err end
        f:write(content)
        f:close()
        return true, nil
    end
end

--- 파일 읽기
local function read_file(filename)
    if has_love_filesystem() then
        if not love.filesystem.getInfo(filename) then return nil end
        local content, err = love.filesystem.read(filename)
        return content
    else
        local f = io.open(filename, "r")
        if not f then return nil end
        local content = f:read("*a")
        f:close()
        return content
    end
end

--- 파일 존재 확인
local function file_exists(filename)
    if has_love_filesystem() then
        return love.filesystem.getInfo(filename) ~= nil
    else
        local f = io.open(filename, "r")
        if f then
            f:close()
            return true
        end
        return false
    end
end

--- 파일 삭제
local function delete_file(filename)
    if has_love_filesystem() then
        if love.filesystem.getInfo(filename) then
            love.filesystem.remove(filename)
        end
        return true
    else
        os.remove(filename)
        return true
    end
end

-- ============================================================
-- Public API
-- ============================================================

--- 세이브 데이터 저장
--- @param data table 세이브 데이터 테이블
--- @return boolean success
function SaveSystem:save(data)
    data.version = SAVE_VERSION
    data.timestamp = os.time()

    local ok, encoded = pcall(json.encode, data)
    if not ok then
        print("[Save] JSON 인코딩 실패: " .. tostring(encoded))
        return false
    end

    -- 백업: 기존 파일이 있으면 .bak으로 복사
    local filename = get_filename()
    local backup = get_backup_filename()
    local existing = read_file(filename)
    if existing then
        write_file(backup, existing)
    end

    local success, err = write_file(filename, encoded)
    if success then
        print("[Save] 저장 완료")
    else
        print("[Save] 저장 실패: " .. tostring(err))
    end
    return success
end

--- 세이브 데이터 로드
--- @return table|nil
function SaveSystem:load()
    local filename = get_filename()
    local content = read_file(filename)

    if not content then
        -- 백업에서 복구 시도
        local backup = get_backup_filename()
        content = read_file(backup)
        if content then
            print("[Save] 메인 세이브 없음, 백업에서 복구")
        end
    end

    if not content then return nil end

    local ok, data = pcall(json.decode, content)
    if not ok then
        print("[Save] 파싱 실패: " .. tostring(data))
        return nil
    end

    return data
end

--- 세이브 파일 존재 확인
--- @return boolean
function SaveSystem:has_save()
    return file_exists(get_filename()) or file_exists(get_backup_filename())
end

--- 모든 세이브 삭제
function SaveSystem:delete_all()
    delete_file(get_filename())
    delete_file(get_backup_filename())
    print("[Save] 모든 세이브 데이터 삭제 완료")
end

-- ============================================================
-- SaveData 구조 (참조용 팩토리)
-- ============================================================
function SaveSystem.create_save_data()
    return {
        version = SAVE_VERSION,
        timestamp = 0,

        -- 현재 런 상태
        spiral = nil,  -- { spiral, realm, total_cleared, blessing_id }
        lives = 5,
        yeop = 50,
        go_count = 0,
        equipped_talismans = {},
        equipped_companions = {},

        -- 보스 전투 상태
        current_boss_id = nil,
        boss_current_hp = 0,
        boss_max_hp = 0,
        current_round_in_realm = 0,

        -- 런 내 웨이브 강화 버프
        wave_chip_bonus = 0,
        wave_mult_bonus = 0,
        wave_talisman_slot_bonus = 0,
        wave_talisman_effect_bonus = 0,
        wave_target_reduction = 0,
        next_round_hand_bonus = 0,

        -- 메타 (영구)
        soul_fragments = 0,
        upgrade_levels = {},     -- { { id=..., level=... }, ... }
        unlocked_achievements = {},
        unlocked_companions = {},
        card_enhancements = {},

        -- 통계
        total_runs = 0,
        total_deaths = 0,
        highest_spiral = 0,
        highest_realm = 0,
        highest_single_score = 0,
        total_play_time_seconds = 0,
    }
end

return SaveSystem
