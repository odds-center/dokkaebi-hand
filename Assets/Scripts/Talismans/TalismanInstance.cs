namespace DokkaebiHand.Talismans
{
    /// <summary>
    /// 런타임 부적 인스턴스
    /// </summary>
    public class TalismanInstance
    {
        public TalismanData Data { get; private set; }
        public bool IsActive { get; set; } = true;

        public TalismanInstance(TalismanData data)
        {
            Data = data;
            IsActive = true;
        }
    }

    /// <summary>
    /// ScriptableObject 없이 동작하는 부적 데이터
    /// </summary>
    public class TalismanData
    {
        public string Name;
        public string NameKR;
        public TalismanRarity Rarity;
        public string Description;
        public string DescriptionKR;
        public TalismanTrigger Trigger;
        public string TriggerCondition;
        public TalismanEffectType EffectType;
        public float EffectValue;
        public float SecondaryMultBonus;  // 추가 배수 보너스 (칩+배수 동시 효과용)
        public float TriggerChance;
        public bool IsCurse;
    }
}
