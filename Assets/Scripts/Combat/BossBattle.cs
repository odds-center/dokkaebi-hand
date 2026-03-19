using System;
using DokkaebiHand.Core;
using DokkaebiHand.Cards;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 보스 전투 시스템: HP 기반 전투
    ///
    /// 전투 흐름:
    /// 1. 보스 HP 표시 (예: 300)
    /// 2. 고스톱 매칭으로 패를 모은다
    /// 3. 족보 완성 → 스톱하면 보스에게 타격 (점×배 = 데미지)
    /// 4. 보스 반격 (기믹 발동 + 데미지)
    /// 5. 보스 HP 0 이하 → 관문 돌파
    /// 6. 내 목숨 0 → 저승에 가라앉다
    ///
    /// 한 판(라운드) = 패 돌리기 ~ 스톱까지
    /// 여러 판 쳐서 보스 HP를 깎아야 함
    /// </summary>
    public class BossBattle
    {
        public int BossMaxHP { get; private set; }
        public int BossCurrentHP { get; private set; }
        public int BossAttackDamage { get; private set; }  // 판마다 플레이어에게 주는 피해
        public bool IsBossDefeated => BossCurrentHP <= 0;

        // 보스 반격으로 인한 추가 효과
        public int CounterChipPenalty { get; private set; }  // 다음 판 점 감소
        public int CounterHandPenalty { get; private set; }  // 다음 판 손패 감소

        public event Action<int> OnBossDamaged;       // 데미지량
        public event Action<int> OnPlayerDamaged;     // 데미지량
        public event Action OnBossDefeated;
        public event Action<string> OnBossCounterAttack;  // 반격 메시지

        private readonly BossDefinition _boss;
        private readonly Random _rng = new Random();

        public BossBattle(BossDefinition boss, int spiralNumber)
        {
            _boss = boss;

            // HP = 기본 목표점수 × 5 (여러 판에 걸쳐 깎도록)
            // 1윤회: 1000~2000, 2윤회: 1500~3000, ...
            float spiralMult = 1f + (spiralNumber - 1) * 0.5f;
            BossMaxHP = (int)(boss.TargetScore * 5 * spiralMult);
            BossCurrentHP = BossMaxHP;

            // 반격 데미지 = 기믹 난이도에 따라
            BossAttackDamage = boss.Gimmick switch
            {
                BossGimmick.None => 0,
                BossGimmick.ConsumeHighest => 1,  // 패 1장 먹기 (간접 피해)
                BossGimmick.FlipAll => 0,          // 방해만
                BossGimmick.ResetField => 0,       // 방해만
                BossGimmick.DisableTalisman => 0,  // 방해만
                BossGimmick.NoBright => 0,         // 광 봉인
                BossGimmick.Skullify => 1,         // 해골 생성
                BossGimmick.FakeCards => 0,        // 방해만
                BossGimmick.Competitive => 0,      // 경쟁형
                BossGimmick.Suppress => 0,         // 억압
                _ => 0
            };
        }

        /// <summary>
        /// 플레이어가 스톱 선택 → 족보 데미지로 보스 HP 깎기
        /// </summary>
        public int DealDamage(ScoringEngine.ScoreResult scoreResult)
        {
            int damage = scoreResult.FinalScore;
            BossCurrentHP -= damage;

            OnBossDamaged?.Invoke(damage);

            if (BossCurrentHP <= 0)
            {
                BossCurrentHP = 0;
                OnBossDefeated?.Invoke();
            }

            return damage;
        }

        /// <summary>
        /// 보스 반격 (매 판 종료 후)
        /// 기믹 외에 추가적인 반격 행동
        /// </summary>
        public string BossCounterAttack(PlayerState player)
        {
            CounterChipPenalty = 0;
            CounterHandPenalty = 0;

            string message = "";

            // 보스 HP 비율에 따른 분노 단계
            float hpRatio = (float)BossCurrentHP / BossMaxHP;

            if (hpRatio < 0.3f)
            {
                // 피 30% 미만 → 광분 상태
                message = BossRageAttack(player);
            }
            else if (hpRatio < 0.6f)
            {
                // 피 60% 미만 → 짜증 상태
                message = BossAngerAttack(player);
            }
            else
            {
                // 여유 상태 → 가벼운 방해
                message = BossLightAttack(player);
            }

            OnBossCounterAttack?.Invoke(message);
            return message;
        }

        private string BossLightAttack(PlayerState player)
        {
            int roll = _rng.Next(3);
            switch (roll)
            {
                case 0:
                    // 조롱 (효과 없음, 분위기용)
                    return _boss.Gimmick switch
                    {
                        BossGimmick.ConsumeHighest => "크하하! 배고프다~",
                        BossGimmick.FlipAll => "히히, 어디 한번 맞춰봐~",
                        BossGimmick.NoBright => "광이 뭐가 대수냐?",
                        _ => "흥, 이 정도로는..."
                    };
                case 1:
                    // 다음 판 점 -10%
                    CounterChipPenalty = 10;
                    return "도깨비가 바닥을 내리쳤다! (다음 판 점 -10%)";
                default:
                    return "도깨비가 코를 킁킁댄다...";
            }
        }

        private string BossAngerAttack(PlayerState player)
        {
            int roll = _rng.Next(3);
            switch (roll)
            {
                case 0:
                    // 손패 1장 제거
                    CounterHandPenalty = 1;
                    return "도깨비가 화가 났다! 손패 1장 빼앗김!";
                case 1:
                    // 다음 판 점 -20%
                    CounterChipPenalty = 20;
                    return "도깨비가 발을 구른다! (다음 판 점 -20%)";
                default:
                    // 엽전 도둑질
                    int stolen = System.Math.Min(player.Yeop, 15);
                    player.Yeop -= stolen;
                    return $"도깨비가 엽전을 훔쳤다! (-{stolen}냥)";
            }
        }

        private string BossRageAttack(PlayerState player)
        {
            int roll = _rng.Next(3);
            switch (roll)
            {
                case 0:
                    // 목숨 위협 (30% 확률로 1 감소)
                    if (_rng.NextDouble() < 0.3)
                    {
                        player.Lives = System.Math.Max(1, player.Lives - 1);
                        return "도깨비가 미쳐 날뛴다!! 목숨 -1!";
                    }
                    return "도깨비가 미친 듯이 날뛰지만... 피했다!";
                case 1:
                    // 손패 2장 제거
                    CounterHandPenalty = 2;
                    return "도깨비가 광분한다!! 손패 2장 빼앗김!";
                default:
                    // 다음 판 점 -30%
                    CounterChipPenalty = 30;
                    return "도깨비의 기세가 바닥을 짓누른다! (다음 판 점 -30%)";
            }
        }

        /// <summary>
        /// HP 바 표시용 (0.0~1.0)
        /// </summary>
        public float GetHPRatio()
        {
            return BossMaxHP > 0 ? (float)BossCurrentHP / BossMaxHP : 0f;
        }

        /// <summary>
        /// HP 바 텍스트
        /// </summary>
        public string GetHPDisplay()
        {
            return $"♥ {BossCurrentHP}/{BossMaxHP}";
        }
    }
}
