--- 화투 48장 카드 데이터베이스
local E = require("src.cards.card_enums")
local CT = E.CardType
local CM = E.CardMonth
local RT = E.RibbonType

local CardDatabase = {}

-- { id, name, name_kr, month, card_type, ribbon, base_points, is_rain_gwang, is_double_pi }
local definitions = {
    -- 1월 (송학)
    { name="January Gwang",     name_kr="1월 광(학)",   month=CM.January,  card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="January HongDan",   name_kr="1월 홍단",     month=CM.January,  card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="January Geurim", name_kr="1월 그림",     month=CM.January,  card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="January Pi",        name_kr="1월 피",       month=CM.January,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 2월 (매조)
    { name="February HongDan",  name_kr="2월 홍단",     month=CM.February, card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="February Geurim",name_kr="2월 그림",     month=CM.February, card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="February Pi1",      name_kr="2월 피1",      month=CM.February, card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="February Pi2",      name_kr="2월 피2",      month=CM.February, card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 3월 (벚꽃)
    { name="March Gwang",       name_kr="3월 광(막)",   month=CM.March,    card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="March HongDan",     name_kr="3월 홍단",     month=CM.March,    card_type=CT.Tti,      ribbon=RT.HongDan,   base_points=10 },
    { name="March Geurim",   name_kr="3월 그림",     month=CM.March,    card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="March Pi",          name_kr="3월 피",       month=CM.March,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 4월 (등나무)
    { name="April ChoDan",      name_kr="4월 초단",     month=CM.April,    card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="April Geurim",   name_kr="4월 그림",     month=CM.April,    card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="April Pi1",         name_kr="4월 피1",      month=CM.April,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="April Pi2",         name_kr="4월 피2",      month=CM.April,    card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 5월 (난초)
    { name="May ChoDan",        name_kr="5월 초단",     month=CM.May,      card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="May Geurim",     name_kr="5월 그림",     month=CM.May,      card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="May Pi1",           name_kr="5월 피1",      month=CM.May,      card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="May Pi2",           name_kr="5월 피2",      month=CM.May,      card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 6월 (모란)
    { name="June CheongDan",    name_kr="6월 청단",     month=CM.June,     card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="June Geurim",    name_kr="6월 그림",     month=CM.June,     card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="June Pi1",          name_kr="6월 피1",      month=CM.June,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="June Pi2",          name_kr="6월 피2",      month=CM.June,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 7월 (싸리)
    { name="July ChoDan",       name_kr="7월 초단",     month=CM.July,     card_type=CT.Tti,      ribbon=RT.ChoDan,    base_points=10 },
    { name="July Geurim",    name_kr="7월 그림",     month=CM.July,     card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="July Pi1",          name_kr="7월 피1",      month=CM.July,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="July Pi2",          name_kr="7월 피2",      month=CM.July,     card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 8월 (공산)
    { name="August Gwang",      name_kr="8월 광(달)",   month=CM.August,   card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="August Geurim",  name_kr="8월 그림",     month=CM.August,   card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="August Pi1",        name_kr="8월 피1",      month=CM.August,   card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="August Pi2",        name_kr="8월 피2",      month=CM.August,   card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 9월 (국화)
    { name="September CheongDan",name_kr="9월 청단",    month=CM.September,card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="September Geurim",name_kr="9월 그림",    month=CM.September,card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="September Pi1",     name_kr="9월 피1",      month=CM.September,card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="September Pi2",     name_kr="9월 피2",      month=CM.September,card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 10월 (단풍)
    { name="October CheongDan", name_kr="10월 청단",    month=CM.October,  card_type=CT.Tti,      ribbon=RT.CheongDan, base_points=10 },
    { name="October Geurim", name_kr="10월 그림",    month=CM.October,  card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="October Pi1",       name_kr="10월 피1",     month=CM.October,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="October Pi2",       name_kr="10월 피2",     month=CM.October,  card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },

    -- 11월 (오동)
    { name="November Gwang",    name_kr="11월 광(비)",  month=CM.November, card_type=CT.Gwang,    ribbon=RT.None,      base_points=20, is_rain_gwang=true },
    { name="November Geurim",name_kr="11월 그림",    month=CM.November, card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="November Pi1",      name_kr="11월 피1",     month=CM.November, card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="November DoublePi", name_kr="11월 쌍피",    month=CM.November, card_type=CT.Pi,       ribbon=RT.None,      base_points=1, is_double_pi=true },

    -- 12월 (비)
    { name="December Gwang",    name_kr="12월 광(비)",  month=CM.December, card_type=CT.Gwang,    ribbon=RT.None,      base_points=20 },
    { name="December Geurim",name_kr="12월 그림",    month=CM.December, card_type=CT.Geurim,ribbon=RT.None,      base_points=10 },
    { name="December Pi1",      name_kr="12월 피1",     month=CM.December, card_type=CT.Pi,       ribbon=RT.None,      base_points=1 },
    { name="December DoublePi", name_kr="12월 쌍피",    month=CM.December, card_type=CT.Pi,       ribbon=RT.None,      base_points=1, is_double_pi=true },
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
