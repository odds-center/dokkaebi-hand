using UnityEngine;
using DokkaebiHand.Cards;

namespace DokkaebiHand.UI
{
    /// <summary>
    /// 목업용 스프라이트/텍스처를 프로그래매틱으로 생성.
    /// 실제 아트 에셋 없이 프로토타입 가능.
    /// </summary>
    public static class MockupSpriteFactory
    {
        // 카드 크기
        public const int CardWidth = 80;
        public const int CardHeight = 120;

        // 카드 타입별 색상
        private static readonly Color GwangColor = new Color(1f, 0.84f, 0f);       // 금색
        private static readonly Color HongDanColor = new Color(0.85f, 0.15f, 0.15f);// 홍단 빨강
        private static readonly Color CheongDanColor = new Color(0.15f, 0.4f, 0.85f);// 청단 파랑
        private static readonly Color ChoDanColor = new Color(0.2f, 0.7f, 0.2f);   // 초단 초록
        private static readonly Color YeolkkeutColor = new Color(0.3f, 0.55f, 0.8f);// 열끗 하늘
        private static readonly Color PiColor = new Color(0.55f, 0.55f, 0.55f);     // 피 회색
        private static readonly Color CardBackColor = new Color(0.12f, 0.12f, 0.22f);// 뒷면 짙은남
        private static readonly Color TableColor = new Color(0.35f, 0.08f, 0.08f);  // 테이블 붉은색

        /// <summary>
        /// 카드 앞면 텍스처 생성
        /// </summary>
        public static Texture2D CreateCardFace(CardMonth month, CardType type, RibbonType ribbon = RibbonType.None)
        {
            var tex = new Texture2D(CardWidth, CardHeight);
            tex.filterMode = FilterMode.Point;

            // 배경 (한지색)
            Color bg = new Color(0.96f, 0.91f, 0.8f);
            FillRect(tex, 0, 0, CardWidth, CardHeight, bg);

            // 테두리 (타입별)
            Color border = GetTypeColor(type, ribbon);
            DrawBorder(tex, border, 3);

            // 상단 바 (월 표시 영역)
            FillRect(tex, 3, CardHeight - 25, CardWidth - 6, 22, border);

            // 중앙 심볼 영역 (타입 표시)
            Color symbolBg = Color.Lerp(bg, border, 0.15f);
            FillRect(tex, 10, 30, CardWidth - 20, 55, symbolBg);

            // 타입 마크 (중앙 사각형)
            int markSize = 20;
            int cx = CardWidth / 2 - markSize / 2;
            int cy = 45;
            FillRect(tex, cx, cy, markSize, markSize, border);

            // 강화 등급 표시 영역 (하단)
            FillRect(tex, 3, 3, CardWidth - 6, 22, Color.Lerp(bg, Color.white, 0.3f));

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 카드 뒷면 텍스처
        /// </summary>
        public static Texture2D CreateCardBack()
        {
            var tex = new Texture2D(CardWidth, CardHeight);
            tex.filterMode = FilterMode.Point;

            FillRect(tex, 0, 0, CardWidth, CardHeight, CardBackColor);
            DrawBorder(tex, new Color(0.3f, 0.3f, 0.5f), 3);

            // 중앙 문양 (도깨비불)
            Color ghostFire = new Color(0f, 0.7f, 1f, 0.8f);
            int size = 24;
            FillRect(tex, CardWidth / 2 - size / 2, CardHeight / 2 - size / 2, size, size, ghostFire);

            // 대각선 패턴
            for (int i = 0; i < CardWidth; i += 8)
            {
                for (int j = 0; j < CardHeight; j += 8)
                {
                    if ((i + j) % 16 == 0)
                        tex.SetPixel(i, j, new Color(0.2f, 0.2f, 0.35f));
                }
            }

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 부적 아이콘 텍스처
        /// </summary>
        public static Texture2D CreateTalismanIcon(Talismans.TalismanRarity rarity)
        {
            int size = 48;
            var tex = new Texture2D(size, size);
            tex.filterMode = FilterMode.Point;

            Color bg = rarity switch
            {
                Talismans.TalismanRarity.Common => new Color(0.6f, 0.6f, 0.6f),
                Talismans.TalismanRarity.Rare => new Color(0.3f, 0.5f, 0.9f),
                Talismans.TalismanRarity.Legendary => new Color(1f, 0.75f, 0f),
                Talismans.TalismanRarity.Cursed => new Color(0.5f, 0f, 0.5f),
                _ => Color.white
            };

            FillRect(tex, 0, 0, size, size, bg);
            DrawBorder(tex, Color.Lerp(bg, Color.white, 0.4f), 2);

            // 부적 문양 (중앙 마름모)
            int half = size / 2;
            for (int y = 0; y < size; y++)
            {
                for (int x = 0; x < size; x++)
                {
                    int dx = Mathf.Abs(x - half);
                    int dy = Mathf.Abs(y - half);
                    if (dx + dy < half / 2)
                        tex.SetPixel(x, y, Color.Lerp(bg, Color.white, 0.6f));
                }
            }

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 테이블(배경) 텍스처
        /// </summary>
        public static Texture2D CreateTableTexture(int width = 512, int height = 512)
        {
            var tex = new Texture2D(width, height);
            tex.filterMode = FilterMode.Bilinear;

            for (int y = 0; y < height; y++)
            {
                for (int x = 0; x < width; x++)
                {
                    // 약간의 노이즈로 천 질감 흉내
                    float noise = Mathf.PerlinNoise(x * 0.05f, y * 0.05f) * 0.08f;
                    Color c = TableColor + new Color(noise, noise * 0.3f, noise * 0.1f);
                    tex.SetPixel(x, y, c);
                }
            }

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 보스 파츠 오버레이 텍스처 (간단한 색 사각형)
        /// </summary>
        public static Texture2D CreatePartsOverlay(Combat.PartsSlot slot)
        {
            int size = 24;
            var tex = new Texture2D(size, size);
            tex.filterMode = FilterMode.Point;

            Color c = slot switch
            {
                Combat.PartsSlot.Head => new Color(1f, 0.3f, 0.3f),
                Combat.PartsSlot.Arm => new Color(0.3f, 1f, 0.3f),
                Combat.PartsSlot.Body => new Color(0.3f, 0.3f, 1f),
                _ => Color.white
            };

            FillRect(tex, 0, 0, size, size, c);
            tex.Apply();
            return tex;
        }

        public static Sprite TextureToSprite(Texture2D tex)
        {
            return Sprite.Create(tex,
                new Rect(0, 0, tex.width, tex.height),
                new Vector2(0.5f, 0.5f), 100f);
        }

        private static Color GetTypeColor(CardType type, RibbonType ribbon)
        {
            if (type == CardType.Tti)
            {
                return ribbon switch
                {
                    RibbonType.HongDan => HongDanColor,
                    RibbonType.CheongDan => CheongDanColor,
                    RibbonType.ChoDan => ChoDanColor,
                    _ => HongDanColor
                };
            }

            return type switch
            {
                CardType.Gwang => GwangColor,
                CardType.Yeolkkeut => YeolkkeutColor,
                CardType.Pi => PiColor,
                _ => Color.white
            };
        }

        private static void FillRect(Texture2D tex, int x, int y, int w, int h, Color color)
        {
            for (int py = y; py < y + h && py < tex.height; py++)
                for (int px = x; px < x + w && px < tex.width; px++)
                    tex.SetPixel(px, py, color);
        }

        private static void DrawBorder(Texture2D tex, Color color, int thickness)
        {
            int w = tex.width, h = tex.height;
            for (int t = 0; t < thickness; t++)
            {
                for (int x = 0; x < w; x++)
                {
                    tex.SetPixel(x, t, color);
                    tex.SetPixel(x, h - 1 - t, color);
                }
                for (int y = 0; y < h; y++)
                {
                    tex.SetPixel(t, y, color);
                    tex.SetPixel(w - 1 - t, y, color);
                }
            }
        }
    }
}
