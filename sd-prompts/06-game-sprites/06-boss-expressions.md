# 보스 표정 & 상태 변형 (14보스 × 6종 = 84종)

> HP 단계별 상태 변화 + 피격 리액션 + 기믹 발동 특수 표정.
> 기본 스프라이트(01-bosses.md)를 기반으로 **표정과 몸 상태가 다른 변형**을 생성.

## 표정 시스템

| 상태 | 트리거 | 설명 |
|------|--------|------|
| `idle` | HP 100~51% | 기본. 여유 있는 상태. 01-bosses.md 기본 스프라이트와 동일 |
| `hit` | 피격 순간 | 데미지 받는 순간의 짧은 리액션. 0.3초간 표시 후 현재 상태로 복귀 |
| `wounded` | HP 50~21% | 부상. 몸에 손상 흔적, 표정 변화. 여유가 사라짐 |
| `critical` | HP 20~1% | 위기. 심하게 부서짐/약해짐. 필사적이거나 분노 |
| `defeat` | HP 0 | 패배. 쓰러지거나 소멸하는 모습 |
| `gimmick` | 기믹 발동 시 | 고유 기믹을 사용할 때의 특수 포즈/표정 |

## 생성 환경

```yaml
Model: Pony Diffusion V6 XL (ComfyUI)
LoRA: Binding of Isaac Style v2.1 (strength 0.65)
Resolution: 800 x 800 → 다운스케일 600x600 (@1920x1080)
Sampler: euler_a
Steps: 30
CFG: 7
Batch: 4장
방법: 기본 보스 스프라이트를 img2img 입력 (denoising 0.3~0.4) 또는 txt2img
```

## 공통 프롬프트 프리픽스

```
score_9, score_8_up, score_7_up, pixel art, game assets, chibi, simple green background, single character sprite, Korean dokkaebi demon, same design as base sprite but different expression and body state, front-facing centered, flat colors, thick black outlines, dark fantasy, fully contained, no cropping
```

## 후처리

```
1. 기본 스프라이트와 비교하여 전체 형태/색상 일관성 확인
2. 크로마키 그린 배경 제거 → 투명 알파
3. Nearest Neighbor 다운스케일 → 300x300
4. PNG (알파) → Assets/Art/Sprites/Boss/[보스ID]_[상태].png
```

## 파일명 규칙

```
boss_[ID]_idle.png      ← 01-bosses.md 기본 스프라이트 (별도 생성 불필요)
boss_[ID]_hit.png
boss_[ID]_wounded.png
boss_[ID]_critical.png
boss_[ID]_defeat.png
boss_[ID]_gimmick.png
```

---

# 일반 보스 (10종 × 5표정 = 50종)

> idle은 01-bosses.md 기본 스프라이트를 사용하므로 여기서는 hit/wounded/critical/defeat/gimmick 5종만 작성.

---

## 1. 먹보 도깨비 (glutton)

### boss_glutton_hit — 피격
**Seed:** 83001
```
The large round-bodied reddish-orange glutton dokkaebi flinching from a hit. Eyes squeezed shut, mouth open in a yelp of pain. Head snapped to one side from impact. One hand clutching belly where hit. Fat body jiggling from the blow. A brief moment of interrupted feasting.
```

### boss_glutton_wounded — 부상 (HP 50%)
**Seed:** 83002
```
The reddish-orange glutton dokkaebi looking less cheerful. One broken horn now cracked further. Bruises on belly. Mouth still showing teeth but in a strained grimace instead of a laugh. One eye swollen slightly shut. Standing with a slight hunch, favoring one side. The greedy confidence fading — this fight is harder than expected.
```

### boss_glutton_critical — 위기 (HP 20%)
**Seed:** 83003
```
The reddish-orange glutton dokkaebi on its knees, belly deflated and sagging. Both horns broken to stumps. Face twisted in desperate rage — eyes wild, teeth bared in a cornered-animal snarl. Deep cracks across the skin. Arms shaking trying to push itself up. The jolly glutton is gone — only a desperate wounded beast remains.
```

### boss_glutton_defeat — 패배
**Seed:** 83004
```
The reddish-orange glutton dokkaebi collapsed on its side, belly flat. Eyes rolled back showing whites. Mouth hanging open with tongue out. Broken horns scattered. Body deflated like an empty sack. Small spirit wisps leaving the body. Completely spent — the glutton has been emptied.
```

### boss_glutton_gimmick — 기믹 (먹어치우기)
**Seed:** 83005
```
The reddish-orange glutton dokkaebi lunging forward with its enormous mouth stretched impossibly wide — far wider than its own head. Eyes gleaming with manic hunger. Both hands reaching forward to grab something. Drool spraying from the gaping maw. The terrifying moment when the glutton devours a card whole.
```

---

## 2. 장난꾸러기 도깨비 (trickster)

### boss_trickster_hit — 피격
**Seed:** 83011
```
The lean blue-gray trickster dokkaebi knocked sideways by an impact. Eyes comically wide and mismatched. Dokkaebi club flying from its grip. Ears splayed in shock. One hand flailing for balance. An undignified stumble — the prankster caught off guard.
```

### boss_trickster_wounded — 부상 (HP 50%)
**Seed:** 83012
```
The blue-gray trickster dokkaebi with a nervous forced grin. Visible scratches across the body. One horn chipped. Ears twitching anxiously. Crouching lower, more defensive. Holding its club tightly with both hands now. The playful confidence replaced by nervous calculation — the joke isn't funny anymore.
```

### boss_trickster_critical — 위기 (HP 20%)
**Seed:** 83013
```
The blue-gray trickster dokkaebi backed into a corner stance, teeth bared in a feral hiss. All playfulness gone. Eyes wild and darting. Ears flat against head. Clothes torn to shreds. Holding the cracked club like a desperate weapon. Body trembling. A cornered rat with no more tricks.
```

### boss_trickster_defeat — 패배
**Seed:** 83014
```
The blue-gray trickster dokkaebi sitting on the ground defeated, legs splayed. Club broken in half beside it. A dazed confused expression — cross-eyed and dizzy. One ear drooping. A few small stars circling above its head. The trickster outsmarted.
```

### boss_trickster_gimmick — 기믹 (패 뒤집기)
**Seed:** 83015
```
The blue-gray trickster dokkaebi with a gleeful evil grin, hands raised doing a dramatic flourish. Fingers waggling as if casting a spell. One eye winking conspiratorially. Club tucked under one arm. Small card shapes flipping in the air around the hands. The moment of chaotic mischief — everything gets shuffled.
```

---

## 3. 불꽃 도깨비 (flame)

### boss_flame_hit — 피격
**Seed:** 83021
```
The charcoal-black fire dokkaebi staggering from a hit, flames flickering and sputtering momentarily. Cracks in skin flashing brighter orange from the impact. Head snapped back. Embers scattering outward from the point of impact. The fire wavers but doesn't go out.
```

### boss_flame_wounded — 부상 (HP 50%)
**Seed:** 83022
```
The fire dokkaebi with visibly reduced flames — fire now covers only half the body instead of fully engulfing it. Some cracks in skin have gone dark and cold. One horn's flame extinguished. Eyes dimmed from white-hot to orange. Stance still aggressive but less explosive. Smoke rising from cooling patches. The inferno is weakening.
```

### boss_flame_critical — 위기 (HP 20%)
**Seed:** 83023
```
The fire dokkaebi barely aflame — only embers glow in the deepest cracks. Most of the body is cold dark charcoal. One arm's fire completely out, hanging limp. Only the eyes and chest core still burn orange. Hunched forward, struggling to keep the fire alive. Desperate fury in the remaining dim glow. The last coals of a dying inferno.
```

### boss_flame_defeat — 패배
**Seed:** 83024
```
The fire dokkaebi collapsed on one knee, all flames extinguished. Body completely dark charcoal gray — no glow remaining. Eyes dark and empty. Thick smoke rising from the cooling body. Cracks fading from orange to dull gray. Ash crumbling from the surface. The fire is dead.
```

### boss_flame_gimmick — 기믹 (바닥 소각)
**Seed:** 83025
```
The fire dokkaebi rearing back with arms thrown wide, flames erupting from its chest in a massive horizontal wave. Mouth open in a roar of fire. Eyes blazing pure white. The body burns at maximum intensity — every crack pouring flame. A wall of fire sweeps outward. The field is being scorched clean.
```

---

## 4. 그림자 도깨비 (shadow)

### boss_shadow_hit — 피격
**Seed:** 83031
```
The shadow dokkaebi's dark form rippling and distorting from an impact — like a stone hitting still water made of darkness. Purple eyes flickering rapidly. The shadow mass recoils, temporarily losing cohesion. Tendrils scatter outward chaotically before pulling back together. A hole of light punched through the darkness.
```

### boss_shadow_wounded — 부상 (HP 50%)
**Seed:** 83032
```
The shadow dokkaebi noticeably more solid and visible — the darkness is thinning, revealing a skeletal form underneath. Purple eyes brighter because the surrounding shadow is weaker. Tendrils shorter and fewer. The dark mass no longer completely obscures the creature inside. Patches of the body flicker between shadow and exposed bone.
```

### boss_shadow_critical — 위기 (HP 20%)
**Seed:** 83033
```
The shadow dokkaebi almost fully exposed — barely any darkness left, revealing a gaunt skeletal creature underneath. Only wisps of shadow cling to the body like tattered cloth. Purple eyes blazing with desperation and fury. Claws and teeth fully visible. Hunched and cornered. The terrifying truth — without its shadow, it's fragile.
```

### boss_shadow_defeat — 패배
**Seed:** 83034
```
The shadow dokkaebi dissolving into scattered wisps of darkness. The form breaking apart into fragments of shadow that drift upward and away. Purple eyes splitting into smaller and smaller motes of fading light. The darkness dispersing like smoke in wind. Nothing solid remains — the shadow loses all coherence.
```

### boss_shadow_gimmick — 기믹 (부적 비활성화)
**Seed:** 83035
```
The shadow dokkaebi extending one long shadow tendril forward with purpose, the tendril's tip shaped like a hand reaching to grab something. Purple eyes focused with malicious intent. The rest of the body perfectly still and concentrated. The shadow reaches into the player's space — stealing power. A surgical strike of darkness.
```

---

## 5. 여우 도깨비 (fox)

### boss_fox_hit — 피격
**Seed:** 83041
```
The elegant fox spirit dokkaebi flinching, beautiful composure shattered for an instant. Hair whipping from the impact. Purple eyes wide with shock — pupils contracted. One hand raised defensively. Fox tail bristling and puffed out. The porcelain mask cracks to show a flash of the predator underneath before recomposing.
```

### boss_fox_wounded — 부상 (HP 50%)
**Seed:** 83042
```
The fox spirit dokkaebi with hair partially disheveled, hanbok torn at one shoulder. The beautiful face now showing strain — smile forced and brittle. One eye flickering between purple and a darker predatory red. Fox tail held stiffly instead of flowing. Posture still elegant but rigid with tension. The illusion of beauty is slipping.
```

### boss_fox_critical — 위기 (HP 20%)
**Seed:** 83043
```
The fox spirit dokkaebi abandoning all pretense of beauty. Hair wild and tangled. True fox face showing through — sharp muzzle, bared fangs, slitted pupils burning red. The elegant hanbok shredded. All nine tails fully spread and bristling. Crouching on all fours like a cornered animal. The beautiful mask is gone — only the beast remains.
```

### boss_fox_defeat — 패배
**Seed:** 83044
```
The fox spirit dokkaebi collapsed gracefully, reverting to a small white fox form curled on the ground. Nine tails wrapped around the tiny body. Eyes closed peacefully. The elaborate hanbok and human form dissolving into fading purple sparkles around the sleeping fox. The illusion ends — only a tired fox remains.
```

### boss_fox_gimmick — 기믹 (패 변환)
**Seed:** 83045
```
The fox spirit dokkaebi with both hands extended, purple illusion magic swirling between the palms. Eyes glowing bright purple with concentric rings — hypnotic. A sly knowing smile. Fox tail swaying rhythmically. Card shapes caught in the purple magic spiral are visually warping and transforming. Reality bends to the fox's will.
```

---

## 6. 거울 도깨비 (mirror)

### boss_mirror_hit — 피격
**Seed:** 83051
```
The crystalline mirror dokkaebi with several mirror shards cracking from impact — spider web fracture patterns spreading across the reflective surface. Reflections in the broken panels distorting wildly. Sharp fragments flying outward. The crack reveals darkness underneath the mirror surface. A shattering sound made visible.
```

### boss_mirror_wounded — 부상 (HP 50%)
**Seed:** 83052
```
The mirror dokkaebi with half its mirror panels cracked or missing, revealing a dark hollow interior. Remaining mirrors show distorted broken reflections. Some shards dangle loosely. The prismatic rainbow refractions now fragmented and chaotic. Standing less symmetrically — the perfect copy is flawed. A broken mirror held together by will.
```

### boss_mirror_critical — 위기 (HP 20%)
**Seed:** 83053
```
The mirror dokkaebi barely holding together — most mirror surface shattered, body mostly dark hollow frame with only a few reflective shards remaining. The shards reflect nothing but darkness. Pieces constantly falling off. Hunched and unstable. The eyes are cracked mirrors about to break completely. Seven years of bad luck in one failing body.
```

### boss_mirror_defeat — 패배
**Seed:** 83054
```
The mirror dokkaebi shattering completely — the body exploding into hundreds of tiny mirror fragments that scatter outward in slow motion. Each fragment reflects a tiny piece of light before going dark. The dark frame collapses inward with nothing left to hold. Only a pile of broken glass remains where the creature stood.
```

### boss_mirror_gimmick — 기믹 (부적 반전)
**Seed:** 83055
```
The mirror dokkaebi holding its chest mirror forward like a shield, the largest mirror panel glowing with reversed colors. The reflection shows the player's talisman power being caught and inverted. Eyes gleaming with copied intelligence. Perfect mimicking pose — one hand extended identically to the player. Your power becomes my power.
```

---

## 7. 화산 도깨비 (volcano)

### boss_volcano_hit — 피격
**Seed:** 83061
```
The massive basalt-gray volcanic dokkaebi shuddering from impact, cracks in body flashing brighter molten orange. A burst of lava erupts from the impact point like blood. Small rocks crumble from the body edges. The crater head belches extra smoke. The mountain shakes but stands.
```

### boss_volcano_wounded — 부상 (HP 50%)
**Seed:** 83062
```
The volcanic dokkaebi with large chunks of rock broken off, exposing more molten interior. The crater head smoking more heavily. Lava flowing more freely from widened cracks — less controlled. Rocky armor partially crumbled, body shape less mountain-like and more raw magma. Still massive but eroding. An unstable volcano about to blow.
```

### boss_volcano_critical — 위기 (HP 20%)
**Seed:** 83063
```
The volcanic dokkaebi barely recognizable — most of the rocky shell crumbled away, revealing a molten core underneath. The body is more lava than stone now — glowing orange-red and dripping. Unstable and pulsing. The crater head collapsed. Arms reduced to stubs of flowing magma. Swaying dangerously. A volcano with its mountain gone — just raw unstable magma.
```

### boss_volcano_defeat — 패배
**Seed:** 83064
```
The volcanic dokkaebi cooling and hardening into a lifeless obsidian statue. All glow extinguished. The lava solidified into dark black glass. Frozen in a final reaching pose. Steam hissing as the last heat escapes. Cracks sealed with cold black stone. An extinct volcano — forever still.
```

### boss_volcano_gimmick — 기믹 (바닥패 소각)
**Seed:** 83065
```
The volcanic dokkaebi slamming both fists into the ground, a shockwave of lava erupting outward in a ring. The crater head erupting upward with magma and ash. Eyes white-hot. Rocky armor glowing from internal pressure. The ground around the creature cracks and burns. A volcanic eruption centered on the battlefield.
```

---

## 8. 황금 도깨비 (gold)

### boss_gold_hit — 피격
**Seed:** 83071
```
The golden dokkaebi reeling from a hit, gold coins scattering from the impact point. One jewel knocked loose from the horns. The polished gold surface dented at the strike point. Coin-eyes spinning. Gold chains swinging wildly. Even in pain, clutching the bag of coins closer — never letting go of the treasure.
```

### boss_gold_wounded — 부상 (HP 50%)
**Seed:** 83072
```
The golden dokkaebi with tarnished patches appearing on the gold surface — the shine fading. Several jewels cracked or fallen from the horns. Gold armor dented. Some coins falling from a torn bag. Grin strained — the invincible golden aura dimming. One hand constantly trying to pick up dropped coins while fighting. Greed persists even in pain.
```

### boss_gold_critical — 위기 (HP 20%)
**Seed:** 83073
```
The golden dokkaebi with most gold tarnished to dull brass. Jeweled horns broken, gems missing. Golden armor crumbling, revealing ordinary dark flesh underneath. Coin-eyes cracked and dim. Empty money bag dangling from one hand. Desperately grasping at the few remaining gold pieces on its body. The gilded exterior peeling away — underneath is just a common dokkaebi.
```

### boss_gold_defeat — 패배
**Seed:** 83074
```
The golden dokkaebi collapsed in a shower of coins, all gold coating stripped away revealing a small ordinary gray dokkaebi underneath. Mountains of scattered coins and broken jewelry surround the tiny defeated figure. The grand golden form was always an illusion of wealth. The real creature is pathetically small and plain. Eyes staring at the scattered coins in disbelief.
```

### boss_gold_gimmick — 기믹 (최고가치 패 강탈)
**Seed:** 83075
```
The golden dokkaebi reaching out with both jeweled hands, gold light emanating from the palms — magnetically pulling something valuable toward itself. Coin-eyes blazing with intense greed. Mouth open in an avaricious laugh. Gold chains rattling. The bag held open to receive stolen treasure. Pure greed made manifest.
```

---

## 9. 회랑 도깨비 (corridor)

### boss_corridor_hit — 피격
**Seed:** 83081
```
The impossibly thin corridor dokkaebi bending and warping from impact — the body folding at impossible angles like a funhouse mirror reflection glitching. Spiral eyes stuttering. The spatial distortion around the body flickering and destabilizing. The long limbs snapping to wrong positions before resetting. A visual glitch in reality.
```

### boss_corridor_wounded — 부상 (HP 50%)
**Seed:** 83082
```
The corridor dokkaebi less impossibly tall — the stretching effect weakening, body proportions becoming slightly more normal. Spiral eyes spinning slower. The Escher-like distortions around the body becoming less convincing — you can see where the illusion breaks. Dark robes thinning. The endless hallway is getting shorter.
```

### boss_corridor_critical — 위기 (HP 20%)
**Seed:** 83083
```
The corridor dokkaebi almost normal-sized, spatial distortions nearly collapsed. The thin body revealed as genuinely fragile without the stretching illusion. Spiral eyes sputtering erratically. Limbs at awkward normal angles — no longer bending impossibly. Dark robes pooled around its feet. The infinite corridor has a dead end.
```

### boss_corridor_defeat — 패배
**Seed:** 83084
```
The corridor dokkaebi folding inward on itself — the body collapsing into a single point like a hallway with forced perspective shrinking to nothing. The spiral eyes becoming a single vanishing point. Robes sucked inward. The creature disappears into its own spatial distortion — a corridor that leads nowhere, closing forever.
```

### boss_corridor_gimmick — 기믹 (매턴 뒤집기)
**Seed:** 83085
```
The corridor dokkaebi spreading its impossibly long arms wide, fingers stretching across the entire frame. Spiral eyes spinning at maximum speed. The body warping the space around it — everything in range is being twisted and flipped. Reality folds like origami around the creature. Cards caught in the distortion field spin and invert.
```

---

## 10. 염라대왕 (yeomra)

### boss_yeomra_hit — 피격
**Seed:** 83091
```
King Yama flinching — a crack of disbelief on the divine face. Golden eyes momentarily widened. One of the six arms losing grip on its object — the scales tipping. Crown shifted slightly off-center. Divine aura flickering. For a fraction of a second, the judge looks mortal. The shock of being challenged.
```

### boss_yeomra_wounded — 부상 (HP 50%)
**Seed:** 83092
```
King Yama with royal robes torn, golden skin dimmed. Two of six arms hanging limp — dropped their objects. Crown cracked. Expression shifted from absolute authority to cold anger. The remaining four arms grip their weapons tighter. Golden aura unstable, flickering between bright and dim. The supreme judge, for the first time, feeling threatened.
```

### boss_yeomra_critical — 위기 (HP 20%)
**Seed:** 83093
```
King Yama on one knee, only two arms still functional. Crown broken in half, hanging loose. Robes shredded. Golden skin peeling to reveal ancient dark flesh underneath. Eyes blazing with desperate divine fury — or is it fear? The golden aura reduced to a faint sputtering glow. Sacred objects scattered on the ground. The unquestionable judge, questioned.
```

### boss_yeomra_defeat — 패배
**Seed:** 83094
```
King Yama seated on the ground in reluctant acceptance. All six arms lowered in surrender. Crown removed and placed on the ground before him. Golden eyes closed. A single tear of golden light on the divine face. The golden aura dims to a soft respectful glow. A slight bow of the head. The supreme judge grants passage — you have earned it.
```

### boss_yeomra_gimmick — 기믹 (광 무효화)
**Seed:** 83095
```
King Yama extending all six arms in a commanding gesture, forming a divine seal pattern. Golden eyes blazing with absolute authority. The judgment scroll held high, glowing with red edict text. A golden barrier emanates from the seal — blocking and nullifying all bright (gwang) cards. The word of the judge is absolute. No light escapes this decree.
```

---

# 재앙 보스 (4종 × 5표정 = 20종)

---

## 11. 백골대장 (skeleton_general) — 윤회 3

### boss_skeleton_hit — 피격
**Seed:** 83101
```
The massive skeleton general dokkaebi rattling from impact — bones scattering from the strike point and magnetically pulling back into place. Blue ghost fire in eye sockets flaring brighter. Armor plates clanking loose. Some bones crack but don't break. The undead general shrugs off what would kill the living.
```

### boss_skeleton_wounded — 부상 (HP 50%)
**Seed:** 83102
```
The skeleton general with visible bone damage — ribs cracked, arm bone chipped. Some armor plates fallen away. Ghost fire in sockets dimmer and flickering. Trophy skulls on the armor crumbling. Bone sword chipped along the edge. Standing less tall — the commanding posture sagging. The war banner tattered. Even bone can break.
```

### boss_skeleton_critical — 위기 (HP 20%)
**Seed:** 83103
```
The skeleton general barely held together — missing entire limb sections, held in place only by faint blue ghost fire sinew. Half the skull cracked open. Armor reduced to a single chest plate. Standing on one leg, using the bone sword as a crutch. Ghost fire sputtering like a dying candle. A skeleton refusing to fall apart — held together by pure military will.
```

### boss_skeleton_defeat — 패배
**Seed:** 83104
```
The skeleton general collapsing — all bones falling apart simultaneously in a cascade. Ghost fire extinguishing in the eye sockets. Armor and bone sword clattering to the ground in a heap. The war banner falling last, draping over the bone pile like a funeral shroud. The general's final order: rest.
```

### boss_skeleton_gimmick — 기믹 (해골패 변환)
**Seed:** 83105
```
The skeleton general raising one bony hand, blue ghost fire surging through the arm. Finger bones pointing at a target. A beam of cold blue skeletal energy shooting from the fingertip — transforming what it touches into bone. Ghost fire blazing in sockets with malicious glee. The general marks another for its army of the dead.
```

---

## 12. 구미호 왕 (ninetail_king) — 윤회 5

### boss_ninetail_hit — 피격
**Seed:** 83111
```
The nine-tailed fox king staggering, golden eyes flashing with surprise. Several tails jerking from the impact. Illusion shimmer around the body flickering — revealing glimpses of the true form underneath. Phantom cards orbiting the body scattering momentarily. The grand deception wavers for an instant.
```

### boss_ninetail_wounded — 부상 (HP 50%)
**Seed:** 83112
```
The fox king with three tails dimmed and drooping — no longer glowing with illusion power. Crown askew. Royal robes losing their shimmer, becoming more solid and ordinary-looking. Fewer phantom cards orbiting — and the fakes are more obviously transparent. Golden markings fading. The illusion king is losing control of the illusion.
```

### boss_ninetail_critical — 위기 (HP 20%)
**Seed:** 83113
```
The fox king with only two tails still active, the rest limp and dark. True form partially visible — a large but ordinary-looking old fox underneath the glamour. Crown fallen. Robes dissolved to wisps. No more phantom cards — the deception completely failed. Golden eyes dimmed to ordinary animal amber. Backed against nothing — no more tricks, no more illusions. Just a cornered old fox.
```

### boss_ninetail_defeat — 패배
**Seed:** 83114
```
The fox king reverted to its true form — an ancient massive nine-tailed fox lying on its side. All tails draped flat. Royal regalia dissolved into fading golden dust. Wise ancient eyes half-closed in acceptance. The magnificence was always an illusion — but the ancient creature underneath is beautiful in its own tired way. A king's illusion ends, but the fox endures.
```

### boss_ninetail_gimmick — 기믹 (가짜 카드)
**Seed:** 83115
```
The fox king with all nine tails fanned wide, each tail tip generating a different phantom card that shimmers between real and fake. Eyes blazing with concentric golden rings — hypnotic illusion at full power. The royal robes swirling with illusory patterns. Both hands conducting the phantom cards like an orchestra. Reality and deception become indistinguishable.
```

---

## 13. 이무기 (imugi) — 윤회 8

### boss_imugi_hit — 피격
**Seed:** 83121
```
The colossal serpentine imugi recoiling, dark scales flashing with lightning discharge from the impact. Body coils tightening defensively. Yellow dragon eyes narrowing with pain and anger. Emerging wing buds and claws flinching. The yeouiju pearl above flickering. Scales cracking at the strike point revealing lighter flesh underneath. The would-be dragon bleeds.
```

### boss_imugi_wounded — 부상 (HP 50%)
**Seed:** 83122
```
The imugi with patches of scales torn away exposing raw flesh. Lightning along the body weaker and sporadic. Emerging dragon features — wing buds and claws — receding back into the serpent form, the transformation failing. Coils less impressive, body lower to the ground. Yellow eyes burning with frustrated determination. The yeouiju pearl dimming. Ascension is slipping away.
```

### boss_imugi_critical — 위기 (HP 20%)
**Seed:** 83123
```
The imugi reduced to a battered serpent — all dragon features retracted. Scales dull and broken. Body barely coiled, lying mostly flat. Yellow eyes blazing with absolute desperate fury. The yeouiju pearl nearly dark, hanging by a thread of failing energy. Lightning reduced to tiny static sparks. Mouth open in a defiant hiss. This creature will not die before becoming a dragon — but it might have to.
```

### boss_imugi_defeat — 패배
**Seed:** 83124
```
The imugi lying still, body uncoiled in a long defeated line. Scales dull gray. Eyes closed. The yeouiju pearl falling slowly from above, landing gently beside the creature's head — close enough to touch but no longer able to be grasped. No lightning remains. A single tear-like drop from the closed eye. The dream of becoming a dragon ends here. So close. So close.
```

### boss_imugi_gimmick — 기믹 (경쟁전 점수)
**Seed:** 83125
```
The imugi rising to maximum height, body fully coiled and tensed. Lightning surging along every scale. Yellow eyes blazing with competitive fire. The yeouiju pearl spinning rapidly above, charging with energy. Emerging dragon features straining outward — claws extending, wing buds flaring. The creature competing with everything it has — matching the player point for point. This is a race to ascension.
```

---

## 14. 저승꽃 (underworld_flower) — 윤회 10+

### boss_flower_hit — 피격
**Seed:** 83131
```
The underworld flower entity shuddering, petals scattering from the impact point. The face behind the flowers flinching — sad eyes squeezing shut. Several ghost flowers wilting instantly at the strike. Vine arms recoiling. Luminescent glow dimming momentarily. Flower petals falling like tears. Even hitting this creature feels like destroying something beautiful.
```

### boss_flower_wounded — 부상 (HP 50%)
**Seed:** 83132
```
The flower entity with half its blooms wilted — ghostly petals dried and curled, hanging limp. The corpse lilies brown and decaying. Spider lilies losing their red. Vine arms thinner, some severed. The face more visible through the thinning flower cover — sad ethereal eyes openly visible. Roots pulling inward defensively. Beauty fading like cut flowers left too long. Still hauntingly lovely, but the garden is dying.
```

### boss_flower_critical — 위기 (HP 20%)
**Seed:** 83133
```
The flower entity nearly stripped — only a few ghost blooms remaining on a bare dark stem-body. The humanoid form fully exposed — thin, dark, fragile, covered in thorns. Sad eyes now showing a flicker of desperate determination. Roots lashing defensively. The last flowers glow intensely as if burning their final energy. A bare winter tree with only a few defiant blossoms clinging to life.
```

### boss_flower_defeat — 패배
**Seed:** 83134
```
The flower entity dissolving into a final cascade of petals. The dark stem-body crumbling to soil. All flowers releasing simultaneously in a breathtaking shower — ghost petals drifting upward like released souls. The sad eyes close peacefully as the face dissolves into petals. The last spider lily falls. Where the creature stood, a single seed remains on a small mound of rich dark earth. Death feeds new life. The most beautiful defeat.
```

### boss_flower_gimmick — 기믹 (강화 억제)
**Seed:** 83135
```
The flower entity extending vine arms wide, roots erupting from below in all directions. Dark thorny vines wrap around invisible objects — suppressing and binding. The flowers glow with an eerie draining light — absorbing color and power from the surroundings. Sad eyes open but determined — this beauty consumes. Pollen clouds drift outward, each spore a tiny suppression spell. The garden doesn't just grow — it smothers.
```
