--- 화투 48장 카드 데이터베이스
local E = require("src.cards.card_enums")
local CT = E.CardType
local CM = E.CardMonth
local RT = E.RibbonType

local CardDatabase = {}

-- { id, name, name_kr, month, card_type, ribbon, base_points, is_rain_gwang, is_double_pi, pi_index }
local definitions = {
    -- 1월 (송학) — 광+홍단+피×2 (열끗 없음)
    { name="January Gwang",     name_kr="1월 광(학)",   month=CM.January,  card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="January HongDan",   name_kr="1월 홍단",     month=CM.January,  card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="January Pi1",       name_kr="1월 피1",      month=CM.January,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="January Pi2",       name_kr="1월 피2",      month=CM.January,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 2월 (매조) — 홍단+열끗+피×2
    { name="February HongDan",  name_kr="2월 홍단",     month=CM.February, card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="February Geurim",   name_kr="2월 열끗",     month=CM.February, card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="February Pi1",      name_kr="2월 피1",      month=CM.February, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="February Pi2",      name_kr="2월 피2",      month=CM.February, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 3월 (벚꽃) — 광+홍단+피×2 (열끗 없음)
    { name="March Gwang",       name_kr="3월 광(막)",   month=CM.March,    card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="March HongDan",     name_kr="3월 홍단",     month=CM.March,    card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="March Pi1",         name_kr="3월 피1",      month=CM.March,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="March Pi2",         name_kr="3월 피2",      month=CM.March,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 4월 (흑싸리) — 초단+열끗+피×2
    { name="April ChoDan",      name_kr="4월 초단",     month=CM.April,    card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="April Geurim",      name_kr="4월 열끗",     month=CM.April,    card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="April Pi1",         name_kr="4월 피1",      month=CM.April,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="April Pi2",         name_kr="4월 피2",      month=CM.April,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 5월 (난초) — 초단+열끗+피×2
    { name="May ChoDan",        name_kr="5월 초단",     month=CM.May,      card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="May Geurim",        name_kr="5월 열끗",     month=CM.May,      card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="May Pi1",           name_kr="5월 피1",      month=CM.May,      card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="May Pi2",           name_kr="5월 피2",      month=CM.May,      card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 6월 (모란) — 청단+열끗+피×2
    { name="June CheongDan",    name_kr="6월 청단",     month=CM.June,     card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="June Geurim",       name_kr="6월 열끗",     month=CM.June,     card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="June Pi1",          name_kr="6월 피1",      month=CM.June,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="June Pi2",          name_kr="6월 피2",      month=CM.June,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 7월 (홍싸리) — 초단+열끗+피×2
    { name="July ChoDan",       name_kr="7월 초단",     month=CM.July,     card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="July Geurim",       name_kr="7월 열끗",     month=CM.July,     card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="July Pi1",          name_kr="7월 피1",      month=CM.July,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="July Pi2",          name_kr="7월 피2",      month=CM.July,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 8월 (공산) — 광+열끗+피×2
    { name="August Gwang",      name_kr="8월 광(달)",   month=CM.August,   card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="August Geurim",     name_kr="8월 열끗",     month=CM.August,   card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="August Pi1",        name_kr="8월 피1",      month=CM.August,   card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="August Pi2",        name_kr="8월 피2",      month=CM.August,   card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 9월 (국진) — 청단+열끗+피×2
    { name="September CheongDan",name_kr="9월 청단",    month=CM.September,card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="September Geurim",  name_kr="9월 열끗",     month=CM.September,card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="September Pi1",     name_kr="9월 피1",      month=CM.September,card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="September Pi2",     name_kr="9월 피2",      month=CM.September,card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 10월 (단풍) — 청단+열끗+피×2
    { name="October CheongDan", name_kr="10월 청단",    month=CM.October,  card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="October Geurim",    name_kr="10월 열끗",    month=CM.October,  card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="October Pi1",       name_kr="10월 피1",     month=CM.October,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="October Pi2",       name_kr="10월 피2",     month=CM.October,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2 },

    -- 11월 (오동) — 광+열끗+피+쌍피
    { name="November Gwang",    name_kr="11월 광(비)",  month=CM.November, card_type=CT.Gwang,    ribbon=RT.None,      base_points=20, is_rain_gwang=true },
    { name="November Geurim",   name_kr="11월 열끗",    month=CM.November, card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="November Pi1",      name_kr="11월 피1",     month=CM.November, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="November DoublePi", name_kr="11월 쌍피",    month=CM.November, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2, is_double_pi=true },

    -- 12월 (비) — 광+열끗+피+쌍피
    { name="December Gwang",    name_kr="12월 광(비)",  month=CM.December, card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="December Geurim",   name_kr="12월 열끗",    month=CM.December, card_type=CT.Geurim,   ribbon=RT.None,      base_points=10 },
    { name="December Pi1",      name_kr="12월 피1",     month=CM.December, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=1 },
    { name="December DoublePi", name_kr="12월 쌍피",    month=CM.December, card_type=CT.Pi,       ribbon=RT.None,      base_points=1,  pi_index=2, is_double_pi=true },
}

function CardDatabase.get_all_definitions()
    return definitions
end

function CardDatabase.get_count()
    return #definitions
end

function CardDatabase.get_by_index(idx)
    return definitions[idx]
end

return CardDatabase
