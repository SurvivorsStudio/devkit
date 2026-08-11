# devkit

SurvivorsStudio 팀 공용 Claude Code 플러그인 마켓플레이스.

## 설치

**셸에서 두 줄입니다.** (Claude Code 세션 안이 아닙니다)

```bash
claude plugin marketplace add SurvivorsStudio/devkit
claude plugin install devkit@survivors
```

확인하고 **세션을 새로 엽니다:**

```bash
claude plugin list          # devkit@survivors ✔ enabled
```

기본 스코프가 `user` 이므로 **한 번 설치하면 어느 폴더에서든 잡힙니다.** 앱마다 다시 설치할
필요가 없습니다. 설치가 끝나면 나머지 환경 점검은 `/onboard` 가 합니다.

> **⚠️ 2026-08-11 정정 — 레포 클론만으로는 설치되지 않습니다.**
>
> 이전 README 는 "`devops-docs` 에 `.claude/settings.json` 이 커밋돼 있으니 그 폴더에서 세션을
> 열면 `/devkit:new-app` 이 그냥 있다" 고 안내했습니다. **틀렸습니다.** 실제로 `/new-app` 이
> `Unknown command` 로 실패했고, `~/.claude/plugins/known_marketplaces.json` 과
> `installed_plugins.json` 양쪽에 `survivors` · `devkit` 이 없었습니다.
>
> `extraKnownMarketplaces` 와 `enabledPlugins` 는 **"이 플러그인을 쓴다" 는 선언**이고
> clone·설치를 트리거하지 않습니다. 설정 커밋이 없애 준 것은 *무엇을 설치할지 알아내는 일*이지
> 설치 그 자체가 아닙니다.
>
> **설치 여부는 `claude plugin list` 로만 판단하십시오.** 설치하면 `~/.claude/plugins/` 에
> 기록이 생기는데, 동시에 `~/.claude/settings.json` 의 `enabledPlugins` 에도 항목이 **함께**
> 써집니다. 그래서 `settings.json` 에 항목이 있다는 것으로는 설치됐는지 안 됐는지 알 수 없습니다
> — 선언만 해도 있고, 설치해도 있습니다.

> ⚠️ **슬래시 `/plugin` 은 주 경로가 아닙니다.** 대화형 패널이라 환경에 따라 막혀 있습니다
> ("`/plugin` isn't available in this environment"). 위의 셸 CLI 는 어디서나 동작합니다 —
> 막히는 경로를 안내하면 안 됩니다.

> **플러그인은 세션 시작 시점에 로드됩니다.** 설치 후 세션을 새로 열어야 합니다. 세션 중간에
> 설치하면 `/devkit:pr` 같은 정식 이름만 잡히고 bare `/pr` 은 실패해, bare 이름 자체가 안 되는
> 것으로 오해하기 쉽습니다.

## 커맨드

| 커맨드 | 하는 일 |
|---|---|
| `/onboard` | 개발 환경을 진단하고 정상화합니다 (여러 번 실행해도 안전) |
| `/new-app` | `app-template` 에서 새 앱 레포를 만듭니다 |
| `/pr` | 논리 단위로 커밋 → AI 리뷰 → PR 생성 (머지는 안 함) |
| `/pr-merge #12` | CI 통과를 기다린 뒤 **squash** 머지 → 브랜치 정리 → 로컬 main 갱신 |
| `/done` | 이 세션의 결정과 이유를 `.done/` 에 기록 (gitignore, 개인 로컬) |

## 쓰는 법

```
/devkit:new-app
```

앱 이름·레포 이름·번들 ID·설명을 물어본 뒤, `app-template` 에서 레포를 만들고
토큰 치환 → `npm install` → `cap add ios/android` → 첫 커밋까지 진행합니다.

> **`/new-app` 으로도 호출됩니다.** `/devkit:new-app` 은 자동완성에 뜨는 정식 이름이고,
> 다른 커맨드가 그 이름을 쓰고 있지 않는 한 bare 이름도 그대로 동작합니다.
> (Claude Code v2.1.216 이상. 그 이전 버전은 bare 이름만 표시됐습니다.)

인자 없이 실행하면 필요한 것을 되묻습니다. 한 번에 주고 싶으면:

```
/devkit:new-app 한손점프
```

## `/pr` 흐름

```
1. main 이면 새 브랜치를 딴다          (feat/… fix/… — 변경 내용에서 유추)
2. 변경사항을 읽고 논리 단위로 커밋     (Conventional Commits, git add -A 금지)
3. pr-reviewer 서브에이전트가 리뷰      (읽기 전용 — 코드를 고치지 않음)
4. 보완 사항이 있으면 그대로 보여주고   지금 고칠지 / 넘길지 묻는다
5. 넘긴 항목은 PR 본문에 기록          조용히 버리지 않음
6. 푸시하고 PR 생성                    머지는 하지 않음
```

리뷰는 **한 번만** 돌립니다. 고친 뒤 재리뷰는 요청할 때만 합니다.

## `/pr-merge` 흐름

```
1. 번호를 받는다                      #12 · 12 · URL. 없으면 현재 브랜치의 PR
2. 머지 가능한지 확인                 draft·닫힘·충돌이면 중단 (충돌 자동 해결 안 함)
3. CI 통과를 기다린다                 실패하면 머지하지 않고 어떤 잡인지 보고
4. squash 메시지를 만든다             제목=PR 제목, 본문=개별 커밋 목록
5. 요약을 보여주고 확인받는다          번호를 잘못 읽어 다른 PR 을 머지하는 사고 방지
6. squash 머지                        --squash 고정. --merge·--rebase·--admin 금지
7. 브랜치 삭제 + 로컬 main 갱신
```

**항상 squash 입니다.** 다른 방식은 쓰지 않습니다.

> squash 머지 후에는 `git branch -d` 가 거부됩니다 — squash 는 브랜치 커밋을 `main` 의 조상으로
> 만들지 않아 git 이 "머지되지 않았다"고 봅니다. 스킬은 머지 성공(`state == MERGED`)을 확인한
> **뒤에만** `-D` 로 지웁니다.

## 구조

```
.claude-plugin/marketplace.json     ← 마켓플레이스 레지스트리 (name: survivors)
plugins/devkit/
├── .claude-plugin/plugin.json      ← 매니페스트만
├── agents/pr-reviewer.md           ← /pr 이 호출하는 리뷰어 (읽기 전용)
└── skills/
    ├── onboard/SKILL.md            ← /onboard
    ├── new-app/SKILL.md            ← /new-app
    ├── pr/SKILL.md                 ← /pr
    ├── pr-merge/SKILL.md           ← /pr-merge
    └── done/SKILL.md               ← /done
```

## `/onboard` 흐름

```
1. 진단 (읽기 전용)        도구 · gh 인증 · git 신원 · 플러그인 · 작업 공간
2. 표 하나로 보고          통과한 것도 보여준다. ✓ 통과 / ✗ 막힘 / ⚠ 경고
3. 확인받는다              전부 / 골라서 / 진단만
4. 수리                    자동 가능한 것만. 브라우저 인증은 명령만 알려준다
5. 재검증                  고친 것만. 플러그인은 새 세션에서 확인
```

**여러 번 실행해도 안전합니다.** 이미 된 것은 건드리지 않습니다.

> ⚠️ **`/onboard` 로 최초 설치를 대체할 수 없습니다.** 플러그인이 없으면 `/onboard` 자체가
> `Unknown command` 입니다. 위의 [설치](#설치) 두 줄은 팀 온보딩 문서에도 남아 있어야
> 합니다. 이 커맨드가 맡는 것은 **설치 이후의 모든 것**과 이미 어긋난 환경의 정상화입니다.

## `/done` 이 남기는 것

**`git log` 가 아는 것은 기록하지 않습니다.** 파일별 변경 요약은 중복입니다.

```
결정과 근거          코드는 결과만 보여줌. 왜 그 선택이었는지는 사라짐
시도했다 버린 것      다음 사람이 같은 길을 다시 걷지 않게 함 — 가장 값진 항목
틀렸던 전제          문서나 계획이 사실과 달랐던 지점
남은 일 · 막힌 것     다음 세션의 출발점
```

`.done/` 은 gitignore 되며 각 레포 루트에 생깁니다. 새 앱은 `/new-app` 이 만들어 둡니다.
**세션 시작 때 통째로 읽는 곳이 아닙니다** — "이거 왜 이렇게 됐지?" 싶을 때 grep 합니다.

`.claude-plugin/` 안에는 **매니페스트만** 둡니다. 스킬·훅 파일을 이 폴더에 넣으면 안 됩니다.

## 커맨드를 고칠 때

`SKILL.md` 는 새 앱을 만들 때 Claude 가 따라갈 절차서입니다. 앱을 만들다 매번 손이 가는
작업이 발견되면 여기에 추가하십시오. 반대로 **아직 겪어보지 않은 케이스를 미리 넣지 마십시오** —
검증되지 않은 절차를 자동화하면 문제가 났을 때 앱 탓인지 커맨드 탓인지 구분되지 않습니다.

### 커맨드를 추가하려면

```
plugins/devkit/skills/<커맨드명>/SKILL.md
```

폴더를 만들고 `SKILL.md` 를 두면 끝입니다. `marketplace.json` 은 건드리지 않습니다 — 등록은
플러그인 단위이고 스킬은 `skills/` 에서 자동 발견됩니다. 호출은 `/devkit:<커맨드명>` 입니다.

### ⚠️ `plugin.json` 에 `version` 을 넣지 마십시오

**의도적으로 비워 둔 필드입니다.** `version` 이 있으면 그 값을 **바꿀 때만** 팀원이 업데이트를
받습니다. 커맨드를 고쳐 푸시해도 버전을 안 올리면 아무에게도 전달되지 않고, "분명 만들었는데 왜
없지?" 가 됩니다.

`version` 을 생략하면 **커밋 SHA 가 버전**이 되어 푸시만으로 전파됩니다. 이 레포가 Public 이라
백그라운드 자동 업데이트도 인증 없이 동작합니다.

즉시 받고 싶은 팀원은 셸에서:

```bash
claude plugin update devkit@survivors
```

실행 후 **세션을 새로 열면** 적용됩니다 (`update --help` 의 `restart required to apply`).

### 어디에 두어야 하나

| 범위 | 위치 |
|---|---|
| **앱 전체 공통** | 여기 (`devkit`) |
| 특정 앱에만 | 그 앱 레포의 `.claude/skills/` |
| 개인용 | `~/.claude/skills/` |

## 관련 레포

| 레포 | 역할 |
|---|---|
| [app-template](https://github.com/SurvivorsStudio/app-template) | 이 커맨드가 복제하는 원본 |
| [core](https://github.com/SurvivorsStudio/core) | 앱 공통 기능 npm 패키지 |
| [devops-docs](https://github.com/SurvivorsStudio/devops-docs) | 설계 근거·결정 기록 (**Private** — 조직 멤버만) |
