# devkit

SurvivorsStudio 팀 공용 개발 워크플로 플러그인입니다. Claude Code와 Codex가 같은
`plugins/devkit/skills/` 및 `agents/` 본문을 사용합니다.

## Claude Code 설치

셸에서 설치합니다.

```bash
claude plugin marketplace add SurvivorsStudio/devkit
claude plugin install devkit@survivors
claude plugin list
```

목록에서 `devkit@survivors`가 enabled인지 확인한 뒤 **새 세션**을 여십시오. 플러그인은
세션 시작 시 로드됩니다. `settings.json`의 `enabledPlugins`만으로 설치 여부를 판단하지 말고
항상 `claude plugin list`를 사용하십시오.

갱신은 다음과 같습니다.

```bash
claude plugin update devkit@survivors
```

갱신 후에도 새 세션이 필요합니다.

## Codex 설치

이 저장소의 팀 마켓플레이스는 기본 개인 마켓플레이스가 아니므로 먼저 GitHub 저장소를
마켓플레이스로 등록합니다.

```bash
codex plugin marketplace add SurvivorsStudio/devkit --ref main
codex plugin add devkit@survivors
codex plugin list
```

`codex plugin list`에서 devkit을 확인한 뒤 **새 작업(새 세션)**에서 사용하십시오. 플러그인을
로컬에서 개발할 때는 `codex plugin marketplace add /path/to/devkit`으로 클론 경로를 등록할 수도
있습니다.

저장소를 갱신한 뒤에는 현재 등록된 마켓플레이스에서 다시 설치합니다.

```bash
codex plugin marketplace add SurvivorsStudio/devkit --ref main
codex plugin add devkit@survivors
codex plugin list
```

개발 중 Codex가 이전 로컬 플러그인을 계속 보이면 Codex 매니페스트의 semantic version을 올린 뒤
다시 설치합니다. 개인 환경의 내부 스크립트 경로에 의존하지 마십시오.

## 제공 스킬

| 스킬 | 용도 |
|---|---|
| `/onboard` | 개발 환경과 설치 상태를 진단하고, 승인 후 정상화 |
| `/new-app` | `app-template`에서 새 앱 저장소 생성 |
| `/pr` | 논리 단위 커밋, 읽기 전용 리뷰, PR 생성 |
| `/pr-merge` | CI 통과 후 squash 머지 및 브랜치 정리 |
| `/done` | 세션의 결정과 근거를 로컬 `.done/`에 기록 |

호스트가 이름공간을 표시하면 `/devkit:pr`처럼 호출할 수 있습니다. 새 설치나 갱신 직후에는
새 세션에서 스킬 검색 결과를 확인하십시오.

## 단일 본문 · 이중 매니페스트

```text
.claude-plugin/marketplace.json          Claude Code 마켓플레이스
.agents/plugins/marketplace.json         Codex 팀 마켓플레이스
plugins/devkit/
├── .claude-plugin/plugin.json           Claude Code 매니페스트 (version 없음)
├── .codex-plugin/plugin.json            Codex 매니페스트 (엄격한 semver version)
├── agents/pr-reviewer.md                 읽기 전용 PR 리뷰 절차
└── skills/                               두 런타임이 함께 쓰는 스킬 본문
```

스킬과 에이전트 본문은 복제하지 않습니다. 호스트별 발견·설치 메타데이터만 분리합니다.

### 버전 정책

Claude Code 매니페스트는 의도적으로 `version`을 두지 않습니다. Claude의 배포 기준은 커밋 SHA이므로
저장소 변경 후 `claude plugin update devkit@survivors`로 갱신합니다.

Codex 매니페스트는 엄격한 semantic version이 필수입니다. 배포 가능한 변경에서는
`plugins/devkit/.codex-plugin/plugin.json`의 버전을 올리고 다시 설치합니다. Claude 매니페스트에
Codex 버전을 복사하지 마십시오.

## 스킬을 고칠 때

새 공용 스킬은 `plugins/devkit/skills/<이름>/SKILL.md`에 추가합니다. 마켓플레이스에는 플러그인만
등록하므로 스킬마다 별도 등록하지 않습니다. 변경 후 두 매니페스트와 마켓플레이스를 보존하고,
각 런타임에서 갱신한 뒤 새 세션으로 확인하십시오.

## 관련 저장소

| 저장소 | 역할 |
|---|---|
| [app-template](https://github.com/SurvivorsStudio/app-template) | 새 앱의 원본 |
| [core](https://github.com/SurvivorsStudio/core) | 앱 공통 기능 npm 패키지 |
| [devops-docs](https://github.com/SurvivorsStudio/devops-docs) | 설계 근거와 결정 기록 |
