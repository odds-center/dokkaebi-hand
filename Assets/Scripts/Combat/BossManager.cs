using System;
using System.Collections.Generic;
using System.Linq;
using DokkaebiHand.Cards;
using DokkaebiHand.Core;

namespace DokkaebiHand.Combat
{
    /// <summary>
    /// 보스 기믹 처리 매니저
    /// </summary>
    public class BossManager
    {
        private BossDefinition _currentBoss;
        private int _turnCounter;
        private bool _reflectNext;

        // 재앙 보스용
        private int _skullCount;
        private int _competitiveScore;
        public int CompetitiveScore => _competitiveScore;
        public int SkullCount => _skullCount;
        public bool IsCalamityBoss => _currentBoss != null &&
            (_currentBoss.Gimmick == BossGimmick.Skullify || _currentBoss.Gimmick == BossGimmick.FakeCards ||
             _currentBoss.Gimmick == BossGimmick.Competitive || _currentBoss.Gimmick == BossGimmick.Suppress);

        public BossDefinition CurrentBoss => _currentBoss;
        public bool IsBossActive => _currentBoss != null;

        public event Action<string> OnBossGimmickTriggered;

        public void SetBoss(BossDefinition boss)
        {
            _currentBoss = boss;
            _turnCounter = 0;
            _skullCount = 0;
            _competitiveScore = 0;
        }

        public void ClearBoss()
        {
            _currentBoss = null;
            _turnCounter = 0;
        }

        /// <summary>
        /// 턴 시작 시 기믹 체크 및 적용
        /// </summary>
        public void OnTurnStart(PlayerState player, DeckManager deckManager)
        {
            if (_currentBoss == null) return;

            _turnCounter++;

            if (_turnCounter % _currentBoss.GimmickInterval != 0)
                return;

            // 거울 도깨비 반사
            if (_reflectNext)
            {
                _reflectNext = false;
                OnBossGimmickTriggered?.Invoke("거울 도깨비가 기믹을 반사했다!");
                return;
            }

            switch (_currentBoss.Gimmick)
            {
                case BossGimmick.ConsumeHighest:
                    ApplyConsumeHighest(player);
                    break;

                case BossGimmick.ResetField:
                    ApplyResetField(deckManager);
                    break;

                case BossGimmick.DisableTalisman:
                    ApplyDisableTalisman(player);
                    break;

                case BossGimmick.NoBright:
                    // Passive — handled in scoring
                    break;

                case BossGimmick.FlipAll:
                    OnBossGimmickTriggered?.Invoke("장난꾸러기 도깨비가 패를 뒤집었다!");
                    break;

                // === 재앙 보스 기믹 ===
                case BossGimmick.Skullify:
                    ApplySkullify(player);
                    break;

                case BossGimmick.FakeCards:
                    ApplyFakeCards(player);
                    break;

                case BossGimmick.Competitive:
                    _competitiveScore += 50;
                    OnBossGimmickTriggered?.Invoke($"이무기 점수: {_competitiveScore} (+50)");
                    break;

                case BossGimmick.Suppress:
                    ApplySuppression(player);
                    break;
            }
        }

        /// <summary>
        /// 거울 도깨비 스킬: 다음 기믹 반사
        /// </summary>
        public void ReflectNextMechanic()
        {
            _reflectNext = true;
        }

        /// <summary>
        /// 광 무효화 체크 (염라대왕 기믹)
        /// </summary>
        public bool IsGwangDisabled()
        {
            return _currentBoss != null && _currentBoss.Gimmick == BossGimmick.NoBright;
        }

        /// <summary>
        /// 먹보 도깨비: 손패 중 최고가치 패 1장 소멸
        /// </summary>
        private void ApplyConsumeHighest(PlayerState player)
        {
            if (player.Hand.Count == 0) return;

            CardInstance highest = player.Hand[0];
            foreach (var card in player.Hand)
            {
                if (card.BasePoints > highest.BasePoints)
                    highest = card;
            }

            player.Hand.Remove(highest);
            OnBossGimmickTriggered?.Invoke(
                $"먹보 도깨비가 {highest.NameKR}을(를) 먹어치웠다!");
        }

        /// <summary>
        /// 불꽃 도깨비: 바닥패 전체 리셋
        /// </summary>
        private void ApplyResetField(DeckManager deckManager)
        {
            // 바닥패를 모두 제거하고 뽑기패에서 새로 배치
            var fieldCards = new List<CardInstance>(deckManager.FieldCards);
            foreach (var card in fieldCards)
                deckManager.RemoveFromField(card);

            // 뽑기패에서 새 바닥패 배치
            int newFieldCount = Math.Min(8, deckManager.DrawPile.Count);
            for (int i = 0; i < newFieldCount; i++)
            {
                var drawn = deckManager.DrawFromPile();
                if (drawn != null)
                    deckManager.AddToField(drawn);
            }

            OnBossGimmickTriggered?.Invoke(
                "불꽃 도깨비가 바닥패를 불태웠다! 새 패가 깔렸다!");
        }

        // === 재앙 보스 기믹 ===

        /// <summary>
        /// 백골대장: 손패 1장을 해골패로 변환 (제거). 3개 = 즉사.
        /// </summary>
        private void ApplySkullify(PlayerState player)
        {
            if (player.Hand.Count == 0) return;

            var rng = new Random();
            int idx = rng.Next(player.Hand.Count);
            var skull = player.Hand[idx];
            player.Hand.RemoveAt(idx);
            _skullCount++;

            OnBossGimmickTriggered?.Invoke(
                $"백골대장이 {skull.NameKR}을(를) 해골로 만들었다! ({_skullCount}/3)");

            if (_skullCount >= 3)
            {
                player.Lives = 0;
                OnBossGimmickTriggered?.Invoke("해골이 3개 모였다... 즉사!");
            }
        }

        /// <summary>
        /// 구미호 왕: 가짜 카드 효과 — 손패 랜덤 1장 제거 + 칩 -50
        /// </summary>
        private void ApplyFakeCards(PlayerState player)
        {
            if (player.Hand.Count == 0) return;

            // 3턴마다 손패 셔플 (랜덤 재배열)
            var rng = new Random();
            for (int i = player.Hand.Count - 1; i > 0; i--)
            {
                int j = rng.Next(i + 1);
                (player.Hand[i], player.Hand[j]) = (player.Hand[j], player.Hand[i]);
            }

            OnBossGimmickTriggered?.Invoke("구미호 왕이 손패를 뒤섞었다!");
        }

        /// <summary>
        /// 저승꽃: 부적 셔플 (랜덤 비활성/활성 전환)
        /// </summary>
        private void ApplySuppression(PlayerState player)
        {
            var rng = new Random();
            // 부적 1개 랜덤 비활성
            var active = player.Talismans.FindAll(t => t.IsActive);
            if (active.Count > 0)
            {
                active[rng.Next(active.Count)].IsActive = false;
                OnBossGimmickTriggered?.Invoke("저승꽃이 부적을 억누른다...");
            }

            // 비활성 1개 랜덤 활성 (셔플 효과)
            var inactive = player.Talismans.FindAll(t => !t.IsActive);
            if (inactive.Count > 0)
                inactive[rng.Next(inactive.Count)].IsActive = true;
        }

        /// <summary>
        /// 그림자 도깨비: 부적 1개 랜덤 비활성화
        /// </summary>
        private void ApplyDisableTalisman(PlayerState player)
        {
            var activeTalismans = player.Talismans.Where(t => t.IsActive).ToList();
            if (activeTalismans.Count == 0) return;

            var rng = new Random();
            var target = activeTalismans[rng.Next(activeTalismans.Count)];
            target.IsActive = false;

            OnBossGimmickTriggered?.Invoke(
                $"그림자 도깨비가 {target.Data.NameKR}을(를) 봉인했다!");
        }
    }
}
