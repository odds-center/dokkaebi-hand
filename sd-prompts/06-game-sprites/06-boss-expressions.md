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

## 공통 네거티브 프롬프트

```
score_4, score_3, score_2, score_1, blurry, photo, realistic, 3d render, smooth shading, anti-aliasing, gradient, soft edges, watercolor, text, watermark, signature
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
reddish-orange glutton dokkaebi, large round body, flinching from hit, eyes squeezed shut, mouth open yelp of pain, head snapped sideways, one hand clutching belly, fat body jiggling, interrupted feasting
```

### boss_glutton_wounded — 부상 (HP 50%)
**Seed:** 83002
```
reddish-orange glutton dokkaebi, less cheerful, broken horn cracked further, bruised belly, strained grimace showing teeth, one eye swollen shut, slight hunch favoring one side, fading confidence
```

### boss_glutton_critical — 위기 (HP 20%)
**Seed:** 83003
```
reddish-orange glutton dokkaebi, on knees, belly deflated sagging, both horns broken to stumps, desperate rage face, wild eyes, teeth bared cornered-animal snarl, deep skin cracks, arms shaking pushing up, wounded beast
```

### boss_glutton_defeat — 패배
**Seed:** 83004
```
reddish-orange glutton dokkaebi, collapsed on side, belly flat, eyes rolled back showing whites, mouth open tongue out, broken horns scattered, deflated empty sack body, spirit wisps leaving body
```

### boss_glutton_gimmick — 기믹 (먹어치우기)
**Seed:** 83005
```
reddish-orange glutton dokkaebi, lunging forward, enormous mouth stretched impossibly wide, eyes gleaming manic hunger, both hands reaching forward, drool spraying from gaping maw, devouring card whole
```

---

## 2. 장난꾸러기 도깨비 (trickster)

### boss_trickster_hit — 피격
**Seed:** 83011
```
lean blue-gray trickster dokkaebi, knocked sideways, eyes comically wide mismatched, dokkaebi club flying from grip, ears splayed in shock, one hand flailing for balance, undignified stumble
```

### boss_trickster_wounded — 부상 (HP 50%)
**Seed:** 83012
```
blue-gray trickster dokkaebi, nervous forced grin, visible scratches across body, one horn chipped, ears twitching anxiously, crouching low defensive stance, holding club tightly with both hands, nervous calculation
```

### boss_trickster_critical — 위기 (HP 20%)
**Seed:** 83013
```
blue-gray trickster dokkaebi, cornered stance, teeth bared feral hiss, wild darting eyes, ears flat against head, clothes torn to shreds, holding cracked club desperately, body trembling, no more tricks
```

### boss_trickster_defeat — 패배
**Seed:** 83014
```
blue-gray trickster dokkaebi, sitting on ground defeated, legs splayed, club broken in half beside it, dazed cross-eyed dizzy expression, one ear drooping, small stars circling above head
```

### boss_trickster_gimmick — 기믹 (패 뒤집기)
**Seed:** 83015
```
blue-gray trickster dokkaebi, gleeful evil grin, hands raised dramatic flourish, fingers waggling casting spell, one eye winking, club tucked under arm, card shapes flipping in air around hands, chaotic mischief
```

---

## 3. 불꽃 도깨비 (flame)

### boss_flame_hit — 피격
**Seed:** 83021
```
charcoal-black fire dokkaebi, staggering from hit, flames flickering sputtering, skin cracks flashing brighter orange, head snapped back, embers scattering outward from impact point, fire wavering
```

### boss_flame_wounded — 부상 (HP 50%)
**Seed:** 83022
```
charcoal-black fire dokkaebi, visibly reduced flames covering half body, some skin cracks gone dark and cold, one horn flame extinguished, eyes dimmed to orange, aggressive but less explosive stance, smoke rising from cooling patches, weakening inferno
```

### boss_flame_critical — 위기 (HP 20%)
**Seed:** 83023
```
charcoal-black fire dokkaebi, barely aflame, only embers in deepest cracks, mostly cold dark charcoal body, one arm fire out hanging limp, only eyes and chest core burning orange, hunched forward struggling, desperate fury, dying inferno last coals
```

### boss_flame_defeat — 패배
**Seed:** 83024
```
charcoal-black fire dokkaebi, collapsed on one knee, all flames extinguished, completely dark charcoal gray body no glow, dark empty eyes, thick smoke rising from cooling body, cracks fading to dull gray, ash crumbling from surface
```

### boss_flame_gimmick — 기믹 (바닥 소각)
**Seed:** 83025
```
charcoal-black fire dokkaebi, rearing back arms thrown wide, flames erupting from chest massive wave, mouth open fire roar, eyes blazing pure white, maximum intensity every crack pouring flame, wall of fire sweeping outward
```

---

## 4. 그림자 도깨비 (shadow)

### boss_shadow_hit — 피격
**Seed:** 83031
```
shadow dokkaebi, dark form rippling distorting from impact, purple eyes flickering rapidly, shadow mass recoiling losing cohesion, tendrils scattering outward chaotically, hole of light punched through darkness
```

### boss_shadow_wounded — 부상 (HP 50%)
**Seed:** 83032
```
shadow dokkaebi, more solid and visible, darkness thinning revealing skeletal form underneath, purple eyes brighter, tendrils shorter and fewer, patches flickering between shadow and exposed bone
```

### boss_shadow_critical — 위기 (HP 20%)
**Seed:** 83033
```
shadow dokkaebi, almost fully exposed, barely any darkness left, gaunt skeletal creature revealed, only shadow wisps clinging like tattered cloth, purple eyes blazing desperation and fury, claws teeth fully visible, hunched cornered, fragile without shadow
```

### boss_shadow_defeat — 패배
**Seed:** 83034
```
shadow dokkaebi, dissolving into scattered darkness wisps, form breaking apart into shadow fragments drifting upward, purple eyes splitting into fading light motes, darkness dispersing like smoke, nothing solid remaining
```

### boss_shadow_gimmick — 기믹 (부적 비활성화)
**Seed:** 83035
```
shadow dokkaebi, extending one long shadow tendril forward, tendril tip shaped like grabbing hand, purple eyes focused malicious intent, body perfectly still concentrated, shadow reaching into player space, surgical darkness strike
```

---

## 5. 여우 도깨비 (fox)

### boss_fox_hit — 피격
**Seed:** 83041
```
elegant fox spirit dokkaebi, flinching, composure shattered, hair whipping from impact, purple eyes wide shock pupils contracted, one hand raised defensively, fox tail bristling puffed out, porcelain mask cracking showing predator underneath
```

### boss_fox_wounded — 부상 (HP 50%)
**Seed:** 83042
```
fox spirit dokkaebi, hair partially disheveled, hanbok torn at one shoulder, strained face forced brittle smile, one eye flickering between purple and predatory red, fox tail held stiffly, elegant but rigid tense posture, beauty illusion slipping
```

### boss_fox_critical — 위기 (HP 20%)
**Seed:** 83043
```
fox spirit dokkaebi, abandoning beauty pretense, hair wild tangled, true fox face showing through, sharp muzzle bared fangs slitted red pupils, elegant hanbok shredded, all nine tails spread bristling, crouching on all fours, cornered beast
```

### boss_fox_defeat — 패배
**Seed:** 83044
```
fox spirit dokkaebi, collapsed gracefully, reverted to small white fox form curled on ground, nine tails wrapped around tiny body, eyes closed peacefully, hanbok dissolving into fading purple sparkles, tired sleeping fox
```

### boss_fox_gimmick — 기믹 (패 변환)
**Seed:** 83045
```
fox spirit dokkaebi, both hands extended, purple illusion magic swirling between palms, eyes glowing bright purple concentric rings hypnotic, sly knowing smile, fox tail swaying rhythmically, card shapes warping in purple magic spiral
```

---

## 6. 거울 도깨비 (mirror)

### boss_mirror_hit — 피격
**Seed:** 83051
```
crystalline mirror dokkaebi, mirror shards cracking from impact, spider web fracture patterns on reflective surface, distorted broken reflections, sharp fragments flying outward, darkness revealed underneath mirror surface
```

### boss_mirror_wounded — 부상 (HP 50%)
**Seed:** 83052
```
mirror dokkaebi, half mirror panels cracked or missing, dark hollow interior revealed, remaining mirrors showing distorted reflections, shards dangling loosely, fragmented chaotic prismatic refractions, asymmetric stance, broken mirror held together by will
```

### boss_mirror_critical — 위기 (HP 20%)
**Seed:** 83053
```
mirror dokkaebi, barely holding together, most mirror surface shattered, dark hollow frame body few reflective shards remaining, shards reflecting only darkness, pieces falling off, hunched unstable, cracked mirror eyes about to break
```

### boss_mirror_defeat — 패배
**Seed:** 83054
```
mirror dokkaebi, shattering completely, body exploding into hundreds of tiny mirror fragments scattering outward, each fragment reflecting light before going dark, dark frame collapsing inward, pile of broken glass remaining
```

### boss_mirror_gimmick — 기믹 (부적 반전)
**Seed:** 83055
```
mirror dokkaebi, chest mirror held forward like shield, largest mirror panel glowing reversed colors, reflection catching and inverting talisman power, eyes gleaming copied intelligence, perfect mimicking pose, one hand extended identically
```

---

## 7. 화산 도깨비 (volcano)

### boss_volcano_hit — 피격
**Seed:** 83061
```
massive basalt-gray volcanic dokkaebi, shuddering from impact, body cracks flashing brighter molten orange, lava burst erupting from impact point, small rocks crumbling from body edges, crater head belching extra smoke, mountain shaking but standing
```

### boss_volcano_wounded — 부상 (HP 50%)
**Seed:** 83062
```
volcanic dokkaebi, large rock chunks broken off exposing molten interior, crater head smoking heavily, lava flowing freely from widened cracks, rocky armor partially crumbled, body more raw magma than mountain, massive but eroding, unstable volcano
```

### boss_volcano_critical — 위기 (HP 20%)
**Seed:** 83063
```
volcanic dokkaebi, barely recognizable, most rocky shell crumbled away, molten core revealed, body more lava than stone glowing orange-red dripping, unstable pulsing, crater head collapsed, arms reduced to magma stubs, swaying dangerously, raw unstable magma
```

### boss_volcano_defeat — 패배
**Seed:** 83064
```
volcanic dokkaebi, cooling hardening into lifeless obsidian statue, all glow extinguished, lava solidified dark black glass, frozen in final reaching pose, steam hissing last heat escaping, cracks sealed cold black stone, extinct volcano
```

### boss_volcano_gimmick — 기믹 (바닥패 소각)
**Seed:** 83065
```
volcanic dokkaebi, slamming both fists into ground, lava shockwave erupting outward in ring, crater head erupting with magma and ash, eyes white-hot, rocky armor glowing from internal pressure, ground cracking and burning around creature
```

---

## 8. 황금 도깨비 (gold)

### boss_gold_hit — 피격
**Seed:** 83071
```
golden dokkaebi, reeling from hit, gold coins scattering from impact point, jewel knocked loose from horns, polished gold surface dented, coin-eyes spinning, gold chains swinging wildly, clutching coin bag closer in pain
```

### boss_gold_wounded — 부상 (HP 50%)
**Seed:** 83072
```
golden dokkaebi, tarnished patches on gold surface shine fading, jewels cracked or fallen from horns, gold armor dented, coins falling from torn bag, strained grin, golden aura dimming, one hand picking up dropped coins while fighting, persistent greed
```

### boss_gold_critical — 위기 (HP 20%)
**Seed:** 83073
```
golden dokkaebi, most gold tarnished to dull brass, jeweled horns broken gems missing, golden armor crumbling revealing ordinary dark flesh, coin-eyes cracked dim, empty money bag dangling from one hand, desperately grasping remaining gold pieces, gilded exterior peeling away
```

### boss_gold_defeat — 패배
**Seed:** 83074
```
golden dokkaebi, collapsed in shower of coins, gold coating stripped revealing small ordinary gray dokkaebi underneath, mountains of scattered coins and broken jewelry surrounding tiny defeated figure, pathetically small plain real form, eyes staring at scattered coins in disbelief
```

### boss_gold_gimmick — 기믹 (최고가치 패 강탈)
**Seed:** 83075
```
golden dokkaebi, reaching out both jeweled hands, gold light emanating from palms pulling magnetically, coin-eyes blazing intense greed, mouth open avaricious laugh, gold chains rattling, bag held open to receive stolen treasure
```

---

## 9. 회랑 도깨비 (corridor)

### boss_corridor_hit — 피격
**Seed:** 83081
```
impossibly thin corridor dokkaebi, bending warping from impact, body folding at impossible angles, funhouse mirror glitch, spiral eyes stuttering, spatial distortion flickering destabilizing, long limbs snapping to wrong positions, reality glitch
```

### boss_corridor_wounded — 부상 (HP 50%)
**Seed:** 83082
```
corridor dokkaebi, less impossibly tall, stretching effect weakening, body proportions becoming more normal, spiral eyes spinning slower, Escher-like distortions less convincing illusion breaking, dark robes thinning, endless hallway getting shorter
```

### boss_corridor_critical — 위기 (HP 20%)
**Seed:** 83083
```
corridor dokkaebi, almost normal-sized, spatial distortions nearly collapsed, thin body genuinely fragile without stretching illusion, spiral eyes sputtering erratically, limbs at awkward normal angles, dark robes pooled around feet, dead end
```

### boss_corridor_defeat — 패배
**Seed:** 83084
```
corridor dokkaebi, folding inward on itself, body collapsing into single vanishing point, forced perspective shrinking to nothing, spiral eyes becoming single vanishing point, robes sucked inward, disappearing into own spatial distortion
```

### boss_corridor_gimmick — 기믹 (매턴 뒤집기)
**Seed:** 83085
```
corridor dokkaebi, impossibly long arms spread wide, fingers stretching across entire frame, spiral eyes spinning maximum speed, body warping space around it, reality folding like origami, cards caught in distortion field spinning inverting
```

---

## 10. 염라대왕 (yeomra)

### boss_yeomra_hit — 피격
**Seed:** 83091
```
King Yama dokkaebi, flinching, disbelief cracking divine face, golden eyes momentarily widened, one of six arms losing grip scales tipping, crown shifted off-center, divine aura flickering, judge looking mortal for an instant
```

### boss_yeomra_wounded — 부상 (HP 50%)
**Seed:** 83092
```
King Yama dokkaebi, royal robes torn, golden skin dimmed, two of six arms hanging limp objects dropped, crown cracked, cold anger expression, remaining four arms gripping weapons tighter, golden aura unstable flickering, supreme judge feeling threatened
```

### boss_yeomra_critical — 위기 (HP 20%)
**Seed:** 83093
```
King Yama dokkaebi, on one knee, only two arms functional, crown broken in half hanging loose, robes shredded, golden skin peeling revealing ancient dark flesh, eyes blazing desperate divine fury, golden aura faint sputtering glow, sacred objects scattered on ground
```

### boss_yeomra_defeat — 패배
**Seed:** 83094
```
King Yama dokkaebi, seated on ground reluctant acceptance, all six arms lowered in surrender, crown removed placed on ground, golden eyes closed, single golden light tear on divine face, golden aura dimmed soft respectful glow, slight head bow, granting passage
```

### boss_yeomra_gimmick — 기믹 (광 무효화)
**Seed:** 83095
```
King Yama dokkaebi, all six arms extended commanding gesture forming divine seal pattern, golden eyes blazing absolute authority, judgment scroll held high glowing red edict text, golden barrier emanating from seal, blocking nullifying gwang cards
```

---

# 재앙 보스 (4종 × 5표정 = 20종)

---

## 11. 백골대장 (skeleton_general) — 윤회 3

### boss_skeleton_hit — 피격
**Seed:** 83101
```
massive skeleton general dokkaebi, rattling from impact, bones scattering from strike point pulling back magnetically, blue ghost fire in eye sockets flaring brighter, armor plates clanking loose, bones cracking but not breaking, undead shrug
```

### boss_skeleton_wounded — 부상 (HP 50%)
**Seed:** 83102
```
skeleton general dokkaebi, visible bone damage ribs cracked arm bone chipped, armor plates fallen away, ghost fire in sockets dimmer flickering, trophy skulls crumbling, bone sword chipped edge, commanding posture sagging standing less tall, war banner tattered
```

### boss_skeleton_critical — 위기 (HP 20%)
**Seed:** 83103
```
skeleton general dokkaebi, barely held together, missing entire limb sections held by faint blue ghost fire sinew, half skull cracked open, armor reduced to single chest plate, standing on one leg bone sword as crutch, ghost fire sputtering like dying candle, held together by pure will
```

### boss_skeleton_defeat — 패배
**Seed:** 83104
```
skeleton general dokkaebi, collapsing, all bones falling apart simultaneously cascading, ghost fire extinguishing in eye sockets, armor and bone sword clattering to ground in heap, war banner falling last draping over bone pile like funeral shroud
```

### boss_skeleton_gimmick — 기믹 (해골패 변환)
**Seed:** 83105
```
skeleton general dokkaebi, raising one bony hand, blue ghost fire surging through arm, finger bones pointing at target, cold blue skeletal energy beam from fingertip, ghost fire blazing in sockets malicious glee, marking target for army of dead
```

---

## 12. 구미호 왕 (ninetail_king) — 윤회 5

### boss_ninetail_hit — 피격
**Seed:** 83111
```
nine-tailed fox king dokkaebi, staggering, golden eyes flashing surprise, several tails jerking from impact, illusion shimmer flickering revealing true form glimpses, phantom cards orbiting body scattering momentarily, grand deception wavering
```

### boss_ninetail_wounded — 부상 (HP 50%)
**Seed:** 83112
```
nine-tailed fox king dokkaebi, three tails dimmed drooping no longer glowing, crown askew, royal robes losing shimmer becoming ordinary, fewer phantom cards orbiting more obviously transparent, golden markings fading, losing control of illusion
```

### boss_ninetail_critical — 위기 (HP 20%)
**Seed:** 83113
```
nine-tailed fox king dokkaebi, only two tails still active rest limp dark, true form partially visible ordinary old fox underneath glamour, crown fallen, robes dissolved to wisps, no phantom cards deception failed, golden eyes dimmed to animal amber, cornered old fox no more tricks
```

### boss_ninetail_defeat — 패배
**Seed:** 83114
```
nine-tailed fox king dokkaebi, reverted to true form, ancient massive nine-tailed fox lying on side, all tails draped flat, royal regalia dissolved into fading golden dust, wise ancient eyes half-closed acceptance, tired beautiful ancient creature
```

### boss_ninetail_gimmick — 기믹 (가짜 카드)
**Seed:** 83115
```
nine-tailed fox king dokkaebi, all nine tails fanned wide, each tail tip generating phantom card shimmering between real and fake, eyes blazing concentric golden rings hypnotic, royal robes swirling illusory patterns, both hands conducting phantom cards like orchestra
```

---

## 13. 이무기 (imugi) — 윤회 8

### boss_imugi_hit — 피격
**Seed:** 83121
```
colossal serpentine imugi dokkaebi, recoiling, dark scales flashing lightning discharge from impact, body coils tightening defensively, yellow dragon eyes narrowing pain anger, emerging wing buds and claws flinching, yeouiju pearl flickering, scales cracking revealing lighter flesh
```

### boss_imugi_wounded — 부상 (HP 50%)
**Seed:** 83122
```
imugi dokkaebi, patches of scales torn away exposing raw flesh, lightning weaker sporadic along body, dragon features receding wing buds claws shrinking transformation failing, coils less impressive body lower to ground, yellow eyes burning frustrated determination, yeouiju pearl dimming, ascension slipping away
```

### boss_imugi_critical — 위기 (HP 20%)
**Seed:** 83123
```
imugi dokkaebi, reduced to battered serpent, all dragon features retracted, scales dull broken, body barely coiled lying mostly flat, yellow eyes blazing absolute desperate fury, yeouiju pearl nearly dark failing energy, lightning reduced to tiny static sparks, mouth open defiant hiss
```

### boss_imugi_defeat — 패배
**Seed:** 83124
```
imugi dokkaebi, lying still, body uncoiled long defeated line, scales dull gray, eyes closed, yeouiju pearl falling slowly landing beside head close but ungraspable, no lightning remaining, single tear drop from closed eye, dragon dream ending
```

### boss_imugi_gimmick — 기믹 (경쟁전 점수)
**Seed:** 83125
```
imugi dokkaebi, rising to maximum height, body fully coiled tensed, lightning surging along every scale, yellow eyes blazing competitive fire, yeouiju pearl spinning rapidly charging with energy, dragon features straining outward claws extending wing buds flaring, competing with everything
```

---

## 14. 저승꽃 (underworld_flower) — 윤회 10+

### boss_flower_hit — 피격
**Seed:** 83131
```
underworld flower entity dokkaebi, shuddering, petals scattering from impact point, face behind flowers flinching sad eyes squeezing shut, ghost flowers wilting instantly, vine arms recoiling, luminescent glow dimming, flower petals falling like tears
```

### boss_flower_wounded — 부상 (HP 50%)
**Seed:** 83132
```
underworld flower entity dokkaebi, half blooms wilted ghostly petals dried curled hanging limp, corpse lilies brown decaying, spider lilies losing red, vine arms thinner some severed, sad ethereal face visible through thinning flower cover, roots pulling inward defensively, fading beauty dying garden
```

### boss_flower_critical — 위기 (HP 20%)
**Seed:** 83133
```
underworld flower entity dokkaebi, nearly stripped, few ghost blooms remaining on bare dark stem-body, humanoid form fully exposed thin dark fragile covered in thorns, sad eyes flickering desperate determination, roots lashing defensively, last flowers glowing intensely burning final energy, bare winter tree defiant blossoms
```

### boss_flower_defeat — 패배
**Seed:** 83134
```
underworld flower entity dokkaebi, dissolving into final cascade of petals, dark stem-body crumbling to soil, all flowers releasing simultaneously breathtaking shower, ghost petals drifting upward like released souls, sad eyes closing peacefully face dissolving into petals, single seed remaining on mound of dark earth
```

### boss_flower_gimmick — 기믹 (강화 억제)
**Seed:** 83135
```
underworld flower entity dokkaebi, vine arms extended wide, roots erupting from below in all directions, dark thorny vines wrapping and binding, flowers glowing eerie draining light absorbing color and power, sad determined open eyes, pollen clouds drifting outward suppression spores, smothering consuming garden
```
