"""
전체 에셋 배치 생성기
- sd-prompts-flux/ 프롬프트를 순서대로 생성
- 이미 생성된 파일은 스킵
"""
import time
from pathlib import Path
from generate import generate

OUTPUT_DIR = Path(__file__).parent / "output"


def already_exists(category: str, name: str) -> bool:
    """이미 생성된 파일인지 확인"""
    cat_dirs = {
        "bosses": "bosses",
        "boss-expressions": "boss-expressions",
        "companions": "companions",
        "talismans": "talismans",
        "backgrounds": "backgrounds",
        "card-illustrations": "card-illustrations",
        "card-extras": "card-extras",
        "icons": "icons",
        "vfx": "vfx",
        "ui-frames": "ui-frames",
        "hud-icons": "hud-icons",
    }
    out_dir = cat_dirs.get(category, category)
    path = OUTPUT_DIR / out_dir / f"{name}.png"
    return path.exists()


def gen(category: str, name: str, prompt: str, seed: int, aspect_ratio: str = None):
    """생성 + 스킵 로직 + 딜레이"""
    if already_exists(category, name):
        print(f"  [스킵] {name} — 이미 존재")
        return
    generate(prompt, name, category=category, seed=seed, aspect_ratio=aspect_ratio)
    time.sleep(1)  # API 과부하 방지


# ============================================================
# 공통 프롬프트 조각
# ============================================================
BOSS_PREFIX = "Simple 16-bit pixel art game boss sprite, low resolution retro style, limited color palette max 16 colors, Korean dokkaebi folklore demon,"
BOSS_SUFFIX = "solid pure green chroma key background, clean pixel grid, no anti-aliasing, no gradients, no text, no letters, no words, no watermark, no signature, inspired by Binding of Isaac and Shovel Knight pixel art style"

EXPR_PREFIX = "Simple 16-bit pixel art game boss sprite expression variant, low resolution retro style, limited color palette max 16 colors, Korean dokkaebi folklore demon, same character design but different expression,"
EXPR_SUFFIX = BOSS_SUFFIX

ICON_PREFIX = "Simple 16-bit pixel art game item icon, low resolution retro style, limited color palette max 8 colors, single item centered,"
ICON_SUFFIX = "solid pure green chroma key background, clean pixel grid, no anti-aliasing, no gradients, no text, no letters, no words, no watermark, no signature, inspired by Binding of Isaac item icon style"

BG_PREFIX = "Simple 16-bit pixel art game background, low resolution retro style, limited color palette, atmospheric,"
BG_SUFFIX = "clean pixel grid, no anti-aliasing, no gradients, no text, no letters, no words, no watermark, no signature, no characters, inspired by Celeste and Eastward background style"

CARD_PREFIX = "Simple 16-bit pixel art hwatu flower card illustration, low resolution retro style, limited color palette max 12 colors, traditional Korean card art,"
CARD_SUFFIX = "solid pure green chroma key background, clean pixel grid, no anti-aliasing, no gradients, no text, no letters, no words, no watermark, no signature, retro game card art style"

COMP_PREFIX = "Simple 16-bit pixel art small friendly companion sprite, low resolution retro style, limited color palette, chibi proportions, front-facing,"
COMP_SUFFIX = BOSS_SUFFIX

HUD_PREFIX = "Simple 16-bit pixel art game HUD icon, low resolution retro style, limited color palette max 6 colors, single element centered, simple clear readable at small size,"
HUD_SUFFIX = "solid pure green chroma key background, sharp pixels, no text, no letters, no words, no watermark, no signature, no ground, no shadow"

VFX_PREFIX = "Simple 16-bit pixel art game VFX particle effect, low resolution retro style, limited color palette,"
VFX_SUFFIX = "solid pure green chroma key background, sharp pixels, no text, no letters, no words, no watermark, no signature"


def generate_bosses():
    print("\n=== 보스 스프라이트 (22종) ===\n")

    bosses = [
        ("boss_glutton", 70001, "large round gluttonous body, massive protruding belly, stubby thick limbs, reddish-orange skin, short broken horns, enormous wide mouth with big uneven teeth, small greedy eyes, tattered dark loincloth, arms akimbo confident laughing, menacing yet comedic"),
        ("boss_trickster", 70002, "lean mischievous prankster, wiry thin body, exaggerated long arms, blue-gray skin, sly wide grin, two curved horns backward, large pointed ears, ragged dark vest, asymmetric eyes one larger, holding wooden club behind back, crouching ready-to-pounce, playful but unsettling"),
        ("boss_flame", 70003, "large muscular fire dokkaebi engulfed in flames, charcoal-black cracked skin with glowing orange lava fissures, sharp angular features, tall pointed horns ablaze, burning orange-white eyes, smoke rising from shoulders, aggressive wide stance, clenched fists dripping flame, tattered burnt cloth at waist"),
        ("boss_shadow", 70004, "shadow dokkaebi made of living darkness, semi-transparent shifting form, edges dissolving into smoke wisps, ink-black body, faint glowing purple eyes as two points of light, wispy shadow tendrils, hunched predatory posture, barely visible claws and teeth, dark purple core glow"),
        ("boss_fox", 70005, "slender elegant fox spirit gumiho, pointed fox ears, large fluffy nine tails, pale white porcelain skin, long dark hair with purple highlights, ornate purple Korean hanbok, glowing purple eyes, subtle dangerous smile, one hand raised with sharp hidden claws, faint purple magical aura"),
        ("boss_mirror", 70006, "crystalline dokkaebi made of fractured mirror shards, angular geometric body, reflective flat panels, two large reflective eyes, sharp jagged edges on limbs, remnants of dark robe, mimicking pose arms raised, prismatic rainbow refractions, silver and crystal blue"),
        ("boss_volcano", 70007, "massive volcanic dokkaebi erupting mountain body, dark basalt-gray rocky skin, glowing molten orange-red cracks, volcanic crater head with magma bubbling, enormous stocky build wider than tall, thick stubby legs, rocky fists dripping lava, small fierce white-hot eyes, rising smoke"),
        ("boss_gold", 70008, "regal dokkaebi entirely gleaming gold, polished golden skin, ornate golden antler horns with jewels, golden armor with coin motifs, wide greedy grin with golden teeth, gold coin eyes, rings on every finger, gold chains, clutching bag of coins, golden club with gems"),
        ("boss_corridor", 70009, "tall unnaturally thin dokkaebi, impossibly elongated limbs, stretched vertically funhouse mirror proportions, pale gray-blue skin, long spindly fingers bending at wrong angles, perpetual unsettling smile, narrow face, spiraling vortex eyes, flowing dark robes trailing"),
        ("boss_yeomra", 70010, "King Yama Korean underworld judge massive deity, six arms holding scroll sword skull mirror scales lotus, elaborate royal Korean robes deep gold and crimson, ornate crown, aged powerful face, golden glowing eyes, long dark beard braided with gold, bronze-gold skin, divine golden aura"),
        ("boss_skeleton_general", 70011, "towering skeleton general made of bones, rusted ancient Korean general armor, horned bone helmet, tattered war banner, empty eye sockets with cold blue ghost fire, skeletal hand gripping massive bone sword, shield from giant skull plate, commanding military posture"),
        ("boss_ninetail_king", 70012, "supreme nine-tailed fox king standing upright regal, nine enormous tails fanned out each different color, luxurious dark fur with golden markings, fox face with ancient knowing golden eyes, elaborate Korean royal crown, ceremonial shimmering robes, floating phantom cards orbiting"),
        ("boss_imugi", 70013, "colossal serpentine imugi unascended dragon, enormous snake body coiled rising upward, dark blue-black iridescent scales, massive horned head, piercing yellow dragon eyes, emerging dragon claws and wing buds, lightning crackling along scales, yeouiju dragon pearl hovering above"),
        ("boss_underworld_flower", 70014, "hauntingly beautiful flower entity humanoid figure of ghostly luminescent flowers, dark stem-body, pale corpse lilies ghostly spider lilies translucent lotus, face partially obscured by petals with sad beautiful eyes, vine-like arms with flowers at fingertips, roots extending downward, floating petals"),
        ("boss_thief", 70021, "sneaky thief dokkaebi, dark hooded cloak, narrow shifty eyes, long nimble fingers, belt of stolen trinkets and keys, crouching sneaky pose, dark gray-green skin, sly smirk, one hand hiding behind back, shadowy rogue"),
        ("boss_fog", 70022, "ethereal fog dokkaebi, body made of swirling mist and vapor, barely visible form, pale white-gray translucent body, faintly glowing white eyes in mist, wispy trailing edges, mysterious floating posture, cold breath visible"),
        ("boss_clock", 70023, "clockwork dokkaebi, body embedded with ticking clock faces, bronze mechanical skin with gears visible, large clock face in chest, ornate clock hands as horns, pendulum swinging from body, dark bronze and brass colors"),
        ("boss_curse_ghost", 70024, "vengeful curse ghost dokkaebi, twisted tortured form, long disheveled black hair covering face, one glowing red eye visible through hair, pale gray-white skin with dark curse marks, tattered white burial robes, ghostly floating pose, dark aura of resentment"),
        ("boss_viper", 70025, "venomous serpent dokkaebi, snake-like body with humanoid upper torso, dark green scaled skin, forked tongue, narrow venomous yellow slit eyes, cobra hood flared around head, dripping purple venom from fangs, coiled lower body, toxic green aura"),
        ("boss_bone_shaman", 70026, "bone shaman dokkaebi, decorated with skulls and bones as ritual ornaments, shaman drum in one hand, bone staff in other, skull mask covering face, dark ritual robes with bone charms, ghostly blue shamanic energy around hands"),
        ("boss_blood_rain", 70027, "blood rain dokkaebi, body dripping with crimson rain constantly, dark red-maroon skin, hollow dark eye sockets weeping blood, arms spread wide summoning rain, soaked tattered crimson robes, sorrowful yet terrifying"),
        ("boss_nightmare", 70028, "nightmare dokkaebi, distorted shifting dreamlike body, face constantly changing, multiple overlapping eyes, body edges rippling like disturbed water, dark purple-black skin, floating in unnatural pose, reality-warping presence"),
    ]

    for boss_id, seed, desc in bosses:
        gen("bosses", boss_id, f"{BOSS_PREFIX} {desc}, {BOSS_SUFFIX}", seed)


def generate_talismans():
    print("\n=== 부적 아이콘 (20종) ===\n")

    talismans = [
        ("talisman_blood_oath", 73001, "crimson blood drop on small white paper talisman, bright red drop, pale paper"),
        ("talisman_red_gate", 73002, "tiny red Korean hongsalmun gate, two red pillars with red beam across top, vivid red gate silhouette"),
        ("talisman_samdo_ferry", 73003, "small brown wooden boat with single tiny cyan ghost flame floating above, side-view boat shape, dark brown hull, cyan wisp"),
        ("talisman_dokkaebi_club", 73004, "short thick wooden club with metal studs, classic dokkaebi bangmangi, dark brown wood, gray metal dots"),
        ("talisman_virtue_gate", 73005, "small stone arch gate with green ribbon tied at top, gray stone, bright green ribbon bow"),
        ("talisman_samsara_bead", 73006, "single round jade-green prayer bead with tiny spiral mark inside, bright green glowing sphere"),
        ("talisman_dokkaebi_hat", 73011, "cone-shaped dark Korean dokkaebi invisibility hat, dark fabric with faint purple shimmer line, triangular hat shape"),
        ("talisman_moonlight_fox", 73012, "small white fox silhouette sitting with yellow crescent moon above, tiny simple fox, white fox yellow moon"),
        ("talisman_underworld_mirror", 73013, "small round traditional Korean bronze mirror, dark bronze rim, bright reflective silver center"),
        ("talisman_girin_horn", 73014, "single curved golden horn, bright gold color, slight upward curve, crescent-like horn shape"),
        ("talisman_fate_dice", 73015, "two small wooden dice side by side, dark brown cubes, red dot marks on faces"),
        ("talisman_scale_desire", 73017, "tiny golden balance scale tilted to one side, one pan lower, simple gold scale shape"),
        ("talisman_reaper_ledger", 73021, "dark scroll partially unrolled with red seal stamp on it, dark brown scroll, bright red seal mark"),
        ("talisman_madness_bright", 73022, "bright golden star shape with jagged chaotic rays shooting outward, gold center, starburst"),
        ("talisman_yeomra_seal", 73023, "square red seal stamp, official seal shape, bright crimson red square with dark lines inside"),
        ("talisman_heavenly_lute", 73024, "small traditional Korean biwa lute instrument, dark brown body, pale strings, simple instrument"),
        ("talisman_hellflame", 73025, "single intense flame, orange-red outer flame with white-hot center, classic fire shape, pointed tips"),
        ("talisman_doom", 73031, "cracked black talisman paper with single glowing red eye in center, dark cracked rectangle, cursed"),
        ("talisman_phantom", 73032, "pale ghostly hand reaching upward, fingers spread, translucent pale gray-white hand shape"),
        ("talisman_oblivion_ribbon", 73033, "dark gray ribbon with loose knot, fraying ends dissolving into scattered pixels, knotted ribbon"),
    ]

    for tal_id, seed, desc in talismans:
        gen("talismans", tal_id, f"{ICON_PREFIX} {desc}, {ICON_SUFFIX}", seed)


def generate_backgrounds():
    print("\n=== 배경 (14종) ===\n")

    backgrounds = [
        ("bg_main_menu", 71001, "Korean afterlife Sanzu River scene, dark misty river flowing, old wooden ferry boat on still water, distant shore in thick fog, floating blue-green ghost flames reflected in water, dead willow tree silhouettes, crescent moon in dark indigo sky, eerie calm"),
        ("bg_shop", 71007, "Korean afterlife marketplace shop stall, wooden counter displaying magical items, hanging paper lanterns with blue ghost fire, shelves of talismans and scrolls, old coins on counter, incense smoke, tattered fabric canopy, dark purple lighting"),
        ("bg_ghost_market", 71002, "Korean underworld night market alley, narrow stone-paved street, ghostly merchant stalls, hanging red and blue paper lanterns, stacked crates and jars, fog rolling through, purple-blue atmospheric lighting"),
        ("bg_yellow_spring", 71003, "endless foggy road to Korean underworld, pale yellow-brown dirt path to vanishing point, dead twisted bare trees, old wooden signposts, thick rolling fog, faint ghostly silhouettes, dim sickly yellow sky"),
        ("bg_hell_pit", 71004, "Korean underworld fire pit hellscape, cracked dark ground with glowing orange-red lava fissures, jagged obsidian rocks, fire erupting from vents, dark smoke, hellish orange-red sky, chains hanging"),
        ("bg_archive_hall", 71005, "Korean underworld records archive grand library, towering dark wooden bookshelves with scrolls, long corridor perspective, dim candlelight, floating dust, bureaucratic afterlife office, dark wood gold trim"),
        ("bg_yama_palace", 71006, "Korean underworld Yama judgment palace throne room, massive ornate throne on raised platform, grand pillars gold and crimson, karma mirror on wall, ceremonial banners, divine golden light, dark stone floor"),
        ("bg_volcanic_hellscape", 71008, "volcanic hellscape with erupting volcanoes, rivers of molten lava between dark basalt islands, raining ash and embers, dark crimson sky, bubbling lava pools, charred landscape"),
        ("bg_golden_maze", 71009, "golden labyrinth maze of treasure, polished gold walls, piles of coins and jewels, ornate golden pillars, dead-end passages, warm golden glow, opulent but dangerous"),
        ("bg_infinite_corridor", 71010, "impossible infinite corridor, Escher-like architecture, doors leading to more corridors, stairs up and down simultaneously, repeating patterns to infinity, pale blue-gray stone, surreal impossible geometry"),
        ("bg_shadow_city", 71011, "city made of living shadows and darkness, dark building silhouettes shifting, streets of pure darkness, faint purple light sources, shadow tendrils from buildings, ink-black sky, oppressive darkness"),
        ("bg_chaos_gate", 71012, "massive ancient gate between worlds, enormous stone gateway with swirling chaotic energy portal, reality cracking around edges, cosmic void beyond, lightning and supernatural energy, final threshold"),
        ("bg_main_menu_v2", 71013, "close-up Sanzu River ferry, old wooden boat with lantern at bow, ghostly mist from dark water, distant shore lights, floating ghost flames, bamboo oar, peaceful yet eerie"),
        ("bg_ghost_market_v2", 71014, "elevated wide view Korean underworld night market, rooftops of ghostly stalls, sea of colored paper lanterns from above, winding narrow streets, misty purple-blue night sky, sprawling bazaar"),
    ]

    for bg_id, seed, desc in backgrounds:
        gen("backgrounds", bg_id, f"{BG_PREFIX} {desc}, {BG_SUFFIX}", seed, aspect_ratio="16:9")


def generate_companions():
    print("\n=== 동료 도깨비 (7종) ===\n")

    companions = [
        ("comp_glutton", 71001, "small round-bodied tamed dokkaebi sitting happily, reddish-orange skin, broken horns, friendly goofy grin, chubby mascot, holding small rice cake, sitting cross-legged, cheerful crescent eyes"),
        ("comp_trickster", 71002, "small lean tamed dokkaebi crouching playfully, blue-gray skin, curved horns, mischievous wink, holding club over shoulder, one hand peace sign, friendly imp"),
        ("comp_fox", 71003, "small elegant tamed fox spirit sitting gracefully, tail curled around body, pale skin, fox ears, warm gentle eyes, simplified purple hanbok, holding small glowing orb"),
        ("comp_mirror", 71004, "small crystalline tamed dokkaebi, reflective mirror-like surfaces, angular geometric body, calm expression, holding small round mirror, peaceful standing pose, silver crystal blue"),
        ("comp_flame", 71005, "small tamed fire dokkaebi, gentle warming flames, charcoal-black cracked skin, softer orange glow like campfire embers, calm serious expression, arms crossed, small controlled flames above horns like candles"),
        ("comp_shadow", 71006, "small tamed shadow dokkaebi hovering slightly, cat-like silhouette, glowing purple eyes softer and curious, small shadow wisps trailing like smoky tail, subtle head tilt curious, quiet shadow cat"),
        ("comp_boatman", 71007, "small Sanzu River ferryman, weathered elderly Korean man, cone-shaped straw hat, simple dark ferryman clothes, holding miniature oar, faint knowing smile, standing calmly with stoic dignity"),
    ]

    for comp_id, seed, desc in companions:
        gen("companions", comp_id, f"{COMP_PREFIX} {desc}, {COMP_SUFFIX}", seed, aspect_ratio="2:3")


def generate_cards():
    print("\n=== 화투 카드 (48장) ===\n")

    cards = [
        # 1월 소나무+학
        ("m01_gwang", 1001, "majestic red-crowned crane standing on gnarled old pine tree, pure white body, solid black tail feathers, vivid red patch on head, thick dark pine trunk diagonal, dense dark green pine needle clusters, small solid red sun circle"),
        ("m01_hongdan", 1002, "dark pine tree trunks and branches growing upward, three thick gnarled trunks, rough bark, dense dark green pine needles, bright vivid red ribbon draped diagonally, solid flat red ribbon strip"),
        ("m01_pi1", 1003, "single pine tree branch extending upward, thick dark trunk, large dark green pine needle cluster fan at tip, smaller cluster below, upper area open space"),
        ("m01_pi2", 1004, "two thin pine branches growing upward, fewer needle clusters, dark green fans at tips, branches crossing loose X-pattern, lower area vegetation only"),
        # 2월 매화+꾀꼬리
        ("m02_yeolkkeut", 2001, "bright yellow-green bush warbler perched on dark plum branch, round plump body, vivid golden yellow belly, olive-green back, dark brown plum branch diagonal, four to five red plum blossoms, solid red five petals"),
        ("m02_hongdan", 2002, "dark plum tree branches extending upward, angular dark branches, rough bark, bright red plum blossoms, vivid bright red ribbon draped diagonally, solid flat ribbon"),
        ("m02_pi1", 2003, "single plum branch curving upward, dark angular branch, three to four red plum blossoms at tip, solid red five petals, yellow centers, one small bud"),
        ("m02_pi2", 2004, "shorter delicate plum branch from lower-right, two to three red blossoms at tip, one loose petal drifting, minimal, abundant negative space"),
        # 3월 벚꽃+장막
        ("m03_gwang", 3001, "lavish cherry blossom tree in full bloom, pale pink-white five-petal flowers, dozens overlapping, vivid bright red ceremonial curtain below, decorative scalloped edge gold trim, dark trunk visible, few loose petals floating"),
        ("m03_hongdan", 3002, "cherry blossom branches with pale pink-white clusters, dark branches, blossoms dense at tips, vivid bright red ribbon draped diagonally, solid flat ribbon, few petals drifting"),
        ("m03_pi1", 3003, "cherry blossom branch extending upward from bottom, dark angular branch, pale pink-white blossom clusters at tips, branch forks once, upper portion open space"),
        ("m03_pi2", 3004, "small cherry blossom branch from lower-right, thin dark branch, two to three pale pink-white blossoms, several loose petals scattering, minimal composition"),
        # 4월 흑싸리+두견새
        ("m04_yeolkkeut", 4001, "small cuckoo bird in dynamic flight diving downward, dark body, wings spread wide, black wisteria vines hanging from top like curtains, dense dark scalloped leaf clusters, gold-yellow ribbon tied across"),
        ("m04_chodan", 4002, "black wisteria vines hanging from top, three dense clusters dark scalloped leaf shapes, solid dark, red ribbon woven between vine clusters draped diagonally, vines dominate upper 65 percent"),
        ("m04_pi1", 4003, "single cluster black wisteria vines hanging from top-right, one dense group dark scalloped leaves, thin vine stem curving, clean open space below"),
        ("m04_pi2", 4004, "two small black wisteria vine clusters hanging from top, smaller and sparser, dark scalloped silhouettes, vines in upper quarter only, vast empty space below"),
        # 5월 난초+다리
        ("m05_yeolkkeut", 5001, "arched wooden bridge crossing over blue water stream, dark brown-red bridge with railings, iris flowers growing below, vivid purple iris petals with yellow centers, long green sword-like leaves, flowing blue water"),
        ("m05_chodan", 5002, "iris flowers in bloom, vivid purple petals, long green sword-shaped leaves growing upward, red ribbon draped diagonally across, solid flat ribbon, flowers fill lower two-thirds"),
        ("m05_pi1", 5003, "single iris flower bloom, vivid purple petals with yellow center, long green leaves arching upward, vegetation in lower portion, open space above"),
        ("m05_pi2", 5004, "two small iris buds on thin stems, purple buds not fully open, sparse green leaves, minimal, mostly negative space"),
        # 6월 모란+나비
        ("m06_yeolkkeut", 6001, "two colorful butterflies fluttering above large red peony flowers, butterflies with orange and black wings, large lush red peony blooms layered petals, dark green broad leaves"),
        ("m06_chungdan", 6002, "large red peony flowers in bloom, layered lush petals, dark green broad leaves, blue ribbon draped diagonally, solid flat blue ribbon"),
        ("m06_pi1", 6003, "single large red peony flower, layered rounded petals, dark green leaves below, flower in lower portion, open space above"),
        ("m06_pi2", 6004, "small peony bud beginning to open, red petals unfurling, single stem with green leaves, minimal, mostly negative space"),
        # 7월 홍싸리+멧돼지
        ("m07_yeolkkeut", 7001, "wild boar running through red bush clover, stocky dark brown boar, small tusks, red-pink bush clover flowers cascading from above, thin arching branches with round flower clusters"),
        ("m07_chodan", 7002, "red bush clover branches arching downward, thin stems with small round red-pink clusters, cascading form, red ribbon draped diagonally, solid flat ribbon"),
        ("m07_pi1", 7003, "single bush clover branch arching from side, thin stem with small red-pink clusters, graceful curve, lower portion, open space above"),
        ("m07_pi2", 7004, "sparse bush clover sprigs, thin stems with few small flower dots, minimal and delicate, mostly negative space"),
        # 8월 공산+달
        ("m08_gwang", 8001, "large full moon in upper portion, bright yellow-white circular moon, dark silhouette mountain range below, silver pampas grass plumes swaying, thin stems with fluffy white-silver seed heads, moonlit night"),
        ("m08_yeolkkeut", 8002, "flock of wild geese flying in V-formation, dark bird silhouettes, silver pampas grass below, thin stems fluffy white seed heads, sunset dusk atmosphere orange to purple"),
        ("m08_pi1", 8003, "silver pampas grass plumes, thin stems swaying, fluffy white-silver seed heads at top, grouped in lower portion, open sky above"),
        ("m08_pi2", 8004, "sparse pampas grass, two thin stems with small seed heads, minimal vegetation, mostly open space"),
        # 9월 국화+잔
        ("m09_yeolkkeut", 9001, "small red sake cup with yellow chrysanthemum flowers, ornate red-orange cup, bright yellow chrysanthemum blooms many layered petals, dark green rounded leaves"),
        ("m09_chungdan", 9002, "yellow chrysanthemum flowers in bloom, many layered petals, dark green rounded leaves, blue ribbon draped diagonally, solid flat blue ribbon"),
        ("m09_pi1", 9003, "single yellow chrysanthemum bloom, layered petals, dark green leaves, flower in lower portion, open space above"),
        ("m09_pi2", 9004, "small chrysanthemum bud, yellow petals beginning to open, single stem with green leaf, minimal, mostly empty space"),
        # 10월 단풍+사슴
        ("m10_yeolkkeut", 10001, "graceful deer standing among maple branches, brown deer body spotted coat small antlers, looking back over shoulder, vivid red-orange maple leaves on dark branches, autumn colors"),
        ("m10_chungdan", 10002, "vivid red-orange maple leaves on dark branches, five-pointed leaf shapes, autumn colors, blue ribbon draped diagonally, solid flat blue ribbon"),
        ("m10_pi1", 10003, "maple branch with red-orange leaves, dark branch extending from side, five-pointed leaves warm autumn colors, lower portion, open space above"),
        ("m10_pi2", 10004, "few scattered maple leaves, two or three red-orange leaves falling, thin branch, minimal autumn scene, mostly open space"),
        # 11월 오동+봉황
        ("m11_gwang", 11001, "magnificent phoenix bird perched on paulownia tree, golden-red phoenix with elaborate tail feathers, broad paulownia leaves, dark trunk, phoenix spreading one wing dramatically, divine radiant presence"),
        ("m11_yeolkkeut", 11002, "paulownia tree with broad round leaves, dark trunk branching, large distinctive three-lobed leaves, autumn colors"),
        ("m11_pi1", 11003, "single paulownia branch with broad leaves, dark stem, large three-lobed leaf shapes, lower portion, open space above"),
        ("m11_pi2", 11004, "small paulownia leaf on thin stem, single broad leaf shape, minimal, mostly empty composition"),
        # 12월 비+버들
        ("m12_gwang", 12001, "figure with umbrella in heavy rain, dark silhouette holding red umbrella, weeping willow branches from above, rain lines filling background, dramatic stormy atmosphere, lightning bolt in sky"),
        ("m12_yeolkkeut", 12002, "swallow bird in flight, dark blue-black body with red throat, forked tail, swooping through rain, weeping willow branches hanging, thin drooping willow leaves, rain lines"),
        ("m12_pi1", 12003, "weeping willow branches hanging downward, thin drooping green willow leaves, graceful cascading form, rain lines in background, lower half vegetation, open sky above"),
        ("m12_pi2", 12004, "sparse willow branches, few thin drooping leaves, light rain lines, minimal composition, mostly open space"),
    ]

    for card_id, seed, desc in cards:
        gen("card-illustrations", card_id, f"{CARD_PREFIX} {desc}, {CARD_SUFFIX}", seed, aspect_ratio="2:3")


def generate_hud_icons():
    print("\n=== HUD 아이콘 (12종) ===\n")

    huds = [
        ("hud_heart_full", 78001, "full red heart, solid bright crimson pixel heart shape, classic game health icon"),
        ("hud_heart_half", 78002, "half red heart, left half bright crimson right half dark gray empty, half health indicator"),
        ("hud_heart_empty", 78003, "empty heart outline, dark gray hollow heart shape outline only, empty health slot"),
        ("hud_card_back", 78011, "tiny card back icon, dark blue-purple rectangle with small pattern, remaining deck indicator"),
        ("hud_card_special", 78012, "golden star on small card shape, special card indicator, bright gold star marker"),
        ("hud_turn_indicator", 78023, "small arrow pointing right, bright golden turn arrow, current turn indicator"),
        ("hud_gimmick_warning", 78061, "warning triangle with exclamation mark, red alert danger indicator, boss gimmick warning"),
        ("hud_talisman_empty", 78041, "empty square slot frame, dark border with subtle pattern, empty equipment slot"),
        ("hud_talisman_filled", 78042, "square slot frame with golden glow inside, active talisman equipped, bright golden fill"),
        ("hud_talisman_locked", 78043, "square slot frame with padlock overlay, locked talisman slot, dark gray locked"),
        ("hud_companion_empty", 78051, "circular empty companion slot frame, dark ring border with horn decoration, empty ally slot"),
        ("hud_companion_active", 78052, "circular companion slot frame with bright glow, active companion indicator, golden glow inside"),
    ]

    for hud_id, seed, desc in huds:
        gen("hud-icons", hud_id, f"{HUD_PREFIX} {desc}, {HUD_SUFFIX}", seed)


def generate_vfx():
    print("\n=== VFX 파티클 (6종) ===\n")

    vfx = [
        ("vfx_dokkaebi_fire", 76001, "floating supernatural ghost flame, blue-green dokkaebi fire wisp, ethereal flickering flame with trailing wisps, cyan and teal colors, glowing core"),
        ("vfx_ink_bloom", 76002, "ink splash spreading outward, dark black ink bloom expanding, splatter pattern with tendrils, calligraphy ink drop impact"),
        ("vfx_blood_splash", 76003, "blood red splash burst, crimson droplets spraying outward from center, impact splatter pattern, dark red to bright red"),
        ("vfx_gold_sparkle", 76004, "golden sparkle burst, star-shaped golden glitter particles radiating outward, warm gold shimmer, multiple small stars"),
        ("vfx_burning_paper", 76005, "talisman paper burning effect, yellow paper curling with orange fire edges, ash particles floating upward, dissolving burning paper"),
        ("vfx_smoke_wisp", 76006, "wispy smoke puff, gray-white smoke cloud rising and dissipating, curling smoke tendril"),
    ]

    for vfx_id, seed, desc in vfx:
        gen("vfx", vfx_id, f"{VFX_PREFIX} {desc}, {VFX_SUFFIX}", seed)


if __name__ == "__main__":
    print("=" * 60)
    print("도깨비의 패 — 전체 에셋 생성 시작")
    print("=" * 60)

    generate_bosses()       # 22종
    generate_talismans()    # 20종
    generate_backgrounds()  # 14종
    generate_companions()   # 7종
    generate_cards()        # 48종
    generate_hud_icons()    # 12종
    generate_vfx()          # 6종

    print("\n" + "=" * 60)
    print("생성 완료! 총 129종 (1차 배치)")
    print("=" * 60)
