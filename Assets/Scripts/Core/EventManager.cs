using System;
using System.Collections.Generic;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 랜덤 이벤트 시스템: 영역 사이에 발생하는 스토리 선택지
    /// </summary>
    public class EventChoice
    {
        public string TextKR;
        public string TextEN;
        public string ResultKR;
        public string ResultEN;
        public Action<PlayerState> Effect;
    }

    public class GameEvent
    {
        public string Id;
        public string TitleKR;
        public string TitleEN;
        public string DescriptionKR;
        public string DescriptionEN;
        public List<EventChoice> Choices;
    }

    public class EventManager
    {
        private readonly Random _rng;
        private readonly HashSet<string> _seenEvents = new HashSet<string>();

        public GameEvent CurrentEvent { get; private set; }

        // 이벤트 Effect 내에서 사용할 공유 RNG
        public Random SharedRng => _rng;

        public EventManager(int? seed = null)
        {
            _rng = seed.HasValue ? new Random(seed.Value) : new Random();
        }

        /// <summary>
        /// 랜덤 이벤트 생성 (같은 런에서 중복 방지)
        /// </summary>
        public GameEvent GenerateEvent(int spiralNumber)
        {
            var pool = GetEventPool();
            pool.RemoveAll(e => _seenEvents.Contains(e.Id));

            if (pool.Count == 0)
            {
                _seenEvents.Clear(); // 모두 본 경우 리셋
                pool = GetEventPool();
            }

            CurrentEvent = pool[_rng.Next(pool.Count)];
            _seenEvents.Add(CurrentEvent.Id);
            return CurrentEvent;
        }

        /// <summary>
        /// 선택지 실행
        /// </summary>
        public string ExecuteChoice(PlayerState player, int choiceIndex)
        {
            if (CurrentEvent == null) return "";
            if (choiceIndex < 0 || choiceIndex >= CurrentEvent.Choices.Count) return "";

            var choice = CurrentEvent.Choices[choiceIndex];
            choice.Effect?.Invoke(player);
            CurrentEvent = null;
            return choice.ResultKR;
        }

        private List<GameEvent> GetEventPool()
        {
            return new List<GameEvent>
            {
                new GameEvent
                {
                    Id = "wanderer",
                    TitleKR = "저승 방랑자",
                    TitleEN = "Underworld Wanderer",
                    DescriptionKR = "길을 잃은 다른 망자를 만났다.\n\"도와줘... 길을 잃었어...\"",
                    DescriptionEN = "You find a lost soul.\n\"Help me... I'm lost...\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "도와준다",
                            TextEN = "Help them",
                            ResultKR = "감사 보상: 엽전 +50",
                            ResultEN = "Reward: +50 Yeop",
                            Effect = p => p.Yeop += 50
                        },
                        new EventChoice
                        {
                            TextKR = "무시한다",
                            TextEN = "Ignore",
                            ResultKR = "아무 일도 없었다.",
                            ResultEN = "Nothing happened.",
                            Effect = _ => { }
                        },
                        new EventChoice
                        {
                            TextKR = "소지품을 뒤진다",
                            TextEN = "Search their belongings",
                            ResultKR = "엽전 +30, 하지만 찝찝하다...",
                            ResultEN = "+30 Yeop, but guilt lingers...",
                            Effect = p => p.Yeop += 30
                        }
                    }
                },

                new GameEvent
                {
                    Id = "ghost_market",
                    TitleKR = "귀신 시장 특별 경매",
                    TitleEN = "Ghost Market Auction",
                    DescriptionKR = "귀신들이 경매를 하고 있다.\n\"입찰가를 불러봐!\"",
                    DescriptionEN = "Ghosts are holding an auction.\n\"Place your bid!\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "목숨 1개를 건다 (-1 목숨, 엽전 +200)",
                            TextEN = "Bet 1 life (-1 life, +200 Yeop)",
                            ResultKR = "목숨을 걸었다! 엽전 +200!",
                            ResultEN = "Life risked! +200 Yeop!",
                            Effect = p => { p.Lives--; p.Yeop += 200; }
                        },
                        new EventChoice
                        {
                            TextKR = "포기한다 (체력 +1)",
                            TextEN = "Give up (+1 life)",
                            ResultKR = "편안한 휴식. 체력 +1.",
                            ResultEN = "Peaceful rest. +1 life.",
                            Effect = p => p.Lives = Math.Min(p.Lives + 1, PlayerState.MaxLives)
                        }
                    }
                },

                new GameEvent
                {
                    Id = "crossroads",
                    TitleKR = "운명의 갈림길",
                    TitleEN = "Crossroads of Fate",
                    DescriptionKR = "두 개의 문이 있다.\n왼쪽: 붉은 문. 뜨거운 기운.\n오른쪽: 푸른 문. 차가운 기운.",
                    DescriptionEN = "Two doors await.\nLeft: Red door. Hot aura.\nRight: Blue door. Cold aura.",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "붉은 문 (엽전 +100)",
                            TextEN = "Red door (+100 Yeop)",
                            ResultKR = "뜨거운 기운이 감쌌다. 엽전 +100!",
                            ResultEN = "Warmth surrounds you. +100 Yeop!",
                            Effect = p => p.Yeop += 100
                        },
                        new EventChoice
                        {
                            TextKR = "푸른 문 (체력 +2)",
                            TextEN = "Blue door (+2 lives)",
                            ResultKR = "차가운 기운이 상처를 치유한다. 체력 +2!",
                            ResultEN = "Cold air heals your wounds. +2 lives!",
                            Effect = p => p.Lives = Math.Min(p.Lives + 2, PlayerState.MaxLives)
                        }
                    }
                },

                new GameEvent
                {
                    Id = "dokkaebi_fire",
                    TitleKR = "도깨비불 시험",
                    TitleEN = "Ghost Fire Trial",
                    DescriptionKR = "도깨비불이 수수께끼를 낸다.\n\"나는 밤에 태어나 낮에 죽는다. 나는 누구인가?\"",
                    DescriptionEN = "A ghost fire poses a riddle.\n\"I'm born at night and die at dawn. What am I?\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "도깨비불",
                            TextEN = "Ghost fire",
                            ResultKR = "정답! 엽전 +80!",
                            ResultEN = "Correct! +80 Yeop!",
                            Effect = p => p.Yeop += 80
                        },
                        new EventChoice
                        {
                            TextKR = "그림자",
                            TextEN = "Shadow",
                            ResultKR = "오답. 도깨비불이 화를 낸다. 엽전 -30.",
                            ResultEN = "Wrong. The fire is angry. -30 Yeop.",
                            Effect = p => p.Yeop = Math.Max(0, p.Yeop - 30)
                        },
                        new EventChoice
                        {
                            TextKR = "달빛",
                            TextEN = "Moonlight",
                            ResultKR = "오답. 도깨비불이 사라진다.",
                            ResultEN = "Wrong. The fire vanishes.",
                            Effect = _ => { }
                        }
                    }
                },

                new GameEvent
                {
                    Id = "prayer",
                    TitleKR = "삼도천 기도",
                    TitleEN = "Prayer at Samdo River",
                    DescriptionKR = "삼도천 강가에 도착한다.\n물결이 반짝인다. 기도를 올릴 수 있을 것 같다.",
                    DescriptionEN = "You reach the river Samdo.\nThe waters glimmer. You could pray here.",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "기도한다 (-50 엽전, +2 체력)",
                            TextEN = "Pray (-50 Yeop, +2 lives)",
                            ResultKR = "기운이 차오른다. 체력 +2!",
                            ResultEN = "Energy flows through you. +2 lives!",
                            Effect = p =>
                            {
                                if (p.Yeop >= 50)
                                {
                                    p.Yeop -= 50;
                                    p.Lives = Math.Min(p.Lives + 2, PlayerState.MaxLives);
                                }
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "동전을 던진다 (-20 엽전, 50% 확률 x2)",
                            TextEN = "Toss a coin (-20, 50% chance to double)",
                            ResultKR = "운명의 동전...",
                            ResultEN = "A coin of fate...",
                            Effect = p =>
                            {
                                if (p.Yeop >= 20)
                                {
                                    p.Yeop -= 20;
                                    if (_rng.NextDouble() < 0.5)
                                        p.Yeop += 40;
                                }
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "그냥 지나간다",
                            TextEN = "Pass by",
                            ResultKR = "강물 소리가 뒤에서 들린다.",
                            ResultEN = "The sound of water fades behind you.",
                            Effect = _ => { }
                        }
                    }
                },

                new GameEvent
                {
                    Id = "dokkaebi_bet",
                    TitleKR = "도깨비의 내기",
                    TitleEN = "Dokkaebi's Bet",
                    DescriptionKR = "잡졸 도깨비가 나타나 내기를 제안한다.\n\"야, 간단한 내기 하나 하자.\"",
                    DescriptionEN = "A minor dokkaebi challenges you.\n\"Hey, let's make a simple bet.\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "받아들인다 (50% 엽전 +100 / 50% 체력 -1)",
                            TextEN = "Accept (50% +100 Yeop / 50% -1 life)",
                            ResultKR = "도박의 결과는...",
                            ResultEN = "The result is...",
                            Effect = p =>
                            {
                                if (_rng.NextDouble() < 0.5)
                                    p.Yeop += 100;
                                else
                                    p.Lives = Math.Max(1, p.Lives - 1);
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "거절한다",
                            TextEN = "Refuse",
                            ResultKR = "도깨비가 킥킥대며 사라진다.",
                            ResultEN = "The dokkaebi giggles and vanishes.",
                            Effect = _ => { }
                        }
                    }
                },

                // === E07: 저승꽃밭 ===
                new GameEvent
                {
                    Id = "flower_field",
                    TitleKR = "저승꽃밭",
                    TitleEN = "Underworld Flower Field",
                    DescriptionKR = "아름다운 꽃밭이 펼쳐진다.\n꽃잎이 반짝인다. 힘이 솟는 느낌...",
                    DescriptionEN = "A beautiful flower field unfolds.\nPetals shimmer. You feel empowered...",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "꽃의 힘을 흡수한다 (3턴 배수 +2)",
                            TextEN = "Absorb flower power (+2 mult for 3 turns)",
                            ResultKR = "꽃의 기운이 몸에 스며든다! 배수 +2!",
                            ResultEN = "Flower energy seeps in! +2 Mult!",
                            Effect = p => p.WaveMultBonus += 2
                        },
                        new EventChoice
                        {
                            TextKR = "꽃잎을 모은다 (+40 엽전)",
                            TextEN = "Gather petals (+40 Yeop)",
                            ResultKR = "아름다운 꽃잎을 모았다. 엽전 +40.",
                            ResultEN = "Beautiful petals gathered. +40 Yeop.",
                            Effect = p => p.Yeop += 40
                        }
                    }
                },

                // === E08: 거울 연못 ===
                new GameEvent
                {
                    Id = "mirror_pond",
                    TitleKR = "거울 연못",
                    TitleEN = "Mirror Pond",
                    DescriptionKR = "맑은 연못에 얼굴이 비친다.\n연못 속에서 무언가 빛나고 있다...",
                    DescriptionEN = "Your face reflects in a clear pond.\nSomething glimmers beneath the surface...",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "연못에 손을 넣는다 (랜덤 부적 교체)",
                            TextEN = "Reach into the pond (random talisman swap)",
                            ResultKR = "부적이 빛나며 변했다!",
                            ResultEN = "Your talisman shimmers and transforms!",
                            Effect = p =>
                            {
                                if (p.Talismans.Count > 0)
                                {
                                    p.Talismans.RemoveAt(p.Talismans.Count - 1);
                                    var all = Talismans.TalismanDatabase.AllTalismans;
                                    var newT = all[_rng.Next(all.Count)];
                                    p.EquipTalisman(new Talismans.TalismanInstance(newT));
                                }
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "연못을 관찰한다 (다음 보스 기믹 정보)",
                            TextEN = "Observe the pond (reveal next boss gimmick)",
                            ResultKR = "다음 적의 약점이 보인다... 목표 -10%!",
                            ResultEN = "You see the next enemy's weakness... Target -10%!",
                            Effect = p => p.WaveTargetReduction += 0.1f
                        },
                        new EventChoice
                        {
                            TextKR = "동전을 던진다 (+20 엽전)",
                            TextEN = "Toss a coin (+20 Yeop)",
                            ResultKR = "동전이 연못 속으로... 엽전 +20.",
                            ResultEN = "The coin sinks... +20 Yeop.",
                            Effect = p => p.Yeop += 20
                        }
                    }
                },

                // === E09: 저승사자의 제안 ===
                new GameEvent
                {
                    Id = "ferryman_deal",
                    TitleKR = "저승사자의 제안",
                    TitleEN = "Ferryman's Proposal",
                    DescriptionKR = "저승사자가 나타난다.\n\"거래를 하자. 네 영혼의 일부와 교환하지.\"",
                    DescriptionEN = "The ferryman appears.\n\"Let's make a deal. Part of your soul in exchange.\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "기믹 무효화 1라운드 (-100 엽전)",
                            TextEN = "Negate boss gimmick 1 round (-100 Yeop)",
                            ResultKR = "저승사자의 힘이 보스를 억누른다!",
                            ResultEN = "The ferryman's power suppresses the boss!",
                            Effect = p =>
                            {
                                if (p.Yeop >= 100) p.Yeop -= 100;
                                else p.Yeop = 0;
                                // 기믹 무효화 플래그 — 간소화: 목표 -20%
                                p.WaveTargetReduction += 0.2f;
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "Go 배수 보너스 +1",
                            TextEN = "+1 Go multiplier bonus",
                            ResultKR = "욕심의 힘이 커진다. Go 배수 +1!",
                            ResultEN = "Greed empowers you. Go mult +1!",
                            Effect = p => p.WaveMultBonus += 1
                        },
                        new EventChoice
                        {
                            TextKR = "거절한다 (엽전 +30)",
                            TextEN = "Refuse (+30 Yeop)",
                            ResultKR = "저승사자가 고개를 끄덕인다. 엽전 +30.",
                            ResultEN = "The ferryman nods. +30 Yeop.",
                            Effect = p => p.Yeop += 30
                        }
                    }
                },

                // === E10: 윤회의 문 ===
                new GameEvent
                {
                    Id = "samsara_gate",
                    TitleKR = "윤회의 문",
                    TitleEN = "Gate of Samsara",
                    DescriptionKR = "빙글빙글 도는 문이 나타났다.\n문 너머로 과거의 자신이 보인다.\n\"다시 태어나고 싶으냐?\"",
                    DescriptionEN = "A spinning gate appears.\nThrough it, you see your past self.\n\"Do you wish to be reborn?\"",
                    Choices = new List<EventChoice>
                    {
                        new EventChoice
                        {
                            TextKR = "환생한다 (체력 MAX, 엽전 0)",
                            TextEN = "Reincarnate (Full HP, 0 Yeop)",
                            ResultKR = "새로운 몸으로 태어났다! 체력 전체 회복, 엽전 초기화!",
                            ResultEN = "Reborn in a new body! Full HP, Yeop reset!",
                            Effect = p => { p.Lives = PlayerState.MaxLives; p.Yeop = 0; }
                        },
                        new EventChoice
                        {
                            TextKR = "힘을 얻는다 (칩 +30, 목숨 -1)",
                            TextEN = "Gain power (+30 Chips, -1 life)",
                            ResultKR = "과거의 힘이 흘러든다. 칩 +30!",
                            ResultEN = "Power from the past flows in. +30 Chips!",
                            Effect = p =>
                            {
                                p.WaveChipBonus += 30;
                                p.Lives = Math.Max(1, p.Lives - 1);
                            }
                        },
                        new EventChoice
                        {
                            TextKR = "문을 닫는다",
                            TextEN = "Close the gate",
                            ResultKR = "문이 사라졌다. 무언가 아쉽다...",
                            ResultEN = "The gate vanishes. Something feels lost...",
                            Effect = _ => { }
                        }
                    }
                }
            };
        }
    }
}
