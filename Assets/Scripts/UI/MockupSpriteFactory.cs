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
        /// 카드 앞면 텍스처 생성 — 화투패 스타일
        /// </summary>
        public static Texture2D CreateCardFace(CardMonth month, CardType type, RibbonType ribbon = RibbonType.None)
        {
            var tex = new Texture2D(CardWidth, CardHeight);
            tex.filterMode = FilterMode.Point;

            // 배경 (한지색 + 월별 색조)
            Color baseBg = new Color(0.96f, 0.91f, 0.8f);
            Color monthTint = GetMonthTint(month);
            Color bg = Color.Lerp(baseBg, monthTint, 0.08f);
            FillRect(tex, 0, 0, CardWidth, CardHeight, bg);

            // 둥근 테두리
            Color border = GetTypeColor(type, ribbon);
            DrawRoundedBorder(tex, border, 3, 6);

            // 상단 바 (월 표시 영역) — 둥근 상단
            Color headerColor = Color.Lerp(border, Color.black, 0.2f);
            FillRect(tex, 3, CardHeight - 22, CardWidth - 6, 19, headerColor);

            // 월별 식물/심볼 그리기 (중앙)
            DrawMonthSymbol(tex, month, type, border, bg);

            // 타입 심볼 (광/띠/열끗/피 마크)
            DrawTypeSymbol(tex, type, ribbon, border);

            // 하단 등급 바
            Color footerColor = Color.Lerp(bg, border, 0.15f);
            FillRect(tex, 3, 3, CardWidth - 6, 16, footerColor);

            // 광 카드 특수 효과 (금빛 광채)
            if (type == CardType.Gwang)
                DrawGwangGlow(tex);

            tex.Apply();
            return tex;
        }

        /// <summary>월별 색조</summary>
        private static Color GetMonthTint(CardMonth month)
        {
            return month switch
            {
                CardMonth.January => new Color(0.2f, 0.5f, 0.2f),   // 소나무 녹색
                CardMonth.February => new Color(0.9f, 0.3f, 0.4f),  // 매화 분홍
                CardMonth.March => new Color(0.9f, 0.2f, 0.3f),     // 벚꽃/피안화 홍
                CardMonth.April => new Color(0.1f, 0.1f, 0.1f),     // 흑등 검정
                CardMonth.May => new Color(0.3f, 0.6f, 0.3f),       // 난초 녹색
                CardMonth.June => new Color(0.8f, 0.2f, 0.5f),      // 모란 자홍
                CardMonth.July => new Color(0.7f, 0.3f, 0.1f),      // 홍싸리 갈색
                CardMonth.August => new Color(0.6f, 0.6f, 0.3f),    // 억새 황색
                CardMonth.September => new Color(0.7f, 0.5f, 0.1f), // 국화 금색
                CardMonth.October => new Color(0.8f, 0.2f, 0.1f),   // 단풍 빨강
                CardMonth.November => new Color(0.4f, 0.3f, 0.6f),  // 오동 보라
                CardMonth.December => new Color(0.1f, 0.1f, 0.3f),  // 비 남색
                _ => Color.gray
            };
        }

        /// <summary>월별 식물 심볼 그리기 (픽셀아트)</summary>
        private static void DrawMonthSymbol(Texture2D tex, CardMonth month, CardType type, Color accent, Color bg)
        {
            int cx = CardWidth / 2;
            int cy = CardHeight / 2 + 5;
            Color dark = Color.Lerp(accent, Color.black, 0.4f);
            Color light = Color.Lerp(accent, Color.white, 0.3f);

            switch (month)
            {
                case CardMonth.January: // 소나무
                    // 줄기
                    FillRect(tex, cx - 2, 20, 4, 50, new Color(0.35f, 0.2f, 0.1f));
                    // 잎 (삼각형 형태)
                    DrawDiamond(tex, cx, cy + 20, 18, new Color(0.15f, 0.4f, 0.15f));
                    DrawDiamond(tex, cx, cy + 8, 14, new Color(0.2f, 0.5f, 0.2f));
                    DrawDiamond(tex, cx, cy - 4, 10, new Color(0.25f, 0.55f, 0.25f));
                    break;

                case CardMonth.February: // 매화
                    // 줄기
                    DrawLine(tex, cx - 15, 25, cx + 5, 75, new Color(0.3f, 0.15f, 0.1f), 2);
                    // 꽃 5개
                    DrawFlower(tex, cx - 5, cy + 15, 6, new Color(0.95f, 0.4f, 0.5f));
                    DrawFlower(tex, cx + 8, cy + 5, 5, new Color(0.9f, 0.3f, 0.45f));
                    DrawFlower(tex, cx - 10, cy - 5, 4, new Color(0.85f, 0.35f, 0.5f));
                    DrawFlower(tex, cx + 3, cy - 12, 5, new Color(0.95f, 0.45f, 0.55f));
                    break;

                case CardMonth.March: // 벚꽃/피안화
                    // 줄기
                    DrawLine(tex, cx, 20, cx, 80, new Color(0.3f, 0.15f, 0.1f), 2);
                    DrawLine(tex, cx, 60, cx - 15, 80, new Color(0.3f, 0.15f, 0.1f), 1);
                    DrawLine(tex, cx, 50, cx + 12, 75, new Color(0.3f, 0.15f, 0.1f), 1);
                    // 꽃
                    DrawFlower(tex, cx, cy + 12, 8, new Color(0.95f, 0.5f, 0.6f));
                    DrawFlower(tex, cx - 12, cy + 5, 5, new Color(0.9f, 0.45f, 0.55f));
                    DrawFlower(tex, cx + 10, cy, 6, new Color(0.92f, 0.5f, 0.58f));
                    break;

                case CardMonth.April: // 흑등/덩굴
                    // 덩굴
                    for (int i = 0; i < 6; i++)
                    {
                        int yy = 25 + i * 12;
                        DrawLine(tex, cx - 12 + i * 2, yy, cx + 12 - i * 2, yy + 10, new Color(0.15f, 0.15f, 0.15f), 2);
                    }
                    // 새 실루엣
                    DrawDiamond(tex, cx + 10, cy + 15, 7, new Color(0.1f, 0.1f, 0.1f));
                    FillRect(tex, cx + 6, cy + 18, 4, 2, new Color(0.1f, 0.1f, 0.1f));
                    break;

                case CardMonth.May: // 난초
                    // 잎 (길고 가는 곡선)
                    DrawLine(tex, cx - 5, 20, cx - 20, 85, new Color(0.2f, 0.5f, 0.2f), 2);
                    DrawLine(tex, cx, 20, cx + 5, 85, new Color(0.25f, 0.55f, 0.25f), 2);
                    DrawLine(tex, cx + 5, 25, cx + 18, 80, new Color(0.2f, 0.45f, 0.2f), 2);
                    // 꽃
                    DrawFlower(tex, cx - 15, cy + 15, 5, new Color(0.6f, 0.4f, 0.7f));
                    break;

                case CardMonth.June: // 모란
                    // 큰 꽃
                    DrawFlower(tex, cx, cy + 5, 14, new Color(0.85f, 0.15f, 0.4f));
                    DrawFlower(tex, cx, cy + 5, 9, new Color(0.95f, 0.3f, 0.5f));
                    DrawFlower(tex, cx, cy + 5, 5, new Color(1f, 0.5f, 0.6f));
                    // 잎
                    DrawDiamond(tex, cx - 12, cy - 10, 8, new Color(0.2f, 0.5f, 0.2f));
                    DrawDiamond(tex, cx + 12, cy - 8, 7, new Color(0.2f, 0.45f, 0.2f));
                    break;

                case CardMonth.July: // 홍싸리/멧돼지
                    // 싸리 줄기들
                    for (int i = 0; i < 5; i++)
                    {
                        int xx = cx - 12 + i * 6;
                        DrawLine(tex, xx, 22, xx + (i % 2 == 0 ? 3 : -3), 82, new Color(0.5f, 0.3f, 0.1f), 1);
                    }
                    // 작은 잎들
                    for (int i = 0; i < 8; i++)
                    {
                        int xx = cx - 15 + (i % 4) * 10;
                        int yy = 35 + (i / 4) * 25;
                        FillRect(tex, xx, yy, 4, 3, new Color(0.6f, 0.35f, 0.15f));
                    }
                    break;

                case CardMonth.August: // 억새/달
                    // 억새
                    for (int i = 0; i < 7; i++)
                    {
                        int xx = cx - 18 + i * 6;
                        DrawLine(tex, xx, 20, xx + (i - 3), 70, new Color(0.6f, 0.55f, 0.3f), 1);
                    }
                    // 달 (상단 원)
                    if (type == CardType.Gwang)
                        DrawCircle(tex, cx, cy + 22, 12, new Color(1f, 0.85f, 0.3f));
                    else
                        DrawCircle(tex, cx, cy + 22, 8, new Color(0.9f, 0.75f, 0.3f));
                    break;

                case CardMonth.September: // 국화
                    // 국화 꽃
                    DrawFlower(tex, cx, cy + 5, 12, new Color(0.9f, 0.7f, 0.1f));
                    DrawFlower(tex, cx, cy + 5, 7, new Color(1f, 0.8f, 0.2f));
                    DrawCircle(tex, cx, cy + 5, 3, new Color(0.7f, 0.5f, 0f));
                    // 잎
                    DrawDiamond(tex, cx - 14, cy - 12, 6, new Color(0.3f, 0.5f, 0.15f));
                    DrawDiamond(tex, cx + 14, cy - 10, 5, new Color(0.25f, 0.45f, 0.15f));
                    break;

                case CardMonth.October: // 단풍
                    // 단풍잎 (여러 개)
                    DrawDiamond(tex, cx, cy + 10, 12, new Color(0.85f, 0.15f, 0.05f));
                    DrawDiamond(tex, cx - 10, cy, 8, new Color(0.9f, 0.25f, 0.1f));
                    DrawDiamond(tex, cx + 10, cy + 5, 9, new Color(0.8f, 0.2f, 0.05f));
                    DrawDiamond(tex, cx - 5, cy - 8, 6, new Color(0.95f, 0.4f, 0.1f));
                    DrawDiamond(tex, cx + 5, cy + 18, 7, new Color(0.85f, 0.3f, 0.08f));
                    break;

                case CardMonth.November: // 오동
                    // 줄기
                    FillRect(tex, cx - 2, 20, 4, 55, new Color(0.3f, 0.2f, 0.15f));
                    // 큰 잎
                    DrawDiamond(tex, cx, cy + 15, 16, new Color(0.3f, 0.25f, 0.5f));
                    DrawDiamond(tex, cx - 10, cy, 10, new Color(0.35f, 0.3f, 0.55f));
                    DrawDiamond(tex, cx + 10, cy + 5, 10, new Color(0.35f, 0.28f, 0.52f));
                    break;

                case CardMonth.December: // 비
                    // 비 줄기들
                    for (int i = 0; i < 8; i++)
                    {
                        int xx = 8 + i * 9;
                        DrawLine(tex, xx, 25, xx - 4, 90, new Color(0.3f, 0.35f, 0.6f, 0.7f), 1);
                    }
                    // 우산/인물 실루엣
                    DrawDiamond(tex, cx, cy + 10, 12, new Color(0.15f, 0.15f, 0.3f));
                    FillRect(tex, cx - 2, cy - 10, 4, 20, new Color(0.15f, 0.15f, 0.3f));
                    break;
            }

            return;
        }

        /// <summary>타입 심볼 그리기 (좌상단 코너)</summary>
        private static void DrawTypeSymbol(Texture2D tex, CardType type, RibbonType ribbon, Color accent)
        {
            int sx = 8, sy = CardHeight - 36;

            switch (type)
            {
                case CardType.Gwang:
                    // 광 마크 — 빛나는 별
                    DrawCircle(tex, sx + 4, sy, 5, new Color(1f, 0.84f, 0f));
                    FillRect(tex, sx + 2, sy - 7, 5, 2, new Color(1f, 0.9f, 0.3f));
                    FillRect(tex, sx + 2, sy + 6, 5, 2, new Color(1f, 0.9f, 0.3f));
                    break;

                case CardType.Tti:
                    // 띠 마크 — 리본 모양
                    Color ribbonColor = ribbon switch
                    {
                        RibbonType.HongDan => new Color(0.85f, 0.1f, 0.1f),
                        RibbonType.CheongDan => new Color(0.1f, 0.3f, 0.85f),
                        RibbonType.ChoDan => new Color(0.1f, 0.6f, 0.1f),
                        _ => accent
                    };
                    FillRect(tex, sx, sy - 3, 12, 7, ribbonColor);
                    FillRect(tex, sx + 1, sy - 2, 10, 5, Color.Lerp(ribbonColor, Color.white, 0.2f));
                    break;

                case CardType.Yeolkkeut:
                    // 열끗 마크 — 다이아몬드
                    DrawDiamond(tex, sx + 5, sy, 5, new Color(0.3f, 0.55f, 0.8f));
                    break;

                case CardType.Pi:
                    // 피 마크 — 작은 점
                    DrawCircle(tex, sx + 3, sy, 3, new Color(0.5f, 0.5f, 0.5f));
                    break;
            }
        }

        /// <summary>광 카드 금빛 광채 효과</summary>
        private static void DrawGwangGlow(Texture2D tex)
        {
            int cx = CardWidth / 2;
            int cy = CardHeight / 2;
            for (int y = 5; y < CardHeight - 5; y++)
            {
                for (int x = 5; x < CardWidth - 5; x++)
                {
                    float dx = (x - cx) / (float)CardWidth;
                    float dy = (y - cy) / (float)CardHeight;
                    float dist = Mathf.Sqrt(dx * dx + dy * dy);
                    if (dist < 0.35f)
                    {
                        Color existing = tex.GetPixel(x, y);
                        float glow = (0.35f - dist) / 0.35f * 0.15f;
                        tex.SetPixel(x, y, Color.Lerp(existing, new Color(1f, 0.9f, 0.5f), glow));
                    }
                }
            }
        }

        // ============================================================
        // 도형 그리기 유틸리티
        // ============================================================

        private static void DrawCircle(Texture2D tex, int cx, int cy, int radius, Color color)
        {
            for (int y = cy - radius; y <= cy + radius; y++)
            {
                for (int x = cx - radius; x <= cx + radius; x++)
                {
                    if (x < 0 || x >= tex.width || y < 0 || y >= tex.height) continue;
                    float dist = Mathf.Sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
                    if (dist <= radius)
                        tex.SetPixel(x, y, color);
                }
            }
        }

        private static void DrawDiamond(Texture2D tex, int cx, int cy, int size, Color color)
        {
            for (int y = cy - size; y <= cy + size; y++)
            {
                for (int x = cx - size; x <= cx + size; x++)
                {
                    if (x < 0 || x >= tex.width || y < 0 || y >= tex.height) continue;
                    int dx = Mathf.Abs(x - cx);
                    int dy = Mathf.Abs(y - cy);
                    if (dx + dy <= size)
                        tex.SetPixel(x, y, color);
                }
            }
        }

        private static void DrawFlower(Texture2D tex, int cx, int cy, int petalSize, Color color)
        {
            // 5개 꽃잎 (상하좌우 + 중앙)
            DrawCircle(tex, cx, cy - petalSize, petalSize / 2 + 1, color);
            DrawCircle(tex, cx, cy + petalSize, petalSize / 2 + 1, color);
            DrawCircle(tex, cx - petalSize, cy, petalSize / 2 + 1, color);
            DrawCircle(tex, cx + petalSize, cy, petalSize / 2 + 1, color);
            // 중심
            DrawCircle(tex, cx, cy, petalSize / 2, Color.Lerp(color, Color.white, 0.4f));
        }

        private static void DrawLine(Texture2D tex, int x0, int y0, int x1, int y1, Color color, int thickness)
        {
            int dx = Mathf.Abs(x1 - x0);
            int dy = Mathf.Abs(y1 - y0);
            int sx = x0 < x1 ? 1 : -1;
            int sy = y0 < y1 ? 1 : -1;
            int err = dx - dy;

            while (true)
            {
                for (int t = -thickness / 2; t <= thickness / 2; t++)
                {
                    int px = x0 + (dy > dx ? t : 0);
                    int py = y0 + (dy > dx ? 0 : t);
                    if (px >= 0 && px < tex.width && py >= 0 && py < tex.height)
                        tex.SetPixel(px, py, color);
                }

                if (x0 == x1 && y0 == y1) break;
                int e2 = 2 * err;
                if (e2 > -dy) { err -= dy; x0 += sx; }
                if (e2 < dx) { err += dx; y0 += sy; }
            }
        }

        private static void DrawRoundedBorder(Texture2D tex, Color color, int thickness, int radius)
        {
            int w = tex.width, h = tex.height;
            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    // 코너 체크
                    bool inCorner = false;
                    int cornerX = 0, cornerY = 0;

                    if (x < radius && y < radius) { inCorner = true; cornerX = radius; cornerY = radius; }
                    else if (x >= w - radius && y < radius) { inCorner = true; cornerX = w - 1 - radius; cornerY = radius; }
                    else if (x < radius && y >= h - radius) { inCorner = true; cornerX = radius; cornerY = h - 1 - radius; }
                    else if (x >= w - radius && y >= h - radius) { inCorner = true; cornerX = w - 1 - radius; cornerY = h - 1 - radius; }

                    if (inCorner)
                    {
                        float dist = Mathf.Sqrt((x - cornerX) * (x - cornerX) + (y - cornerY) * (y - cornerY));
                        if (dist > radius) continue; // 코너 밖 = 투명
                        if (dist > radius - thickness)
                            tex.SetPixel(x, y, color);
                    }
                    else
                    {
                        // 직선 영역
                        bool onBorder = x < thickness || x >= w - thickness || y < thickness || y >= h - thickness;
                        if (onBorder) tex.SetPixel(x, y, color);
                    }
                }
            }
        }

        /// <summary>
        /// 보스 도깨비 실루엣 (Mock 이미지)
        /// </summary>
        public static Texture2D CreateBossSilhouette()
        {
            int size = 128;
            var tex = new Texture2D(size, size);
            tex.filterMode = FilterMode.Point;
            Color clear = new Color(0, 0, 0, 0);
            Color body = new Color(0.2f, 0.05f, 0.05f);
            Color eye = new Color(1f, 0.2f, 0.1f);
            Color horn = new Color(0.4f, 0.1f, 0.1f);
            Color outline = new Color(0.6f, 0.1f, 0.1f);

            // 투명 배경
            for (int y = 0; y < size; y++)
                for (int x = 0; x < size; x++)
                    tex.SetPixel(x, y, clear);

            int cx = size / 2;

            // 몸통 (큰 원)
            DrawCircle(tex, cx, 45, 35, body);
            DrawCircle(tex, cx, 45, 36, outline); // 테두리만
            DrawCircle(tex, cx, 45, 34, body);    // 다시 채우기

            // 머리 (중간 원)
            DrawCircle(tex, cx, 85, 25, body);
            DrawCircle(tex, cx, 85, 26, outline);
            DrawCircle(tex, cx, 85, 24, body);

            // 뿔 왼쪽
            FillRect(tex, cx - 20, 105, 6, 18, horn);
            FillRect(tex, cx - 22, 118, 4, 8, horn);

            // 뿔 오른쪽
            FillRect(tex, cx + 14, 105, 6, 18, horn);
            FillRect(tex, cx + 18, 118, 4, 8, horn);

            // 눈 (빨간 빛)
            DrawCircle(tex, cx - 10, 88, 4, eye);
            DrawCircle(tex, cx + 10, 88, 4, eye);
            // 눈동자
            DrawCircle(tex, cx - 10, 88, 2, new Color(1f, 0.9f, 0.3f));
            DrawCircle(tex, cx + 10, 88, 2, new Color(1f, 0.9f, 0.3f));

            // 입 (이빨)
            FillRect(tex, cx - 12, 74, 24, 4, new Color(0.1f, 0.02f, 0.02f));
            FillRect(tex, cx - 6, 72, 3, 4, new Color(0.9f, 0.85f, 0.7f)); // 왼쪽 이빨
            FillRect(tex, cx + 3, 72, 3, 4, new Color(0.9f, 0.85f, 0.7f)); // 오른쪽 이빨

            // 팔 (양쪽)
            FillRect(tex, cx - 40, 35, 12, 8, body);
            FillRect(tex, cx + 28, 35, 12, 8, body);

            // 도깨비불 (주변에 떠다니는 불꽃)
            DrawCircle(tex, cx - 45, 100, 5, new Color(0f, 0.7f, 1f, 0.6f));
            DrawCircle(tex, cx + 45, 95, 4, new Color(0f, 0.6f, 0.9f, 0.5f));
            DrawCircle(tex, cx - 35, 60, 3, new Color(0f, 0.5f, 0.8f, 0.4f));

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

        // ============================================================
        // 둥근 사각형 (border-radius) 텍스처 생성
        // ============================================================

        /// <summary>
        /// 둥근 사각형 텍스처 생성 (CSS border-radius 처럼)
        /// 9-slice 스프라이트로 사용하면 어떤 크기에도 적용 가능
        /// </summary>
        public static Texture2D CreateRoundedRect(int w, int h, int radius, Color fillColor,
            int borderWidth = 0, Color? borderColor = null)
        {
            var tex = new Texture2D(w, h);
            tex.filterMode = FilterMode.Bilinear;
            Color border = borderColor ?? fillColor;
            Color clear = new Color(0, 0, 0, 0);

            for (int y = 0; y < h; y++)
            {
                for (int x = 0; x < w; x++)
                {
                    float dist = DistToRoundedRect(x, y, w, h, radius);

                    if (dist <= -borderWidth)
                    {
                        // 내부 채우기
                        tex.SetPixel(x, y, fillColor);
                    }
                    else if (dist <= 0)
                    {
                        // 보더 영역
                        tex.SetPixel(x, y, border);
                    }
                    else if (dist <= 1f)
                    {
                        // 안티앨리어싱 (부드러운 가장자리)
                        float a = 1f - dist;
                        Color edge = borderWidth > 0 ? border : fillColor;
                        tex.SetPixel(x, y, new Color(edge.r, edge.g, edge.b, edge.a * a));
                    }
                    else
                    {
                        tex.SetPixel(x, y, clear);
                    }
                }
            }

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 둥근 사각형 + 그라데이션 배경
        /// </summary>
        public static Texture2D CreateRoundedRectGradient(int w, int h, int radius,
            Color topColor, Color bottomColor, int borderWidth = 0, Color? borderColor = null)
        {
            var tex = new Texture2D(w, h);
            tex.filterMode = FilterMode.Bilinear;
            Color border = borderColor ?? topColor;
            Color clear = new Color(0, 0, 0, 0);

            for (int y = 0; y < h; y++)
            {
                float t = (float)y / h;
                Color fill = Color.Lerp(bottomColor, topColor, t);

                for (int x = 0; x < w; x++)
                {
                    float dist = DistToRoundedRect(x, y, w, h, radius);

                    if (dist <= -borderWidth)
                        tex.SetPixel(x, y, fill);
                    else if (dist <= 0)
                        tex.SetPixel(x, y, border);
                    else if (dist <= 1f)
                    {
                        float a = 1f - dist;
                        Color edge = borderWidth > 0 ? border : fill;
                        tex.SetPixel(x, y, new Color(edge.r, edge.g, edge.b, edge.a * a));
                    }
                    else
                        tex.SetPixel(x, y, clear);
                }
            }

            tex.Apply();
            return tex;
        }

        /// <summary>
        /// 9-slice 스프라이트로 변환 (어떤 크기에도 깨지지 않음)
        /// </summary>
        public static Sprite CreateRoundedSprite(Texture2D tex, int radius)
        {
            int border = radius + 2;
            return Sprite.Create(tex,
                new Rect(0, 0, tex.width, tex.height),
                new Vector2(0.5f, 0.5f), 100f, 0,
                SpriteMeshType.FullRect,
                new Vector4(border, border, border, border));
        }

        // 둥근 사각형까지의 부호 있는 거리 계산
        private static float DistToRoundedRect(int px, int py, int w, int h, int r)
        {
            // 가장 가까운 코너까지의 거리
            float dx = Mathf.Max(Mathf.Max(r - px, px - (w - 1 - r)), 0);
            float dy = Mathf.Max(Mathf.Max(r - py, py - (h - 1 - r)), 0);

            if (dx > 0 && dy > 0)
            {
                // 코너 영역: 원형 거리
                return Mathf.Sqrt(dx * dx + dy * dy) - r;
            }

            // 직선 영역: 가장자리까지 거리
            float edgeDist = Mathf.Min(
                Mathf.Min(px, w - 1 - px),
                Mathf.Min(py, h - 1 - py)
            );
            return -edgeDist;
        }

        // ============================================================
        // 캐시된 UI 스프라이트 (매번 생성 방지)
        // ============================================================

        private static Sprite _panelSprite;
        private static Sprite _buttonSprite;
        private static Sprite _buttonHoverSprite;
        private static Sprite _cardBgSprite;

        /// <summary>패널용 둥근 사각형 (radius 12, 반투명 다크)</summary>
        public static Sprite GetPanelSprite()
        {
            if (_panelSprite == null)
            {
                var tex = CreateRoundedRect(64, 64, 12,
                    new Color(0.08f, 0.08f, 0.16f, 0.92f),
                    2, new Color(0.25f, 0.2f, 0.4f, 0.6f));
                _panelSprite = CreateRoundedSprite(tex, 12);
            }
            return _panelSprite;
        }

        /// <summary>버튼용 둥근 사각형 (radius 8)</summary>
        public static Sprite GetButtonSprite(Color fill, Color? border = null)
        {
            var tex = CreateRoundedRectGradient(64, 32, 8,
                Color.Lerp(fill, Color.white, 0.08f),
                Color.Lerp(fill, Color.black, 0.15f),
                2, border ?? Color.Lerp(fill, Color.white, 0.25f));
            return CreateRoundedSprite(tex, 8);
        }

        /// <summary>기본 버튼 스프라이트 (캐시)</summary>
        public static Sprite GetDefaultButtonSprite()
        {
            if (_buttonSprite == null)
            {
                var fill = new Color(0.15f, 0.15f, 0.28f);
                _buttonSprite = GetButtonSprite(fill);
            }
            return _buttonSprite;
        }

        /// <summary>카드 배경용 둥근 사각형 (radius 6)</summary>
        public static Sprite GetCardBgSprite()
        {
            if (_cardBgSprite == null)
            {
                var tex = CreateRoundedRect(48, 64, 6,
                    new Color(0.96f, 0.91f, 0.8f),
                    2, new Color(0.7f, 0.6f, 0.4f));
                _cardBgSprite = CreateRoundedSprite(tex, 6);
            }
            return _cardBgSprite;
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
