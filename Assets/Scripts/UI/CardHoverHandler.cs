using UnityEngine;
using UnityEngine.EventSystems;
using DokkaebiHand.Cards;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 카드 마우스 호버: 위로 살짝 올림 + 툴팁.
    /// 스케일 변경 안 함 (HorizontalLayoutGroup 레이아웃 깨짐 방지).
    /// SetAsLastSibling 안 함 (카드 순서 변경 → 연쇄 재배치 방지).
    /// </summary>
    public class CardHoverHandler : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
    {
        private CardInstance _card;
        private MockupGameView _view;
        private bool _initialized;
        private bool _isHovered;

        public void Initialize(CardInstance card, MockupGameView view)
        {
            _card = card;
            _view = view;
            _initialized = true;
        }

        public void OnPointerEnter(PointerEventData eventData)
        {
            if (!_initialized || _isHovered) return;
            _isHovered = true;

            // 위치만 위로 올림 (LayoutGroup의 padding 밖으로)
            var rt = GetComponent<RectTransform>();
            rt.anchoredPosition += new Vector2(0, 18);

            // 툴팁
            _view.ShowCardTooltip(_card, (Vector2)rt.position);
        }

        public void OnPointerExit(PointerEventData eventData)
        {
            if (!_initialized || !_isHovered) return;
            _isHovered = false;

            var rt = GetComponent<RectTransform>();
            rt.anchoredPosition -= new Vector2(0, 18);

            _view.HideCardTooltip();
        }

        private void OnDisable()
        {
            if (_isHovered)
            {
                var rt = GetComponent<RectTransform>();
                if (rt != null) rt.anchoredPosition -= new Vector2(0, 18);
                _isHovered = false;
            }
            if (_initialized && _view != null)
                _view.HideCardTooltip();
        }
    }
}
