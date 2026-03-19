namespace DokkaebiHand.Cards
{
    /// <summary>
    /// 게임 내에서 사용되는 카드 인스턴스.
    /// ScriptableObject 참조 또는 데이터베이스 정의를 래핑.
    /// </summary>
    public class CardInstance
    {
        public int Id { get; private set; }
        public string Name { get; private set; }
        public string NameKR { get; private set; }
        public CardMonth Month { get; private set; }
        public CardType Type { get; private set; }
        public RibbonType Ribbon { get; private set; }
        public int BasePoints { get; private set; }
        public bool IsRainGwang { get; private set; }
        public bool IsDoublePi { get; private set; }

        public CardInstance(int id, HwaTuCardDatabase.CardDefinition def)
        {
            Id = id;
            Name = def.Name;
            NameKR = def.NameKR;
            Month = def.Month;
            Type = def.Type;
            Ribbon = def.Ribbon;
            BasePoints = def.BasePoints;
            IsRainGwang = def.IsRainGwang;
            IsDoublePi = def.IsDoublePi;
        }

        public int GetPiValue()
        {
            if (Type == CardType.Pi)
                return IsDoublePi ? 2 : 1;
            return 0;
        }

        public override string ToString()
        {
            return $"[{Id}] {NameKR} ({Month}월 {Type})";
        }
    }
}
