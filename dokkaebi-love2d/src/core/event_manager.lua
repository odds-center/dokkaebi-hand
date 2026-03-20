--- 랜덤 이벤트 시스템: 영역 사이에 발생하는 스토리 선택지
local PlayerState = require("src.core.player_state")

local EventManager = {}
EventManager.__index = EventManager

function EventManager.new(seed)
    local self = setmetatable({
        _seen_events  = {},
        current_event = nil,
        _seed         = seed,
    }, EventManager)
    if seed then
        math.randomseed(seed)
    end
    return self
end

--- 랜덤 이벤트 생성 (같은 런에서 중복 방지)
function EventManager:generate_event(spiral_number)
    local pool = self:_get_event_pool()

    -- 이미 본 이벤트 제거
    local filtered = {}
    for _, e in ipairs(pool) do
        if not self._seen_events[e.id] then
            table.insert(filtered, e)
        end
    end

    if #filtered == 0 then
        self._seen_events = {}
        filtered = self:_get_event_pool()
    end

    local chosen = filtered[math.random(#filtered)]
    self._seen_events[chosen.id] = true
    self.current_event = chosen
    return chosen
end

--- 선택지 실행
function EventManager:execute_choice(player, choice_index)
    if not self.current_event then return "" end
    local choices = self.current_event.choices
    if choice_index < 1 or choice_index > #choices then return "" end

    local choice = choices[choice_index]
    if choice.effect then
        choice.effect(player)
    end
    local result = choice.result_kr
    self.current_event = nil
    return result
end

--- 이벤트 풀 생성 (10개)
function EventManager:_get_event_pool()
    return {
        -- E01: 저승 방랑자
        {
            id = "wanderer",
            title_kr = "저승 방랑자",
            title_en = "Underworld Wanderer",
            desc_kr = "길을 잃은 다른 망자를 만났다.\n\"도와줘... 길을 잃었어...\"",
            desc_en = "You find a lost soul.\n\"Help me... I'm lost...\"",
            choices = {
                {
                    text_kr = "도와준다",
                    text_en = "Help them",
                    result_kr = "감사 보상: 엽전 +50",
                    result_en = "Reward: +50 Yeop",
                    effect = function(p) p.yeop = p.yeop + 50 end,
                },
                {
                    text_kr = "무시한다",
                    text_en = "Ignore",
                    result_kr = "아무 일도 없었다.",
                    result_en = "Nothing happened.",
                    effect = function(_) end,
                },
                {
                    text_kr = "소지품을 뒤진다",
                    text_en = "Search their belongings",
                    result_kr = "엽전 +30, 하지만 찝찝하다...",
                    result_en = "+30 Yeop, but guilt lingers...",
                    effect = function(p) p.yeop = p.yeop + 30 end,
                },
            },
        },

        -- E02: 귀신 시장 특별 경매
        {
            id = "ghost_market",
            title_kr = "귀신 시장 특별 경매",
            title_en = "Ghost Market Auction",
            desc_kr = "귀신들이 경매를 하고 있다.\n\"입찰가를 불러봐!\"",
            desc_en = "Ghosts are holding an auction.\n\"Place your bid!\"",
            choices = {
                {
                    text_kr = "목숨 1개를 건다 (-1 목숨, 엽전 +200)",
                    text_en = "Bet 1 life (-1 life, +200 Yeop)",
                    result_kr = "목숨을 걸었다! 엽전 +200!",
                    result_en = "Life risked! +200 Yeop!",
                    effect = function(p)
                        p.lives = p.lives - 1
                        p.yeop = p.yeop + 200
                    end,
                },
                {
                    text_kr = "포기한다 (체력 +1)",
                    text_en = "Give up (+1 life)",
                    result_kr = "편안한 휴식. 체력 +1.",
                    result_en = "Peaceful rest. +1 life.",
                    effect = function(p)
                        p.lives = math.min(p.lives + 1, PlayerState.MAX_LIVES)
                    end,
                },
            },
        },

        -- E03: 운명의 갈림길
        {
            id = "crossroads",
            title_kr = "운명의 갈림길",
            title_en = "Crossroads of Fate",
            desc_kr = "두 개의 문이 있다.\n왼쪽: 붉은 문. 뜨거운 기운.\n오른쪽: 푸른 문. 차가운 기운.",
            desc_en = "Two doors await.\nLeft: Red door. Hot aura.\nRight: Blue door. Cold aura.",
            choices = {
                {
                    text_kr = "붉은 문 (엽전 +100)",
                    text_en = "Red door (+100 Yeop)",
                    result_kr = "뜨거운 기운이 감쌌다. 엽전 +100!",
                    result_en = "Warmth surrounds you. +100 Yeop!",
                    effect = function(p) p.yeop = p.yeop + 100 end,
                },
                {
                    text_kr = "푸른 문 (체력 +2)",
                    text_en = "Blue door (+2 lives)",
                    result_kr = "차가운 기운이 상처를 치유한다. 체력 +2!",
                    result_en = "Cold air heals your wounds. +2 lives!",
                    effect = function(p)
                        p.lives = math.min(p.lives + 2, PlayerState.MAX_LIVES)
                    end,
                },
            },
        },

        -- E04: 도깨비불 시험
        {
            id = "dokkaebi_fire",
            title_kr = "도깨비불 시험",
            title_en = "Ghost Fire Trial",
            desc_kr = "도깨비불이 수수께끼를 낸다.\n\"나는 밤에 태어나 낮에 죽는다. 나는 누구인가?\"",
            desc_en = "A ghost fire poses a riddle.\n\"I'm born at night and die at dawn. What am I?\"",
            choices = {
                {
                    text_kr = "도깨비불",
                    text_en = "Ghost fire",
                    result_kr = "정답! 엽전 +80!",
                    result_en = "Correct! +80 Yeop!",
                    effect = function(p) p.yeop = p.yeop + 80 end,
                },
                {
                    text_kr = "그림자",
                    text_en = "Shadow",
                    result_kr = "오답. 도깨비불이 화를 낸다. 엽전 -30.",
                    result_en = "Wrong. The fire is angry. -30 Yeop.",
                    effect = function(p) p.yeop = math.max(0, p.yeop - 30) end,
                },
                {
                    text_kr = "달빛",
                    text_en = "Moonlight",
                    result_kr = "오답. 도깨비불이 사라진다.",
                    result_en = "Wrong. The fire vanishes.",
                    effect = function(_) end,
                },
            },
        },

        -- E05: 삼도천 기도
        {
            id = "prayer",
            title_kr = "삼도천 기도",
            title_en = "Prayer at Samdo River",
            desc_kr = "삼도천 강가에 도착한다.\n물결이 반짝인다. 기도를 올릴 수 있을 것 같다.",
            desc_en = "You reach the river Samdo.\nThe waters glimmer. You could pray here.",
            choices = {
                {
                    text_kr = "기도한다 (-50 엽전, +2 체력)",
                    text_en = "Pray (-50 Yeop, +2 lives)",
                    result_kr = "기운이 차오른다. 체력 +2!",
                    result_en = "Energy flows through you. +2 lives!",
                    effect = function(p)
                        if p.yeop >= 50 then
                            p.yeop = p.yeop - 50
                            p.lives = math.min(p.lives + 2, PlayerState.MAX_LIVES)
                        end
                    end,
                },
                {
                    text_kr = "동전을 던진다 (-20 엽전, 50% 확률 x2)",
                    text_en = "Toss a coin (-20, 50% chance to double)",
                    result_kr = "운명의 동전...",
                    result_en = "A coin of fate...",
                    effect = function(p)
                        if p.yeop >= 20 then
                            p.yeop = p.yeop - 20
                            if math.random() < 0.5 then
                                p.yeop = p.yeop + 40
                            end
                        end
                    end,
                },
                {
                    text_kr = "그냥 지나간다",
                    text_en = "Pass by",
                    result_kr = "강물 소리가 뒤에서 들린다.",
                    result_en = "The sound of water fades behind you.",
                    effect = function(_) end,
                },
            },
        },

        -- E06: 도깨비의 내기
        {
            id = "dokkaebi_bet",
            title_kr = "도깨비의 내기",
            title_en = "Dokkaebi's Bet",
            desc_kr = "잡졸 도깨비가 나타나 내기를 제안한다.\n\"야, 간단한 내기 하나 하자.\"",
            desc_en = "A minor dokkaebi challenges you.\n\"Hey, let's make a simple bet.\"",
            choices = {
                {
                    text_kr = "받아들인다 (50% 엽전 +100 / 50% 체력 -1)",
                    text_en = "Accept (50% +100 Yeop / 50% -1 life)",
                    result_kr = "도박의 결과는...",
                    result_en = "The result is...",
                    effect = function(p)
                        if math.random() < 0.5 then
                            p.yeop = p.yeop + 100
                        else
                            p.lives = math.max(1, p.lives - 1)
                        end
                    end,
                },
                {
                    text_kr = "거절한다",
                    text_en = "Refuse",
                    result_kr = "도깨비가 킥킥대며 사라진다.",
                    result_en = "The dokkaebi giggles and vanishes.",
                    effect = function(_) end,
                },
            },
        },

        -- E07: 저승꽃밭
        {
            id = "flower_field",
            title_kr = "저승꽃밭",
            title_en = "Underworld Flower Field",
            desc_kr = "아름다운 꽃밭이 펼쳐진다.\n꽃잎이 반짝인다. 힘이 솟는 느낌...",
            desc_en = "A beautiful flower field unfolds.\nPetals shimmer. You feel empowered...",
            choices = {
                {
                    text_kr = "꽃의 힘을 흡수한다 (3턴 배수 +2)",
                    text_en = "Absorb flower power (+2 mult for 3 turns)",
                    result_kr = "꽃의 기운이 몸에 스며든다! 배수 +2!",
                    result_en = "Flower energy seeps in! +2 Mult!",
                    effect = function(p) p.wave_mult_bonus = p.wave_mult_bonus + 2 end,
                },
                {
                    text_kr = "꽃잎을 모은다 (+40 엽전)",
                    text_en = "Gather petals (+40 Yeop)",
                    result_kr = "아름다운 꽃잎을 모았다. 엽전 +40.",
                    result_en = "Beautiful petals gathered. +40 Yeop.",
                    effect = function(p) p.yeop = p.yeop + 40 end,
                },
            },
        },

        -- E08: 거울 연못
        {
            id = "mirror_pond",
            title_kr = "거울 연못",
            title_en = "Mirror Pond",
            desc_kr = "맑은 연못에 얼굴이 비친다.\n연못 속에서 무언가 빛나고 있다...",
            desc_en = "Your face reflects in a clear pond.\nSomething glimmers beneath the surface...",
            choices = {
                {
                    text_kr = "연못에 손을 넣는다 (랜덤 부적 교체)",
                    text_en = "Reach into the pond (random talisman swap)",
                    result_kr = "부적이 빛나며 변했다!",
                    result_en = "Your talisman shimmers and transforms!",
                    effect = function(p)
                        -- 부적 교체: 마지막 부적 제거 후 랜덤 장착
                        -- (부적 DB 의존; 간소화 구현)
                        if #p.talismans > 0 then
                            table.remove(p.talismans, #p.talismans)
                            -- 실제 구현 시 TalismanDatabase에서 랜덤 선택 후 equip
                        end
                    end,
                },
                {
                    text_kr = "연못을 관찰한다 (다음 보스 기믹 정보)",
                    text_en = "Observe the pond (reveal next boss gimmick)",
                    result_kr = "다음 적의 약점이 보인다... 목표 -10%!",
                    result_en = "You see the next enemy's weakness... Target -10%!",
                    effect = function(p) p.wave_target_reduction = p.wave_target_reduction + 0.1 end,
                },
                {
                    text_kr = "동전을 던진다 (+20 엽전)",
                    text_en = "Toss a coin (+20 Yeop)",
                    result_kr = "동전이 연못 속으로... 엽전 +20.",
                    result_en = "The coin sinks... +20 Yeop.",
                    effect = function(p) p.yeop = p.yeop + 20 end,
                },
            },
        },

        -- E09: 저승사자의 제안
        {
            id = "ferryman_deal",
            title_kr = "저승사자의 제안",
            title_en = "Ferryman's Proposal",
            desc_kr = "저승사자가 나타난다.\n\"거래를 하자. 네 영혼의 일부와 교환하지.\"",
            desc_en = "The ferryman appears.\n\"Let's make a deal. Part of your soul in exchange.\"",
            choices = {
                {
                    text_kr = "기믹 무효화 1라운드 (-100 엽전)",
                    text_en = "Negate boss gimmick 1 round (-100 Yeop)",
                    result_kr = "저승사자의 힘이 보스를 억누른다!",
                    result_en = "The ferryman's power suppresses the boss!",
                    effect = function(p)
                        if p.yeop >= 100 then
                            p.yeop = p.yeop - 100
                        else
                            p.yeop = 0
                        end
                        p.wave_target_reduction = p.wave_target_reduction + 0.2
                    end,
                },
                {
                    text_kr = "Go 배수 보너스 +1",
                    text_en = "+1 Go multiplier bonus",
                    result_kr = "욕심의 힘이 커진다. Go 배수 +1!",
                    result_en = "Greed empowers you. Go mult +1!",
                    effect = function(p) p.wave_mult_bonus = p.wave_mult_bonus + 1 end,
                },
                {
                    text_kr = "거절한다 (엽전 +30)",
                    text_en = "Refuse (+30 Yeop)",
                    result_kr = "저승사자가 고개를 끄덕인다. 엽전 +30.",
                    result_en = "The ferryman nods. +30 Yeop.",
                    effect = function(p) p.yeop = p.yeop + 30 end,
                },
            },
        },

        -- E10: 윤회의 문
        {
            id = "samsara_gate",
            title_kr = "윤회의 문",
            title_en = "Gate of Samsara",
            desc_kr = "빙글빙글 도는 문이 나타났다.\n문 너머로 과거의 자신이 보인다.\n\"다시 태어나고 싶으냐?\"",
            desc_en = "A spinning gate appears.\nThrough it, you see your past self.\n\"Do you wish to be reborn?\"",
            choices = {
                {
                    text_kr = "환생한다 (체력 MAX, 엽전 0)",
                    text_en = "Reincarnate (Full HP, 0 Yeop)",
                    result_kr = "새로운 몸으로 태어났다! 체력 전체 회복, 엽전 초기화!",
                    result_en = "Reborn in a new body! Full HP, Yeop reset!",
                    effect = function(p)
                        p.lives = PlayerState.MAX_LIVES
                        p.yeop = 0
                    end,
                },
                {
                    text_kr = "힘을 얻는다 (칩 +30, 목숨 -1)",
                    text_en = "Gain power (+30 Chips, -1 life)",
                    result_kr = "과거의 힘이 흘러든다. 칩 +30!",
                    result_en = "Power from the past flows in. +30 Chips!",
                    effect = function(p)
                        p.wave_chip_bonus = p.wave_chip_bonus + 30
                        p.lives = math.max(1, p.lives - 1)
                    end,
                },
                {
                    text_kr = "문을 닫는다",
                    text_en = "Close the gate",
                    result_kr = "문이 사라졌다. 무언가 아쉽다...",
                    result_en = "The gate vanishes. Something feels lost...",
                    effect = function(_) end,
                },
            },
        },
    }
end

return EventManager
