--- 화투 카드 열거형
local CardMonth = {
    January = 1, February = 2, March = 3, April = 4,
    May = 5, June = 6, July = 7, August = 8,
    September = 9, October = 10, November = 11, December = 12
}

local CardType = {
    Gwang = "gwang",         -- 광
    Tti = "tti",             -- 띠
    Yeolkkeut = "yeolkkeut", -- 열끗
    Pi = "pi"                -- 피
}

local RibbonType = {
    None = "none",
    HongDan = "hongdan",     -- 홍단
    CheongDan = "cheongdan", -- 청단
    ChoDan = "chodan"        -- 초단
}

-- 카드 타입 가치 순서 (광 > 열끗 > 띠 > 피)
local CardTypeValue = {
    [CardType.Gwang] = 4,
    [CardType.Yeolkkeut] = 3,
    [CardType.Tti] = 2,
    [CardType.Pi] = 1,
}

return {
    CardMonth = CardMonth,
    CardType = CardType,
    RibbonType = RibbonType,
    CardTypeValue = CardTypeValue,
}
