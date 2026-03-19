using UnityEngine;

namespace DokkaebiHand.Talismans
{
    public enum TalismanRarity
    {
        Common,     // 일반
        Rare,       // 희귀
        Legendary,  // 전설
        Cursed      // 저주
    }

    public enum TalismanTrigger
    {
        OnCardPlayed,       // 패를 낼 때
        OnYokboComplete,    // 족보 완성 시
        OnTurnStart,        // 턴 시작
        OnTurnEnd,          // 턴 종료
        OnRoundStart,       // 라운드 시작
        OnRoundEnd,         // 라운드 종료 (점수 정산)
        OnGoDecision,       // Go 선택 시
        OnStopDecision,     // Stop 선택 시
        OnMatchSuccess,     // 매칭 성공 시
        OnMatchFail,        // 매칭 실패 시
        Passive             // 상시 적용
    }

    public enum TalismanEffectType
    {
        AddChips,           // 칩 가산
        AddMult,            // 배수 가산
        MultiplyMult,       // 배수 승산
        ReduceTarget,       // 목표 점수 감소
        WildCard,           // 와일드카드 변환
        TransmuteCard,      // 카드 변이
        DestroyCard,        // 카드 소멸
        Special             // 특수 효과
    }

    [CreateAssetMenu(fileName = "NewTalisman", menuName = "DokkaebiHand/Talisman")]
    public class Talisman : ScriptableObject
    {
        [Header("기본 정보")]
        public string talismanName;
        public string talismanNameKR;
        public TalismanRarity rarity;
        [TextArea]
        public string description;
        [TextArea]
        public string descriptionKR;

        [Header("트리거")]
        public TalismanTrigger trigger;
        public string triggerCondition; // 추가 조건 (예: "피 패일 때")

        [Header("효과")]
        public TalismanEffectType effectType;
        public float effectValue;       // 수치 (칩/배수/퍼센트 등)
        public float triggerChance = 1f; // 발동 확률 (0~1)

        [Header("특수")]
        public bool IsCurse;            // 저주 부적 (강제 장착, 제거 불가)

        [Header("비주얼")]
        public Sprite talismanSprite;
    }
}
