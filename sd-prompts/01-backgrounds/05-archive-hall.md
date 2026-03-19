# 배경 05 — 4영역: 명부전 (冥府殿) / 문서전각

## 출력 크기
- **최종 크기: 1920x1080px (전체 화면 배경)**
- 사용 화면: 4영역 전투 배경
- UI 오버레이: 하단 손패 영역(950x160), 상단 보스 HP 바(600x30), 점수 패널(400x80)

## 장면 설명
거대한 서고. 천장까지 쌓인 두루마리와 책. 촛불만이 유일한 빛.
**느낌: 조용하고 경외스럽다. 모든 죽은 자의 기록이 여기 있다.**

## 색감 지시
- 주조: 어두운 갈색/먹색 — 나무, 그림자
- 강조: 따뜻한 금색 — 촛불 빛
- 보조: 한지 베이지 (#F5E6CA) — 두루마리, 책
- 포인트: 먹빛 (#1A1A2E) — 천장으로 갈수록 어둠

---

## 프롬프트 A (거대 서고 정면)
**Seed:** 90041

```
(enormous ancient library hall:1.4), korean underworld records archive,
(towering wooden bookshelves:1.3) reaching up into darkness above,
hundreds of (rolled scrolls:1.2) filling every shelf,
old leather-bound books stacked in precarious piles,
(warm candlelight:1.3) from dozens of candles on reading tables,
candle flames creating pools of golden warm light,
(dust particles floating:1.2) visible in the candle beams,
long dramatic shadows stretching across wooden floor,
a single large reading desk in center with open scroll,
dark upper area fading into complete blackness above shelves,
wooden ladders leaning against tall shelves,
the smell of old paper captured in visual atmosphere,
(silent reverent atmosphere:1.2) like a temple of knowledge,
color palette: dark wood brown, candlelight gold, parchment beige (#F5E6CA), deep black
```

## 프롬프트 B (복도 시점)
**Seed:** 90042

```
(long corridor between massive scroll shelves:1.4),
narrow passage with shelves towering on both sides,
(scrolls and books:1.2) packed floor to ceiling,
some scrolls protruding slightly creating irregular wall texture,
single line of candles on low wooden rail along the corridor,
(warm golden light:1.2) creating a path of illumination,
darkness closing in from above and from the far end,
wooden floor with centuries of wear patterns,
occasional scroll lying on the ground as if dropped long ago,
cobwebs in the upper corners connecting shelf to shelf,
perspective lines drawing the eye deep into the corridor,
(dusty ancient atmosphere:1.2) undisturbed for centuries,
this place holds every dead soul's story,
color palette: aged wood, candle gold, shadow black, dust gray, parchment cream
```

---

## 사용 팁
- 촛불의 따뜻함 vs 어둠의 깊이가 핵심 대비
- 두루마리/책의 반복 패턴은 SD가 매우 잘 생성함
- 먼지 입자는 `particles` 토큰이 잘 먹힘
- CFG 7 유지 — 낮추면 책이 뭉개지고, 높이면 인공적으로 보임
