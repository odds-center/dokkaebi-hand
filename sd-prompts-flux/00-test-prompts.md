# 테스트 프롬프트 — FLUX Dev (LoRA 없음)

> **모델:** `black-forest-labs/flux-dev`
> LoRA 없이 순수 FLUX Dev 사용

## 권장 설정

```json
{
  "prompt": "[프롬프트]",
  "go_fast": false,
  "guidance": 7,
  "megapixels": "1",
  "num_outputs": 4,
  "aspect_ratio": "1:1",
  "output_format": "png",
  "output_quality": 100,
  "num_inference_steps": 50
}
```

---

## 테스트 A — 먹보 도깨비 (검정 배경)

```
Simple 16-bit pixel art game boss sprite, low resolution retro style, limited color palette max 16 colors, Korean dokkaebi folklore demon, large round gluttonous body, massive protruding belly, stubby thick limbs, reddish-orange skin, short broken horns, enormous wide mouth with big uneven teeth, small greedy eyes, tattered dark loincloth, food stains on body, arms akimbo confident laughing pose, menacing yet comedic, solid black background, clean pixel grid, no anti-aliasing, no gradients, no text, no watermark, inspired by Binding of Isaac and Shovel Knight pixel art style
```

## 테스트 B — 먹보 도깨비 (녹색 크로마키)

```
Simple 16-bit pixel art game boss sprite, low resolution retro style, limited color palette max 16 colors, Korean dokkaebi folklore demon, large round gluttonous body, massive protruding belly, stubby thick limbs, reddish-orange skin, short broken horns, enormous wide mouth with big uneven teeth, small greedy eyes, tattered dark loincloth, food stains on body, arms akimbo confident laughing pose, menacing yet comedic, solid pure green chroma key background, clean pixel grid, no anti-aliasing, no gradients, no text, no watermark, inspired by Binding of Isaac and Shovel Knight pixel art style
```

## 테스트 C — 장난꾸러기 도깨비 (검정 배경)

```
Simple 16-bit pixel art game boss sprite, low resolution retro style, limited color palette max 16 colors, Korean dokkaebi folklore demon, lean mischievous prankster, wiry thin body, exaggerated long arms, blue-gray skin, sly wide grin, two curved horns, large pointed ears, ragged dark vest, asymmetric eyes, holding wooden club behind back, crouching ready-to-pounce, playful but unsettling, solid black background, clean pixel grid, no anti-aliasing, no gradients, no text, no watermark, inspired by Binding of Isaac and Shovel Knight pixel art style
```

## 테스트 D — 부적 아이콘 (검정 배경)

```
Simple 16-bit pixel art game item icon, low resolution retro style, limited color palette max 8 colors, single item centered, Korean talisman bujeok charm, yellow paper with red mystical symbol, glowing supernatural aura, solid black background, clean pixel grid, no anti-aliasing, no gradients, no text, no watermark, inspired by Binding of Isaac item icon style
```

## 테스트 E — 화투 1월 송학 카드 (검정 배경, 2:3)

```
Simple 16-bit pixel art hwatu flower card illustration, low resolution retro style, limited color palette max 12 colors, traditional Korean card art, red-crowned crane standing on gnarled pine tree, pure white body, black tail feathers, red patch on head, dark pine trunk, green pine needles, red sun circle, solid black background, clean pixel grid, no anti-aliasing, no gradients, no text, no watermark, inspired by retro game card art style
```

---

> **A와 B를 비교**해서 배경색 결정 후 전체 프롬프트에 적용.
> **C, D, E**는 다른 에셋 타입이 동일 스타일로 나오는지 확인용.
