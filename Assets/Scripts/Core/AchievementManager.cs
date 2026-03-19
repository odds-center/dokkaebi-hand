using System;
using System.Collections.Generic;

namespace DokkaebiHand.Core
{
    public enum AchievementCategory
    {
        Progress,
        Yokbo,
        GoStop,
        Special,
        Hidden
    }

    public class AchievementDefinition
    {
        public string Id;
        public string NameKR;
        public string NameEN;
        public string DescriptionKR;
        public AchievementCategory Category;
        public int SoulReward;
        public bool IsHidden;
    }

    /// <summary>
    /// Steam 업적 연동 가능한 업적 관리 시스템
    /// </summary>
    public class AchievementManager
    {
        private HashSet<string> _unlocked = new HashSet<string>();
        private List<AchievementDefinition> _allAchievements;

        public event Action<AchievementDefinition> OnAchievementUnlocked;

        public IReadOnlyList<AchievementDefinition> AllAchievements => _allAchievements;

        public AchievementManager()
        {
            _allAchievements = InitializeAchievements();
        }

        public bool IsUnlocked(string id) => _unlocked.Contains(id);

        public bool TryUnlock(string id)
        {
            if (_unlocked.Contains(id)) return false;

            var def = _allAchievements.Find(a => a.Id == id);
            if (def == null) return false;

            _unlocked.Add(id);
            OnAchievementUnlocked?.Invoke(def);
            return true;
        }

        public int GetUnlockedCount() => _unlocked.Count;
        public int GetTotalCount() => _allAchievements.Count;

        public List<string> GetUnlockedIds() => new List<string>(_unlocked);

        public void LoadUnlocked(List<string> ids)
        {
            _unlocked = new HashSet<string>(ids);
        }

        // === 조건 체크 헬퍼 ===

        public void CheckProgress(int spiralCleared, int totalRealms, int deaths)
        {
            if (totalRealms >= 1) TryUnlock("first_step");
            if (totalRealms >= 5) TryUnlock("explorer");
            if (totalRealms >= 10) TryUnlock("yeomra_judgment");
            if (totalRealms >= 20) TryUnlock("spiral_2");
            if (totalRealms >= 50) TryUnlock("spiral_5");
            if (totalRealms >= 100) TryUnlock("spiral_10");
            if (deaths >= 10) TryUnlock("tenth_death");
        }

        public void CheckYokbo(string yokboName, int singleRoundScore)
        {
            if (yokboName.Contains("삼광")) TryUnlock("three_gwang");
            if (yokboName.Contains("사광")) TryUnlock("four_gwang");
            if (yokboName.Contains("오광")) TryUnlock("five_gwang");
            if (singleRoundScore >= 10000) TryUnlock("score_10k");
            if (singleRoundScore >= 1000000) TryUnlock("score_1m");
        }

        public void CheckGo(int goCount, bool succeeded)
        {
            if (goCount >= 1) TryUnlock("first_go");
            if (goCount >= 2) TryUnlock("bold_choice");
            if (goCount >= 3 && succeeded) TryUnlock("mad_gambler");
            if (goCount >= 3 && !succeeded) TryUnlock("greed_price");
        }

        private List<AchievementDefinition> InitializeAchievements()
        {
            return new List<AchievementDefinition>
            {
                // === 진행 ===
                Ach("first_step", "첫 발걸음", "First Step", "1영역 클리어", AchievementCategory.Progress, 20),
                Ach("explorer", "저승 탐험가", "Explorer", "5영역 클리어", AchievementCategory.Progress, 50),
                Ach("yeomra_judgment", "염라의 심판", "Yeomra's Judgment", "나선 1 완료 (10영역)", AchievementCategory.Progress, 100),
                Ach("spiral_2", "두 번째 윤회", "Second Cycle", "나선 2 돌입 (20영역)", AchievementCategory.Progress, 200),
                Ach("spiral_5", "저승의 전설", "Underworld Legend", "나선 5 돌입 (50영역)", AchievementCategory.Progress, 500),
                Ach("spiral_10", "무한의 끝", "Edge of Infinity", "나선 10 돌입 (100영역)", AchievementCategory.Progress, 1000),
                Ach("tenth_death", "열 번째 죽음", "Tenth Death", "10회 사망", AchievementCategory.Progress, 20),

                // === 족보 ===
                Ach("three_gwang", "삼광 달성", "Three Brights", "삼광 완성", AchievementCategory.Yokbo, 30),
                Ach("four_gwang", "사광 달성", "Four Brights", "사광 완성", AchievementCategory.Yokbo, 50),
                Ach("five_gwang", "오광 달성", "Five Brights", "오광 완성", AchievementCategory.Yokbo, 100),
                Ach("score_10k", "만점왕", "10K Master", "단일 라운드 10,000점", AchievementCategory.Yokbo, 200),
                Ach("score_1m", "백만장자", "Millionaire", "단일 라운드 1,000,000점", AchievementCategory.Yokbo, 500),

                // === Go/Stop ===
                Ach("first_go", "첫 Go", "First Go", "Go 1회 선택", AchievementCategory.GoStop, 10),
                Ach("bold_choice", "대담한 선택", "Bold Choice", "Go 2회 연속", AchievementCategory.GoStop, 30),
                Ach("mad_gambler", "미친 도박사", "Mad Gambler", "Go 3회 성공", AchievementCategory.GoStop, 200),
                Ach("greed_price", "욕심의 대가", "Price of Greed", "Go 3회 실패 즉사", AchievementCategory.GoStop, 20),

                // === 특수 ===
                Ach("no_talisman", "무부적", "No Talisman", "부적 없이 나선 1 완료", AchievementCategory.Special, 200),
                Ach("curse_lover", "저주 수용자", "Curse Lover", "저주 부적 3개 장착 클리어", AchievementCategory.Special, 150),
                Ach("nirvana_card", "해탈", "Nirvana", "카드 1장 해탈 등급 달성", AchievementCategory.Special, 300),

                // === 히든 ===
                Ach("boatman_talk", "???", "???", "뱃사공에게 5번 대화", AchievementCategory.Hidden, 50, true),
                Ach("zero_score", "???", "???", "점수 0으로 라운드 종료", AchievementCategory.Hidden, 10, true),
                Ach("time_100h", "???", "???", "총 플레이 시간 100시간", AchievementCategory.Hidden, 0, true),
            };
        }

        private AchievementDefinition Ach(string id, string nameKR, string nameEN,
            string desc, AchievementCategory cat, int reward, bool hidden = false)
        {
            return new AchievementDefinition
            {
                Id = id, NameKR = nameKR, NameEN = nameEN,
                DescriptionKR = desc, Category = cat,
                SoulReward = reward, IsHidden = hidden
            };
        }
    }
}
