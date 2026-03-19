using System;
using System.Collections.Generic;
using DokkaebiHand.Talismans;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 상점 시스템: 부적 3종 + 소모품 2종 랜덤 진열
    /// </summary>
    public class ShopItem
    {
        public string Id;
        public string NameKR;
        public string NameEN;
        public int Cost;
        public bool IsSold;

        // 부적 아이템
        public TalismanData TalismanData;

        // 소모품
        public string ConsumableType; // "health", "card_pack", "curse_remove"
    }

    public class ShopManager
    {
        private readonly Random _rng;

        public List<ShopItem> CurrentStock { get; private set; } = new List<ShopItem>();

        public ShopManager(int? seed = null)
        {
            _rng = seed.HasValue ? new Random(seed.Value) : new Random();
        }

        /// <summary>
        /// 상점 재고 생성 (영역 클리어 후 호출)
        /// </summary>
        public void GenerateStock(int spiralNumber, float discount = 0f)
        {
            CurrentStock.Clear();

            // 부적 3종
            var allTalismans = TalismanDatabase.AllTalismans;
            var shuffled = new List<TalismanData>(allTalismans);
            ShuffleList(shuffled);

            int talismanCount = Math.Min(3, shuffled.Count);
            for (int i = 0; i < talismanCount; i++)
            {
                var t = shuffled[i];
                int baseCost = t.Rarity switch
                {
                    TalismanRarity.Common => 30 + _rng.Next(20),
                    TalismanRarity.Rare => 80 + _rng.Next(40),
                    TalismanRarity.Legendary => 200 + _rng.Next(100),
                    TalismanRarity.Cursed => 0, // 저주는 무료 (강제)
                    _ => 50
                };

                int finalCost = (int)(baseCost * (1f - discount));

                CurrentStock.Add(new ShopItem
                {
                    Id = $"talisman_{i}",
                    NameKR = t.NameKR,
                    NameEN = t.Name,
                    Cost = finalCost,
                    TalismanData = t
                });
            }

            // 소모품: 체력 회복
            CurrentStock.Add(new ShopItem
            {
                Id = "health",
                NameKR = "체력 회복",
                NameEN = "Health Restore",
                Cost = (int)(75 * (1f - discount)),
                ConsumableType = "health"
            });

            // 소모품: 패 팩 (소)
            CurrentStock.Add(new ShopItem
            {
                Id = "card_pack",
                NameKR = "패 팩 (소)",
                NameEN = "Card Pack (S)",
                Cost = (int)(40 * (1f - discount)),
                ConsumableType = "card_pack"
            });

            // 소모품: 패 팩 (대) — 나선 2+ 부터
            if (spiralNumber >= 2)
            {
                CurrentStock.Add(new ShopItem
                {
                    Id = "card_pack_large",
                    NameKR = "패 팩 (대)",
                    NameEN = "Card Pack (L)",
                    Cost = (int)(80 * (1f - discount)),
                    ConsumableType = "card_pack_large"
                });
            }

            // 소모품: 저주 해제부
            bool hasCurse = false;
            // 저주가 있는지 체크는 Purchase 시점에서 처리
            CurrentStock.Add(new ShopItem
            {
                Id = "curse_remove",
                NameKR = "저주 해제부",
                NameEN = "Curse Buster",
                Cost = (int)(100 * (1f - discount)),
                ConsumableType = "curse_remove"
            });

            // 소모품: 감정부 (다음 상점 전설 부적 보장)
            CurrentStock.Add(new ShopItem
            {
                Id = "sentiment_stone",
                NameKR = "감정부",
                NameEN = "Sentiment Stone",
                Cost = (int)(60 * (1f - discount)),
                ConsumableType = "sentiment_stone"
            });
        }

        /// <summary>
        /// 아이템 구매
        /// </summary>
        public bool Purchase(PlayerState player, int itemIndex)
        {
            if (itemIndex < 0 || itemIndex >= CurrentStock.Count) return false;

            var item = CurrentStock[itemIndex];
            if (item.IsSold) return false;
            if (player.Yeop < item.Cost) return false;

            player.Yeop -= item.Cost;
            item.IsSold = true;

            // 효과 적용
            if (item.TalismanData != null)
            {
                if (!player.CanEquipTalisman() && !item.TalismanData.IsCurse) return false;
                player.EquipTalisman(new TalismanInstance(item.TalismanData));
            }
            else if (item.ConsumableType == "health")
            {
                player.Lives = Math.Min(player.Lives + 1, 6);
            }
            else if (item.ConsumableType == "card_pack")
            {
                player.NextRoundHandBonus += 2;
            }
            else if (item.ConsumableType == "card_pack_large")
            {
                player.NextRoundHandBonus += 4;
            }
            else if (item.ConsumableType == "curse_remove")
            {
                // 저주 부적 1개 제거
                var curseIdx = player.Talismans.FindIndex(t => t.Data.IsCurse);
                if (curseIdx >= 0)
                    player.Talismans.RemoveAt(curseIdx);
                else
                    return false; // 저주 없으면 구매 불가
            }
            else if (item.ConsumableType == "sentiment_stone")
            {
                // 다음 상점 전설 보장 플래그 (간소화: 즉시 전설 부적 장착)
                var legends = Talismans.TalismanDatabase.GetByRarity(Talismans.TalismanRarity.Legendary);
                if (legends.Count > 0 && player.CanEquipTalisman())
                {
                    var t = legends[new Random().Next(legends.Count)];
                    player.EquipTalisman(new Talismans.TalismanInstance(t));
                }
            }

            return true;
        }

        /// <summary>
        /// 카드 강화 (대장간)
        /// </summary>
        public bool UpgradeCard(PlayerState player, Cards.CardEnhancementManager enhManager, int cardId, int cost)
        {
            if (player.Yeop < cost) return false;
            var enh = enhManager.GetEnhancement(cardId);
            if (!enh.Upgrade()) return false;
            player.Yeop -= cost;
            return true;
        }

        private void ShuffleList<T>(List<T> list)
        {
            for (int i = list.Count - 1; i > 0; i--)
            {
                int j = _rng.Next(i + 1);
                (list[i], list[j]) = (list[j], list[i]);
            }
        }
    }
}
