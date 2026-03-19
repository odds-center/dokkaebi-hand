using System;
using System.Collections.Generic;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 사주팔자 시스템: 매 런마다 고유한 운명 조합 생성
    /// 년(오행) × 월(기질) × 일(운) × 시(축복/저주) = 500가지 조합
    /// </summary>
    public enum DestinyElement { Wood, Fire, Earth, Metal, Water }
    public enum DestinyTemperament { Warm, Hot, Quiet, Variable }
    public enum DestinyFortune { GreatLuck, Luck, Normal, Curse, GreatCurse }
    public enum DestinyHour { Blessing, Lucky, Cursed, Breaking, Void }

    public class DestinyProfile
    {
        public DestinyElement Element;
        public DestinyTemperament Temperament;
        public DestinyFortune Fortune;
        public DestinyHour Hour;

        public string GetNameKR()
        {
            string el = Element switch
            {
                DestinyElement.Wood => "목(木)",
                DestinyElement.Fire => "화(火)",
                DestinyElement.Earth => "토(土)",
                DestinyElement.Metal => "금(金)",
                DestinyElement.Water => "수(水)",
                _ => "?"
            };
            string temp = Temperament switch
            {
                DestinyTemperament.Warm => "온(溫)",
                DestinyTemperament.Hot => "열(熱)",
                DestinyTemperament.Quiet => "정(靜)",
                DestinyTemperament.Variable => "변(變)",
                _ => "?"
            };
            string fort = Fortune switch
            {
                DestinyFortune.GreatLuck => "대길(大吉)",
                DestinyFortune.Luck => "길(吉)",
                DestinyFortune.Normal => "평(平)",
                DestinyFortune.Curse => "흉(凶)",
                DestinyFortune.GreatCurse => "대흉(大凶)",
                _ => "?"
            };
            string hr = Hour switch
            {
                DestinyHour.Blessing => "복(福)",
                DestinyHour.Lucky => "운(運)",
                DestinyHour.Cursed => "액(厄)",
                DestinyHour.Breaking => "파(破)",
                DestinyHour.Void => "공(空)",
                _ => "?"
            };
            return $"{el} {temp} {fort} {hr}";
        }

        public string GetDescKR()
        {
            var lines = new List<string>();
            lines.Add(GetElementDesc());
            lines.Add(GetTemperamentDesc());
            lines.Add(GetFortuneDesc());
            lines.Add(GetHourDesc());
            return string.Join("\n", lines);
        }

        private string GetElementDesc()
        {
            return Element switch
            {
                DestinyElement.Wood => "목: 띠 칩 +20%",
                DestinyElement.Fire => "화: 광 배수 +1",
                DestinyElement.Earth => "토: 시작 엽전 +50",
                DestinyElement.Metal => "금: 열끗 칩 +20%",
                DestinyElement.Water => "수: 피 활성화 -2장 (피 족보 8장부터)",
                _ => ""
            };
        }

        private string GetTemperamentDesc()
        {
            return Temperament switch
            {
                DestinyTemperament.Warm => "온: 매칭 실패 시 칩 +5",
                DestinyTemperament.Hot => "열: Go 배수 보너스 +1",
                DestinyTemperament.Quiet => "정: Stop 선택 시 칩 +30",
                DestinyTemperament.Variable => "변: 30% 확률로 바닥패 2장 교체",
                _ => ""
            };
        }

        private string GetFortuneDesc()
        {
            return Fortune switch
            {
                DestinyFortune.GreatLuck => "대길: 보상 +50%",
                DestinyFortune.Luck => "길: 보상 +20%",
                DestinyFortune.Normal => "평: 변동 없음",
                DestinyFortune.Curse => "흉: 보상 -20%",
                DestinyFortune.GreatCurse => "대흉: 보상 -50%, 넋 3배!",
                _ => ""
            };
        }

        private string GetHourDesc()
        {
            return Hour switch
            {
                DestinyHour.Blessing => "복: 이벤트 보상 증가",
                DestinyHour.Lucky => "운: 상점 가격 -15%",
                DestinyHour.Cursed => "액: 보스 기믹 강화",
                DestinyHour.Breaking => "파: 시작 손패 -2장",
                DestinyHour.Void => "공: 부적 슬롯 -1",
                _ => ""
            };
        }
    }

    public class DestinySystem
    {
        private readonly Random _rng;

        public DestinyProfile CurrentDestiny { get; private set; }

        public DestinySystem(int? seed = null)
        {
            _rng = seed.HasValue ? new Random(seed.Value) : new Random();
        }

        /// <summary>
        /// 새 런 시작 시 랜덤 사주 생성
        /// </summary>
        public DestinyProfile GenerateDestiny()
        {
            CurrentDestiny = new DestinyProfile
            {
                Element = (DestinyElement)_rng.Next(5),
                Temperament = (DestinyTemperament)_rng.Next(4),
                Fortune = (DestinyFortune)_rng.Next(5),
                Hour = (DestinyHour)_rng.Next(5)
            };
            return CurrentDestiny;
        }

        /// <summary>
        /// 사주에 따른 칩 보너스 (족보별)
        /// </summary>
        public int GetChipBonus(string yokboType)
        {
            if (CurrentDestiny == null) return 0;

            return CurrentDestiny.Element switch
            {
                DestinyElement.Wood when yokboType.Contains("단") => 20, // 띠 관련 +20%→flat +20
                DestinyElement.Metal when yokboType.Contains("열끗") => 20,
                _ => 0
            };
        }

        /// <summary>
        /// 사주에 따른 배수 보너스
        /// </summary>
        public int GetMultBonus()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Element == DestinyElement.Fire ? 1 : 0;
        }

        /// <summary>
        /// 시작 엽전 보너스
        /// </summary>
        public int GetStartYeopBonus()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Element == DestinyElement.Earth ? 50 : 0;
        }

        /// <summary>
        /// 피 활성화 감소 (수)
        /// </summary>
        public int GetPiReduction()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Element == DestinyElement.Water ? 2 : 0;
        }

        /// <summary>
        /// 매칭 실패 칩 보너스 (온)
        /// </summary>
        public int GetMatchFailChipBonus()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Temperament == DestinyTemperament.Warm ? 5 : 0;
        }

        /// <summary>
        /// Go 배수 추가 (열)
        /// </summary>
        public int GetGoMultBonus()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Temperament == DestinyTemperament.Hot ? 1 : 0;
        }

        /// <summary>
        /// Stop 칩 보너스 (정)
        /// </summary>
        public int GetStopChipBonus()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Temperament == DestinyTemperament.Quiet ? 30 : 0;
        }

        /// <summary>
        /// 보상 배율 (운/흉)
        /// </summary>
        public float GetRewardMultiplier()
        {
            if (CurrentDestiny == null) return 1f;
            return CurrentDestiny.Fortune switch
            {
                DestinyFortune.GreatLuck => 1.5f,
                DestinyFortune.Luck => 1.2f,
                DestinyFortune.Normal => 1f,
                DestinyFortune.Curse => 0.8f,
                DestinyFortune.GreatCurse => 0.5f,
                _ => 1f
            };
        }

        /// <summary>
        /// 대흉: 영혼 조각 보너스 배율
        /// </summary>
        public float GetSoulFragmentMultiplier()
        {
            if (CurrentDestiny == null) return 1f;
            return CurrentDestiny.Fortune == DestinyFortune.GreatCurse ? 3f : 1f;
        }

        /// <summary>
        /// 상점 할인 (운 시)
        /// </summary>
        public float GetShopDiscount()
        {
            if (CurrentDestiny == null) return 0f;
            return CurrentDestiny.Hour == DestinyHour.Lucky ? 0.15f : 0f;
        }

        /// <summary>
        /// 시작 손패 감소 (파 시)
        /// </summary>
        public int GetHandPenalty()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Hour == DestinyHour.Breaking ? 2 : 0;
        }

        /// <summary>
        /// 부적 슬롯 감소 (공 시)
        /// </summary>
        public int GetTalismanSlotPenalty()
        {
            if (CurrentDestiny == null) return 0;
            return CurrentDestiny.Hour == DestinyHour.Void ? 1 : 0;
        }

        /// <summary>
        /// 보스 기믹 강화 여부 (액 시)
        /// </summary>
        public bool IsBossEnhanced()
        {
            return CurrentDestiny?.Hour == DestinyHour.Cursed;
        }
    }
}
