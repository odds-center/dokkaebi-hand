using System;
using System.Collections.Generic;
using UnityEngine;

namespace DokkaebiHand.Core
{
    public enum Language
    {
        Korean,     // ko
        English,    // en
        Japanese,   // ja
        Chinese     // zh (간체)
    }

    /// <summary>
    /// 다국어 시스템. 네트워크 불필요, 코드 내장.
    /// 한국어(기본) / 영어 / 일본어 / 중국어(간체) 지원.
    /// </summary>
    public class LocalizationManager
    {
        private static LocalizationManager _instance;
        public static LocalizationManager Instance => _instance ??= new LocalizationManager();

        public Language CurrentLanguage { get; private set; } = Language.Korean;

        private Dictionary<string, string[]> _table; // key → [ko, en, ja, zh]

        public event Action<Language> OnLanguageChanged;

        public LocalizationManager()
        {
            BuildTable();
            DetectSystemLanguage();
        }

        public void SetLanguage(Language lang)
        {
            CurrentLanguage = lang;
            PlayerPrefs.SetInt("dokkaebi_lang", (int)lang);
            OnLanguageChanged?.Invoke(lang);
        }

        /// <summary>
        /// 키로 현재 언어의 텍스트 조회
        /// </summary>
        public string Get(string key)
        {
            if (_table.TryGetValue(key, out var texts))
            {
                int idx = (int)CurrentLanguage;
                if (idx >= 0 && idx < texts.Length && !string.IsNullOrEmpty(texts[idx]))
                    return texts[idx];
                return texts[0]; // fallback: 한국어
            }
            return $"[{key}]"; // 미등록 키
        }

        /// <summary>
        /// 포맷 문자열 지원: L("score_format", score, mult)
        /// </summary>
        public string Get(string key, params object[] args)
        {
            string template = Get(key);
            try { return string.Format(template, args); }
            catch { return template; }
        }

        /// <summary>
        /// 시스템 언어 자동 감지
        /// </summary>
        private void DetectSystemLanguage()
        {
            if (PlayerPrefs.HasKey("dokkaebi_lang"))
            {
                CurrentLanguage = (Language)PlayerPrefs.GetInt("dokkaebi_lang");
                return;
            }

            CurrentLanguage = Application.systemLanguage switch
            {
                SystemLanguage.Korean => Language.Korean,
                SystemLanguage.Japanese => Language.Japanese,
                SystemLanguage.Chinese => Language.Chinese,
                SystemLanguage.ChineseSimplified => Language.Chinese,
                SystemLanguage.ChineseTraditional => Language.Chinese,
                _ => Language.English
            };
        }

        // ========================================================
        // 전체 텍스트 테이블
        // 순서: [한국어, 영어, 일본어, 중국어(간체)]
        // ========================================================
        private void BuildTable()
        {
            _table = new Dictionary<string, string[]>();

            // === 메인 메뉴 ===
            Add("title", "도깨비의 패", "Dokkaebi's Hand", "トッケビの手札", "鬼怪之牌");
            Add("subtitle", "무한 로그라이트 화투 덱빌더", "Infinite Roguelite Hwatu Deckbuilder", "無限ローグライト花札デッキビルダー", "无限肉鸽花牌构筑");
            Add("new_game", "새 게임", "New Game", "ニューゲーム", "新游戏");
            Add("continue", "이어하기", "Continue", "つづきから", "继续");
            Add("collection", "도감", "Collection", "図鑑", "图鉴");
            Add("settings", "설정", "Settings", "設定", "设置");
            Add("quit", "종료", "Quit", "終了", "退出");
            Add("language", "언어", "Language", "言語", "语言");
            Add("input_hint", "모든 조작은 마우스/터치로 가능합니다", "All controls via mouse/touch", "すべてマウス/タッチで操作できます", "所有操作均可通过鼠标/触控完成");

            // === 게임 플레이 (고스톱 용어 그대로 + 저승 세계관) ===
            Add("chips", "점", "Pts", "点", "点");               // 고스톱 기본: 점
            Add("mult", "배", "×", "倍", "倍");                  // 고스톱 기본: 배 (고 하면 배가 늘어남)
            Add("target", "관문", "Gate", "関門", "关卡");       // 저승 세계관: 보스가 지키는 관문
            Add("score", "점수", "Score", "スコア", "分数");     // 그대로
            Add("round", "판", "Round", "局", "局");             // 고스톱 용어: "한 판"
            Add("turn", "차례", "Turn", "番", "轮");             // 자연스러운 한국어
            Add("hand", "손패", "Hand", "手札", "手牌");
            Add("field", "바닥패", "Field", "場札", "场牌");
            Add("draw_pile", "더미", "Pile", "山", "牌堆");      // 고스톱: 더미
            Add("captured", "먹은 패", "Captured", "取った札", "吃到的牌"); // 고스톱: "먹다"

            Add("score_format", "{0}점 × {1}배 = {2}점", "{0} × {1} = {2}", "{0}点 × {1}倍 = {2}点", "{0}点 × {1}倍 = {2}点");

            // === 카드 타입 ===
            Add("type_gwang", "광", "Bright", "光", "光");
            Add("type_tti", "띠", "Ribbon", "短冊", "带");
            Add("type_yeolkkeut", "열끗", "Animal", "タネ", "十点");
            Add("type_pi", "피", "Junk", "カス", "皮");
            Add("type_ssangpi", "쌍피", "Double Junk", "二カス", "双皮");

            // === 띠 타입 ===
            Add("ribbon_hong", "홍단", "Red Scroll", "赤短", "红丹");
            Add("ribbon_cheong", "청단", "Blue Scroll", "青短", "青丹");
            Add("ribbon_cho", "초단", "Plain Scroll", "草短", "草丹");

            // === 월 이름 ===
            Add("month_1", "1월 송학", "January · Pine", "1月 松に鶴", "一月 松鹤");
            Add("month_2", "2월 매조", "February · Plum", "2月 梅に鶯", "二月 梅鸟");
            Add("month_3", "3월 벚꽃", "March · Cherry", "3月 桜に幕", "三月 樱花");
            Add("month_4", "4월 흑싸리", "April · Wisteria", "4月 藤に杜鵑", "四月 黑荻");
            Add("month_5", "5월 난초", "May · Orchid", "5月 菖蒲に八橋", "五月 兰草");
            Add("month_6", "6월 모란", "June · Peony", "6月 牡丹に蝶", "六月 牡丹");
            Add("month_7", "7월 홍싸리", "July · Clover", "7月 萩に猪", "七月 红荻");
            Add("month_8", "8월 공산", "August · Moon", "8月 芒に月", "八月 芒月");
            Add("month_9", "9월 국진", "September · Chrysanthemum", "9月 菊に盃", "九月 菊酒");
            Add("month_10", "10월 단풍", "October · Maple", "10月 紅葉に鹿", "十月 红叶");
            Add("month_11", "11월 오동", "November · Paulownia", "11月 桐に鳳凰", "十一月 梧桐");
            Add("month_12", "12월 비", "December · Rain", "12月 柳に小野道風", "十二月 雨");

            // === 족보 (전통 + 고유) ===
            Add("yokbo_ogwang", "오광 — 천지개벽", "Five Brights — Genesis", "五光 — 天地開闢", "五光 — 天地开辟");
            Add("yokbo_sagwang", "사광 — 사방수호", "Four Brights — Guardian", "四光 — 四方守護", "四光 — 四方守护");
            Add("yokbo_samgwang", "삼광 — 삼재초복", "Three Brights — Fortune", "三光 — 三災初福", "三光 — 三灾初福");
            Add("yokbo_bigwang", "비광 — 폭풍전야", "Rain Bright — Before Storm", "雨光 — 嵐の前夜", "雨光 — 暴风前夜");
            Add("yokbo_hongdan", "홍단 — 붉은 서약", "Red Scrolls — Crimson Oath", "赤短 — 紅の誓い", "红丹 — 赤红誓约");
            Add("yokbo_cheongdan", "청단 — 푸른 맹세", "Blue Scrolls — Azure Vow", "青短 — 蒼の誓い", "青丹 — 蔚蓝誓约");
            Add("yokbo_chodan", "초단 — 풀의 결속", "Plain Scrolls — Verdant Bond", "草短 — 草の結束", "草丹 — 草之羁绊");
            // 전통 확장
            Add("yokbo_godori", "고도리 — 새 세 마리의 비상", "Go-Dori — Three Birds Soar", "高鳥 — 三鳥飛翔", "高鸟 — 三鸟飞翔");
            Add("yokbo_jodori", "저도리 — 땅짐승의 행진", "Low Beasts March", "低鳥 — 地獣行進", "低鸟 — 地兽行进");
            Add("yokbo_chongtong", "총통 — 한 달을 독식", "Full Month Sweep", "総統 — 月独占", "总统 — 月独占");
            Add("yokbo_sipjang", "십장 — 정확한 수확", "Perfect Ten", "十場 — 正確な収穫", "十场 — 精确收获");
            // 고유 족보
            Add("yokbo_sagye", "사계 — 봄여름가을겨울", "Four Seasons Cycle", "四季 — 春夏秋冬", "四季 — 春夏秋冬");
            Add("yokbo_ihwa", "이화접동 — 봄꽃의 릴레이", "Spring Relay", "梨花接棟 — 春花リレー", "梨花接栋 — 春花接力");
            Add("yokbo_samhan", "삼한사온 — 빛과 먼지의 조화", "Cold & Warm Harmony", "三寒四温 — 光と塵", "三寒四温 — 光尘和谐");
            Add("yokbo_honse", "혼세마왕 — 만물을 손에", "Chaos King", "混世魔王 — 万物掌握", "混世魔王 — 万物在手");
            Add("yokbo_pungryu", "저승풍류 — 글과 짐승", "Underworld Arts", "風流 — 文と獣", "风流 — 文兽相伴");
            Add("yokbo_wolha", "월하독작 — 달과 국화잔", "Moonlit Solitude", "月下独酌", "月下独酌");
            Add("yokbo_biyeon", "비연 — 두 새의 만남", "Two Swallows Meet", "飛燕 — 二鳥の出会い", "飞燕 — 双鸟相逢");
            Add("yokbo_sunhu", "선후착 — 시작과 끝", "Alpha & Omega", "先後着 — 始と終", "先后着 — 始与终");
            Add("yokbo_dokkaebi_fire", "도깨비불 — 어둠 속 빛", "Ghost Fire", "鬼火 — 闇の光", "鬼火 — 暗中之光");
            Add("yokbo_samdantong", "삼단통 — 삼색의 어울림", "Triple Dan", "三丹通 — 三色調和", "三丹通 — 三色和谐");

            // === 고/스톱 (고스톱 원래 용어 + 저승 분위기) ===
            Add("go", "고", "Go", "ゴー", "继续");
            Add("stop", "스톱", "Stop", "ストップ", "停止");
            Add("go_or_stop", "고 할래? 스톱 할래?", "Go or Stop?", "ゴーかストップか？", "继续还是停止？");
            Add("go_risk_1", "2배 / 다음 관문 ×1.5", "×2 / Next gate ×1.5", "2倍 / 次の関門×1.5", "2倍 / 下一关×1.5");
            Add("go_risk_2", "4배 / 손패 -1장", "×4 / Hand -1", "4倍 / 手札-1枚", "4倍 / 手牌-1");
            Add("go_risk_3", "10배 / 지면 혼비백산!", "×10 / Lose = soul scatter!", "10倍 / 負け=魂散！", "10倍 / 输了魂飞魄散！");
            Add("go_success", "고 성공!", "Go Success!", "ゴー成功！", "继续成功！");
            Add("greed_kills", "욕심이 목숨을 앗아간다", "Greed takes your life", "欲が命を奪う", "贪念夺命");

            // === 저승 구조 (나선 → 윤회 / 영역 → 관문) ===
            Add("spiral", "윤회", "Cycle", "輪廻", "轮回");           // 나선 → 윤회 (저승에서 돌고 도는 것)
            Add("realm", "관문", "Gate", "関門", "关卡");              // 영역 → 관문 (보스가 지키는 문)
            Add("spiral_info", "{0}번째 윤회 | {1}번째 관문", "Cycle {0} | Gate {1}/10", "第{0}輪廻 | 第{1}関門", "第{0}轮回 | 第{1}关");
            Add("total_cleared", "{0}개 관문 돌파", "{0} gates cleared", "{0}関門突破", "突破{0}个关卡");
            Add("next_spiral", "다음 윤회로!", "To next cycle!", "次の輪廻へ！", "进入下一轮回！");

            // === 이승의 문 ===
            Add("gate_title", "이승의 문이 나타났다", "The Gate to the Living has appeared", "現世の門が現れた", "生门出现了");
            Add("gate_desc", "이승으로 돌아갈 수 있다.\n하지만, 계속할 수도 있다.", "You can return to the living.\nOr, you can continue.", "現世に戻ることができる。\nしかし、続けることもできる。", "你可以回到人间。\n但也可以继续前行。");
            Add("gate_enter", "이승의 문 (엔딩 보기)", "Enter the Gate (View Ending)", "現世の門へ（エンディング）", "进入生门（观看结局）");
            Add("gate_refuse", "아직이다. 더 깊이 간다.", "Not yet. Go deeper.", "まだだ。もっと深くへ。", "还没到时候。继续深入。");

            // === 도깨비 (적) ===
            Add("boss_appears", "{0}이(가) 판을 깔았다!", "{0} sets the board!", "{0}が場を開いた！", "{0}摆下了牌局！");
            Add("boss_target", "{0}점 넘겨야 통과", "Need {0} to pass", "{0}点以上で突破", "达到{0}分才能通过");
            Add("boss_parts", "기물 {0}개", "{0} pieces", "器物{0}個", "{0}个器物");  // 파츠 → 기물 (도깨비의 물건)
            Add("boss_defeated", "이겼다!", "Won!", "勝った！", "赢了！");

            // === 보스 이름 ===
            Add("boss_glutton", "먹보 도깨비", "Glutton Dokkaebi", "食いしん坊トッケビ", "贪吃鬼怪");
            Add("boss_ice", "얼음 도깨비", "Ice Dokkaebi", "氷のトッケビ", "冰霜鬼怪");
            Add("boss_fox", "여우 도깨비", "Fox Dokkaebi", "狐のトッケビ", "狐妖鬼怪");
            Add("boss_mirror", "거울 도깨비", "Mirror Dokkaebi", "鏡のトッケビ", "镜像鬼怪");
            Add("boss_yeomra", "염라왕", "King Yeomra", "閻魔王", "阎罗王");
            Add("boss_volcano", "화산 도깨비", "Volcano Dokkaebi", "火山のトッケビ", "火山鬼怪");
            Add("boss_gold", "황금 도깨비", "Golden Dokkaebi", "黄金のトッケビ", "黄金鬼怪");
            Add("boss_corridor", "회랑 도깨비", "Corridor Dokkaebi", "回廊のトッケビ", "回廊鬼怪");
            Add("boss_shadow", "그림자 도깨비", "Shadow Dokkaebi", "影のトッケビ", "暗影鬼怪");
            Add("boss_jeonryun", "오도전륜왕", "King Jeonryun", "五道転輪王", "五道转轮王");

            // === 파츠 ===
            Add("parts_iron_horn", "쇠뿔", "Iron Horn", "鉄角", "铁角");
            Add("parts_fire_horn", "화염 뿔", "Flame Horn", "炎の角", "炎角");
            Add("parts_ice_crown", "얼음 왕관", "Ice Crown", "氷の王冠", "冰冠");
            Add("parts_skull_crown", "해골 면류관", "Skull Crown", "髑髏の冠", "骷髅冠");
            Add("parts_iron_plate", "철갑", "Iron Plate", "鉄甲", "铁甲");
            Add("parts_fire_mark", "화문", "Fire Mark", "火紋", "火纹");
            Add("parts_chain_arm", "쇠사슬", "Chain Arm", "鎖の腕", "锁链臂");
            Add("parts_shadow_arm", "그림자 팔", "Shadow Arm", "影の腕", "暗影臂");

            // === 부적 ===
            Add("talisman", "부적", "Talisman", "お守り", "符咒");
            Add("talisman_slot", "부적 슬롯", "Talisman Slot", "お守りスロット", "符咒栏位");
            Add("tal_blood_oath", "피의 맹세", "Blood Oath", "血の誓い", "血誓");
            Add("tal_blood_oath_desc", "피 패 1장당 +1 배수", "+1 Mult per Junk card", "カス1枚につき倍率+1", "每张皮牌+1倍率");
            Add("tal_dokkaebi_hat", "도깨비 감투", "Dokkaebi Hat", "トッケビの帽子", "鬼怪头巾");
            Add("tal_dokkaebi_hat_desc", "띠 1장당 목표 -5%", "-5% target per Ribbon", "短冊1枚につき目標-5%", "每张带牌目标-5%");
            Add("tal_reaper_ledger", "저승사자의 명부", "Reaper's Ledger", "死神の名簿", "死神名簿");
            Add("tal_reaper_ledger_desc", "점수 끝자리 4일 때 배수 ×4", "×4 Mult when score ends in 4", "スコア末尾4で倍率×4", "分数末尾为4时倍率×4");

            // === 저승 장터 ===
            Add("shop", "저승 장터", "Dead Market", "あの世の市場", "冥市");
            Add("shop_greeting", "어이, 아직 숨 붙어있는 손님이잖아.", "Hey, a breathing customer.", "おや、まだ息のある客か。", "哟，还有口气的客人。");
            Add("buy", "거래", "Trade", "取引", "交易");
            Add("yeop", "엽전", "Coins", "葉銭", "叶钱");
            Add("remove_talisman", "부적 떼기", "Remove Talisman", "お守り外し", "去除符咒");
            Add("next_realm", "다음 관문으로", "To Next Gate", "次の関門へ", "前往下一关");

            // === 길들인 도깨비 ===
            Add("companion", "길들인 도깨비", "Tamed Dokkaebi", "手懐けたトッケビ", "驯服的鬼怪");
            Add("skill_ready", "부려먹기 가능", "Ready", "使役可能", "可差遣");
            Add("skill_cooldown", "{0}차례 후", "in {0} turns", "{0}番後", "{0}轮后");

            // === 저승의 수련 ===
            Add("soul_fragment", "넋", "Soul", "魂", "魂");                   // 저승 화폐: 넋
            Add("permanent_upgrade", "저승 수련", "Underworld Training", "冥界修行", "冥界修行");
            Add("path_card", "화투꾼의 수련", "Gambler's Way", "花札師の道", "花牌师之道");
            Add("path_talisman", "무당의 수련", "Shaman's Way", "巫女の道", "巫师之道");
            Add("path_survival", "망자의 수련", "Survivor's Way", "亡者の道", "亡者之道");
            Add("upgrade_level", "Lv.{0}/{1}", "Lv.{0}/{1}", "Lv.{0}/{1}", "Lv.{0}/{1}");
            Add("upgrade_cost", "비용: {0}", "Cost: {0}", "コスト: {0}", "费用: {0}");

            // === 카드 강화 등급 ===
            Add("tier_base", "기본", "Base", "基本", "基础");
            Add("tier_refined", "연마", "Refined", "錬磨", "精炼");
            Add("tier_divine", "신통", "Divine", "神通", "神通");
            Add("tier_legendary", "전설", "Legendary", "伝説", "传说");
            Add("tier_nirvana", "해탈", "Nirvana", "解脱", "涅槃");

            // === 업적 ===
            Add("achievement", "업적", "Achievement", "実績", "成就");
            Add("achievement_unlocked", "업적 달성!", "Achievement Unlocked!", "実績解除！", "成就解锁！");

            // === 게임 상태 (저승 분위기) ===
            Add("game_over", "저승에 가라앉다", "Sunk into the Underworld", "冥界に沈む", "沉入冥界");
            Add("victory", "이겼다!", "Won!", "勝った！", "赢了！");
            Add("next_round", "다음 판 ▶", "Next Round ▶", "次の局 ▶", "下一局 ▶");
            Add("restart", "다시 치자", "Play Again", "もう一局", "再来一局");
            Add("main_menu", "삼도천으로", "To Samdo River", "三途の川へ", "回到三途川");
            Add("retry", "한 판 더", "One More", "もう一度", "再来一局");

            // === HUD ===
            Add("lives", "목숨", "Lives", "命", "命");
            Add("lives_display", "♥ {0}", "♥ {0}", "♥ {0}", "♥ {0}");
            Add("yeop_display", "{0}냥", "{0} coins", "{0}両", "{0}两");  // 엽전 단위: 냥
            Add("soul_display", "넋 {0}", "Soul {0}", "魂 {0}", "魂 {0}");

            // === 매칭 결과 (고스톱 용어) ===
            Add("match_none", "안 맞네 — 바닥에 깔기", "No match — place on field", "合わない — 場に出す", "不匹配 — 放到场上");
            Add("match_single", "먹었다!", "Captured!", "取った！", "吃到了！");
            Add("match_double", "쪽! 하나 골라", "Pick one!", "一枚選べ！", "选一张！");  // 고스톱: 쪽
            Add("match_triple", "쓸! 싹쓸이!", "Sweep!", "総取り！", "清扫！");            // 고스톱: 쓸

            // === 저승의 가호 (윤회 시작 시 선택) ===
            Add("blessing_title", "도깨비의 거래", "Dokkaebi's Deal", "トッケビの取引", "鬼怪的交易");
            Add("blessing_fire", "업화", "Hellfire", "業火", "业火");
            Add("blessing_ice", "빙결", "Frostbind", "氷結", "冰结");
            Add("blessing_void", "공허", "Void", "空虚", "虚空");
            Add("blessing_chaos", "혼돈", "Chaos", "混沌", "混沌");
            Add("blessing_skip", "거부 (아무것도 받지 않음)", "Refuse (take nothing)", "拒否（何も受け取らない）", "拒绝（不接受任何）");

            // === 스토리 ===
            Add("story_you_died", "넌 죽었다.", "You are dead.", "お前は死んだ。", "你死了。");
            Add("story_boatman_intro", "이 패로 왕들의 하수인을 이겨라.\n열 번 이기면 — 이승으로 돌아갈 수 있다.", "Beat the kings' servants with these cards.\nWin ten times — and you can return to the living.", "この札で王の手下を倒せ。\n十回勝てば — 現世に戻れる。", "用这些牌打败王的手下。\n赢十次 — 就能回到人间。");
            Add("story_boatman_warning", "물론, 지면...\n영원히 이 강 밑에 가라앉는다.", "Of course, if you lose...\nyou sink beneath this river forever.", "もちろん、負ければ…\n永遠にこの川の底に沈む。", "当然，如果输了……\n你将永远沉入这条河底。");
            Add("story_ending_light", "이승의 빛이 쏟아진다...", "Light from the living world pours in...", "現世の光が溢れ出す…", "人间的光芒倾泻而出……");
            Add("story_not_over", "아직 끝나지 않았다.", "It's not over yet.", "まだ終わっていない。", "还没有结束。");

            // === 보스 대사 ===
            Add("glutton_intro", "크하하! 네 패에서 맛있는 냄새가 나는구나!", "Hahaha! Your cards smell delicious!", "ガハハ！お前の札からうまそうな匂いがするぞ！", "哈哈哈！你的牌闻起来真香！");
            Add("glutton_defeat", "으억... 배가 너무 불러...", "Urgh... too full...", "うぅ…腹が一杯だ…", "呃……吃太饱了……");
            Add("glutton_victory", "꺼억! 맛있었다! 넌 이제 내 밥이야!", "Burp! Delicious! You're my meal now!", "ゲプッ！美味かった！お前は俺の飯だ！", "嗝！真好吃！你现在是我的食物了！");
            Add("yeomra_intro", "감히 이승으로 돌아가겠다고? 한 판 뜨자!", "You dare to return? Let's play!", "現世に戻るだと？勝負だ！", "你竟敢想回去？来一局！");
            Add("yeomra_defeat", "허... 대단하구나. 이승의 길을 열어주마.", "Hm... impressive. I'll open the way.", "ふむ…見事だ。道を開こう。", "嗯……了不起。我为你打开通道。");

            // === 부적 확장 13종 ===
            Add("tal_samdo_ferry", "삼도천의 나룻배", "Samdo Ferry", "三途の渡し船", "三途渡船");
            Add("tal_samdo_ferry_desc", "라운드 시작 시 칩 +15", "+15 Chips at round start", "ラウンド開始時チップ+15", "回合开始时筹码+15");
            Add("tal_dokkaebi_club", "도깨비 방망이", "Dokkaebi Club", "トッケビの棍棒", "鬼怪棒");
            Add("tal_dokkaebi_club_desc", "쓸 시 칩 +40", "+40 Chips on Sweep", "総取り時チップ+40", "清扫时筹码+40");
            Add("tal_virtue_gate", "열녀문", "Virtue Gate", "貞女の門", "烈女门");
            Add("tal_virtue_gate_desc", "초단 완성 시 배수 +2", "+2 Mult on Cho Dan", "草短完成時倍率+2", "草丹完成时倍率+2");
            Add("tal_underworld_mirror", "황천의 거울", "Underworld Mirror", "黄泉の鏡", "黄泉镜");
            Add("tal_underworld_mirror_desc", "Stop 시 칩 +50", "+50 Chips on Stop", "ストップ時チップ+50", "停止时筹码+50");
            Add("tal_girin_horn", "기린 각", "Girin Horn", "麒麟の角", "麒麟角");
            Add("tal_girin_horn_desc", "열끗 5장+ 시 배수 +3", "+3 Mult on 5+ Animals", "タネ5枚以上で倍率+3", "十点5张以上时倍率+3");
            Add("tal_fate_dice", "사주팔자의 주사위", "Fate Dice", "四柱推命のサイコロ", "四柱骰子");
            Add("tal_fate_dice_desc", "Go 시 50% 칩 +80", "50% +80 Chips on Go", "ゴー時50%チップ+80", "继续时50%筹码+80");
            Add("tal_yeomra_seal", "염라왕의 도장", "Yeomra's Seal", "閻魔王の印", "阎罗王印");
            Add("tal_yeomra_seal_desc", "오광 시 배수 x3", "x3 Mult on Five Brights", "五光で倍率×3", "五光时倍率×3");
            Add("tal_heavenly_lute", "천상의 비파", "Heavenly Lute", "天上の琵琶", "天上琵琶");
            Add("tal_heavenly_lute_desc", "청단 시 칩+100 배수+2", "+100 Chips +2 Mult on Cheong", "青短でチップ+100倍率+2", "青丹时筹码+100倍率+2");
            Add("tal_hellflame", "지옥불꽃", "Hellflame", "地獄の炎", "地狱烈焰");
            Add("tal_hellflame_desc", "피 15장+ 시 배수 x2", "x2 Mult on 15+ Pi", "カス15枚以上で倍率×2", "皮牌15张以上时倍率×2");
            Add("tal_phantom", "허깨비", "Phantom", "幻影", "幻影");
            Add("tal_phantom_desc", "매칭 실패 시 엽전 -5", "-5 Yeop on match fail", "マッチ失敗で葉銭-5", "匹配失败时叶钱-5");
            Add("tal_oblivion_ribbon", "망각의 띠", "Oblivion Ribbon", "忘却の帯", "遗忘之带");
            Add("tal_oblivion_ribbon_desc", "Go 2회+ 시 손패 -1", "Hand -1 on Go 2+", "ゴー2回以上で手札-1", "继续2次以上时手牌-1");
            Add("tal_samsara_bead", "윤회의 구슬", "Samsara Bead", "輪廻の珠", "轮回珠");
            Add("tal_samsara_bead_desc", "광 1장당 칩 +10", "+10 Chips per Gwang", "光1枚につきチップ+10", "每张光牌筹码+10");
            Add("tal_scale_desire", "욕망의 저울", "Scale of Desire", "欲望の天秤", "欲望之秤");
            Add("tal_scale_desire_desc", "목표 -10%, 영역 시 목숨 -1", "Target -10%, -1 life per realm", "目標-10%、領域ごとに命-1", "目标-10%，每领域命-1");

            // === 웨이브 강화 ===
            Add("wave_upgrade_title", "강화를 택하라", "Choose an Upgrade", "強化を選べ", "选择强化");
            Add("wave_chip_20", "칩 강화", "Chip Boost", "チップ強化", "筹码强化");
            Add("wave_chip_20_desc", "모든 족보 칩 +20", "+20 Chips to all Yokbo", "全族譜チップ+20", "所有牌型筹码+20");
            Add("wave_mult_1", "배수 강화", "Mult Boost", "倍率強化", "倍率强化");
            Add("wave_mult_1_desc", "기본 배수 +1", "+1 base Mult", "基本倍率+1", "基础倍率+1");
            Add("wave_hand_1", "손패 추가", "Extra Hand", "手札追加", "手牌追加");
            Add("wave_hand_1_desc", "다음 라운드 손패 +1", "+1 Hand next round", "次ラウンド手札+1", "下回合手牌+1");
            Add("wave_talisman_boost", "부적 증폭", "Talisman Amp", "お守り増幅", "符咒增幅");
            Add("wave_talisman_boost_desc", "부적 효과 +50%", "Talisman effects +50%", "お守り効果+50%", "符咒效果+50%");
            Add("wave_talisman_slot", "부적 슬롯", "Talisman Slot", "お守りスロット", "符咒栏位");
            Add("wave_talisman_slot_desc", "부적 슬롯 +1", "+1 Talisman slot", "お守りスロット+1", "符咒栏位+1");
            Add("wave_heal_2", "치유", "Heal", "治癒", "治愈");
            Add("wave_heal_2_desc", "목숨 +2 회복", "Restore 2 lives", "命+2回復", "恢复2条命");
            Add("wave_yeop_100", "엽전 보너스", "Yeop Bonus", "葉銭ボーナス", "叶钱奖励");
            Add("wave_yeop_100_desc", "엽전 +100", "+100 Yeop", "葉銭+100", "叶钱+100");
            Add("wave_target_10", "목표 감소", "Target Reduce", "目標減少", "目标减少");
            Add("wave_target_10_desc", "다음 영역 목표 -10%", "Next realm target -10%", "次の領域目標-10%", "下一领域目标-10%");
            Add("wave_random_talisman", "랜덤 부적", "Random Talisman", "ランダムお守り", "随机符咒");
            Add("wave_random_talisman_desc", "일반 부적 1개 장착", "Equip 1 Common talisman", "一般お守り1個装着", "装备1个普通符咒");
            Add("wave_soul_30", "영혼 수확", "Soul Harvest", "魂の収穫", "灵魂收割");
            Add("wave_soul_30_desc", "넋 +30", "+30 Soul Fragments", "魂の欠片+30", "灵魂碎片+30");
            Add("wave_gamble", "도박", "Gamble", "ギャンブル", "赌博");
            Add("wave_gamble_desc", "50% 엽전+50 or 목숨-1", "50% +50 Yeop or -1 life", "50%葉銭+50か命-1", "50%叶钱+50或命-1");
            Add("wave_mega_mult", "극한 배수", "Mega Mult", "極限倍率", "极限倍率");
            Add("wave_mega_mult_desc", "배수 +3, 목숨 -1", "+3 Mult, -1 life", "倍率+3、命-1", "倍率+3，命-1");

            // === 튜토리얼 ===
            Add("tutorial_skip", "튜토리얼 건너뛰기", "Skip Tutorial", "チュートリアルスキップ", "跳过教程");
            Add("tutorial_next", "다음 ▶", "Next ▶", "次へ ▶", "下一步 ▶");
            Add("tutorial_step1_dialogue", "자, 이 패로 시작하자.\n같은 월의 패끼리 매칭시키는 게 기본이야.\n손패를 클릭해서 바닥에 내봐.",
                "Let's begin.\nMatch cards of the same month.\nClick a hand card to play it.",
                "さあ、始めよう。\n同じ月の札を合わせるのが基本だ。\n手札をクリックして出してみろ。",
                "开始吧。\n把同月份的牌配对是基本规则。\n点击手牌打出。");
            Add("tutorial_step1_hint", "같은 월 패를 클릭!", "Click same month card!", "同じ月の札をクリック！", "点击同月份的牌！");
            Add("tutorial_step2_dialogue", "잘했어. 이제 족보를 배울 차례야.\n같은 종류의 패를 모으면 족보가 완성돼.\n홍단: 1,2,3월 홍색 띠 3장.",
                "Well done. Now learn Yokbo.\nCollect same type cards to complete sets.\nHong Dan: Jan/Feb/Mar red ribbons.",
                "よくやった。次は族譜だ。\n同じ種類の札を集めると族譜が完成する。\n赤短：1,2,3月の赤い短冊3枚。",
                "做得好。现在学习牌型。\n收集同类型牌完成牌型。\n红丹：一二三月红色带牌3张。");
            Add("tutorial_step2_hint", "족보를 완성해보세요!", "Try completing a Yokbo!", "族譜を完成させよう！", "试着完成一个牌型！");
            Add("tutorial_step3_dialogue", "족보가 나왔지? 여기서 중요한 선택이야.\nGo: 더 높은 배수를 노린다. 하지만 리스크가 커져.\nStop: 안전하게 현재 점수를 확정한다.",
                "Got a Yokbo? Time for the big choice.\nGo: Risk for higher mult. But danger grows.\nStop: Lock in your current score safely.",
                "族譜が出たな？ここからが大事な選択だ。\nゴー：高い倍率を狙う。だがリスクも増す。\nストップ：安全に今のスコアを確定する。",
                "出了牌型？现在是重要的选择。\n继续：追求更高倍率，但风险增大。\n停止：安全锁定当前分数。");
            Add("tutorial_step3_hint", "Go or Stop!", "Go or Stop!", "ゴーかストップか！", "继续还是停止！");
            Add("tutorial_step4_dialogue", "보스에겐 각자 기믹이 있어.\n먹보 도깨비: 매 3턴마다 네 최고 패를 먹어치워.\n족보를 빨리 완성하는 게 핵심이야!",
                "Each boss has a gimmick.\nGlutton Dokkaebi: Eats your best card every 3 turns.\nComplete Yokbo quickly!",
                "ボスにはそれぞれギミックがある。\n食いしん坊トッケビ：3ターンごとに最強の札を食う。\n族譜を早く完成させるのがカギだ！",
                "每个Boss都有机制。\n贪吃鬼怪：每3回合吃掉你最好的牌。\n快速完成牌型是关键！");
            Add("tutorial_step4_hint", "보스 기믹을 조심!", "Watch out for boss gimmicks!", "ボスギミックに注意！", "注意Boss机制！");
            Add("tutorial_complete", "잘했어! 이제 진짜 전투를 시작하자.\n더 깊이 들어갈수록 더 강한 녀석들이 기다리고 있어.",
                "Well done! Now the real battle begins.\nDeeper you go, stronger they get.",
                "よくやった！さあ本番だ。\n深く行くほど強い奴らが待っている。",
                "做得好！现在开始真正的战斗。\n越深入，敌人越强。");
            Add("tutorial_boatman", "뱃사공", "Boatman", "船頭", "船夫");

            // === 대장간 ===
            Add("forge", "대장간", "Forge", "鍛冶場", "锻造坊");
            Add("forge_desc", "카드를 강화하여 더 강하게!", "Enhance cards for more power!", "札を強化してもっと強く！", "强化卡牌变得更强！");
            Add("forge_cost", "비용: {0} 엽전", "Cost: {0} Yeop", "コスト: {0} 葉銭", "费用: {0} 叶钱");
            Add("forge_max", "최대 등급!", "Max tier!", "最大等級！", "最高等级！");
            Add("forge_success", "강화 성공!", "Upgrade success!", "強化成功！", "强化成功！");

            // === 동료 도깨비 UI ===
            Add("companion_use", "스킬 사용", "Use Skill", "スキル使用", "使用技能");
            Add("companion_slot", "동료 {0}/{1}", "Companion {0}/{1}", "仲間 {0}/{1}", "同伴 {0}/{1}");

            // === 업적 UI ===
            Add("collection_title", "도감", "Collection", "図鑑", "图鉴");
            Add("achievement_list", "업적 목록", "Achievement List", "実績一覧", "成就列表");
            Add("card_collection", "카드 도감", "Card Collection", "カード図鑑", "卡牌图鉴");
            Add("achievement_progress", "달성: {0}/{1}", "Progress: {0}/{1}", "達成: {0}/{1}", "进度: {0}/{1}");

            // === 섯다 족보 ===
            Add("seotda", "섯다", "Seotda", "ソッタ", "色打");
            Add("seotda_38", "38광땡 — 화투의 정점!", "38 Bright Pair — Ultimate!", "38光テン — 花札の頂点！", "38光对 — 花牌之巅！");
            Add("seotda_18", "18광땡", "18 Bright Pair", "18光テン", "18光对");
            Add("seotda_13", "13광땡", "13 Bright Pair", "13光テン", "13光对");
            Add("seotda_gwangttaeng", "광땡", "Bright Pair", "光テン", "光对");
            Add("seotda_jangttaeng", "장땡", "10-Pair", "十テン", "十对");
            Add("seotda_ttaeng", "{0}땡", "{0}-Pair", "{0}テン", "{0}对");
            Add("seotda_ali", "알리 (1-2)", "Ali (1-2)", "アリ", "阿里");
            Add("seotda_doksa", "독사 (1-4)", "Doksa (1-4)", "ドクサ", "毒蛇");
            Add("seotda_gupping", "구삥 (1-9)", "Gupping (1-9)", "グッピン", "九一");
            Add("seotda_jangpping", "장삥 (1-10)", "Jangpping (1-10)", "チャンピン", "长一");
            Add("seotda_jangsa", "장사 (4-10)", "Jangsa (4-10)", "チャンサ", "四十");
            Add("seotda_seryuk", "세륙 (4-6)", "Seryuk (4-6)", "セリュク", "四六");
            Add("seotda_kkeut", "{0}끗", "{0} Kkeut", "{0}クッ", "{0}点");
            Add("seotda_gaboh", "갑오 (0끗)", "Gaboh (0)", "カッポ", "甲午");

            // === 전투 ===
            Add("damage", "{0} 타격!", "{0} damage!", "{0}ダメージ！", "{0}伤害！");
            Add("boss_hp", "HP: {0}/{1}", "HP: {0}/{1}", "HP: {0}/{1}", "HP: {0}/{1}");
            Add("boss_counter", "반격!", "Counter!", "反撃！", "反击！");
            Add("boss_rage", "광분!", "Enraged!", "激昂！", "暴怒！");

            // === 사주팔자 ===
            Add("destiny_title", "사주팔자", "Four Pillars of Destiny", "四柱推命", "四柱八字");
            Add("destiny_info", "운명: {0}", "Destiny: {0}", "運命: {0}", "命运: {0}");
            Add("destiny_element_wood", "목(木)", "Wood", "木", "木");
            Add("destiny_element_fire", "화(火)", "Fire", "火", "火");
            Add("destiny_element_earth", "토(土)", "Earth", "土", "土");
            Add("destiny_element_metal", "금(金)", "Metal", "金", "金");
            Add("destiny_element_water", "수(水)", "Water", "水", "水");

            // === 욕망의 저울 ===
            Add("greed_scale", "욕망의 저울", "Scale of Desire", "欲望の天秤", "欲望之秤");
            Add("greed_safe", "균형", "Balanced", "均衡", "平衡");
            Add("greed_tempted", "동요", "Tempted", "動揺", "动摇");
            Add("greed_greedy", "집착", "Obsessed", "執着", "执念");
            Add("greed_consumed", "탐식", "Consumed", "貪食", "吞噬");

            // === 도깨비 각인 ===
            Add("seal", "각인", "Seal", "刻印", "刻印");
            Add("seal_greed", "탐식의 각인", "Greed Seal", "貪食の刻印", "贪食之印");
            Add("seal_deception", "기만의 각인", "Deception Seal", "欺瞞の刻印", "欺瞒之印");
            Add("seal_delusion", "환혹의 각인", "Delusion Seal", "幻惑の刻印", "幻惑之印");
            Add("seal_truth", "진실의 각인", "Truth Seal", "真実の刻印", "真实之印");
            Add("seal_judgment", "심판의 각인", "Judgment Seal", "審判の刻印", "审判之印");
            Add("seal_rage", "분노의 각인", "Rage Seal", "憤怒の刻印", "愤怒之印");
            Add("seal_avarice", "탐욕의 각인", "Avarice Seal", "貪欲の刻印", "贪欲之印");
            Add("seal_patience", "인내의 각인", "Patience Seal", "忍耐の刻印", "忍耐之印");
            Add("seal_replication", "복제의 각인", "Replication Seal", "複製の刻印", "复制之印");
            Add("seal_samsara", "윤회의 각인", "Samsara Seal", "輪廻の刻印", "轮回之印");

            // === 재앙 보스 ===
            Add("calamity", "재앙", "Calamity", "災厄", "灾厄");
            Add("boss_skeleton", "백골대장", "Skeleton General", "白骨大将", "白骨大将");
            Add("boss_ninetail", "구미호 왕", "Nine-Tail Fox King", "九尾狐王", "九尾狐王");
            Add("boss_imugi", "이무기", "Imugi", "イムギ", "螭龙");
            Add("boss_flower", "저승꽃", "Underworld Flower", "あの世の花", "冥花");

            // === 세이브/로드 ===
            Add("save_loaded", "이어하기", "Continue", "つづきから", "继续");
            Add("save_info", "나선 {0} 영역 {1}", "Spiral {0} Realm {1}", "螺旋{0} 領域{1}", "螺旋{0} 领域{1}");
            Add("no_save", "세이브 없음", "No Save", "セーブなし", "无存档");
        }

        private void Add(string key, string ko, string en, string ja, string zh)
        {
            _table[key] = new[] { ko, en, ja, zh };
        }
    }

    /// <summary>
    /// 편의 정적 접근자
    /// </summary>
    public static class L
    {
        public static string Get(string key) => LocalizationManager.Instance.Get(key);
        public static string Get(string key, params object[] args) => LocalizationManager.Instance.Get(key, args);
    }
}
