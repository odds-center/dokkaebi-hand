# 배경 01 — 메인 메뉴: 삼도천 (三途川)

## 장면 설명
삼도천 강가. 게임의 첫 인상. 안개 낀 강, 낡은 나무배, 떠다니는 도깨비불.
**느낌: 쓸쓸하지만 신비롭다. 무섭지 않고 아련하다.**

## 색감 지시
- 주조: 먹빛 남색 (#1A1A2E) — 하늘, 물
- 강조: 도깨비불 청색 (#00D4FF) — 물 위의 불꽃들
- 보조: 먹물 회색 (#2D2D44) — 산, 안개
- 포인트: 희미한 보라 — 먼 수평선

---

## 프롬프트 A (안개 강조)
**Seed:** 90001

```
(misty river at night:1.4), (thick fog hovering over still dark water:1.3),
ancient korean underworld river crossing,
(floating blue ghost flames:1.3) scattered across the water surface,
(old weathered wooden boat:1.2) silhouette resting on the river,
distant dark mountain ridges barely visible through mist,
ink wash atmosphere with wet brush strokes,
(dark navy sky:1.2) fading into black at top,
(cyan light reflections:1.1) on calm water from ghost fires,
thin layer of low-hanging fog creating depth,
dead reeds along riverbank in foreground,
somber tranquil mood, no wind, absolute stillness,
color palette: dark navy, ink gray, cyan blue accents
```

## 프롬프트 B (배 강조)
**Seed:** 90002

```
(ancient ferry boat on dark river:1.4), (korean underworld Sanzu River:1.2),
lone wooden boat with worn oar resting across it,
dark still water reflecting faint blue ghost lights,
(dokkaebi fire:1.3) floating in pairs across the misty river,
(heavy mist:1.2) rolling in from distant mountains,
ink painting composition with strong horizontal layers,
sky layer: deep navy (#1A1A2E) with faint stars,
mist layer: gray-blue fog obscuring the horizon,
water layer: dark mirror reflecting ghost lights,
foreground: rocky riverbank with dead grass,
atmosphere of waiting, a passage that must be crossed,
color palette: dark navy, steel gray, cyan (#00D4FF) points
```

## 프롬프트 C (도깨비불 강조)
**Seed:** 90003

```
(dozens of floating ghost fires:1.4) over a dark korean river at night,
(supernatural blue-green flames:1.3) hovering at different heights,
each flame casting (faint cyan glow:1.2) on the misty water below,
wide river stretching into darkness on both sides,
ancient stone steps leading down to water's edge in foreground,
fog so thick the far bank is invisible,
ink wash sky blending with water at the horizon,
(ethereal otherworldly atmosphere:1.3),
the fires are the only light source in complete darkness,
cold blue and dark navy color scheme,
feeling of souls wandering along the river,
color palette: pure black, dark navy, cyan (#00D4FF), teal
```

---

## 사용 팁
- 3가지 프롬프트를 모두 돌려보고 분위기가 가장 맞는 것 선택
- 메인 메뉴는 게임의 첫인상이므로 **가장 많은 시간을 투자**할 것
- 안개량은 CFG를 낮추면(5~6) 더 몽환적, 높이면(8~9) 더 선명
- 도깨비불 개수가 너무 많으면 negative에 `too many lights` 추가
