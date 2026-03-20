--- 섯다 2장 족보 판정
--- 규칙: 그림 패(광/띠/그림)만 섯다 족보 인정.
---       피는 끗(숫자값)으로만 계산.
local Enums = require("src.cards.card_enums")
local CT = Enums.CardType

local SeotdaChallenge = {}

--- 카드가 "그림 패"인지 (광/띠/그림 = 족보 대상)
local function is_picture(card)
    return card.card_type == CT.Gwang
        or card.card_type == CT.Tti
        or card.card_type == CT.Geurim
end

--- 2장 평가 → { name, rank }
function SeotdaChallenge.evaluate(a, b)
    local mA = a.month
    local mB = b.month
    local a_pic = is_picture(a)
    local b_pic = is_picture(b)

    -- 피가 섞이면 끗 계산만
    if not a_pic or not b_pic then
        local kkeut = (mA + mB) % 10
        if kkeut == 0 then return { name = "갑오", rank = 0 } end
        return { name = kkeut .. "끗", rank = kkeut }
    end

    -- 이하: 두 장 모두 그림 패 → 정식 섯다 족보

    local a_gwang = a.card_type == CT.Gwang
    local b_gwang = b.card_type == CT.Gwang

    -- 광땡 (두 장 모두 광)
    if a_gwang and b_gwang then
        if (mA == 3 and mB == 8) or (mA == 8 and mB == 3) then
            return { name = "38광땡", rank = 100 }
        end
        if (mA == 1 and mB == 8) or (mA == 8 and mB == 1) then
            return { name = "18광땡", rank = 99 }
        end
        if (mA == 1 and mB == 3) or (mA == 3 and mB == 1) then
            return { name = "13광땡", rank = 98 }
        end
        return { name = "광땡", rank = 95 }
    end

    -- 땡 (같은 월)
    if mA == mB then
        local name = mA == 10 and "장땡" or (mA .. "땡")
        return { name = name, rank = 80 + mA }
    end

    -- 특수 조합
    local small = math.min(mA, mB)
    local big = math.max(mA, mB)

    if small == 1 and big == 2 then return { name = "알리", rank = 75 } end
    if small == 1 and big == 4 then return { name = "독사", rank = 74 } end
    if small == 1 and big == 9 then return { name = "구삥", rank = 73 } end
    if small == 1 and big == 10 then return { name = "장삥", rank = 72 } end
    if small == 4 and big == 10 then return { name = "장사", rank = 71 } end
    if small == 4 and big == 6 then return { name = "세륙", rank = 70 } end

    -- 사구파토 (4+9=13, 끗3이지만 재경기 기회)
    if (small == 4 and big == 9) then
        return { name = "사구파토", rank = 3, rematch = true }
    end

    -- 끗
    local kkeut = (mA + mB) % 10
    if kkeut == 0 then return { name = "갑오", rank = 0 } end
    return { name = kkeut .. "끗", rank = kkeut }
end

--- 섯다 기본 데미지 테이블
function SeotdaChallenge.base_damage(rank)
    if rank == 100 then return 55      -- 38광땡
    elseif rank == 99 then return 45   -- 18광땡
    elseif rank == 98 then return 40   -- 13광땡
    elseif rank == 95 then return 35   -- 기타 광땡
    elseif rank >= 90 then return 30   -- 장땡
    elseif rank >= 80 then return 18 + (rank - 80)  -- N땡 (상향: 15→18)
    elseif rank == 75 then return 28   -- 알리 (상향: 25→28)
    elseif rank == 74 then return 25   -- 독사 (상향: 22→25)
    elseif rank == 73 then return 22   -- 구삥 (상향: 20→22)
    elseif rank == 72 then return 20   -- 장삥 (상향: 18→20)
    elseif rank == 71 then return 18   -- 장사 (상향: 16→18)
    elseif rank == 70 then return 16   -- 세륙 (상향: 14→16)
    elseif rank >= 7 then return 8 + rank   -- 7~9끗 (상향: 6→8)
    elseif rank >= 1 then return 5 + rank   -- 1~6끗 (상향: 3→5)
    else return 4  -- 갑오 (상향: 2→4)
    end
end

return SeotdaChallenge
