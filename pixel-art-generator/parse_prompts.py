"""
sd-prompts/ 의 md 파일을 파싱하여 프롬프트 목록을 추출하는 모듈.

md 파일 구조:
  - 00-common.md: 공통 프리픽스/네거티브
  - 01-xxx.md: 개별 에셋 프롬프트 (### name, **Seed:** N, ``` prompt ```)
"""
import re
import sys
from pathlib import Path
from dataclasses import dataclass, field

# 현재 디렉토리를 모듈 경로에 추가
sys.path.insert(0, str(Path(__file__).parent))

from config import SD_PROMPTS_DIR, CATEGORY_CONFIG


@dataclass
class PromptEntry:
    """파싱된 단일 프롬프트"""
    name: str                    # 에셋 이름 (예: boss_glutton)
    prompt: str                  # 개별 프롬프트 본문
    common_prefix: str           # 공통 프리픽스
    negative: str                # 네거티브 프롬프트
    seed: int | None = None      # 시드
    category: str = ""           # 카테고리 폴더명
    width: int = 512
    height: int = 512
    source_file: str = ""        # 원본 md 파일명

    @property
    def full_prompt(self) -> str:
        """공통 프리픽스 + 개별 프롬프트 결합 (Pony 태그 제거)"""
        prefix = self._clean_pony_tags(self.common_prefix)
        body = self._clean_pony_tags(self.prompt)
        if prefix and body:
            return f"{prefix}, {body}"
        return body or prefix

    @staticmethod
    def _clean_pony_tags(text: str) -> str:
        """Pony/ComfyUI 전용 태그 제거, 순수 영어 프롬프트만 남김"""
        if not text:
            return ""
        # Pony 품질 태그 제거
        text = re.sub(r'score_\d+(?:_up)?,?\s*', '', text)
        # LoRA 트리거 워드 제거 (source_anime 등)
        text = re.sub(r'source_\w+,?\s*', '', text)
        # chibi 제거 (FLUX에서는 불필요)
        text = re.sub(r'\bchibi,?\s*', '', text)
        # game assets 유지, pixel art 유지
        # 연속 쉼표/공백 정리
        text = re.sub(r',\s*,', ',', text)
        text = re.sub(r'^\s*,\s*', '', text)
        text = re.sub(r'\s*,\s*$', '', text)
        text = re.sub(r'\s+', ' ', text)
        return text.strip()


def parse_common_md(common_path: Path) -> tuple[str, str]:
    """
    00-common.md에서 공통 프리픽스와 네거티브 프롬프트 추출

    Returns:
        (common_prefix, negative_prompt)
    """
    if not common_path.exists():
        return "", ""

    content = common_path.read_text(encoding="utf-8")

    # 공통 프롬프트 프리픽스 추출 (## 공통 프롬프트 프리픽스 아래 코드 블록)
    prefix = ""
    neg = ""

    # 프리픽스 찾기
    prefix_match = re.search(
        r'(?:공통\s*프롬프트\s*프리픽스|Common\s*Prefix).*?```\s*\n(.*?)```',
        content, re.DOTALL | re.IGNORECASE
    )
    if prefix_match:
        prefix = prefix_match.group(1).strip().replace('\n', ' ')

    # 네거티브 찾기
    neg_match = re.search(
        r'(?:공통\s*네거티브|Negative).*?```\s*\n(.*?)```',
        content, re.DOTALL | re.IGNORECASE
    )
    if neg_match:
        neg = neg_match.group(1).strip().replace('\n', ' ')

    return prefix, neg


def parse_prompt_md(
    md_path: Path,
    common_prefix: str,
    negative: str,
    category: str,
    default_width: int,
    default_height: int,
) -> list[PromptEntry]:
    """
    개별 md 파일에서 프롬프트 목록 추출.

    패턴:
      ### asset_name — 설명
      **Seed:** 12345
      ```
      prompt text here
      ```
    """
    content = md_path.read_text(encoding="utf-8")
    entries = []

    # md 자체에 공통 프리픽스가 있으면 그걸 사용
    local_prefix_match = re.search(
        r'(?:공통\s*프롬프트\s*프리픽스|Common.*Prefix).*?```\s*\n(.*?)```',
        content, re.DOTALL | re.IGNORECASE
    )
    local_neg_match = re.search(
        r'(?:공통\s*네거티브|Negative).*?```\s*\n(.*?)```',
        content, re.DOTALL | re.IGNORECASE
    )

    if local_prefix_match:
        common_prefix = local_prefix_match.group(1).strip().replace('\n', ' ')
    if local_neg_match:
        negative = local_neg_match.group(1).strip().replace('\n', ' ')

    # md 자체에 해상도 정보가 있으면 추출
    res_match = re.search(r'Resolution:\s*(\d+)\s*x\s*(\d+)', content)
    if res_match:
        default_width = int(res_match.group(1))
        default_height = int(res_match.group(2))

    # "### 프롬프트" 패턴이 다수이고, "### 설정" 패턴도 다수인 경우 (04-concept-art 스타일)
    # ## 캐릭터이름 → ### 설정 → ### 프롬프트 → **Seed:** → ``` prompt ```
    # 이 경우 ## 단위로 분리하여 이름을 추출해야 함
    prompt_count = len(re.findall(r'^### 프롬프트', content, re.MULTILINE))
    setup_count = len(re.findall(r'^### 설정', content, re.MULTILINE))
    if prompt_count >= 2 and setup_count >= 2:
        h2_blocks = re.split(r'(?=^##\s+(?!#))', content, flags=re.MULTILINE)
        for h2_block in h2_blocks:
            h2_match = re.match(r'^##\s+(.+?)(?:\s*(?:—|–|-)\s+.+)?\s*$', h2_block, re.MULTILINE)
            if not h2_match:
                continue
            section_name = h2_match.group(1).strip()

            # skip non-asset sections
            if any(kw in section_name for kw in ['설정', '환경', '후처리', '공통', '규격', '표시']):
                continue

            seed_match = re.search(r'\*\*Seed:?\*\*:?\s*(\d+)', h2_block)
            seed = int(seed_match.group(1)) if seed_match else None

            prompt_blocks_found = re.findall(r'```\s*\n(.*?)```', h2_block, re.DOTALL)
            prompt_text = None
            for pb in prompt_blocks_found:
                pb_stripped = pb.strip()
                if pb_stripped.startswith(('Model:', 'Filter', '1.', 'Resolution')):
                    continue
                prompt_text = pb_stripped.replace('\n', ' ')

            if not prompt_text:
                continue

            # 한글 이름 → 영어 변환
            clean_name = section_name
            if re.search(r'[가-힣]', clean_name):
                # 프롬프트 코드블록에서 첫 의미있는 영어 명사 추출
                skip_eng = {'seed', 'batch', 'model', 'pony', 'lora', 'resolution',
                            'sampler', 'steps', 'cfg', 'img2img', 'denoising'}
                eng_parts = re.findall(r'\b([a-zA-Z_]{3,})\b', h2_block[:500])
                eng_parts = [p.lower() for p in eng_parts if p.lower() not in skip_eng]
                if eng_parts and prompt_text:
                    # 프롬프트 첫 단어에서 키워드 추출
                    first_words = prompt_text.split(',')[0].strip().split()[:3]
                    clean_name = '_'.join(w.lower() for w in first_words if w.isalpha())
                if not clean_name or clean_name == section_name:
                    clean_name = re.sub(r'[^a-zA-Z0-9]', '_', clean_name).strip('_')

            # concept_ 접두사 추가
            if not clean_name.startswith('concept_'):
                clean_name = f"concept_{clean_name}"

            entries.append(PromptEntry(
                name=clean_name,
                prompt=prompt_text,
                common_prefix=common_prefix,
                negative=negative,
                seed=seed,
                category=category,
                width=default_width,
                height=default_height,
                source_file=md_path.name,
            ))

        return entries

    # 개별 프롬프트 추출: ### name 또는 ## 프롬프트 A/B/C 패턴
    # 패턴 1: ### asset_name — 설명  /  **Seed:** N  /  ``` prompt ```
    # 패턴 2: ## 프롬프트 A (설명)  /  **Seed:** N  /  ``` prompt ```
    blocks = re.split(r'(?=^###?\s+)', content, flags=re.MULTILINE)

    for block in blocks:
        # 이름 추출
        name_match = re.match(
            r'^###?\s+(?:프롬프트\s+)?(\S+)\s*(?:—|–|-|:)?\s*(.*)',
            block, re.MULTILINE
        )
        if not name_match:
            continue

        raw_name = name_match.group(1).strip()

        # 공통 설정/환경/후처리/카테고리 헤더 섹션 건너뛰기
        skip_keywords = [
            '생성', '환경', '후처리', '공통', '역할', '출력', '장면', '색감',
            '사용', '임포트', '카드', '해상도', '핵심', '전통', '월별',
            '이미지', '중요', '중요:', 'Unity', 'Filter',
        ]
        # 카테고리 헤더 건너뛰기 (예: ## 일반 (Common), ## 재앙 보스 등)
        category_headers = [
            '일반', '재앙', '희귀', '전설', '저주', '에픽', 'Common', 'Rare',
            'Epic', 'Legendary', 'Cursed',
        ]
        if raw_name in skip_keywords or raw_name.rstrip('*').rstrip(':') in skip_keywords:
            continue
        if any(kw in raw_name for kw in skip_keywords):
            continue
        if raw_name in category_headers:
            continue

        # Pony 태그가 이름인 경우 건너뛰기 (score_9, score_4 등)
        if re.match(r'^score_\d', raw_name):
            continue

        # "프롬프트" 헤더인 경우 → 상위 섹션 이름에서 에셋명 추출
        if raw_name == '프롬프트':
            # 상위 ## 섹션에서 이름 찾기 (예: ## 망자 (亡者) — 주인공)
            parent_match = re.search(r'^##\s+(.+?)(?:\s*(?:—|–|-)\s+.+)?$', block, re.MULTILINE)
            if not parent_match:
                # block 이전 content에서 찾기
                block_start = content.find(block)
                preceding = content[:block_start] if block_start > 0 else ""
                parent_match = re.search(r'##\s+(.+?)(?:\s*(?:—|–|-)\s+.+)?\s*$', preceding, re.MULTILINE)
            if parent_match:
                raw_name = parent_match.group(1).strip()
            else:
                continue

        # "Seed:" 로 시작하는 이름은 잘못된 파싱
        if raw_name.startswith('Seed'):
            continue

        # "```" 자체가 이름인 경우 건너뛰기
        if raw_name.startswith('`'):
            continue

        # 번호+점 형태 (예: "2-1.") — seed가 있으면 살림, 없으면 건너뛰기
        if re.match(r'^\d+-\d+\.?$', raw_name):
            seed_check = re.search(r'\*\*Seed:?\*\*:?\s*(\d+)', block)
            if not seed_check:
                continue
            # 번호 뒤의 실제 이름을 추출 (예: "### 2-1. 업화(業火) — 화염 서예")
            full_line_match = re.match(
                r'^###?\s+\d+-\d+\.?\s*(.+?)(?:\s*(?:—|–|-)\s+.*)?$',
                block, re.MULTILINE
            )
            if full_line_match:
                raw_name = full_line_match.group(1).strip()

        # 코드 블록이 없는 섹션은 건너뛰기
        if '```' not in block:
            continue

        # seed 추출
        seed_match = re.search(r'\*\*Seed:?\*\*:?\s*(\d+)', block)
        seed = int(seed_match.group(1)) if seed_match else None

        # 크기 추출 (개별 오버라이드)
        size_match = re.search(r'\*\*크기:?\*\*:?\s*(\d+)\s*x\s*(\d+)', block)
        w = int(size_match.group(1)) if size_match else default_width
        h = int(size_match.group(2)) if size_match else default_height

        # 프롬프트 추출 (코드 블록에서)
        # 공통 프리픽스/네거티브 코드블록은 건너뛰기
        prompt_blocks = re.findall(r'```\s*\n(.*?)```', block, re.DOTALL)
        if not prompt_blocks:
            continue

        # 마지막 코드 블록이 실제 프롬프트 (yaml 블록 등 제외)
        prompt_text = None
        for pb in prompt_blocks:
            pb_stripped = pb.strip()
            # yaml이나 설정 블록 건너뛰기
            if pb_stripped.startswith(('Model:', 'Filter', '1.', 'Resolution')):
                continue
            prompt_text = pb_stripped.replace('\n', ' ')

        if not prompt_text:
            continue

        # 이름 정규화
        clean_name = raw_name.strip('*').strip()
        # 한글 이름이면 영어 이름 추출 시도
        if re.search(r'[가-힣]', clean_name):
            eng_match = re.search(r'([a-z_]+\d*)', block[:200], re.IGNORECASE)
            if eng_match:
                clean_name = eng_match.group(1)
            else:
                clean_name = re.sub(r'[^a-zA-Z0-9_]', '_', clean_name)

        entries.append(PromptEntry(
            name=clean_name,
            prompt=prompt_text,
            common_prefix=common_prefix,
            negative=negative,
            seed=seed,
            category=category,
            width=w,
            height=h,
            source_file=md_path.name,
        ))

    return entries


def parse_category(category_folder: str) -> list[PromptEntry]:
    """
    하나의 카테고리 폴더(예: 01-backgrounds)의 모든 md를 파싱

    Returns:
        해당 카테고리의 모든 PromptEntry 리스트
    """
    cat_dir = SD_PROMPTS_DIR / category_folder
    if not cat_dir.exists():
        print(f"[경고] 폴더 없음: {cat_dir}")
        return []

    config = CATEGORY_CONFIG.get(category_folder, {})
    default_w = config.get("width", 512)
    default_h = config.get("height", 512)

    # 공통 설정 파싱
    common_prefix, negative = parse_common_md(cat_dir / "00-common.md")

    # 개별 md 파싱
    entries = []
    md_files = sorted(cat_dir.glob("*.md"))

    for md_file in md_files:
        if md_file.name == "00-common.md":
            continue

        parsed = parse_prompt_md(
            md_file, common_prefix, negative,
            category_folder, default_w, default_h,
        )
        entries.extend(parsed)

    return entries


def parse_all() -> dict[str, list[PromptEntry]]:
    """
    sd-prompts/ 전체 파싱

    Returns:
        {카테고리: [PromptEntry, ...]} 딕셔너리
    """
    all_prompts = {}

    for category_folder in sorted(CATEGORY_CONFIG.keys()):
        entries = parse_category(category_folder)
        if entries:
            all_prompts[category_folder] = entries

    return all_prompts


if __name__ == "__main__":
    # 파싱 테스트
    all_data = parse_all()

    total = 0
    for cat, entries in all_data.items():
        print(f"\n[{cat}] — {len(entries)}개")
        for e in entries[:3]:  # 처음 3개만 미리보기
            print(f"  {e.name} (seed={e.seed}, {e.width}x{e.height})")
            print(f"    → {e.full_prompt[:80]}...")
        if len(entries) > 3:
            print(f"  ... 외 {len(entries) - 3}개")
        total += len(entries)

    print(f"\n{'='*50}")
    print(f"총 {total}개 프롬프트 파싱 완료")
