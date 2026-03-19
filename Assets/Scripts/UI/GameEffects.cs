using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 게임 시각 효과 시스템: 임팩트, 전투 모션, 연출
    /// 먹물 스타일 이펙트 + 화면 흔들림 + 카드 애니메이션 + 점수 팝업
    /// </summary>
    public class GameEffects : MonoBehaviour
    {
        private Canvas _canvas;
        private Transform _effectLayer;
        private Image _screenTint;
        private Image _flashOverlay;

        // 흔들림 상태
        private RectTransform _shakeTarget;
        private Vector2 _shakeOriginal;
        private float _shakeTimer;
        private float _shakeIntensity;

        public void Initialize(Canvas canvas)
        {
            _canvas = canvas;

            // 이펙트 레이어 (최상위)
            var layerObj = new GameObject("EffectLayer");
            layerObj.transform.SetParent(canvas.transform, false);
            _effectLayer = layerObj.transform;
            var layerRt = layerObj.AddComponent<RectTransform>();
            layerRt.anchorMin = Vector2.zero;
            layerRt.anchorMax = Vector2.one;
            layerRt.offsetMin = Vector2.zero;
            layerRt.offsetMax = Vector2.zero;

            // 화면 틴트 오버레이
            var tintObj = new GameObject("ScreenTint");
            tintObj.transform.SetParent(_effectLayer, false);
            _screenTint = tintObj.AddComponent<Image>();
            _screenTint.color = Color.clear;
            _screenTint.raycastTarget = false;
            var tintRt = tintObj.GetComponent<RectTransform>();
            tintRt.anchorMin = Vector2.zero;
            tintRt.anchorMax = Vector2.one;
            tintRt.offsetMin = Vector2.zero;
            tintRt.offsetMax = Vector2.zero;

            // 플래시 오버레이
            var flashObj = new GameObject("Flash");
            flashObj.transform.SetParent(_effectLayer, false);
            _flashOverlay = flashObj.AddComponent<Image>();
            _flashOverlay.color = Color.clear;
            _flashOverlay.raycastTarget = false;
            var flashRt = flashObj.GetComponent<RectTransform>();
            flashRt.anchorMin = Vector2.zero;
            flashRt.anchorMax = Vector2.one;
            flashRt.offsetMin = Vector2.zero;
            flashRt.offsetMax = Vector2.zero;
        }

        private void Update()
        {
            UpdateShake();
            UpdateFade();
        }

        // ============================================================
        // 화면 흔들림
        // ============================================================

        public void ScreenShake(float intensity = 5f, float duration = 0.3f)
        {
            if (_canvas == null) return;
            _shakeTarget = _canvas.GetComponent<RectTransform>();
            _shakeOriginal = _shakeTarget.anchoredPosition;
            _shakeIntensity = intensity;
            _shakeTimer = duration;
        }

        private void UpdateShake()
        {
            if (_shakeTimer <= 0 || _shakeTarget == null) return;

            _shakeTimer -= Time.deltaTime;
            float fade = _shakeTimer / 0.3f;
            float x = UnityEngine.Random.Range(-_shakeIntensity, _shakeIntensity) * fade;
            float y = UnityEngine.Random.Range(-_shakeIntensity, _shakeIntensity) * fade;
            _shakeTarget.anchoredPosition = _shakeOriginal + new Vector2(x, y);

            if (_shakeTimer <= 0)
                _shakeTarget.anchoredPosition = _shakeOriginal;
        }

        // ============================================================
        // 화면 플래시
        // ============================================================

        private float _flashTimer;
        private Color _flashColor;

        public void Flash(Color color, float duration = 0.15f)
        {
            if (_flashOverlay == null) return;
            _flashColor = color;
            _flashTimer = duration;
            _flashOverlay.color = new Color(color.r, color.g, color.b, 0.6f);
        }

        private void UpdateFade()
        {
            if (_flashTimer <= 0 || _flashOverlay == null) return;
            _flashTimer -= Time.deltaTime;
            float a = Mathf.Max(0, _flashTimer / 0.15f) * 0.6f;
            _flashOverlay.color = new Color(_flashColor.r, _flashColor.g, _flashColor.b, a);
        }

        // ============================================================
        // 욕망의 저울 틴트
        // ============================================================

        public void SetGreedTint(float redAmount)
        {
            if (_screenTint == null) return;
            _screenTint.color = new Color(1f, 0f, 0f, redAmount * 0.3f);
        }

        public void ClearTint()
        {
            if (_screenTint != null)
                _screenTint.color = Color.clear;
        }

        // ============================================================
        // 점수 팝업 (데미지 숫자 스타일)
        // ============================================================

        public void SpawnScorePopup(string text, Vector2 position, Color color, float scale = 1f)
        {
            if (_effectLayer == null) return;

            var obj = new GameObject("ScorePopup");
            obj.transform.SetParent(_effectLayer, false);

            var tmp = obj.AddComponent<TextMeshProUGUI>();
            tmp.text = text;
            tmp.fontSize = (int)(32 * scale);
            tmp.fontStyle = FontStyles.Bold;
            tmp.color = color;
            tmp.alignment = TextAlignmentOptions.Center;
            tmp.raycastTarget = false;

            var rt = obj.GetComponent<RectTransform>();
            rt.anchoredPosition = position;
            rt.sizeDelta = new Vector2(400, 50);

            StartCoroutine(AnimatePopup(obj, rt, tmp));
        }

        private IEnumerator AnimatePopup(GameObject obj, RectTransform rt, TextMeshProUGUI tmp)
        {
            float elapsed = 0f;
            float duration = 1.2f;
            Vector2 start = rt.anchoredPosition;

            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = elapsed / duration;

                // 위로 떠오르며 페이드아웃
                rt.anchoredPosition = start + new Vector2(0, 80 * t);
                // 처음 0.3초 확대, 이후 축소
                float s = t < 0.25f ? 1f + t * 2f : 1.5f - (t - 0.25f) * 0.5f;
                rt.localScale = Vector3.one * s;
                tmp.color = new Color(tmp.color.r, tmp.color.g, tmp.color.b, 1f - t);

                yield return null;
            }

            Destroy(obj);
        }

        // ============================================================
        // 카드 매칭 이펙트
        // ============================================================

        public void PlayMatchEffect(Vector2 position, bool isSweep = false)
        {
            // 매칭 성공: 노란 플래시 + 작은 흔들림
            Flash(isSweep ? new Color(1f, 0.5f, 0f) : new Color(1f, 1f, 0.5f), 0.1f);
            if (isSweep)
                ScreenShake(8f, 0.3f);
            else
                ScreenShake(3f, 0.15f);

            string text = isSweep ? "쓸!" : "매칭!";
            Color col = isSweep ? new Color(1f, 0.6f, 0f) : new Color(0.2f, 1f, 0.4f);
            SpawnScorePopup(text, position, col, isSweep ? 1.5f : 1f);
        }

        /// <summary>
        /// 족보 완성 이펙트 (먹물 느낌)
        /// </summary>
        public void PlayYokboEffect(string yokboName, Vector2 position)
        {
            Flash(new Color(1f, 0.84f, 0f), 0.2f);
            ScreenShake(6f, 0.25f);
            SpawnScorePopup(yokboName, position + new Vector2(0, 40), new Color(1f, 0.84f, 0f), 1.8f);

            // 먹물 번짐 효과 (간소화: 큰 검은 팝업 → 페이드)
            SpawnInkBloom(position);
        }

        private void SpawnInkBloom(Vector2 position)
        {
            var obj = new GameObject("InkBloom");
            obj.transform.SetParent(_effectLayer, false);
            var img = obj.AddComponent<Image>();
            img.color = new Color(0, 0, 0, 0.4f);
            img.raycastTarget = false;

            var rt = obj.GetComponent<RectTransform>();
            rt.anchoredPosition = position;
            rt.sizeDelta = new Vector2(50, 50);

            StartCoroutine(AnimateInkBloom(obj, rt, img));
        }

        private IEnumerator AnimateInkBloom(GameObject obj, RectTransform rt, Image img)
        {
            float elapsed = 0f;
            float duration = 0.8f;

            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = elapsed / duration;

                // 빠르게 퍼지고 서서히 사라짐
                float size = 50 + 600 * Mathf.Sqrt(t);
                rt.sizeDelta = new Vector2(size, size);
                img.color = new Color(0, 0, 0, 0.4f * (1f - t));

                yield return null;
            }

            Destroy(obj);
        }

        // ============================================================
        // Go/Stop 연출
        // ============================================================

        /// <summary>
        /// Go 선택 임팩트
        /// </summary>
        public void PlayGoEffect(int goCount, Vector2 position)
        {
            Color col;
            float shakeAmt;
            float scale;

            switch (goCount)
            {
                case 1:
                    col = new Color(1f, 0.6f, 0.2f);
                    shakeAmt = 4f;
                    scale = 1.2f;
                    break;
                case 2:
                    col = new Color(1f, 0.3f, 0.1f);
                    shakeAmt = 8f;
                    scale = 1.6f;
                    break;
                default: // 3+ Go
                    col = new Color(1f, 0f, 0f);
                    shakeAmt = 15f;
                    scale = 2.5f;
                    break;
            }

            Flash(col, goCount >= 3 ? 0.5f : 0.2f);
            ScreenShake(shakeAmt, goCount >= 3 ? 0.6f : 0.3f);
            SpawnScorePopup($"Go ×{goCount}!", position, col, scale);
        }

        /// <summary>
        /// Stop 확정 이펙트
        /// </summary>
        public void PlayStopEffect(int finalScore, Vector2 position)
        {
            Flash(new Color(0.3f, 0.5f, 1f), 0.15f);
            ScreenShake(3f, 0.15f);
            SpawnScorePopup($"{finalScore}", position, Color.white, 2f);
        }

        // ============================================================
        // 보스 등장 연출
        // ============================================================

        public void PlayBossEntrance(string bossName, Vector2 position)
        {
            Flash(new Color(0.5f, 0f, 0f), 0.3f);
            ScreenShake(10f, 0.5f);
            SpawnScorePopup(bossName, position, new Color(1f, 0.3f, 0.3f), 2.2f);
        }

        /// <summary>
        /// 보스 기믹 발동 이펙트
        /// </summary>
        public void PlayBossGimmickEffect(Vector2 position)
        {
            Flash(new Color(0.8f, 0f, 0.3f), 0.2f);
            ScreenShake(6f, 0.3f);
            SpawnScorePopup("기믹!", position, new Color(1f, 0.2f, 0.5f), 1.4f);
        }

        /// <summary>
        /// 보스 격파 이펙트
        /// </summary>
        public void PlayBossDefeatEffect(string bossName, Vector2 position)
        {
            Flash(new Color(1f, 0.84f, 0f), 0.4f);
            ScreenShake(12f, 0.5f);
            SpawnScorePopup($"{bossName} 격파!", position, new Color(1f, 0.84f, 0f), 2.5f);
            SpawnInkBloom(position);
        }

        // ============================================================
        // 카드 강화 이펙트
        // ============================================================

        public void PlayEnhanceEffect(Vector2 position, string tierName)
        {
            Flash(new Color(0.8f, 0.6f, 0f), 0.2f);
            ScreenShake(4f, 0.2f);
            SpawnScorePopup($"강화! → {tierName}", position, new Color(1f, 0.84f, 0f), 1.4f);
        }

        // ============================================================
        // 부적 발동 이펙트
        // ============================================================

        public void PlayTalismanEffect(string talismanName, Vector2 position)
        {
            SpawnScorePopup(talismanName, position, new Color(0.5f, 1f, 0.8f), 1f);
        }

        // ============================================================
        // 피격/사망 이펙트
        // ============================================================

        public void PlayDamageEffect()
        {
            Flash(new Color(1f, 0f, 0f), 0.3f);
            ScreenShake(10f, 0.4f);
        }

        public void PlayDeathEffect()
        {
            Flash(Color.black, 0.8f);
            ScreenShake(15f, 0.8f);
        }

        // ============================================================
        // 3 Go 특수 연출 (7초 시퀀스)
        // ============================================================

        public void PlayTripleGoSequence(Action onComplete)
        {
            StartCoroutine(TripleGoSequenceCoroutine(onComplete));
        }

        private IEnumerator TripleGoSequenceCoroutine(Action onComplete)
        {
            // Phase 1: 정적 (0.0~0.5초) — 화면 회색조, 심장 소리
            _screenTint.color = new Color(0, 0, 0, 0.5f);
            yield return new WaitForSeconds(0.5f);

            // Phase 2: 충격파 (0.5~1.0초) — 빨간 플래시
            Flash(new Color(1f, 0f, 0f), 0.3f);
            ScreenShake(15f, 0.5f);
            _screenTint.color = new Color(1f, 0f, 0f, 0.3f);
            yield return new WaitForSeconds(0.5f);

            // Phase 3: 완전 정적 (1.0~1.5초)
            _screenTint.color = Color.clear;
            yield return new WaitForSeconds(0.5f);

            // Phase 4: 폭발 (1.5~3.0초) — 먹물 폭풍 + 골든 번호
            Flash(new Color(1f, 0.84f, 0f), 0.5f);
            ScreenShake(20f, 1f);
            SpawnInkBloom(Vector2.zero);
            SpawnScorePopup("×10!", new Vector2(0, 50), new Color(1f, 0f, 0f), 3f);
            yield return new WaitForSeconds(1.5f);

            // Phase 5: 결과 (3.0~5.0초)
            ClearTint();
            yield return new WaitForSeconds(2f);

            onComplete?.Invoke();
        }
    }
}
