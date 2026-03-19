using System;
using System.Collections.Generic;
using DokkaebiHand.Cards;
using DokkaebiHand.Combat;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 동료 도깨비: 격파한 보스를 동료로 소환하여 액티브 스킬 사용
    /// </summary>
    public class CompanionData
    {
        public string Id;
        public string NameKR;
        public string AbilityNameKR;
        public string AbilityDesc;
        public int Cooldown;         // 턴 단위 쿨타임
        public string UnlockBossId;  // 해금 조건 보스 ID
    }

    public class CompanionInstance
    {
        public CompanionData Data { get; private set; }
        public int CurrentCooldown { get; private set; }
        public bool IsReady => CurrentCooldown <= 0;

        public CompanionInstance(CompanionData data)
        {
            Data = data;
            CurrentCooldown = 0;
        }

        public bool Activate()
        {
            if (!IsReady) return false;
            CurrentCooldown = Data.Cooldown;
            return true;
        }

        public void TickCooldown()
        {
            if (CurrentCooldown > 0) CurrentCooldown--;
        }
    }

    public class CompanionManager
    {
        public List<CompanionInstance> ActiveCompanions { get; private set; } = new List<CompanionInstance>();
        public const int MaxSlots = 2;

        private HashSet<string> _unlockedIds = new HashSet<string>();

        public event Action<CompanionInstance, string> OnCompanionActivated;

        public static List<CompanionData> AllCompanions { get; } = new List<CompanionData>
        {
            new CompanionData
            {
                Id = "glutton", NameKR = "먹보 도깨비",
                AbilityNameKR = "탐식", AbilityDesc = "바닥패 1장 제거",
                Cooldown = 3, UnlockBossId = "glutton"
            },
            new CompanionData
            {
                Id = "trickster", NameKR = "장난꾸러기 도깨비",
                AbilityNameKR = "속임수", AbilityDesc = "손패 1장과 바닥패 1장 교환",
                Cooldown = 4, UnlockBossId = "trickster"
            },
            new CompanionData
            {
                Id = "fox", NameKR = "여우 도깨비",
                AbilityNameKR = "환혹", AbilityDesc = "다음 매칭 시 와일드카드 1회",
                Cooldown = 5, UnlockBossId = "fox"
            },
            new CompanionData
            {
                Id = "mirror", NameKR = "거울 도깨비",
                AbilityNameKR = "반사", AbilityDesc = "보스 기믹 1회 반사",
                Cooldown = 6, UnlockBossId = "mirror"
            },
            new CompanionData
            {
                Id = "flame", NameKR = "불꽃 도깨비",
                AbilityNameKR = "소각", AbilityDesc = "바닥패 전체 리셋 (자발적)",
                Cooldown = 8, UnlockBossId = "flame"
            },
            new CompanionData
            {
                Id = "shadow", NameKR = "그림자 도깨비",
                AbilityNameKR = "잠식", AbilityDesc = "보스 목표 점수 -15% (1라운드)",
                Cooldown = 10, UnlockBossId = "shadow"
            },
            new CompanionData
            {
                Id = "boatman", NameKR = "뱃사공",
                AbilityNameKR = "항해", AbilityDesc = "현재 턴 되감기 (Undo)",
                Cooldown = 12, UnlockBossId = "secret_boatman"
            }
        };

        public void UnlockCompanion(string id)
        {
            _unlockedIds.Add(id);
        }

        public bool IsUnlocked(string id) => _unlockedIds.Contains(id);

        public bool Equip(string id)
        {
            if (!_unlockedIds.Contains(id)) return false;
            if (ActiveCompanions.Count >= MaxSlots) return false;
            if (ActiveCompanions.Exists(c => c.Data.Id == id)) return false;

            var data = AllCompanions.Find(c => c.Id == id);
            if (data == null) return false;

            ActiveCompanions.Add(new CompanionInstance(data));
            return true;
        }

        public bool ActivateCompanion(int slotIndex)
        {
            if (slotIndex < 0 || slotIndex >= ActiveCompanions.Count) return false;

            var companion = ActiveCompanions[slotIndex];
            if (!companion.Activate()) return false;

            OnCompanionActivated?.Invoke(companion, companion.Data.AbilityDesc);
            return true;
        }

        /// <summary>
        /// 동료 스킬 실행 (RoundManager 연동)
        /// </summary>
        public bool ExecuteAbility(int slotIndex, Combat.RoundManager round,
            PlayerState player, Combat.BossManager boss = null)
        {
            if (slotIndex < 0 || slotIndex >= ActiveCompanions.Count) return false;
            var companion = ActiveCompanions[slotIndex];
            if (!companion.IsReady) return false;

            bool success = false;
            switch (companion.Data.Id)
            {
                case "glutton":
                    // 탐식: 바닥패 1장 제거
                    if (round.FieldCards.Count > 0)
                        success = round.CompanionRemoveFieldCard(0);
                    break;

                case "trickster":
                    // 속임수: 손패↔바닥 교환
                    if (player.Hand.Count > 0 && round.FieldCards.Count > 0)
                        success = round.CompanionSwapCards(player.Hand[0], 0);
                    break;

                case "fox":
                    // 환혹: 다음 매칭 와일드카드
                    round.SetWildCardNext();
                    success = true;
                    break;

                case "mirror":
                    // 반사: 보스 기믹 1회 반사
                    if (boss != null)
                    {
                        boss.ReflectNextMechanic();
                        success = true;
                    }
                    break;

                case "flame":
                    // 소각: 바닥패 전체 리셋
                    success = round.CompanionResetField();
                    break;

                case "shadow":
                    // 잠식: 목표 점수 -15%
                    round.ApplyShadowReduction();
                    success = true;
                    break;

                case "boatman":
                    // 항해: 현재 턴 Undo (간소화: 목표 -10%)
                    round.ApplyShadowReduction();
                    success = true;
                    break;
            }

            if (success)
                companion.Activate();

            return success;
        }

        public void TickAllCooldowns()
        {
            foreach (var c in ActiveCompanions)
                c.TickCooldown();
        }

        public HashSet<string> GetUnlockedIds() => new HashSet<string>(_unlockedIds);

        public void LoadUnlocked(IEnumerable<string> ids)
        {
            _unlockedIds = new HashSet<string>(ids);
        }
    }
}
