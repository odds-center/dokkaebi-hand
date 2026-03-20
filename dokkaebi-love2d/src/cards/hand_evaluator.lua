--- 핸드 평가: 선택한 카드에서 모든 콤보를 찾아 반환
--- Balatro 스타일 — 여러 콤보가 동시에 스택.
--- Seotda 카테고리는 최고 1개만 적용.

local E = require("src.cards.card_enums")
local CT = E.CardType
local RT = E.RibbonType

local HandEvaluator = {}

-- 콤보 티어 순서값 (낮을수록 높은 티어)
local TIER = { S = 1, A = 2, B = 3, C = 4, D = 5 }

-- 헬퍼: 리본 세트 체크
local function has_ribbon_set(tti_cards, ribbon, m1, m2, m3)
    local found = { false, false, false }
    local months = { m1, m2, m3 }
    for _, c in ipairs(tti_cards) do
        if c.ribbon == ribbon then
            for i, m in ipairs(months) do
                if c.month == m then found[i] = true end
            end
        end
    end
    return found[1] and found[2] and found[3]
end

-- 헬퍼: 테이블에 값 포함 여부
local function contains(tbl, val)
    for _, v in ipairs(tbl) do if v == val then return true end end
    return false
end

-- 헬퍼: 특정 조건의 카드 존재 여부
local function any_month(cards, month)
    for _, c in ipairs(cards) do if c.month == month then return true end end
    return false
end

--- 선택한 카드들을 평가 → 콤보 목록 반환
function HandEvaluator.evaluate(selected_cards)
    if not selected_cards or #selected_cards == 0 then return {} end

    local all_combos = {}
    local card_count = #selected_cards

    -- 기본 데이터 준비
    local months = {}
    local distinct_months = {}
    local distinct_months_set = {}
    local types = {}
    local gwang_cards = {}
    local tti_cards = {}
    local geurim_cards = {}
    local pi_cards = {}
    local month_counts = {}
    local has_rain_gwang = false

    for _, c in ipairs(selected_cards) do
        table.insert(months, c.month)
        if not distinct_months_set[c.month] then
            distinct_months_set[c.month] = true
            table.insert(distinct_months, c.month)
        end
        table.insert(types, c.card_type)
        month_counts[c.month] = (month_counts[c.month] or 0) + 1

        if c.card_type == CT.Gwang then
            table.insert(gwang_cards, c)
            if c.is_rain_gwang then has_rain_gwang = true end
        elseif c.card_type == CT.Tti then table.insert(tti_cards, c)
        elseif c.card_type == CT.Geurim then table.insert(geurim_cards, c)
        elseif c.card_type == CT.Pi then table.insert(pi_cards, c)
        end
    end

    -- 월 합산
    local month_sum = 0
    for _, m in ipairs(months) do month_sum = month_sum + m end

    -- 피 가치 합계
    local total_pi_value = 0
    for _, c in ipairs(pi_cards) do
        total_pi_value = total_pi_value + (c.is_double_pi and 2 or 1)
    end

    -- 리본 세트 체크
    local has_hongdan = has_ribbon_set(tti_cards, RT.HongDan, 1, 2, 3)
    local has_cheongdan = has_ribbon_set(tti_cards, RT.CheongDan, 6, 9, 10)
    local has_chodan = has_ribbon_set(tti_cards, RT.ChoDan, 4, 5, 7)

    local function add(combo) table.insert(all_combos, combo) end
    local function has_combo(id)
        for _, c in ipairs(all_combos) do if c.id == id then return true end end
        return false
    end

    -- ==================== Tier S ====================
    -- 밸런스 기준: 보스 HP 100~400 (1윤회). 족보는 "시너지 버프"이므로
    -- chips = 섯다 기본 데미지에 더해지는 보너스, mult = 최종 배수에 곱해지는 값.
    -- 너무 높으면 1판에 보스가 녹으므로 보수적으로 조정.

    if #gwang_cards >= 5 then
        add({ id="ogwang", name_kr="오광", tier=TIER.S, category="gostop", chips=40, mult=2.2 })
    end

    if any_month(gwang_cards, 3) and any_month(gwang_cards, 8) then
        add({ id="38gwangttaeng", name_kr="38광땡", tier=TIER.S, category="seotda", chips=35, mult=2.0 })
    end

    if #distinct_months >= 12 then
        add({ id="hwangcheon_dari", name_kr="황천의다리", tier=TIER.S, category="jeoseung", chips=45, mult=2.5 })
    end

    if has_hongdan and has_cheongdan and has_chodan then
        add({ id="samdantong", name_kr="삼단통", tier=TIER.S, category="gostop", chips=35, mult=2.0 })
    end

    local chongtong_count = 0
    for _, cnt in pairs(month_counts) do if cnt >= 4 then chongtong_count = chongtong_count + 1 end end
    if chongtong_count >= 3 then
        add({ id="yunhoe", name_kr="윤회", tier=TIER.S, category="jeoseung", chips=40, mult=2.2 })
    end

    -- ==================== Tier A ====================

    if #gwang_cards == 4 and not has_rain_gwang then
        add({ id="sagwang", name_kr="사광", tier=TIER.A, category="gostop", chips=28, mult=1.8 })
    end
    if #gwang_cards == 4 and has_rain_gwang then
        add({ id="bisagwang", name_kr="비사광", tier=TIER.A, category="gostop", chips=22, mult=1.6 })
    end

    if any_month(gwang_cards, 1) and any_month(gwang_cards, 3) and not has_combo("38gwangttaeng") then
        add({ id="13gwangttaeng", name_kr="13광땡", tier=TIER.A, category="seotda", chips=28, mult=1.8 })
    end
    if any_month(gwang_cards, 1) and any_month(gwang_cards, 8) and not has_combo("38gwangttaeng") then
        add({ id="18gwangttaeng", name_kr="18광땡", tier=TIER.A, category="seotda", chips=30, mult=1.8 })
    end

    if card_count >= 2 and (month_counts[10] or 0) >= 2 then
        add({ id="jangttaeng", name_kr="장땡", tier=TIER.A, category="seotda", chips=25, mult=1.7 })
    end
    if card_count >= 2 and (month_counts[9] or 0) >= 2 then
        add({ id="9ttaeng", name_kr="9땡", tier=TIER.A, category="seotda", chips=22, mult=1.6 })
    end
    if card_count >= 2 and (month_counts[8] or 0) >= 2 then
        add({ id="8ttaeng", name_kr="8땡", tier=TIER.A, category="seotda", chips=20, mult=1.5 })
    end

    if #gwang_cards >= 3 and #pi_cards >= 5 then
        add({ id="dokkaebi_bul", name_kr="도깨비불", tier=TIER.A, category="jeoseung", chips=20, mult=1.5 })
    end
    if total_pi_value >= 15 then
        add({ id="jeoseung_kkot", name_kr="저승꽃", tier=TIER.A, category="jeoseung", chips=20, mult=1.5, heal=2, heal_hold=true })
    end

    if distinct_months_set[3] and distinct_months_set[6] and distinct_months_set[9] then
        add({ id="samdocheon", name_kr="삼도천", tier=TIER.A, category="jeoseung", chips=18, mult=1.4 })
    end

    -- ==================== Tier B ====================

    if #gwang_cards == 3 and not has_rain_gwang then
        add({ id="samgwang", name_kr="삼광", tier=TIER.B, category="gostop", chips=18, mult=1.5 })
    end
    if #gwang_cards == 3 and has_rain_gwang then
        add({ id="bigwang", name_kr="비광", tier=TIER.B, category="gostop", chips=15, mult=1.4 })
    end

    if has_hongdan then add({ id="hongdan", name_kr="홍단", tier=TIER.B, category="gostop", chips=15, mult=1.4 }) end
    if has_cheongdan then add({ id="cheongdan", name_kr="청단", tier=TIER.B, category="gostop", chips=15, mult=1.4 }) end
    if has_chodan then add({ id="chodan", name_kr="초단", tier=TIER.B, category="gostop", chips=15, mult=1.4 }) end

    if any_month(geurim_cards, 2) and any_month(geurim_cards, 4) and any_month(geurim_cards, 8) then
        add({ id="godori", name_kr="고도리", tier=TIER.B, category="gostop", chips=15, mult=1.4 })
    end

    for m, cnt in pairs(month_counts) do
        if cnt >= 4 then
            add({ id="chongtong_"..m, name_kr="총통("..m.."월)", tier=TIER.B, category="gostop", chips=12, mult=1.3 })
        end
    end

    -- 7땡~1땡
    for m = 7, 1, -1 do
        if (month_counts[m] or 0) >= 2 then
            add({ id=m.."ttaeng", name_kr=m.."땡", tier=TIER.B, category="seotda", chips=8+m, mult=1.2+m*0.03 })
        end
    end

    if distinct_months_set[1] and distinct_months_set[2] then
        add({ id="ali", name_kr="알리", tier=TIER.B, category="seotda", chips=12, mult=1.3 })
    end
    if distinct_months_set[1] and distinct_months_set[4] then
        add({ id="doksa", name_kr="독사", tier=TIER.B, category="seotda", chips=10, mult=1.25 })
    end
    if distinct_months_set[1] and distinct_months_set[9] then
        add({ id="gupping", name_kr="구삥", tier=TIER.B, category="seotda", chips=9, mult=1.2 })
    end

    if distinct_months_set[3] and distinct_months_set[6] and distinct_months_set[9] and distinct_months_set[12] then
        add({ id="sagye", name_kr="사계", tier=TIER.B, category="seasonal", chips=14, mult=1.3 })
    end
    if any_month(gwang_cards, 1) and any_month(gwang_cards, 12) then
        add({ id="seonhuchak", name_kr="선후착", tier=TIER.B, category="jeoseung", chips=14, mult=1.3 })
    end

    -- 봄의연회
    local spring = 0
    for _, m in ipairs(months) do if m >= 1 and m <= 3 then spring = spring + 1 end end
    if spring >= 4 and distinct_months_set[1] and distinct_months_set[2] and distinct_months_set[3] then
        add({ id="bom_yeonhoe", name_kr="봄의연회", tier=TIER.B, category="seasonal", chips=10, mult=1.2, heal=1, heal_hold=true })
    end

    -- 가을단풍
    local autumn = 0
    for _, m in ipairs(months) do if m >= 8 and m <= 10 then autumn = autumn + 1 end end
    if autumn >= 4 and distinct_months_set[8] and distinct_months_set[9] and distinct_months_set[10] then
        add({ id="gaeul_danpung", name_kr="가을단풍", tier=TIER.B, category="seasonal", chips=10, mult=1.2 })
    end

    -- ==================== Tier C ====================

    if distinct_months_set[1] and distinct_months_set[10] then
        add({ id="jangpping", name_kr="장삥", tier=TIER.C, category="seotda", chips=10, mult=1.25 })
    end
    if distinct_months_set[4] and distinct_months_set[10] then
        add({ id="jangsa", name_kr="장사", tier=TIER.C, category="seotda", chips=8, mult=1.2 })
    end
    if distinct_months_set[4] and distinct_months_set[6] then
        add({ id="seryuk", name_kr="세륙", tier=TIER.C, category="seotda", chips=7, mult=1.2 })
    end

    if #tti_cards >= 5 then add({ id="tti5", name_kr="띠5장", tier=TIER.C, category="collection", chips=10, mult=1.3 }) end
    if #geurim_cards >= 5 then add({ id="geurim5", name_kr="그림5장", tier=TIER.C, category="collection", chips=10, mult=1.3 }) end
    if total_pi_value >= 10 then add({ id="pi10", name_kr="피10장", tier=TIER.C, category="collection", chips=8, mult=1.2 }) end

    if any_month(gwang_cards, 8) and any_month(geurim_cards, 9) then
        add({ id="wolha_dokjak", name_kr="월하독작", tier=TIER.C, category="jeoseung", chips=12, mult=1.3, heal=1, heal_hold=true })
    end

    local kkeut = month_sum % 10
    if kkeut >= 5 and kkeut <= 9 and card_count >= 2 then
        add({ id="kkeut"..kkeut, name_kr="끗"..kkeut, tier=TIER.C, category="seotda", chips=4+kkeut, mult=1.05+kkeut*0.03 })
    end

    for m, cnt in pairs(month_counts) do
        if cnt == 2 then add({ id="wolhap_"..m, name_kr="월합("..m.."월)", tier=TIER.C, category="monthpair", chips=8, mult=1.2 }) end
        if cnt == 3 then add({ id="wolsam_"..m, name_kr="월삼("..m.."월)", tier=TIER.C, category="monthpair", chips=14, mult=1.4 }) end
    end

    -- 여름바람
    local summer = 0
    for _, m in ipairs(months) do if m >= 6 and m <= 8 then summer = summer + 1 end end
    if summer >= 3 and distinct_months_set[6] and distinct_months_set[7] and distinct_months_set[8] then
        add({ id="summer", name_kr="여름바람", tier=TIER.C, category="seasonal", chips=8, mult=1.2 })
    end

    if distinct_months_set[11] and distinct_months_set[12] then
        add({ id="winter", name_kr="겨울한파", tier=TIER.C, category="seasonal", chips=7, mult=1.2 })
    end

    -- 저승 오리지널
    if any_month(gwang_cards, 1) and any_month(gwang_cards, 11) then
        add({ id="yeomra_simpan", name_kr="염라의심판", tier=TIER.C, category="jeoseung", chips=12, mult=1.3 })
    end
    if distinct_months_set[12] and distinct_months_set[11] and #pi_cards >= 1 then
        add({ id="jeoseung_gil", name_kr="저승길", tier=TIER.C, category="jeoseung", chips=10, mult=1.25 })
    end

    local has_rain = false
    for _, c in ipairs(selected_cards) do if c.is_rain_gwang then has_rain = true; break end end
    if has_rain and any_month(gwang_cards, 1) then
        add({ id="gwihwa", name_kr="귀화", tier=TIER.C, category="jeoseung", chips=10, mult=1.25 })
    end
    if #gwang_cards == 1 and #pi_cards >= 3 then
        add({ id="honbaek_bunri", name_kr="혼백분리", tier=TIER.C, category="jeoseung", chips=8, mult=1.2 })
    end

    if card_count >= 3 then
        local distinct_types = {}
        for _, t in ipairs(types) do distinct_types[t] = true end
        local type_count = 0
        for _ in pairs(distinct_types) do type_count = type_count + 1 end
        if type_count >= 3 then
            add({ id="eopgyeongdae", name_kr="업경대", tier=TIER.C, category="jeoseung", chips=10, mult=1.25 })
        end
    end

    if #geurim_cards >= 3 then
        add({ id="dokkaebi_bangmangi", name_kr="도깨비방망이", tier=TIER.C, category="jeoseung", chips=12, mult=1.3 })
    end
    if #pi_cards >= 5 then
        add({ id="pibada", name_kr="피바다", tier=TIER.C, category="jeoseung", chips=10, mult=1.25 })
    end
    if card_count >= 3 and #distinct_months == card_count then
        add({ id="musang", name_kr="무상", tier=TIER.C, category="jeoseung", chips=8, mult=1.2 })
    end
    if #tti_cards >= 2 and #pi_cards >= 2 then
        add({ id="kkotbi", name_kr="꽃비", tier=TIER.C, category="jeoseung", chips=8, mult=1.2, heal=1, heal_hold=true })
    end
    if (month_counts[12] or 0) >= 2 then
        add({ id="gwimungwan", name_kr="귀문관", tier=TIER.C, category="jeoseung", chips=10, mult=1.25 })
    end

    -- ==================== Tier D ====================

    if kkeut >= 1 and kkeut <= 4 and card_count >= 2 then
        add({ id="kkeut"..kkeut.."_low", name_kr="끗"..kkeut, tier=TIER.D, category="seotda", chips=2+kkeut, mult=1+kkeut*0.02 })
    end
    if kkeut == 0 and card_count >= 2 then
        add({ id="mangtong", name_kr="망통", tier=TIER.D, category="seotda", chips=2, mult=0.5 })
    end
    if card_count == 1 then
        add({ id="single", name_kr="단일패", tier=TIER.D, category="fallback", chips=math.max(selected_cards[1].base_points, 3), mult=1 })
    end
    if #pi_cards == card_count and card_count >= 2 then
        add({ id="pijjak", name_kr="피짝", tier=TIER.D, category="fallback", chips=total_pi_value, mult=1 })
    end

    -- Seotda 최고 1개만 남기기
    all_combos = HandEvaluator.filter_best_seotda(all_combos)

    -- 티어순 정렬
    table.sort(all_combos, function(a, b)
        if a.tier ~= b.tier then return a.tier < b.tier end
        return (a.chips * a.mult) > (b.chips * b.mult)
    end)

    return all_combos
end

--- Seotda 카테고리 최고 1개만
function HandEvaluator.filter_best_seotda(combos)
    local best = nil
    local best_score = -1
    for _, c in ipairs(combos) do
        if c.category == "seotda" then
            local tier_val = ({ [1]=10000, [2]=1000, [3]=100, [4]=10, [5]=1 })[c.tier] or 1
            local score = tier_val + c.chips * c.mult
            if score > best_score then best_score = score; best = c end
        end
    end

    local result = {}
    for _, c in ipairs(combos) do
        if c.category ~= "seotda" or (best and c.id == best.id) then
            table.insert(result, c)
        end
    end
    return result
end

--- 콤보 목록의 칩/배수 합산
function HandEvaluator.get_total_score(combos)
    if not combos or #combos == 0 then return 0, 1 end
    local total_chips = 0
    local total_mult = 1
    for _, c in ipairs(combos) do
        total_chips = total_chips + c.chips
        total_mult = total_mult * c.mult
    end
    return total_chips, total_mult
end

return HandEvaluator
