--- 상점 시스템: 부적 3종 + 소모품 진열
local PlayerState = require("src.core.player_state")

-- ============================================================
-- ShopItem
-- ============================================================
local ShopItem = {}
ShopItem.__index = ShopItem

function ShopItem.new(t)
    return setmetatable({
        id              = t.id,
        name_kr         = t.name_kr,
        name_en         = t.name_en,
        cost            = t.cost or 0,
        is_sold         = false,
        talisman_data   = t.talisman_data,   -- nil for consumables
        consumable_type = t.consumable_type,  -- "health", "card_pack", etc.
    }, ShopItem)
end

-- ============================================================
-- ShopManager
-- ============================================================
local ShopManager = {}
ShopManager.__index = ShopManager

function ShopManager.new(seed)
    local self = setmetatable({
        current_stock = {},
        _seed = seed,
    }, ShopManager)
    if seed then
        math.randomseed(seed)
    end
    return self
end

--- Fisher-Yates shuffle
local function shuffle_list(list)
    for i = #list, 2, -1 do
        local j = math.random(i)
        list[i], list[j] = list[j], list[i]
    end
end

--- 상점 재고 생성 (영역 클리어 후 호출)
function ShopManager:generate_stock(spiral_number, discount)
    discount = discount or 0
    self.current_stock = {}

    -- 부적 3종 (TalismanDatabase가 있으면 사용, 없으면 스텁)
    local ok, TalismanDB = pcall(require, "src.talismans.talisman_database")
    if ok and TalismanDB and TalismanDB.all_talismans then
        local all = {}
        for _, t in ipairs(TalismanDB.all_talismans) do
            table.insert(all, t)
        end
        shuffle_list(all)

        local talisman_count = math.min(3, #all)
        for i = 1, talisman_count do
            local t = all[i]
            local base_cost
            local rarity = t.rarity or "common"
            if rarity == "common" then
                base_cost = 30 + math.random(0, 19)
            elseif rarity == "rare" then
                base_cost = 80 + math.random(0, 39)
            elseif rarity == "legendary" then
                base_cost = 200 + math.random(0, 99)
            elseif rarity == "cursed" then
                base_cost = 0
            else
                base_cost = 50
            end

            local final_cost = math.floor(base_cost * (1.0 - discount))
            table.insert(self.current_stock, ShopItem.new({
                id = "talisman_" .. i,
                name_kr = t.name_kr or t.name or ("부적 " .. i),
                name_en = t.name or ("Talisman " .. i),
                cost = final_cost,
                talisman_data = t,
            }))
        end
    end

    -- 소모품: 체력 회복
    table.insert(self.current_stock, ShopItem.new({
        id = "health",
        name_kr = "체력 회복",
        name_en = "Health Restore",
        cost = math.floor(75 * (1.0 - discount)),
        consumable_type = "health",
    }))

    -- 소모품: 패 팩 (소)
    table.insert(self.current_stock, ShopItem.new({
        id = "card_pack",
        name_kr = "패 팩 (소)",
        name_en = "Card Pack (S)",
        cost = math.floor(40 * (1.0 - discount)),
        consumable_type = "card_pack",
    }))

    -- 소모품: 패 팩 (대) — 윤회 2+ 부터
    if spiral_number >= 2 then
        table.insert(self.current_stock, ShopItem.new({
            id = "card_pack_large",
            name_kr = "패 팩 (대)",
            name_en = "Card Pack (L)",
            cost = math.floor(80 * (1.0 - discount)),
            consumable_type = "card_pack_large",
        }))
    end

    -- 소모품: 저주 해제부
    table.insert(self.current_stock, ShopItem.new({
        id = "curse_remove",
        name_kr = "저주 해제부",
        name_en = "Curse Buster",
        cost = math.floor(100 * (1.0 - discount)),
        consumable_type = "curse_remove",
    }))

    -- 소모품: 감정부 (다음 상점 전설 부적 보장)
    table.insert(self.current_stock, ShopItem.new({
        id = "sentiment_stone",
        name_kr = "감정부",
        name_en = "Sentiment Stone",
        cost = math.floor(60 * (1.0 - discount)),
        consumable_type = "sentiment_stone",
    }))
end

--- 아이템 구매
--- @param player PlayerState
--- @param item_index number 1-based index
--- @return boolean success
function ShopManager:purchase(player, item_index)
    if item_index < 1 or item_index > #self.current_stock then return false end

    local item = self.current_stock[item_index]
    if item.is_sold then return false end
    if player.yeop < item.cost then return false end

    player.yeop = player.yeop - item.cost
    item.is_sold = true

    -- 효과 적용
    if item.talisman_data then
        local is_curse = item.talisman_data.is_curse
        if not player:can_equip_talisman() and not is_curse then
            -- 슬롯 부족: 환불
            player.yeop = player.yeop + item.cost
            item.is_sold = false
            return false
        end
        -- TalismanInstance 래퍼 생성 (간소화: data 직접 사용)
        local talisman = { data = item.talisman_data }
        player:equip_talisman(talisman)

    elseif item.consumable_type == "health" then
        player.lives = math.min(player.lives + 1, PlayerState.MAX_LIVES)

    elseif item.consumable_type == "card_pack" then
        player.next_round_hand_bonus = player.next_round_hand_bonus + 2

    elseif item.consumable_type == "card_pack_large" then
        player.next_round_hand_bonus = player.next_round_hand_bonus + 4

    elseif item.consumable_type == "curse_remove" then
        -- 저주 부적 1개 제거
        local curse_idx = nil
        for i, t in ipairs(player.talismans) do
            if t.data and t.data.is_curse then
                curse_idx = i
                break
            end
        end
        if curse_idx then
            table.remove(player.talismans, curse_idx)
        else
            -- 저주 없으면 구매 불가: 환불
            player.yeop = player.yeop + item.cost
            item.is_sold = false
            return false
        end

    elseif item.consumable_type == "sentiment_stone" then
        -- 간소화: 즉시 전설 부적 장착 시도
        local ok2, TalismanDB = pcall(require, "src.talismans.talisman_database")
        if ok2 and TalismanDB and TalismanDB.get_by_rarity then
            local legends = TalismanDB.get_by_rarity("legendary")
            if legends and #legends > 0 and player:can_equip_talisman() then
                local t = legends[math.random(#legends)]
                player:equip_talisman({ data = t })
            end
        end
    end

    return true
end

return ShopManager
