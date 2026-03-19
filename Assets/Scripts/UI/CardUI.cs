using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DokkaebiHand.Cards;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 개별 카드 UI 컴포넌트
    /// </summary>
    public class CardUI : MonoBehaviour
    {
        [SerializeField] private Image _cardImage;
        [SerializeField] private TextMeshProUGUI _monthText;
        [SerializeField] private TextMeshProUGUI _typeText;
        [SerializeField] private Image _typeIcon;
        [SerializeField] private Image _highlight;
        [SerializeField] private Button _button;

        private CardInstance _cardData;
        private bool _isFaceUp = true;

        public CardInstance CardData => _cardData;
        public Button Button => _button;

        public void Setup(CardInstance card)
        {
            _cardData = card;
            UpdateVisuals();
        }

        public void SetFaceUp(bool faceUp)
        {
            _isFaceUp = faceUp;
            UpdateVisuals();
        }

        public void SetHighlight(bool active, Color color = default)
        {
            if (_highlight != null)
            {
                _highlight.gameObject.SetActive(active);
                if (active && color != default)
                    _highlight.color = color;
            }
        }

        private void UpdateVisuals()
        {
            if (_cardData == null) return;

            if (_isFaceUp)
            {
                if (_monthText != null)
                    _monthText.text = $"{(int)_cardData.Month}월";

                if (_typeText != null)
                {
                    _typeText.text = _cardData.Type switch
                    {
                        CardType.Gwang => "광",
                        CardType.Tti => GetRibbonLabel(),
                        CardType.Yeolkkeut => "열끗",
                        CardType.Pi => _cardData.IsDoublePi ? "쌍피" : "피",
                        _ => ""
                    };
                }

                if (_typeIcon != null)
                {
                    _typeIcon.color = _cardData.Type switch
                    {
                        CardType.Gwang => new Color(1f, 0.84f, 0f),    // Gold
                        CardType.Tti => new Color(0.8f, 0.2f, 0.2f),   // Red
                        CardType.Yeolkkeut => new Color(0.2f, 0.6f, 0.8f), // Blue
                        CardType.Pi => new Color(0.5f, 0.5f, 0.5f),    // Gray
                        _ => Color.white
                    };
                }
            }
            else
            {
                // 뒷면
                if (_monthText != null) _monthText.text = "?";
                if (_typeText != null) _typeText.text = "";
            }
        }

        private string GetRibbonLabel()
        {
            return _cardData.Ribbon switch
            {
                RibbonType.HongDan => "홍단",
                RibbonType.CheongDan => "청단",
                RibbonType.ChoDan => "초단",
                _ => "띠"
            };
        }
    }
}
