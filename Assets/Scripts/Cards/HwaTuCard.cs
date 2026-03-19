using UnityEngine;

namespace DokkaebiHand.Cards
{
    public enum CardMonth
    {
        January = 1,   // 송학 (소나무/학)
        February = 2,  // 매조 (매화/꾀꼬리)
        March = 3,     // 벚꽃 (벚꽃/커튼)
        April = 4,     // 흑싸리 (등나무/두견새)
        May = 5,       // 난초 (난초/다리)
        June = 6,      // 모란 (모란/나비)
        July = 7,      // 홍싸리 (싸리/멧돼지)
        August = 8,    // 공산 (억새/달/기러기)
        September = 9, // 국진 (국화/술잔)
        October = 10,  // 단풍 (단풍/사슴)
        November = 11, // 오동 (오동/봉황)
        December = 12  // 비 (비/사람)
    }

    public enum CardType
    {
        Gwang,    // 광 (Bright)
        Tti,      // 띠 (Ribbon)
        Yeolkkeut,// 열끗 (Animal/10-point)
        Pi        // 피 (Junk)
    }

    public enum RibbonType
    {
        None,
        HongDan,  // 홍단 (Red poetry ribbon)
        CheongDan,// 청단 (Blue ribbon)
        ChoDan    // 초단 (Plain ribbon)
    }

    [CreateAssetMenu(fileName = "NewHwaTuCard", menuName = "DokkaebiHand/HwaTu Card")]
    public class HwaTuCard : ScriptableObject
    {
        [Header("기본 정보")]
        public string cardName;
        public string cardNameKR;
        public CardMonth month;
        public CardType cardType;
        public RibbonType ribbonType = RibbonType.None;

        [Header("점수")]
        public int basePoints;

        [Header("특수 효과")]
        public bool isRainGwang;      // 비광 (December Bright - counts conditionally)
        public bool isDoublePi;       // 쌍피 (Double junk - worth 2 pi)
        [TextArea]
        public string specialEffect;

        [Header("비주얼")]
        public Sprite cardSprite;
        public Sprite cardBack;

        public int GetPiValue()
        {
            if (cardType == CardType.Pi)
                return isDoublePi ? 2 : 1;
            return 0;
        }
    }
}
