using UnityEngine;

namespace DokkaebiHand.Combat
{
    public enum BossGimmick
    {
        None,
        ConsumeHighest,     // 먹보 도깨비: 매 턴 최고가치 패 1장 소멸
        FlipAll,            // 장난꾸러기 도깨비: 모든 패 뒤집기
        ResetField,         // 불꽃 도깨비: 3턴마다 바닥패 리셋
        DisableTalisman,    // 그림자 도깨비: 부적 1개 비활성화
        NoBright,           // 염라대왕: 광 무효화
        // === 재앙 보스 기믹 ===
        Skullify,           // 백골대장: 카드→해골패 변환, 3개 모이면 즉사
        FakeCards,          // 구미호 왕: 30% 가짜 카드, 매칭실패 시 -50칩
        Competitive,        // 이무기: 보스도 점수 누적, 경쟁
        Suppress            // 저승꽃: 매 라운드 강화 1개 비활성 + 족보명 숨김
    }

    [CreateAssetMenu(fileName = "NewBoss", menuName = "DokkaebiHand/Boss")]
    public class BossData : ScriptableObject
    {
        [Header("기본 정보")]
        public string bossName;
        public string bossNameKR;
        [TextArea]
        public string description;

        [Header("난이도")]
        public int targetScore = 300;
        public int rounds = 3;

        [Header("기믹")]
        public BossGimmick gimmick;
        public int gimmickInterval = 1; // 기믹 발동 간격 (턴)

        [Header("대사")]
        [TextArea] public string introDialogue;
        [TextArea] public string defeatDialogue;
        [TextArea] public string victoryDialogue;

        [Header("보상")]
        public int yeopReward = 50;
        public bool dropsLegendaryTalisman;

        [Header("비주얼")]
        public Sprite bossSprite;
    }
}
