using System.Collections.Generic;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 보스 데이터베이스 (런타임용)
    /// </summary>
    public class BossDefinition
    {
        public string Id;
        public string Name;
        public string NameKR;
        public string Description;
        public int TargetScore;
        public int Rounds;
        public BossGimmick Gimmick;
        public int GimmickInterval;
        public string IntroDialogue;
        public string DefeatDialogue;
        public string VictoryDialogue;
        public int YeopReward;
        public bool DropsLegendaryTalisman;
    }

    public static class BossDatabase
    {
        private static List<BossDefinition> _allBosses;

        public static List<BossDefinition> AllBosses
        {
            get
            {
                if (_allBosses == null)
                    Initialize();
                return _allBosses;
            }
        }

        private static void Initialize()
        {
            _allBosses = new List<BossDefinition>
            {
                // 1. 먹보 도깨비 — 입문
                new BossDefinition
                {
                    Id = "glutton",
                    Name = "Glutton Dokkaebi",
                    NameKR = "먹보 도깨비",
                    Description = "2턴마다 손패 중 최고가치 패 1장을 먹어치운다",
                    TargetScore = 100,
                    Rounds = 6,
                    Gimmick = BossGimmick.ConsumeHighest,
                    GimmickInterval = 2,
                    IntroDialogue = "크하하! 네 패에서 맛있는 냄새가 나는구나!",
                    DefeatDialogue = "으억... 배가 너무 불러...",
                    VictoryDialogue = "꺼억! 맛있었다! 넌 이제 내 밥이야!",
                    YeopReward = 30,
                    DropsLegendaryTalisman = false
                },

                // 2. 장난꾸러기 도깨비 — 입문
                new BossDefinition
                {
                    Id = "trickster",
                    Name = "Trickster Dokkaebi",
                    NameKR = "장난꾸러기 도깨비",
                    Description = "2턴마다 패를 뒤집는다",
                    TargetScore = 150,
                    Rounds = 6,
                    Gimmick = BossGimmick.FlipAll,
                    GimmickInterval = 2,
                    IntroDialogue = "히히히! 눈 감고 쳐봐라~!",
                    DefeatDialogue = "에잇, 네 눈이 너무 좋구나!",
                    VictoryDialogue = "히히! 찍기의 달인이 될 뻔했는데~",
                    YeopReward = 35,
                    DropsLegendaryTalisman = false
                },

                // 3. 불꽃 도깨비 — 초급
                new BossDefinition
                {
                    Id = "flame",
                    Name = "Flame Dokkaebi",
                    NameKR = "불꽃 도깨비",
                    Description = "3턴마다 바닥패를 전부 불태워 리셋한다",
                    TargetScore = 200,
                    Rounds = 6,
                    Gimmick = BossGimmick.ResetField,
                    GimmickInterval = 3,
                    IntroDialogue = "타오르는 화투판... 재밌지 않나?",
                    DefeatDialogue = "꺼져가는 불꽃... 인정한다...",
                    VictoryDialogue = "모두 태워버리겠다!",
                    YeopReward = 40,
                    DropsLegendaryTalisman = false
                },

                // 4. 그림자 도깨비 — 중급
                new BossDefinition
                {
                    Id = "shadow",
                    Name = "Shadow Dokkaebi",
                    NameKR = "그림자 도깨비",
                    Description = "부적 1개를 랜덤으로 비활성화한다",
                    TargetScore = 230,
                    Rounds = 5,
                    Gimmick = BossGimmick.DisableTalisman,
                    GimmickInterval = 2,
                    IntroDialogue = "그림자가 너의 힘을 삼켜가고 있다...",
                    DefeatDialogue = "빛이... 너무 밝다...",
                    VictoryDialogue = "어둠 속에서 영원히 헤매거라!",
                    YeopReward = 50,
                    DropsLegendaryTalisman = true
                },

                // 5. 여우 도깨비 — 중급
                new BossDefinition
                {
                    Id = "fox",
                    Name = "Fox Dokkaebi",
                    NameKR = "여우 도깨비",
                    Description = "매 2턴마다 바닥패 2장의 월을 변경한다",
                    TargetScore = 200,
                    Rounds = 5,
                    Gimmick = BossGimmick.FlipAll,
                    GimmickInterval = 2,
                    IntroDialogue = "후후... 눈을 잘 떠야 할 거야.",
                    DefeatDialogue = "아이고... 꼬리가 잡혔네...",
                    VictoryDialogue = "후후후, 속았지?",
                    YeopReward = 45,
                    DropsLegendaryTalisman = false
                },

                // 6. 거울 도깨비 — 중급
                new BossDefinition
                {
                    Id = "mirror",
                    Name = "Mirror Dokkaebi",
                    NameKR = "거울 도깨비",
                    Description = "부적 효과를 반전시킨다",
                    TargetScore = 260,
                    Rounds = 5,
                    Gimmick = BossGimmick.DisableTalisman,
                    GimmickInterval = 3,
                    IntroDialogue = "네 힘이 곧 나의 힘...",
                    DefeatDialogue = "거울이... 깨진다...",
                    VictoryDialogue = "네 그림자에 갇혀라!",
                    YeopReward = 50,
                    DropsLegendaryTalisman = false
                },

                // 7. 화산 도깨비 — 상급
                new BossDefinition
                {
                    Id = "volcano",
                    Name = "Volcano Dokkaebi",
                    NameKR = "화산 도깨비",
                    Description = "매 2턴 바닥패 1장 소각",
                    TargetScore = 300,
                    Rounds = 5,
                    Gimmick = BossGimmick.ResetField,
                    GimmickInterval = 2,
                    IntroDialogue = "뜨거운 용암 위에서 패를 쳐볼 테냐!",
                    DefeatDialogue = "크윽... 식어간다...",
                    VictoryDialogue = "모든 것을 녹여버리겠다!",
                    YeopReward = 55,
                    DropsLegendaryTalisman = false
                },

                // 8. 황금 도깨비 — 상급 (하이리스크 하이리턴)
                new BossDefinition
                {
                    Id = "gold",
                    Name = "Golden Dokkaebi",
                    NameKR = "황금 도깨비",
                    Description = "강하지만 보상도 크다",
                    TargetScore = 350,
                    Rounds = 6,
                    Gimmick = BossGimmick.ConsumeHighest,
                    GimmickInterval = 3,
                    IntroDialogue = "금으로 된 패를 원하느냐? 그럼 이겨봐라!",
                    DefeatDialogue = "내 금은보화를... 가져가거라...",
                    VictoryDialogue = "탐욕은 모든 것을 삼킨다!",
                    YeopReward = 80,
                    DropsLegendaryTalisman = true
                },

                // 9. 회랑 도깨비 — 상급
                new BossDefinition
                {
                    Id = "corridor",
                    Name = "Corridor Dokkaebi",
                    NameKR = "회랑 도깨비",
                    Description = "매 턴 패를 뒤집는다",
                    TargetScore = 320,
                    Rounds = 5,
                    Gimmick = BossGimmick.FlipAll,
                    GimmickInterval = 1,
                    IntroDialogue = "이 끝없는 회랑에서 빠져나갈 수 있겠느냐...",
                    DefeatDialogue = "길을 찾다니... 대단하구나...",
                    VictoryDialogue = "영원히 이 회랑을 떠돌게 될 것이다!",
                    YeopReward = 60,
                    DropsLegendaryTalisman = false
                },

                // 10. 염라대왕 — 보스 (나선 1 최종)
                new BossDefinition
                {
                    Id = "yeomra",
                    Name = "King Yeomra",
                    NameKR = "염라대왕",
                    Description = "광을 무효화시킨다. 피와 띠만으로 승부하라",
                    TargetScore = 400,
                    Rounds = 6,
                    Gimmick = BossGimmick.NoBright,
                    GimmickInterval = 1,
                    IntroDialogue = "감히 이승으로 돌아가겠다고? 한 판 뜨자!",
                    DefeatDialogue = "허... 대단하구나. 이승의 길을 열어주마.",
                    VictoryDialogue = "저승에서 영원히 내 패거리가 되거라!",
                    YeopReward = 100,
                    DropsLegendaryTalisman = true
                }
            };
        }

        public static BossDefinition GetBoss(int index)
        {
            if (index < 0 || index >= AllBosses.Count)
                return AllBosses[0];
            return AllBosses[index];
        }

        public static BossDefinition GetById(string id)
        {
            return AllBosses.Find(b => b.Id == id);
        }

        // === 재앙 보스 (나선 3/5/8/10 등장) ===
        private static List<BossDefinition> _calamityBosses;

        public static List<BossDefinition> CalamityBosses
        {
            get
            {
                if (_calamityBosses == null) InitializeCalamity();
                return _calamityBosses;
            }
        }

        private static void InitializeCalamity()
        {
            _calamityBosses = new List<BossDefinition>
            {
                new BossDefinition
                {
                    Id = "skeleton_general",
                    Name = "Skeleton General",
                    NameKR = "백골대장",
                    Description = "매 턴 카드 1장을 해골패로 변환. 해골 3개 = 즉사.",
                    TargetScore = 5000,
                    Rounds = 5,
                    Gimmick = BossGimmick.Skullify,
                    GimmickInterval = 1,
                    IntroDialogue = "뼈뼈뼈... 살이 아까운가? 뼈만 남겨주마...",
                    DefeatDialogue = "깔깔깔... 뼈는 거짓말을 하지 않아...",
                    VictoryDialogue = "뼈밖에 남지 않았구나! 껄껄껄!",
                    YeopReward = 500,
                    DropsLegendaryTalisman = true
                },
                new BossDefinition
                {
                    Id = "ninetail_king",
                    Name = "Nine-Tail Fox King",
                    NameKR = "구미호 왕",
                    Description = "30% 카드가 가짜. 매칭 실패 시 -50칩. 3턴마다 손패 셔플.",
                    TargetScore = 6000,
                    Rounds = 5,
                    Gimmick = BossGimmick.FakeCards,
                    GimmickInterval = 3,
                    IntroDialogue = "후후... 진짜와 가짜를 구분할 수 있겠느냐?",
                    DefeatDialogue = "이 눈으로... 간파하다니...",
                    VictoryDialogue = "환상 속에서 영원히 헤매거라! 후후후!",
                    YeopReward = 600,
                    DropsLegendaryTalisman = true
                },
                new BossDefinition
                {
                    Id = "imugi",
                    Name = "Imugi (Greater Demon)",
                    NameKR = "이무기",
                    Description = "경쟁전: 이무기도 매 턴 +50점 누적. 먼저 목표 달성해야 승리.",
                    TargetScore = 8000,
                    Rounds = 7,
                    Gimmick = BossGimmick.Competitive,
                    GimmickInterval = 1,
                    IntroDialogue = "나도 용이 되려면 이겨야 한다! 승부다!",
                    DefeatDialogue = "크으... 결국 승천은 네 몫이었구나...",
                    VictoryDialogue = "하하하! 이무기는 결국 용이 되었다!",
                    YeopReward = 800,
                    DropsLegendaryTalisman = true
                },
                new BossDefinition
                {
                    Id = "underworld_flower",
                    Name = "Underworld Flower King",
                    NameKR = "저승꽃",
                    Description = "매 라운드 강화 1개 비활성 + 5턴마다 부적 셔플 + 족보명 숨김.",
                    TargetScore = 10000,
                    Rounds = 7,
                    Gimmick = BossGimmick.Suppress,
                    GimmickInterval = 5,
                    IntroDialogue = "아름답지 않니? 이 꽃들은 전부 망자의 혼으로 피어났단다.",
                    DefeatDialogue = "꽃잎이... 흩날린다... 아름답구나...",
                    VictoryDialogue = "너도 꽃이 되어라. 영원히... 아름답게...",
                    YeopReward = 1000,
                    DropsLegendaryTalisman = true
                }
            };
        }

        /// <summary>
        /// 재앙 보스 가져오기 (나선 번호 기반)
        /// </summary>
        public static BossDefinition GetCalamityBoss(int spiralNumber)
        {
            return spiralNumber switch
            {
                3 => CalamityBosses[0],   // 백골대장
                5 => CalamityBosses[1],   // 구미호 왕
                8 => CalamityBosses[2],   // 이무기
                >= 10 => CalamityBosses[3], // 저승꽃
                _ => null
            };
        }
    }
}
