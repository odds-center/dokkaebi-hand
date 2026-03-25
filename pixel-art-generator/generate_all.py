"""
전체 에셋 배치 생성기 (Google Nano Banana 2)
- 순서: 보스 idle → 보스 표정/상태 → 동료 → 부적 → 카드 → 배경 → HUD → VFX
- 이미 생성된 파일은 스킵
- 표정/피격은 idle 이미지를 레퍼런스로 사용
"""
import time
from pathlib import Path
from generate import generate

OUTPUT_DIR = Path(__file__).parent / "output"


def already_exists(category: str, name: str) -> bool:
    """이미 생성된 파일인지 확인"""
    out_dir = OUTPUT_DIR / category / f"{name}.png"
    return out_dir.exists()


def gen(category: str, name: str, prompt: str, seed: int, aspect_ratio: str = None, reference_image: str = None):
    """생성 + 스킵 로직 + 딜레이"""
    if already_exists(category, name):
        print(f"  [스킵] {name} — 이미 존재")
        return
    generate(prompt, name, category=category, seed=seed, aspect_ratio=aspect_ratio, reference_image=reference_image)
    time.sleep(1)


# ============================================================
# 텍스트 방지 (모든 프롬프트 공통)
# ============================================================
NO_TEXT = "absolutely no text, no letters, no words, no writing, no symbols, no script, no kanji, no hangul, no numbers on image"

# ============================================================
# 보스 프롬프트
# ============================================================
BOSS_PREFIX = "Pixel art game boss character, beautifully crafted game sprite, front-facing centered pose, vibrant saturated colors, clean flat cel shading, bold black outlines, Korean dokkaebi folklore demon, cute chibi proportions, charming cartoon villain, inspired by Dead Cells and Hades pixel art quality,"
BOSS_SUFFIX = f"solid pure green background #00FF00, single character with margins, sharp pixels, no anti-aliasing, no gradients, no ground, no floor, no shadow, no platform, no scroll, no banner, {NO_TEXT}, premium 16-bit pixel art masterpiece"


# ============================================================
# 기타 카테고리 프롬프트
# ============================================================
COMP_PREFIX = "Pixel art small friendly companion sprite, chibi proportions, front-facing centered, flat cel shading, bold black outlines, vibrant colors, adorable mascot,"
COMP_SUFFIX = f"solid pure green background #00FF00, single character with margins, sharp pixels, no anti-aliasing, no gradients, no ground, no floor, no shadow, {NO_TEXT}, premium 16-bit pixel art"

ICON_PREFIX = "Pixel art game item icon, flat cel shading, bold black outlines, single object centered, vibrant colors, illustration only for overlay on UI frame,"
ICON_SUFFIX = f"solid pure green background #00FF00, sharp pixels, no anti-aliasing, no gradients, no ground, no floor, no shadow, no frame, no border, no card shape, no box, no container, {NO_TEXT}, 16-bit retro game style"

BG_PREFIX = "Pixel art game background scene, atmospheric, detailed environment, vibrant colors,"
BG_SUFFIX = f"sharp pixels, no anti-aliasing, no gradients, no characters, no UI, {NO_TEXT}, 16-bit retro game style"

CARD_PREFIX = "Traditional Korean hwatu hanafuda card pixel art, strictly flat cel shading only, no gradients, no smooth shading, no shadows, no highlights, no glow effects, no lighting, bold black outlines, limited color palette max 8 colors per card, solid flat color fills only, classic hwatu card composition, dark navy-black background #0A0A14,"
CARD_SUFFIX = f"solid flat dark navy-black background, strictly flat colors only, absolutely no gradients no shading no shadows no glow no lighting effects, sharp crisp pixels, no anti-aliasing, no blur, no card frame, no border, {NO_TEXT}, NES SNES 16-bit retro pixel art style"

HUD_PREFIX = "Pixel art game HUD icon, flat cel shading, single element centered, simple clear readable, vibrant colors, icon illustration only for overlay on UI,"
HUD_SUFFIX = f"solid pure green background #00FF00, sharp pixels, no ground, no floor, no shadow, no frame, no border, no box, {NO_TEXT}, 16-bit retro game style"

VFX_PREFIX = "Pixel art game VFX particle effect, flat cel shading, vibrant colors,"
VFX_SUFFIX = f"solid pure green background #00FF00, sharp pixels, no ground, no floor, no shadow, {NO_TEXT}, 16-bit retro game style"

UI_PREFIX = "Pixel art game UI frame panel, flat cel shading, bold black outlines, Korean underworld dark fantasy theme, ornate decorative border,"
UI_SUFFIX = f"solid pure green background #00FF00, sharp pixels, no anti-aliasing, no gradients, {NO_TEXT}, 16-bit retro game style"

# ============================================================
# 스타일 레퍼런스
# ============================================================
STYLE_REF = str(OUTPUT_DIR / "bosses" / "boss_glutton.png")


# ============================================================
# 보스 데이터
# ============================================================
BOSSES = [
    # === 기본 보스 (관문 1~3) ===
    ("boss_glutton", 1234, "large rotund gluttonous body, big round belly, short stubby limbs, warm reddish-orange skin, two golden curved horns, wild spiky dark hair, huge grinning mouth showing sharp white fangs, tattered brown loincloth, food crumbs on belly, hands on hips power pose"),
    ("boss_trickster", 1234, "lean wiry mischievous prankster, blue-gray skin, sly wide grin, two curved horns backward, large pointed ears, ragged dark vest, holding wooden club behind back, crouching playful pose"),
    ("boss_thief", 1234, "sneaky thief dokkaebi, dark hooded cloak, narrow shifty eyes, long nimble fingers, belt of stolen trinkets, crouching sneaky pose, dark gray-green skin, sly smirk"),
    # === 중급 보스 (관문 3~5) ===
    ("boss_flame", 1234, "large muscular fire dokkaebi engulfed in flames, charcoal-black cracked skin with glowing orange lava fissures, tall pointed horns ablaze, burning orange eyes, aggressive wide stance, clenched fists dripping flame"),
    ("boss_fog", 1234, "ethereal fog dokkaebi, body of swirling mist, barely visible form, pale translucent body, glowing white eyes in mist, wispy trailing edges, mysterious floating posture"),
    ("boss_fox", 1234, "slender elegant nine-tailed fox spirit gumiho, pointed fox ears, fluffy nine tails, pale white skin, long dark hair with purple highlights, ornate purple Korean hanbok, glowing purple eyes, subtle dangerous smile"),
    # === 상급 보스 (관문 4~7) ===
    ("boss_shadow", 1234, "shadow dokkaebi made of living darkness, ink-black body, glowing purple eyes, wispy shadow tendrils, hunched predatory posture, dark purple core glow"),
    ("boss_mirror", 1234, "crystalline dokkaebi made of fractured mirror shards, angular geometric body, reflective panels, two large reflective eyes, sharp jagged edges, silver and crystal blue"),
    ("boss_curse_ghost", 1234, "vengeful curse ghost, twisted form, long disheveled black hair covering face, one glowing red eye through hair, pale skin with curse marks, tattered white burial robes, ghostly floating"),
    ("boss_viper", 1234, "venomous serpent dokkaebi, snake body with humanoid upper torso, dark green scales, forked tongue, venomous yellow slit eyes, cobra hood around head, dripping purple venom"),
    # === 고급 보스 (관문 6~9) ===
    ("boss_volcano", 1234, "massive volcanic dokkaebi, dark basalt-gray rocky skin, glowing molten orange-red cracks, volcanic crater head with magma, enormous stocky build, rocky fists dripping lava"),
    ("boss_gold", 1234, "regal dokkaebi entirely gleaming gold, polished golden skin, ornate golden antler horns with jewels, golden armor with coin motifs, wide greedy grin with golden teeth, gold coin eyes"),
    ("boss_corridor", 1234, "tall unnaturally thin dokkaebi, impossibly elongated limbs, pale gray-blue skin, long spindly fingers, perpetual unsettling smile, spiraling vortex eyes, flowing dark robes"),
    ("boss_clock", 1234, "clockwork dokkaebi, body with clock faces, bronze mechanical skin with gears, large clock face in chest, clock hands as horns, pendulum swinging, dark bronze and brass"),
    ("boss_bone_shaman", 1234, "bone shaman dokkaebi, decorated with skulls and bones, shaman drum in hand, bone staff, skull mask, dark ritual robes with bone charms, blue shamanic energy"),
    ("boss_blood_rain", 1234, "blood rain dokkaebi, body dripping crimson rain, dark red-maroon skin, hollow eye sockets weeping blood, arms spread summoning rain, tattered crimson robes"),
    ("boss_nightmare", 1234, "nightmare dokkaebi, distorted shifting dreamlike body, multiple overlapping eyes, body edges rippling, dark purple-black skin, floating unnatural pose"),
    # === 10관문 보스 ===
    ("boss_yeomra", 1234, "King Yama massive deity judge, six arms holding sword skull mirror scales lotus, elaborate royal Korean robes deep gold and crimson, ornate crown, golden glowing eyes, long dark beard, divine golden aura, final boss"),
    # === 재앙 보스 ===
    ("boss_skeleton_general", 1234, "towering skeleton general made of bones, rusted Korean general armor, horned bone helmet, empty eye sockets with cold blue ghost fire, gripping massive bone sword, commanding military posture"),
    ("boss_ninetail_king", 1234, "supreme nine-tailed fox king standing upright, nine enormous tails fanned out, dark fur with golden markings, fox face with golden eyes, Korean royal crown, ceremonial robes"),
    ("boss_imugi", 1234, "colossal serpentine imugi unascended dragon, snake body coiled rising, dark blue-black iridescent scales, massive horned head, piercing yellow dragon eyes, emerging claws, lightning along scales"),
    ("boss_underworld_flower", 1234, "hauntingly beautiful flower entity, humanoid figure of ghostly luminescent flowers, dark stem-body, pale ghostly spider lilies, face obscured by petals with sad eyes, vine-like arms"),
    # === 특수/영적 보스 ===
    ("boss_wonhon", 1234, "wandering lost spirit, translucent pale ghostly humanoid, tattered white funeral robes, sorrowful empty eyes, floating above ground, faint blue spectral aura, reaching hands"),
    ("boss_jeoseung_saja", 1234, "Korean grim reaper jeoseung saja, tall imposing figure in black traditional hat and robes, pale stern face, holding soul-catching rope, dark authoritative presence"),
    ("boss_gumiho", 1234, "beautiful nine-tailed fox gumiho in human female form, elegant Korean hanbok, fox ears visible, nine white tails, holding glowing fox bead, seductive dangerous beauty"),
    ("boss_haetae", 1234, "mythical haetae lion-dog guardian beast, stocky muscular body, curly mane, single horn on forehead, scaled body, fierce protective stance, stone-gray and gold"),
    ("boss_bulgasari", 1234, "bulgasari iron-eating beast, massive dark metallic body, sharp jagged mouth, small fierce eyes, armored hide, four stocky legs, eating metal and weapons"),
    ("boss_san_shin", 1234, "Korean mountain god san shin, elderly wise man with long white beard, sitting on tiger, holding magical staff, pine tree behind, divine mountain spirit aura"),
    ("boss_yongwang", 1234, "dragon king yongwang, majestic Eastern dragon with long serpentine body, blue-green scales, golden whiskers, holding magic pearl, ocean waves around, regal crown"),
    # === 변형 보스 ===
    ("boss_cheonji_ma", 1234, "heaven-earth demon cheonji ma, massive demonic figure split half-light half-dark, one side celestial gold other side infernal black, two-faced cosmic entity"),
    ("boss_tal_gwangdae", 1234, "masked jester tal gwangdae, Korean traditional mask on face, colorful patchwork jester outfit, dancing pose, holding fan and bells, chaotic trickster"),
    ("boss_dalgyal", 1234, "egg ghost dalgyal gwishin, smooth white oval egg-shaped head with no face, pale white body, eerily featureless, unsettling blank presence, white robes"),
    ("boss_mul_gwishin", 1234, "water ghost mul gwishin, dripping wet ghostly figure, long dark wet hair, waterlogged pale blue-green skin, seaweed tangled, reaching out from water, drowning victim ghost"),
    ("boss_mansin", 1234, "Korean shaman mudang mansin, colorful ceremonial shaman robes, holding ritual bells and knife, ecstatic dance pose, spiritual energy ribbons swirling"),
    ("boss_myeongbu_gwanri", 1234, "underworld bureaucrat clerk, formal Korean official robes and hat, holding ledger book and brush, stern administrative expression, ghostly pale, official seal"),
    ("boss_heuk_muin", 1234, "black warrior heuk muin, dark armored martial artist, black Korean warrior armor, dual swords, combat stance, dark energy aura, fierce masked face"),
    ("boss_samjokgu", 1234, "three-legged dog samjokgu, mythical three-legged hunting dog, fiery orange fur, three powerful legs, glowing eyes, loyal but fierce guardian beast, flames on paws"),
    ("boss_baeksa", 1234, "white serpent baeksa, enormous elegant white snake, coiled upright, hood spread like cobra, piercing blue eyes, silvery white scales, mystical cold aura"),
    ("boss_cheolma", 1234, "iron horse demon cheolma, mechanical dark iron horse body with rider fused together, steam venting from joints, glowing red eyes, heavy iron hooves, dark metal armor"),
    ("boss_duggaebi", 1234, "giant toad spirit duggaebi, massive warty dark green toad, sitting upright, bulging golden eyes, wide mouth, wearing small crown, toxic purple drool, swamp creature"),
    ("boss_taepoong", 1234, "typhoon spirit taepoong, swirling wind entity, body made of spiraling storm clouds, fierce wind-swept form, lightning eyes, debris orbiting, howling storm presence"),
    ("boss_jisin", 1234, "earthquake spirit jisin, massive stone golem cracking apart, rocky brown body with glowing seismic cracks, heavy fists slamming ground, dust and debris falling"),
    ("boss_kkum_gwishin", 1234, "dream ghost kkum gwishin, ethereal shifting figure between sleep and wake, half-transparent, starry cosmic patterns on body, drowsy hypnotic eyes, floating in dreamlike pose"),
    ("boss_geoulgwi", 1234, "mirror demon geoulgwi, body made of dark cracked mirrors, reflecting distorted images, angular sharp edges, one large mirror face showing warped reflection, silver-black"),
    ("boss_mangja_wang", 1234, "king of the dead mangja wang, skeletal king on dark throne, crown of bones, tattered royal purple robes, holding scepter of skulls, hollow burning eyes, undead sovereign"),
    ("boss_cheonnyeon_namu", 1234, "millennium ancient tree spirit, massive gnarled old tree with face in trunk, twisted branches like arms, glowing green eyes in bark, moss and vines covering, ancient wise presence"),
    ("boss_bul_dokkebi", 1234, "fire will-o-wisp dokkaebi, small floating flame spirit body, bright blue-green ghostly fire core, flickering wispy form, mischievous glowing eyes in flames"),
    # === 변형 저승사자 ===
    ("boss_gwangpok_saja", 1234, "berserk reaper, muscular aggressive jeoseung saja, torn black robes, wild red eyes, dual scythes, berserk fury stance, dark red aura, chains breaking"),
    ("boss_naenghyeol_saja", 1234, "cold-blooded reaper, ice-cold jeoseung saja, frosted blue-black robes, frozen breath, icicle scythe, emotionless frozen expression, ice crystals forming"),
    ("boss_eolin_saja", 1234, "young rookie reaper, small young jeoseung saja, oversized black robes dragging, nervous uncertain expression, holding scythe too big for body, apprentice reaper"),
    # === 변형 구미호 ===
    ("boss_cheonnyeon_gumiho", 1234, "ancient thousand-year gumiho, extremely powerful fox spirit, nine massive golden tails, dark ornate robes, ancient knowing eyes, overwhelming mystical power aura"),
    ("boss_baek_gumiho", 1234, "white gumiho, pure white nine-tailed fox, pristine white fur and tails, ice blue eyes, elegant white Korean hanbok, cold beautiful ethereal presence"),
    # === 변형 도깨비 ===
    ("boss_bul_dokkaebi", 1234, "fire dokkaebi variant, red-orange flaming dokkaebi, body wreathed in fire, burning club weapon, aggressive fire-breathing, intense heat aura"),
    ("boss_eol_dokkaebi", 1234, "ice dokkaebi, frozen blue-white dokkaebi, icicle horns, frost-covered body, frozen club weapon, cold breath, ice crystal aura, blue skin"),
    ("boss_wang_dokkaebi", 1234, "dokkaebi king, largest most powerful dokkaebi, massive golden horns, royal dark robes with dokkaebi patterns, giant golden club, commanding king presence"),
    # === 변형 원혼/귀신 ===
    ("boss_han_wonhon", 1234, "grudge spirit, dark vengeful spirit consumed by hatred, black-red aura of resentment, distorted angry face, clawed hands, dark energy radiating, cursed presence"),
    ("boss_cheonyeo_gwishin", 1234, "maiden ghost cheonyeo gwishin, pale beautiful young woman ghost in white burial dress, long straight black hair covering one eye, sorrowful expression, floating gracefully"),
    ("boss_janggun_gwishin", 1234, "general ghost janggun gwishin, armored Korean general spirit, battle-damaged ancient armor, commanding military presence, ghostly war banner, spectral army behind"),
    # === 변형 신수 ===
    ("boss_no_yongwang", 1234, "old dragon king, aged weathered dragon, gray-blue faded scales, long white whiskers, wise but fierce ancient eyes, storms gathering, elder dragon presence"),
    ("boss_no_sanshin", 1234, "angry mountain god, wrathful san shin with earthquake power, cracking earth beneath, red angry face, wild white hair flowing, divine rage, mountain crumbling"),
    ("boss_hwangeum_haetae", 1234, "golden haetae, legendary golden lion-dog, entirely gold body, brilliant golden mane, golden horn, jeweled eyes, divine judge beast, radiant golden aura"),
    ("boss_cheolsik_bulgasari", 1234, "iron bulgasari, massive dark iron-plated beast, completely armored in black iron, glowing red eyes through iron visor, crushing iron jaws, indestructible metal body"),
]

# ============================================================
# STEP 1: 보스 스프라이트
# ============================================================
def generate_bosses():
    print(f"\n=== STEP 1: 보스 스프라이트 ({len(BOSSES)}종) ===\n")
    for boss_id, seed, desc in BOSSES:
        gen("bosses", boss_id, f"{BOSS_PREFIX} {desc}, {BOSS_SUFFIX}", seed, reference_image=STYLE_REF)


# ============================================================
# STEP 3: 동료 도깨비
# ============================================================
def generate_companions():
    print("\n=== STEP 3: 동료 도깨비 (7종) ===\n")
    companions = [
        ("comp_glutton", 71001, "small round-bodied tamed dokkaebi sitting happily, reddish-orange skin, broken horns, friendly goofy grin, chubby mascot, holding small rice cake, cheerful crescent eyes"),
        ("comp_trickster", 71002, "small lean tamed dokkaebi crouching playfully, blue-gray skin, curved horns, mischievous wink, holding club over shoulder, friendly imp"),
        ("comp_fox", 71003, "small elegant tamed fox spirit sitting gracefully, tail curled around body, pale skin, fox ears, warm gentle eyes, simplified purple hanbok, holding glowing orb"),
        ("comp_mirror", 71004, "small crystalline tamed dokkaebi, reflective mirror surfaces, angular body, calm expression, holding small round mirror, silver crystal blue"),
        ("comp_flame", 71005, "small tamed fire dokkaebi, gentle warming flames, charcoal skin, softer orange glow like campfire embers, calm expression, small controlled flames above horns"),
        ("comp_shadow", 71006, "small tamed shadow dokkaebi hovering, cat-like silhouette, glowing purple eyes softer and curious, shadow wisps trailing like smoky tail"),
        ("comp_boatman", 71007, "small Sanzu River ferryman, weathered elderly Korean man, cone straw hat, simple dark ferryman clothes, holding miniature oar, faint knowing smile"),
    ]
    for comp_id, seed, desc in companions:
        gen("companions", comp_id, f"{COMP_PREFIX} {desc}, {COMP_SUFFIX}", seed, aspect_ratio="2:3", reference_image=STYLE_REF)


# ============================================================
# STEP 4: 부적 아이콘
# ============================================================
def generate_talismans():
    print("\n=== STEP 4: 부적 아이콘 (20종) ===\n")
    talismans = [
        ("talisman_blood_oath", 73001, "crimson blood drop on small white paper talisman, bright red drop, pale paper"),
        ("talisman_red_gate", 73002, "tiny red Korean hongsalmun gate, two red pillars with red beam across top"),
        ("talisman_samdo_ferry", 73003, "small brown wooden boat with single tiny cyan ghost flame floating above"),
        ("talisman_dokkaebi_club", 73004, "short thick wooden club with metal studs, classic dokkaebi bangmangi"),
        ("talisman_virtue_gate", 73005, "small stone arch gate with green ribbon tied at top"),
        ("talisman_samsara_bead", 73006, "single round jade-green prayer bead with tiny spiral mark inside, glowing sphere"),
        ("talisman_dokkaebi_hat", 73011, "cone-shaped dark Korean dokkaebi invisibility hat, dark fabric with faint purple shimmer"),
        ("talisman_moonlight_fox", 73012, "small white fox silhouette sitting with yellow crescent moon above"),
        ("talisman_underworld_mirror", 73013, "small round traditional Korean bronze mirror, dark bronze rim, bright reflective center"),
        ("talisman_girin_horn", 73014, "single curved golden horn, bright gold color, crescent-like horn shape"),
        ("talisman_fate_dice", 73015, "two small wooden dice side by side, dark brown cubes, red dot marks"),
        ("talisman_scale_desire", 73017, "tiny golden balance scale tilted to one side, simple gold scale shape"),
        ("talisman_reaper_ledger", 73021, "dark ancient book partially open with red seal stamp, dark brown book, red seal"),
        ("talisman_madness_bright", 73022, "bright golden star shape with jagged chaotic rays shooting outward, starburst"),
        ("talisman_yeomra_seal", 73023, "square red seal stamp, bright crimson red square with dark pattern inside"),
        ("talisman_heavenly_lute", 73024, "small traditional Korean biwa lute instrument, dark brown body, pale strings"),
        ("talisman_hellflame", 73025, "single intense flame, orange-red outer with white-hot center, classic fire shape"),
        ("talisman_doom", 73031, "cracked black talisman paper with single glowing red eye in center, cursed"),
        ("talisman_phantom", 73032, "pale ghostly hand reaching upward, fingers spread, translucent pale gray-white"),
        ("talisman_oblivion_ribbon", 73033, "dark gray ribbon with loose knot, fraying ends dissolving into pixels"),
    ]
    for tal_id, seed, desc in talismans:
        gen("talismans", tal_id, f"{ICON_PREFIX} {desc}, {ICON_SUFFIX}", seed, reference_image=STYLE_REF)


# ============================================================
# STEP 5: 배경
# ============================================================
def generate_backgrounds():
    print("\n=== STEP 5: 배경 (14종) ===\n")
    backgrounds = [
        ("bg_main_menu", 71001, "Korean afterlife Sanzu River scene, dark misty river, old wooden ferry boat on still water, distant shore in fog, floating blue-green ghost flames, dead willow silhouettes, crescent moon, eerie calm"),
        ("bg_shop", 71007, "Korean afterlife marketplace stall, wooden counter with magical items, hanging paper lanterns with blue ghost fire, shelves of talismans, old coins, incense smoke, dark purple lighting"),
        ("bg_ghost_market", 71002, "Korean underworld night market alley, narrow stone street, ghostly merchant stalls, red and blue paper lanterns, fog rolling, purple-blue atmospheric lighting"),
        ("bg_yellow_spring", 71003, "endless foggy road to Korean underworld, pale dirt path to vanishing point, dead twisted bare trees, old signposts, thick fog, dim yellow sky"),
        ("bg_hell_pit", 71004, "Korean underworld fire pit hellscape, cracked ground with glowing lava fissures, jagged obsidian rocks, fire erupting, dark smoke, orange-red sky, chains"),
        ("bg_archive_hall", 71005, "Korean underworld records archive library, towering dark wooden bookshelves with scrolls, long corridor, dim candlelight, floating dust, dark wood gold trim"),
        ("bg_yama_palace", 71006, "Korean underworld Yama judgment palace throne room, massive ornate throne, grand pillars gold and crimson, karma mirror, ceremonial banners, divine golden light"),
        ("bg_volcanic_hellscape", 71008, "volcanic hellscape with erupting volcanoes, rivers of molten lava, raining ash, dark crimson sky, bubbling lava pools, charred landscape"),
        ("bg_golden_maze", 71009, "golden labyrinth maze of treasure, polished gold walls, piles of coins and jewels, golden pillars, dead-end passages, warm golden glow"),
        ("bg_infinite_corridor", 71010, "impossible infinite corridor, Escher-like architecture, doors leading to more corridors, repeating patterns, pale blue-gray stone, surreal geometry"),
        ("bg_shadow_city", 71011, "city made of living shadows, dark building silhouettes shifting, streets of darkness, faint purple lights, shadow tendrils, ink-black sky"),
        ("bg_chaos_gate", 71012, "massive ancient gate between worlds, enormous stone gateway with swirling chaotic energy portal, reality cracking, cosmic void beyond, lightning"),
        ("bg_main_menu_v2", 71013, "close-up Sanzu River ferry, old wooden boat with lantern at bow, ghostly mist, distant shore lights, floating ghost flames, bamboo oar"),
        ("bg_ghost_market_v2", 71014, "elevated wide view Korean underworld night market, rooftops of ghostly stalls, sea of colored paper lanterns, winding narrow streets, misty purple-blue night"),
    ]
    for bg_id, seed, desc in backgrounds:
        gen("backgrounds", bg_id, f"{BG_PREFIX} {desc}, {BG_SUFFIX}", seed, aspect_ratio="16:9")


# ============================================================
# STEP 6: 화투 카드
# ============================================================
def generate_cards():
    print("\n=== STEP 4: 화투 카드 (48장) ===\n")

    # 전통 화투 구도 + 저승 테마, 검정 배경, 강한 식별성
    cards = [
        # ===== 1월 송학 (소나무+학) — 빨간 해, 흰 학, 짙은 소나무 =====
        ("m01_gwang", 1001, "JANUARY PINE CRANE GWANG: large vivid red sun disc in upper right, elegant white crane with red crown standing on thick twisted dark pine tree, dense dark green pine needle clusters, classic hwatu composition"),
        ("m01_hongdan", 1002, "JANUARY PINE RED RIBBON: two thick dark pine tree trunks with dense green needle clusters, bright vivid RED RIBBON banner draped horizontally across middle, classic hwatu red ribbon card"),
        ("m01_pi1", 1003, "JANUARY PINE JUNK: single dark pine tree trunk with spreading green needle clusters at top, simple composition, sparse"),
        ("m01_pi2", 1004, "JANUARY PINE JUNK: two thin pine branches crossing, small green needle tufts, very simple minimal composition"),

        # ===== 2월 매화 (매화+꾀꼬리) — 붉은 매화, 노란 새 =====
        ("m02_yeolkkeut", 2001, "FEBRUARY PLUM WARBLER: bright golden-yellow bush warbler bird perched on dark angular plum branch, vivid red-pink plum blossoms with five petals, classic hwatu animal card"),
        ("m02_hongdan", 2002, "FEBRUARY PLUM RED RIBBON: dark angular plum branches with red-pink plum blossoms, bright vivid RED RIBBON banner draped horizontally, classic hwatu red ribbon card"),
        ("m02_pi1", 2003, "FEBRUARY PLUM JUNK: single dark plum branch with three red-pink plum blossoms, simple"),
        ("m02_pi2", 2004, "FEBRUARY PLUM JUNK: short plum twig with two small blossoms, one petal falling, minimal"),

        # ===== 3월 벚꽃 (벚꽃+장막) — 분홍 꽃, 빨간 커튼 =====
        ("m03_gwang", 3001, "MARCH CHERRY BLOSSOM CURTAIN GWANG: large bright RED ceremonial curtain taking lower third with gold fringe, cherry blossom tree above in full bloom with many pale pink flowers, dark trunk, petals floating, classic hwatu"),
        ("m03_hongdan", 3002, "MARCH CHERRY BLOSSOM RED RIBBON: cherry blossom branches with pale pink flower clusters, bright vivid RED RIBBON banner draped horizontally, falling petals, classic hwatu"),
        ("m03_pi1", 3003, "MARCH CHERRY BLOSSOM JUNK: cherry blossom branch with pink-white flower cluster at top, dark branch"),
        ("m03_pi2", 3004, "MARCH CHERRY BLOSSOM JUNK: small twig with two cherry blossoms, scattered petals drifting, minimal"),

        # ===== 4월 흑싸리 (등나무+두견새) — 검은 덩굴, 새 =====
        ("m04_yeolkkeut", 4001, "APRIL BLACK WISTERIA CUCKOO: small dark cuckoo bird in flight diving downward, black wisteria vines hanging densely from top, dark purple-black cascading leaves, classic hwatu"),
        ("m04_chodan", 4002, "APRIL BLACK WISTERIA RED RIBBON: dense black wisteria vines hanging from top, cascading dark leaves, bright vivid RED RIBBON woven through vines horizontally, classic hwatu cho-dan"),
        ("m04_pi1", 4003, "APRIL BLACK WISTERIA JUNK: cluster of black wisteria vines hanging, dark scalloped leaf shapes"),
        ("m04_pi2", 4004, "APRIL BLACK WISTERIA JUNK: two small dark vine clusters hanging from top, sparse, minimal"),

        # ===== 5월 난초 (창포+다리) — 보라 꽃, 나무 다리 =====
        ("m05_yeolkkeut", 5001, "MAY IRIS BRIDGE: arched wooden bridge crossing over water in center, vivid purple iris flowers with yellow centers growing below bridge, long green sword-shaped leaves, classic hwatu"),
        ("m05_chodan", 5002, "MAY IRIS RED RIBBON: vivid purple iris flowers with yellow centers, long green sword leaves growing upward, bright vivid RED RIBBON draped horizontally, classic hwatu cho-dan"),
        ("m05_pi1", 5003, "MAY IRIS JUNK: single purple iris flower with yellow center, long green leaves"),
        ("m05_pi2", 5004, "MAY IRIS JUNK: two small purple iris buds on thin stems, sparse green leaves, minimal"),

        # ===== 6월 모란 (모란+나비) — 큰 붉은 꽃, 나비 =====
        ("m06_yeolkkeut", 6001, "JUNE PEONY BUTTERFLY: two colorful butterflies with orange-black wings fluttering above large vivid red peony flowers, lush layered petals, dark green broad leaves, classic hwatu"),
        ("m06_chungdan", 6002, "JUNE PEONY BLUE RIBBON: large vivid red peony flowers with layered petals, dark green leaves, bright BLUE RIBBON banner draped horizontally, classic hwatu cheong-dan"),
        ("m06_pi1", 6003, "JUNE PEONY JUNK: single large red peony bloom with layered round petals, dark leaves"),
        ("m06_pi2", 6004, "JUNE PEONY JUNK: small red peony bud beginning to open, single stem, minimal"),

        # ===== 7월 홍싸리 (싸리+멧돼지) — 붉은 싸리, 멧돼지 =====
        ("m07_yeolkkeut", 7001, "JULY BUSH CLOVER BOAR: stocky dark brown wild boar charging through, red-pink bush clover flowers cascading from above, thin arching stems with round flower clusters, classic hwatu"),
        ("m07_chodan", 7002, "JULY BUSH CLOVER RED RIBBON: red-pink bush clover branches arching downward with round flower clusters, bright vivid RED RIBBON draped horizontally, classic hwatu cho-dan"),
        ("m07_pi1", 7003, "JULY BUSH CLOVER JUNK: single arching bush clover branch with red-pink flower clusters"),
        ("m07_pi2", 7004, "JULY BUSH CLOVER JUNK: sparse thin clover sprigs with few small flowers, minimal"),

        # ===== 8월 공산 (억새+보름달) — 큰 달, 억새, 산 =====
        ("m08_gwang", 8001, "AUGUST FULL MOON GWANG: very large bright yellow-white full moon circle dominating upper half, dark mountain silhouette ridge below, silver-white pampas grass plumes swaying in foreground, classic hwatu moon card"),
        ("m08_yeolkkeut", 8002, "AUGUST GEESE: flock of wild geese flying in V-formation as dark silhouettes, silver pampas grass below, orange-purple sunset sky, classic hwatu"),
        ("m08_pi1", 8003, "AUGUST PAMPAS JUNK: silver-white pampas grass plumes on thin stems swaying"),
        ("m08_pi2", 8004, "AUGUST PAMPAS JUNK: two thin pampas grass stems with small seed heads, minimal"),

        # ===== 9월 국화 (국화+술잔) — 노란 꽃, 빨간 잔 =====
        ("m09_yeolkkeut", 9001, "SEPTEMBER CHRYSANTHEMUM CUP: ornate small red sake cup in center, bright vivid yellow chrysanthemum flowers surrounding it, many layered petals, dark green rounded leaves, classic hwatu"),
        ("m09_chungdan", 9002, "SEPTEMBER CHRYSANTHEMUM BLUE RIBBON: bright yellow chrysanthemum flowers with layered petals, dark green leaves, bright BLUE RIBBON banner draped horizontally, classic hwatu cheong-dan"),
        ("m09_pi1", 9003, "SEPTEMBER CHRYSANTHEMUM JUNK: single bright yellow chrysanthemum bloom with layered petals"),
        ("m09_pi2", 9004, "SEPTEMBER CHRYSANTHEMUM JUNK: small yellow chrysanthemum bud, single stem, minimal"),

        # ===== 10월 단풍 (단풍+사슴) — 붉은 단풍, 사슴 =====
        ("m10_yeolkkeut", 10001, "OCTOBER MAPLE DEER: graceful brown deer with small antlers standing among vivid red-orange maple branches, looking back over shoulder, bright autumn maple leaves, classic hwatu"),
        ("m10_chungdan", 10002, "OCTOBER MAPLE BLUE RIBBON: vivid red-orange maple leaves on dark branches, five-pointed leaf shapes, bright BLUE RIBBON banner draped horizontally, autumn colors, classic hwatu cheong-dan"),
        ("m10_pi1", 10003, "OCTOBER MAPLE JUNK: dark branch with vivid red-orange maple leaves, autumn"),
        ("m10_pi2", 10004, "OCTOBER MAPLE JUNK: few red-orange maple leaves falling from thin branch, minimal"),

        # ===== 11월 오동 (오동+봉황) — 금빛 봉황, 넓은 잎 =====
        ("m11_gwang", 11001, "NOVEMBER PAULOWNIA PHOENIX GWANG: magnificent golden-red phoenix bird with elaborate long tail feathers perched on paulownia tree, broad green paulownia leaves, one wing spread dramatically, divine golden glow, classic hwatu"),
        ("m11_yeolkkeut", 11002, "NOVEMBER PAULOWNIA: paulownia tree with distinctive broad three-lobed leaves, dark trunk branching upward, large green leaves"),
        ("m11_pi1", 11003, "NOVEMBER PAULOWNIA JUNK: single paulownia branch with broad three-lobed leaf"),
        ("m11_pi2", 11004, "NOVEMBER PAULOWNIA JUNK: small paulownia leaf on thin stem, minimal"),

        # ===== 12월 비 (비+버들+우산 사내) — 비, 버들, 우산 쓴 사람 =====
        ("m12_gwang", 12001, "DECEMBER RAIN MAN GWANG: dark silhouette figure holding bright red umbrella standing in heavy rain, weeping willow branches from above, dramatic rain lines filling background, lightning bolt in dark sky, classic hwatu rain card"),
        ("m12_yeolkkeut", 12002, "DECEMBER SWALLOW: dark swallow bird with red throat and forked tail swooping through rain, weeping willow branches hanging, rain lines, classic hwatu"),
        ("m12_pi1", 12003, "DECEMBER WILLOW JUNK: weeping willow branches hanging downward with thin drooping leaves, rain lines"),
        ("m12_pi2", 12004, "DECEMBER WILLOW JUNK: sparse thin willow branches, few drooping leaves, light rain, minimal"),
    ]
    for card_id, seed, desc in cards:
        gen("card-illustrations", card_id, f"{CARD_PREFIX} {desc}, {CARD_SUFFIX}", seed, aspect_ratio="2:3", reference_image=STYLE_REF)


# ============================================================
# STEP 7: HUD 아이콘
# ============================================================
def generate_hud_icons():
    print("\n=== STEP 7: HUD 아이콘 (12종) ===\n")
    huds = [
        ("hud_heart_full", 78001, "full red heart, solid bright crimson pixel heart shape, classic game health icon"),
        ("hud_heart_half", 78002, "half red heart, left half crimson right half dark gray empty, half health"),
        ("hud_heart_empty", 78003, "empty heart outline, dark gray hollow heart shape, empty health slot"),
        ("hud_card_back", 78011, "tiny card back icon, dark blue-purple rectangle with small pattern, deck indicator"),
        ("hud_card_special", 78012, "golden star on small card shape, special card indicator, bright gold star"),
        ("hud_turn_indicator", 78023, "small arrow pointing right, bright golden turn arrow, current turn indicator"),
        ("hud_gimmick_warning", 78061, "warning triangle with exclamation mark, red alert danger indicator"),
        ("hud_talisman_empty", 78041, "empty square slot frame, dark border with subtle pattern, empty slot"),
        ("hud_talisman_filled", 78042, "square slot frame with golden glow inside, active talisman equipped"),
        ("hud_talisman_locked", 78043, "square slot frame with padlock overlay, locked slot, dark gray"),
        ("hud_companion_empty", 78051, "circular empty companion slot, dark ring border with horn decoration"),
        ("hud_companion_active", 78052, "circular companion slot with bright glow, active companion, golden glow"),
    ]
    for hud_id, seed, desc in huds:
        gen("hud-icons", hud_id, f"{HUD_PREFIX} {desc}, {HUD_SUFFIX}", seed, reference_image=STYLE_REF)


# ============================================================
# STEP 8: VFX 파티클
# ============================================================
def generate_vfx():
    print("\n=== STEP 8: VFX 파티클 (6종) ===\n")
    vfx = [
        ("vfx_dokkaebi_fire", 76001, "floating supernatural ghost flame, blue-green dokkaebi fire wisp, ethereal flickering, cyan and teal, glowing core"),
        ("vfx_ink_bloom", 76002, "ink splash spreading outward, dark black ink bloom, splatter pattern with tendrils, calligraphy ink drop"),
        ("vfx_blood_splash", 76003, "blood red splash burst, crimson droplets spraying from center, impact splatter, dark to bright red"),
        ("vfx_gold_sparkle", 76004, "golden sparkle burst, star-shaped golden glitter radiating, warm gold shimmer, multiple small stars"),
        ("vfx_burning_paper", 76005, "talisman paper burning, yellow paper curling with orange fire edges, ash particles floating"),
        ("vfx_smoke_wisp", 76006, "wispy smoke puff, gray-white smoke cloud rising and dissipating, curling smoke tendril"),
    ]
    for vfx_id, seed, desc in vfx:
        gen("vfx", vfx_id, f"{VFX_PREFIX} {desc}, {VFX_SUFFIX}", seed, reference_image=STYLE_REF)


# ============================================================
# STEP 8: UI 프레임
# ============================================================
def generate_ui_frames():
    print("\n=== STEP 8: UI 프레임 (10종) ===\n")
    ui_frames = [
        ("ui_card_frame_gwang", 79001, "hwatu card frame for Gwang bright card, golden ornate border, dark inner area, royal gold trim, prestigious feeling, vertical rectangle card shape"),
        ("ui_card_frame_tti", 79002, "hwatu card frame for ribbon card, red-accented border, dark inner area, elegant trim, vertical rectangle card shape"),
        ("ui_card_frame_yeolkkeut", 79003, "hwatu card frame for animal card, blue-accented border, dark inner area, nature motif trim, vertical rectangle card shape"),
        ("ui_card_frame_pi", 79004, "hwatu card frame for junk card, simple gray border, dark inner area, minimal trim, vertical rectangle card shape"),
        ("ui_talisman_frame", 79011, "talisman equipment slot frame, square ornate border, dark purple inner area, mystical Korean talisman paper edge, magical glow trim"),
        ("ui_panel_dark", 79021, "dark UI panel background, Korean underworld stone texture, subtle ornate border, dark navy-purple interior, wide rectangular panel"),
        ("ui_panel_shop", 79022, "shop UI panel, wooden market stall frame, warm brown border with lantern decorations, dark interior, wide rectangular"),
        ("ui_button_normal", 79031, "game button frame normal state, dark stone button shape, subtle border glow, rounded rectangle, compact"),
        ("ui_button_hover", 79032, "game button frame hover state, golden glowing border, bright highlight, rounded rectangle, compact"),
        ("ui_hp_bar_frame", 79041, "boss HP bar frame, long horizontal bar border, dark ornate frame with skull decorations at ends, empty interior for fill"),
    ]
    for ui_id, seed, desc in ui_frames:
        gen("ui-frames", ui_id, f"{UI_PREFIX} {desc}, {UI_SUFFIX}", seed, aspect_ratio="16:9", reference_image=STYLE_REF)


# ============================================================
# 메인 실행
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("도깨비의 패 — 전체 에셋 생성 (Nano Banana 2)")
    print("=" * 60)

    # 순서: 보스 → 동료 → 부적 → 카드 → 배경 → HUD → VFX → UI
    generate_bosses()        # STEP 1: 22종
    generate_companions()    # STEP 2: 7종
    generate_talismans()     # STEP 3: 20종
    generate_cards()         # STEP 4: 48종
    generate_backgrounds()   # STEP 5: 14종
    generate_hud_icons()     # STEP 6: 12종
    generate_vfx()           # STEP 7: 6종
    generate_ui_frames()     # STEP 8: 10종

    total = len(BOSSES) + 7 + 20 + 48 + 14 + 12 + 6 + 10
    print("\n" + "=" * 60)
    print(f"생성 완료! 총 {total}종")
    print(f"  보스: {len(BOSSES)} | 동료: 7 | 부적: 20 | 카드: 48")
    print("  배경: 14 | HUD: 12 | VFX: 6 | UI: 10")
    print("=" * 60)
