--- 섯다 2장 족보 판정
local Enums = require("src.cards.card_enums")

local SeotdaChallenge = {}

--- 2장 평가 → { name, rank }
function SeotdaChallenge.evaluate(a, b)
    local mA = a.month
    local mB = b.month
    local a_gwang = a.card_type == Enums.CardType.Gwang
    local b_gwang = b.card_type == Enums.CardType.Gwang

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

    -- 끗
    local kkeut = (mA + mB) % 10
    if kkeut == 0 then return { name = "갑오", rank = 0 } end
    return { name = kkeut .. "끗", rank = kkeut }
end

--- 섯다 기본 데미지 테이블
function SeotdaChallenge.base_damage(rank)
    if rank == 100 then return 80      -- 38광땡
    elseif rank == 99 then return 70   -- 18광땡
    elseif rank == 98 then return 65   -- 13광땡
    elseif rank == 95 then return 60   -- 기타 광땡
    elseif rank >= 90 then return 50   -- 장땡
    elseif rank >= 80 then return 25 + (rank - 80) * 2  -- N땡
    elseif rank == 75 then return 35   -- 알리
    elseif rank == 74 then return 32   -- 독사
    elseif rank == 73 then return 30   -- 구삥
    elseif rank == 72 then return 28   -- 장삥
    elseif rank == 71 then return 25   -- 장사
    elseif rank == 70 then return 22   -- 세륙
    elseif rank >= 7 then return 12 + rank  -- 7~9끗
    elseif rank >= 1 then return 8 + rank   -- 1~6끗
    else return 5  -- 갑오
    end
end

return SeotdaChallenge
