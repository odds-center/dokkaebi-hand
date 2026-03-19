using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;

namespace DokkaebiHand.Core
{
    /// <summary>
    /// 세이브 데이터 구조 — JSON 직렬화용.
    /// 네트워크 불필요. 로컬 파일 + Steam 클라우드 이중 저장.
    /// </summary>
    [Serializable]
    public class SaveData
    {
        public string Version = "0.2.0";
        public long Timestamp;

        // 현재 런 상태
        public SpiralSaveData Spiral;
        public int Lives;
        public int Yeop;
        public int GoCount;
        public List<string> EquippedTalismans = new List<string>();
        public List<string> EquippedCompanions = new List<string>();

        // 런 내 웨이브 강화 버프
        public int WaveChipBonus;
        public int WaveMultBonus;
        public int WaveTalismanSlotBonus;
        public float WaveTalismanEffectBonus;
        public float WaveTargetReduction;
        public int NextRoundHandBonus;

        // 메타 (영구)
        public int SoulFragments;
        public List<UpgradeSaveEntry> UpgradeLevels = new List<UpgradeSaveEntry>();
        public List<string> UnlockedAchievements = new List<string>();
        public List<string> UnlockedCompanions = new List<string>();
        public List<CardEnhancementSave> CardEnhancements = new List<CardEnhancementSave>();

        // 통계
        public int TotalRuns;
        public int TotalDeaths;
        public int HighestSpiral;
        public int HighestRealm;
        public int HighestSingleScore;
        public float TotalPlayTimeSeconds;
    }

    [Serializable]
    public class UpgradeSaveEntry
    {
        public string Id;
        public int Level;
    }

    [Serializable]
    public class CardEnhancementSave
    {
        public int CardId;
        public int Tier;
        public int MutatedMonth = -1;  // -1 = none
        public int MutatedType = -1;
        public List<string> Seals = new List<string>();
    }

    /// <summary>
    /// 저장 백엔드 인터페이스.
    /// Steam, 로컬 파일 등 다양한 저장소를 지원하기 위한 추상화.
    /// </summary>
    public interface ISaveBackend
    {
        bool Save(string key, string json);
        string Load(string key);
        bool HasSave(string key);
        bool Delete(string key);
        string BackendName { get; }
    }

    /// <summary>
    /// 로컬 파일 저장 백엔드.
    /// Application.persistentDataPath에 JSON 파일로 저장.
    /// 네트워크 불필요.
    /// </summary>
    public class LocalFileSaveBackend : ISaveBackend
    {
        public string BackendName => "LocalFile";

        private string GetPath(string key)
        {
            return Path.Combine(Application.persistentDataPath, $"{key}.json");
        }

        public bool Save(string key, string json)
        {
            try
            {
                string path = GetPath(key);
                string dir = Path.GetDirectoryName(path);
                if (!Directory.Exists(dir))
                    Directory.CreateDirectory(dir);

                // 백업: 기존 파일이 있으면 .bak으로 복사
                if (File.Exists(path))
                    File.Copy(path, path + ".bak", true);

                File.WriteAllText(path, json);
                Debug.Log($"[Save] 로컬 저장 완료: {path}");
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"[Save] 로컬 저장 실패: {e.Message}");
                return false;
            }
        }

        public string Load(string key)
        {
            try
            {
                string path = GetPath(key);
                if (!File.Exists(path))
                {
                    // 백업에서 복구 시도
                    if (File.Exists(path + ".bak"))
                    {
                        Debug.LogWarning("[Save] 메인 세이브 없음, 백업에서 복구");
                        return File.ReadAllText(path + ".bak");
                    }
                    return null;
                }
                return File.ReadAllText(path);
            }
            catch (Exception e)
            {
                Debug.LogError($"[Save] 로컬 로드 실패: {e.Message}");
                return null;
            }
        }

        public bool HasSave(string key)
        {
            return File.Exists(GetPath(key));
        }

        public bool Delete(string key)
        {
            try
            {
                string path = GetPath(key);
                if (File.Exists(path)) File.Delete(path);
                if (File.Exists(path + ".bak")) File.Delete(path + ".bak");
                return true;
            }
            catch { return false; }
        }
    }

    /// <summary>
    /// Steam 클라우드 저장 백엔드 (Steamworks.NET 연동).
    /// Steam 클라이언트가 없으면 자동으로 비활성화.
    /// </summary>
    public class SteamCloudSaveBackend : ISaveBackend
    {
        public string BackendName => "SteamCloud";
        private bool _isAvailable;

        public SteamCloudSaveBackend()
        {
            // Steamworks 초기화 확인
            // 실제 구현 시 SteamAPI.IsSteamRunning() 등으로 체크
            _isAvailable = false; // Steam SDK 연동 전까지 비활성
            #if STEAMWORKS_ENABLED
            try
            {
                _isAvailable = Steamworks.SteamAPI.IsSteamRunning()
                    && Steamworks.SteamRemoteStorage.IsCloudEnabledForAccount();
            }
            catch { _isAvailable = false; }
            #endif
        }

        public bool Save(string key, string json)
        {
            if (!_isAvailable) return false;
            #if STEAMWORKS_ENABLED
            try
            {
                byte[] data = System.Text.Encoding.UTF8.GetBytes(json);
                bool result = Steamworks.SteamRemoteStorage.FileWrite(key + ".json", data, data.Length);
                if (result) Debug.Log($"[Save] Steam 클라우드 저장 완료: {key}");
                return result;
            }
            catch (Exception e)
            {
                Debug.LogError($"[Save] Steam 클라우드 저장 실패: {e.Message}");
                return false;
            }
            #else
            return false;
            #endif
        }

        public string Load(string key)
        {
            if (!_isAvailable) return null;
            #if STEAMWORKS_ENABLED
            try
            {
                string filename = key + ".json";
                if (!Steamworks.SteamRemoteStorage.FileExists(filename)) return null;
                int size = Steamworks.SteamRemoteStorage.GetFileSize(filename);
                byte[] data = new byte[size];
                Steamworks.SteamRemoteStorage.FileRead(filename, data, size);
                return System.Text.Encoding.UTF8.GetString(data);
            }
            catch { return null; }
            #else
            return null;
            #endif
        }

        public bool HasSave(string key)
        {
            if (!_isAvailable) return false;
            #if STEAMWORKS_ENABLED
            return Steamworks.SteamRemoteStorage.FileExists(key + ".json");
            #else
            return false;
            #endif
        }

        public bool Delete(string key)
        {
            if (!_isAvailable) return false;
            #if STEAMWORKS_ENABLED
            return Steamworks.SteamRemoteStorage.FileDelete(key + ".json");
            #else
            return false;
            #endif
        }
    }

    /// <summary>
    /// 세이브 매니저: 이중 저장 (로컬 + Steam).
    /// 로드 시 더 최신 데이터를 사용.
    /// 네트워크 완전 불필요 — Steam 클라우드는 Steam 클라이언트가 처리.
    /// </summary>
    public class SaveManager
    {
        private const string RunSaveKey = "dokkaebi_run";
        private const string MetaSaveKey = "dokkaebi_meta";

        private readonly ISaveBackend _localBackend;
        private readonly ISaveBackend _steamBackend;

        public SaveManager()
        {
            _localBackend = new LocalFileSaveBackend();
            _steamBackend = new SteamCloudSaveBackend();
        }

        /// <summary>
        /// 세이브 (로컬 + Steam 이중 저장)
        /// </summary>
        public void Save(SaveData data)
        {
            data.Timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
            string json = JsonUtility.ToJson(data, true);

            // 1차: 로컬 저장 (항상 성공해야 함)
            bool localOk = _localBackend.Save(MetaSaveKey, json);
            if (!localOk)
                Debug.LogError("[SaveManager] 로컬 저장 실패! 데이터 유실 위험.");

            // 2차: Steam 클라우드 (있으면 추가 저장)
            _steamBackend.Save(MetaSaveKey, json);
        }

        /// <summary>
        /// 로드 (더 최신 데이터 선택)
        /// </summary>
        public SaveData Load()
        {
            string localJson = _localBackend.Load(MetaSaveKey);
            string steamJson = _steamBackend.Load(MetaSaveKey);

            SaveData localData = ParseSave(localJson);
            SaveData steamData = ParseSave(steamJson);

            // 둘 다 없으면 null
            if (localData == null && steamData == null)
                return null;

            // 하나만 있으면 그것 사용
            if (localData == null) return steamData;
            if (steamData == null) return localData;

            // 둘 다 있으면 더 최신 것 사용
            if (steamData.Timestamp > localData.Timestamp)
            {
                Debug.Log("[SaveManager] Steam 클라우드가 더 최신. 클라우드 데이터 사용.");
                // 로컬도 최신으로 동기화
                _localBackend.Save(MetaSaveKey, steamJson);
                return steamData;
            }
            else
            {
                Debug.Log("[SaveManager] 로컬이 더 최신. 로컬 데이터 사용.");
                // 스팀도 최신으로 동기화
                _steamBackend.Save(MetaSaveKey, localJson);
                return localData;
            }
        }

        public bool HasSave()
        {
            return _localBackend.HasSave(MetaSaveKey)
                || _steamBackend.HasSave(MetaSaveKey);
        }

        public void DeleteAll()
        {
            _localBackend.Delete(MetaSaveKey);
            _steamBackend.Delete(MetaSaveKey);
            Debug.Log("[SaveManager] 모든 세이브 데이터 삭제 완료.");
        }

        /// <summary>
        /// 자동 저장 시점:
        /// - 영역 클리어 시
        /// - 상점 퇴장 시
        /// - 이승의 문 선택 시
        /// - 앱 종료/백그라운드 시 (OnApplicationPause, OnApplicationQuit)
        /// </summary>
        public void AutoSave(GameManager game)
        {
            var data = BuildSaveData(game);
            Save(data);
        }

        public SaveData BuildSaveData(GameManager game)
        {
            var data = new SaveData
            {
                Spiral = game.Spiral.ToSaveData(),
                Lives = game.Player.Lives,
                Yeop = game.Player.Yeop,
                GoCount = game.Player.GoCount,
                SoulFragments = game.Upgrades.SoulFragments,
                UnlockedAchievements = game.Achievements.GetUnlockedIds(),
                UnlockedCompanions = new List<string>(game.Companions.GetUnlockedIds()),
                // 런 내 웨이브 강화 버프
                WaveChipBonus = game.Player.WaveChipBonus,
                WaveMultBonus = game.Player.WaveMultBonus,
                WaveTalismanSlotBonus = game.Player.WaveTalismanSlotBonus,
                WaveTalismanEffectBonus = game.Player.WaveTalismanEffectBonus,
                WaveTargetReduction = game.Player.WaveTargetReduction,
                NextRoundHandBonus = game.Player.NextRoundHandBonus,
            };

            // 부적 목록
            foreach (var t in game.Player.Talismans)
                data.EquippedTalismans.Add(t.Data.Name);

            // 업그레이드 레벨
            foreach (var upg in game.Upgrades.AllUpgrades)
            {
                int level = game.Upgrades.GetLevel(upg.Id);
                if (level > 0)
                    data.UpgradeLevels.Add(new UpgradeSaveEntry { Id = upg.Id, Level = level });
            }

            return data;
        }

        private SaveData ParseSave(string json)
        {
            if (string.IsNullOrEmpty(json)) return null;
            try
            {
                return JsonUtility.FromJson<SaveData>(json);
            }
            catch
            {
                Debug.LogWarning("[SaveManager] 세이브 파싱 실패");
                return null;
            }
        }
    }
}
