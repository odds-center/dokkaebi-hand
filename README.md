# 도깨비의 패 (Dokkaebi's Hand)

> "저승에서 도깨비와 목숨을 건 화투판. 족보를 쌓고, 부적을 조합하고, Go를 외쳐라."

한국적 오컬트 세계관의 로그라이트 덱빌딩 카드 게임.
화투(Go-Stop) 룰 기반 + Balatro 스타일 시너지/콤보 시스템 + 뱀서식 무한 엔드게임.

## 문서

### 코어 시스템 설계
- [프로젝트 개요](docs/01-project-overview.md)
- [아키텍처](docs/02-architecture.md)
- [화투패 시스템](docs/03-card-system.md)
- [부적 시스템](docs/04-talisman-system.md)
- [보스 시스템](docs/05-boss-system.md)
- [Go/Stop 룰](docs/06-go-stop-rules.md)
- [MVP 현황](docs/07-mvp-status.md)

### 게임 디자인
- [GDD (Game Design Document)](docs/08-game-design-document.md)
- [세계관 & 스토리 (기본)](docs/09-worldbuilding-story.md)
- [밸런스 설계](docs/10-balance-design.md)
- [상점 & 이벤트 시스템](docs/11-shop-event-system.md)
- [UI/UX 설계](docs/12-ui-ux-design.md)
- [아트 & 사운드 디렉션](docs/13-art-sound-direction.md)
- [튜토리얼 설계](docs/14-tutorial-design.md)
- [로그라이크 진행 & 메타](docs/15-roguelike-progression.md)
- [로컬라이제이션 계획](docs/16-localization-plan.md)
- [수익화 & 비즈니스](docs/17-monetization-business.md)
- [기술 사양](docs/18-technical-spec.md)

### 확장 세계관 & 핵심 시스템
- [확장 세계관 — 저승 십왕과 윤회](docs/20-expanded-worldbuilding.md)
- [무한 모드 — 황천의 끝 (뱀서식 엔드게임)](docs/21-endless-mode-design.md)
- [화투패 업그레이드 & 이펙트](docs/22-card-upgrade-system.md)
- [영구 강화 & 업적 시스템](docs/23-permanent-upgrade-system.md)
- [게임 차별성 & 고유 시스템](docs/24-differentiation-unique-features.md)
- [Steam 통합 & PC 빌드](docs/25-steam-integration.md)

### 보스 & 스토리
- [보스 랜덤화 & 파츠 시스템](docs/28-boss-randomization-parts.md)
- [전체 스토리 스크립트](docs/29-full-story-script.md)
- [무한 게임 구조 — 끝없는 나선, 선택적 엔딩](docs/30-infinite-game-structure.md)

### 경험 설계
- [감정적 경험 설계 — 시각/청각/촉각](docs/26-emotional-experience-design.md)
- [가상 플레이 시나리오 — 첫 보스까지](docs/27-play-scenario.md)
- [입력 & 저장 & 오프라인 설계](docs/31-input-save-offline.md)

## 기술 스택
- **엔진:** Unity (C#) / 2D URP
- **타겟:** Steam (PC)
- **입력:** 마우스/터치 전용 (키보드 불필요)
- **네트워크:** 불필요 (100% 오프라인 동작)
- **저장:** 로컬 파일 + Steam 클라우드 이중 저장
- **다국어:** 한국어 / English / 日本語 / 中文 (시스템 언어 자동 감지)
- **숫자 표기:** 큰 숫자 자동 단축 (42K, 1.23M, ×120)

## 빌드
Unity 2022.3 LTS 이상에서 프로젝트를 열어주세요.
