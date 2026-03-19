using System;
using System.Collections.Generic;
using DokkaebiHand.Combat;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 무한 나선(Infinite Spiral) 관리.
    /// 10영역 1세트 = 1나선. 나선은 무한 반복.
    /// 매 나선 완료 시 "이승의 문" 출현 → 선택적 엔딩 or 계속.
    /// </summary>
    public class SpiralManager
    {
        public int CurrentSpiral { get; private set; } = 1;
        public int CurrentRealm { get; private set; } = 1;
        public int TotalRealmsCleared { get; private set; } = 0;

        public const int RealmsPerSpiral = 10;

        // 나선 시작 시 선택한 축복/저주
        public SpiralBlessing ActiveBlessing { get; private set; }

        public event Action<int> OnSpiralAdvanced;
        public event Action OnGateAppeared;

        /// <summary>
        /// 현재 영역의 절대 번호 (1, 2, 3, ... ∞)
        /// </summary>
        public int AbsoluteRealm => (CurrentSpiral - 1) * RealmsPerSpiral + CurrentRealm;

        /// <summary>
        /// 현재 영역의 목표 점수 (선형 스케일링)
        /// 기본값 × (1 + 0.12 × (AbsoluteRealm - 1))
        /// </summary>
        public int GetTargetScore(int baseTarget)
        {
            float multiplier = 1f + 0.12f * (AbsoluteRealm - 1);
            return (int)(baseTarget * multiplier);
        }

        /// <summary>
        /// 현재 나선에서 보스에 붙는 파츠 수
        /// </summary>
        public int GetPartsCount()
        {
            if (CurrentSpiral <= 1) return 0;
            if (CurrentSpiral <= 2) return 1;
            if (CurrentSpiral <= 3) return 2;
            return 3;
        }

        /// <summary>
        /// 현재 나선의 파츠 최소 등급
        /// </summary>
        public PartsRarity GetMinPartsRarity()
        {
            if (CurrentSpiral <= 3) return PartsRarity.Common;
            if (CurrentSpiral <= 5) return PartsRarity.Rare;
            return PartsRarity.Legendary;
        }

        /// <summary>
        /// 영역 클리어 → 다음 영역 또는 나선 완료
        /// </summary>
        public bool AdvanceRealm()
        {
            TotalRealmsCleared++;
            CurrentRealm++;

            if (CurrentRealm > RealmsPerSpiral)
            {
                // 나선 완료 → 이승의 문 출현
                OnGateAppeared?.Invoke();
                return true; // gate appeared
            }

            return false;
        }

        /// <summary>
        /// 이승의 문 거부 → 다음 나선으로
        /// </summary>
        public void ContinueToNextSpiral()
        {
            CurrentSpiral++;
            CurrentRealm = 1;
            ActiveBlessing = null;
            OnSpiralAdvanced?.Invoke(CurrentSpiral);
        }

        /// <summary>
        /// 나선 시작 시 축복 선택
        /// </summary>
        public void SelectBlessing(SpiralBlessing blessing)
        {
            ActiveBlessing = blessing;
        }

        /// <summary>
        /// 세이브용 상태 직렬화
        /// </summary>
        public SpiralSaveData ToSaveData()
        {
            return new SpiralSaveData
            {
                Spiral = CurrentSpiral,
                Realm = CurrentRealm,
                TotalCleared = TotalRealmsCleared,
                BlessingId = ActiveBlessing?.Id
            };
        }

        public void LoadFromSave(SpiralSaveData data)
        {
            CurrentSpiral = data.Spiral;
            CurrentRealm = data.Realm;
            TotalRealmsCleared = data.TotalCleared;
        }
    }

    [Serializable]
    public class SpiralSaveData
    {
        public int Spiral;
        public int Realm;
        public int TotalCleared;
        public string BlessingId;
    }

    /// <summary>
    /// 나선 시작 시 선택하는 축복/저주 (양날의 검)
    /// </summary>
    public class SpiralBlessing
    {
        public string Id;
        public string Name;
        public string NameKR;
        public string BonusDesc;
        public string PenaltyDesc;

        // 효과 값
        public float ChipBonus;
        public float MultBonus;
        public float TargetPenalty;
        public int HandPenalty;
        public float TalismanEffectMult; // 부적 효과 배율 (공허: 2.0)
        public int TalismanSlotPenalty;  // 부적 슬롯 감소 (공허: 2)

        public static List<SpiralBlessing> GetAll()
        {
            return new List<SpiralBlessing>
            {
                new SpiralBlessing
                {
                    Id = "fire", Name = "Hellfire", NameKR = "업화(業火)",
                    BonusDesc = "모든 칩 +20%", PenaltyDesc = "매 5턴 바닥패 1장 소각",
                    ChipBonus = 0.2f
                },
                new SpiralBlessing
                {
                    Id = "ice", Name = "Frostbind", NameKR = "빙결(氷結)",
                    BonusDesc = "모든 배수 +1", PenaltyDesc = "매 라운드 시작 손패 -1",
                    MultBonus = 1, HandPenalty = 1
                },
                new SpiralBlessing
                {
                    Id = "void", Name = "Void", NameKR = "공허(空虛)",
                    BonusDesc = "부적 효과 2배", PenaltyDesc = "부적 슬롯 -2",
                    TalismanEffectMult = 2.0f, TalismanSlotPenalty = 2
                },
                new SpiralBlessing
                {
                    Id = "chaos", Name = "Chaos", NameKR = "혼돈(混沌)",
                    BonusDesc = "랜덤 족보 매턴 1개 강제 완성", PenaltyDesc = "좋을 수도, 나쁠 수도",
                    ChipBonus = 0
                }
            };
        }
    }
}
