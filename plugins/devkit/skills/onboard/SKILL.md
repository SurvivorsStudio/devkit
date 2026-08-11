---
name: onboard
description: 팀원의 개발 환경을 진단하고 정상화합니다. 필수 도구·GitHub 인증·devkit 플러그인·작업 공간을 점검한 뒤, 고칠 수 있는 것을 확인받고 수리합니다. 사용자가 "/onboard", "처음 세팅", "환경 점검", "커맨드가 안 잡혀요", "세팅이 뭔가 이상해" 라고 할 때 사용합니다.
---

# 팀원 환경 세팅 · 정상화

새로 합류한 사람과 **이미 세팅해 놓고 뭔가 어긋난 사람** 둘 다를 대상으로 합니다.

> **여러 번 실행해도 안전합니다.** 이미 된 것은 건드리지 않습니다. 진단은 읽기 전용이고,
> 상태를 바꾸는 것은 4단계에서 확인을 받은 뒤에만 합니다.

## 원칙

| | |
|---|---|
| **진단은 읽기 전용** | 1단계에서 아무것도 바꾸지 않습니다. 전부 본 뒤에 판단합니다 |
| **수리는 확인 후** | 무엇을 고칠지 보여주고 승인받습니다. 조용히 고치지 마십시오 |
| **사람만 할 수 있는 것은 넘깁니다** | 브라우저 인증, 조직 초대, 대용량 설치는 명령만 알려 줍니다 |
| **중간에 멈춰도 손해가 없어야 합니다** | 반쯤 고쳐진 상태가 남지 않는 순서로 진행합니다 |

> ⚠️ **이 커맨드는 devkit 플러그인이 이미 설치된 사람만 부를 수 있습니다.**
> 플러그인이 없으면 `/onboard` 자체가 `Unknown command` 입니다. 최초 설치 두 줄은
> `devops-docs/02_팀원_온보딩.md` 에 남겨 두었습니다 — 그걸 이 커맨드로 대체할 수 없습니다.
> 이 커맨드가 맡는 것은 **설치 이후의 모든 것**과 **이미 어긋난 환경의 정상화**입니다.

---

## 1단계 — 진단

**전부 실행한 뒤 한 번에 보고합니다.** 하나 실패할 때마다 멈추지 마십시오 — 팀원은 자기 환경에
몇 개가 문제인지 한눈에 알고 싶어 합니다.

### A. 필수 도구

```bash
node -v; git --version; gh --version; claude --version
```

| 항목 | 합격 기준 |
|---|---|
| Node | **22 이상** (Capacitor CLI 요구사항) |
| git · gh · claude | 있으면 됨 |

메이저 버전만 뽑아 비교하십시오: `node -v | sed 's/v\([0-9]*\).*/\1/'`

### B. GitHub 인증

```bash
gh auth status
gh api user -q .login                                   # 실제 로그인 계정
gh auth status 2>&1 | grep "Token scopes"
gh repo view SurvivorsStudio/devops-docs --json name -q .name    # 조직 접근
```

| 항목 | 합격 기준 |
|---|---|
| 로그인 | 최소 한 계정 |
| 스코프 | **`repo` 와 `workflow` 둘 다.** `workflow` 가 없으면 앱 레포 첫 푸시가 거부됩니다 |
| 조직 접근 | `devops-docs` 조회 성공. 실패하면 조직 멤버가 아니거나 활성 계정이 다른 것 |

> ⚠️ **`gh auth status` 가 보여주는 이름을 실제 계정으로 믿지 마십시오.** 그것은 로그인 당시
> 이름이라, GitHub 에서 계정명을 바꾸면 낡은 이름이 그대로 남습니다. 실제 계정은
> `gh api user -q .login` 이 답입니다. (실제 사례: `hosts.yml` 에는 `Sanghoon-builder`,
> 실제 로그인은 `SangHoon-dw`)

> ⚠️ **계정이 둘 이상이면 활성 계정을 반드시 확인하십시오.** `gh` 는 활성 계정을 컴퓨터 전체에
> 하나로 저장합니다. 회사 계정이 활성인 채로 개인 조직 레포를 만지면 `gh` 가 레포를 못 찾습니다
> (`Could not resolve to a Repository`). 진단에서 이 조합이 나오면 **어느 계정이 조직에 접근
> 가능한지**까지 확인해 보고하십시오.

### C. git 신원

```bash
git config user.name; git config user.email
git config --show-origin --get user.email
```

비어 있으면 커밋이 실패하거나 엉뚱한 저자로 찍힙니다. **어느 파일에서 온 값인지**까지 보고하십시오
— 계정이 둘 이상인 사람은 폴더별로 갈라 두는 경우가 있고(`includeIf "gitdir:..."`), 그게 의도한
대로 걸려 있는지가 여기서 드러납니다.

### D. devkit 플러그인

```bash
claude plugin list
```

`devkit@survivors` 가 `✔ enabled` 로 보여야 합니다.

> ⚠️ **`.claude/settings.json` 에 등록돼 있는 것은 설치가 아닙니다.** `extraKnownMarketplaces` ·
> `enabledPlugins` 는 "이 플러그인을 쓴다" 는 선언일 뿐이고 clone·설치를 트리거하지 않습니다.
> 반드시 위 명령으로 확인하십시오 — 파일만 보고 "설치됨" 으로 판단하면 안 됩니다.

최신인지도 봅니다. `version` 이 커밋 SHA 이므로 원격 최신과 비교할 수 있습니다:

```bash
git ls-remote https://github.com/SurvivorsStudio/devkit HEAD
```

### E. 작업 공간

`devops-docs` 를 찾아 상태를 봅니다.

```bash
git -C <경로> rev-parse --show-toplevel
git -C <경로> status --short
git -C <경로> fetch -q origin && git -C <경로> log --oneline HEAD..origin/main
```

| 항목 | 합격 기준 |
|---|---|
| 클론 존재 | 있어야 함. **없으면** 아래 참조 |
| 워킹 트리 | 깨끗하면 좋음. 더러운 것 자체는 문제가 아니니 **보고만** 하십시오 |
| origin 대비 | 뒤져 있으면 뒤진 커밋 수를 알려 줌 |

**`devops-docs` 가 아예 없을 수 있습니다.** 플러그인은 사용자 스코프라 레포 없이도 설치되므로,
클론 전에 `/onboard` 를 부르는 사람이 있습니다. 그때는 **어디에 클론할지 물어본 뒤** 만듭니다:

```bash
git clone https://github.com/SurvivorsStudio/devops-docs
```

경로를 짐작하지 마십시오. 앱 레포들과 같은 부모 폴더에 두어야 하므로 기존 `app-*` 이 있으면
그 옆을 제안하고, 없으면 물어봅니다.

### F. 이미 세팅했던 사람에게만 나타나는 것

새 팀원에게는 해당 없고, **한동안 쓰다 어긋난 환경**에서 나오는 항목입니다.

| 확인 | 명령 | 왜 문제인가 |
|---|---|---|
| `core` npm link 잔존 | `ls -l <앱>/node_modules/@survivorsstudio/core` 가 심볼릭 링크인지 | 커밋하면 **CI 가 없는 링크를 찾다 실패**합니다 |
| 플러그인 구버전 | D 의 SHA 비교 | 새 커맨드가 안 잡히거나 옛 절차를 따릅니다 |
| `settings.local.json` 이 추적됨 | `git check-ignore -v .claude/settings.local.json` | 개인 설정이 팀에 올라갑니다 |
| 앱 레포 위치가 흩어짐 | `devops-docs` 와 같은 부모 폴더에 있는지 | `/pr` 의 승격 후보 비교가 로컬 앱 레포를 봅니다 |

---

## 2단계 — 진단 결과 보고

**표 하나로 보여줍니다.** 통과한 것도 함께 보여주십시오 — 무엇이 이미 되어 있는지 아는 것이
새 팀원에게는 절반입니다.

```
환경 진단 결과

  ✓ Node 22.14.0
  ✓ git · gh · claude
  ✓ GitHub 로그인 — babysean (조직 접근 OK)
  ✗ 토큰에 workflow 스코프 없음        → 앱 레포 첫 푸시가 거부됩니다
  ✗ devkit 플러그인 미설치
  ⚠ devops-docs 가 origin/main 보다 3개 뒤짐
  ⚠ app-hansonjump 에 core npm link 가 남아 있음

자동 수리 가능 2건 · 직접 하셔야 하는 것 1건 · 판단 필요 1건
```

기호는 이렇게 씁니다: `✓` 통과 · `✗` 막힘(고쳐야 진행 불가) · `⚠` 경고(진행은 되지만 사고 위험).

**증상이 아니라 결과를 적으십시오.** "workflow 스코프 없음" 만 쓰면 팀원은 그게 왜 문제인지
모릅니다. 무엇이 실패하게 되는지 한 줄 붙이십시오.

## 3단계 — 확인받기

`AskUserQuestion` 으로 묻습니다. **승인 없이 수리하지 마십시오.**

- 자동 수리 가능한 항목을 나열하고 **전부 / 골라서 / 진단만** 중에서 고르게 합니다
- 사람이 해야 하는 항목은 선택지에 넣지 말고, 명령만 그대로 보여줍니다

## 4단계 — 수리

### 자동으로 해도 되는 것

| 문제 | 수리 | 세션 재시작 |
|---|---|---|
| 마켓플레이스 미등록 | `claude plugin marketplace add SurvivorsStudio/devkit` | 필요 |
| 플러그인 미설치 | `claude plugin install devkit@survivors` | 필요 |
| 플러그인 구버전 | `claude plugin update devkit@survivors` | 필요 |
| `devops-docs` 뒤짐 | `git pull --ff-only origin main` | — |
| `.done/` 없음 | `mkdir -p .done` | — |
| git 신원 없음 | 이름·이메일을 **물어본 뒤** `git config` | — |

`--ff-only` 를 쓰십시오. 로컬 커밋이 있으면 머지 커밋을 만들지 않고 실패하며, 그때는 팀원에게
넘기는 것이 맞습니다.

### 사람이 해야 하는 것 — 대신 실행하지 마십시오

| 문제 | 알려줄 명령 |
|---|---|
| Node 22 미만 | `brew install node` (또는 nvm 으로 22 설치) |
| gh 미로그인 | `gh auth login` — HTTPS + 브라우저, 스코프에 `repo`·`workflow` |
| `workflow` 스코프 없음 | `gh auth refresh -h github.com -s workflow` |
| 조직 멤버 아님 | 초대를 요청하십시오. 초대 수락 전에는 앱 레포를 만들 수 없습니다 |
| 활성 계정이 조직 접근 불가 | `gh auth switch --user <계정>` — 어느 계정이 맞는지 확인시킨 뒤 |
| Xcode · Android Studio | 실기기 빌드가 필요해질 때. 미리 받을 이유가 없습니다 |

**브라우저 인증과 자격 증명 입력은 본인만 합니다.** 명령을 보여주고 끝내십시오.

### npm link 잔존은 임의로 해제하지 마십시오

지금 `core` 를 검증하는 중일 수 있습니다. **커밋 전에 되돌려야 한다는 사실만 알리고** 판단은
넘기십시오:

```bash
npm unlink @survivorsstudio/core && npm install
```

## 5단계 — 재검증

수리한 항목만 다시 확인합니다. 전체 진단을 처음부터 돌리지 마십시오.

플러그인을 설치·갱신했다면 **이 세션에서는 확인이 불가능합니다.** 플러그인은 세션 시작 시점에
로드되므로 `claude plugin list` 로 설치 사실만 확인하고, 커맨드가 잡히는지는 새 세션에서 봅니다.

> ⚠️ **세션 중간에 설치하면 `/devkit:pr` 같은 정식 이름만 잡히고 bare `/pr` 은 실패합니다.**
> 이것을 "bare 이름은 원래 안 된다" 로 오해하기 쉽습니다. 새 세션에서 판단하도록 안내하십시오.

## 6단계 — 보고

- 고친 것 / 남은 것 / 팀원이 직접 해야 하는 것을 나눠서
- **세션 재시작이 필요하면 그것을 마지막 줄에** 두십시오. 중간에 묻히면 안 읽습니다
- 다음에 할 일 한 줄: 세팅이 끝났으면 `/new-app`, 이미 앱이 있으면 그 폴더로 이동

---

## 하지 말 것

- **`gh auth login` · `gh auth refresh` 를 대신 실행하지 마십시오.** 브라우저 인증이고 자격
  증명은 본인만 다룹니다
- **토큰을 파일에 적지 마십시오.** `gh` 는 keychain 을 씁니다. 평문으로 옮기지 마십시오
- **`git reset --hard` · `git checkout -- .` · `git clean` 을 쓰지 마십시오.** 팀원의 작업이
  날아갑니다. 워킹 트리가 더러우면 보고만 하십시오
- **이미 있는 클론 위에 다시 클론하지 마십시오.** 경로를 확인하고, 있으면 그것을 쓰십시오
- **`.claude/settings.local.json` 을 통째로 덮어쓰지 마십시오.** 개인 설정이 들어 있습니다.
  고칠 것이 있으면 해당 키만 바꾸십시오
- **`.claude/settings.json`(팀 공용)을 이 커맨드로 고치지 마십시오.** 그건 PR 로 합니다
- **확인 없이 수리하지 마십시오.** 3단계는 생략 불가입니다
- **진단을 요약하거나 걸러내지 마십시오.** 통과 항목까지 그대로 보여줍니다

## 실패했을 때

| 증상 | 확인 |
|---|---|
| `claude plugin install` 이 SSH 오류 | git SSH 키가 없습니다. `ssh -T git@github.com` 으로 확인 |
| 설치했는데 `plugin list` 에 없음 | scope 를 확인하십시오. 기본은 `user` 입니다 |
| `gh repo view` 가 `Could not resolve` | 조직 멤버가 아니거나 **활성 계정이 다릅니다.** 권한 오류와 구분되지 않으니 둘 다 확인 |
| `git pull --ff-only` 실패 | 로컬 커밋이 있습니다. 자동으로 풀지 말고 팀원에게 넘기십시오 |
| `node -v` 가 없음 | 설치 안내만. nvm 사용자는 셸을 새로 열어야 할 수 있습니다 |
| 진단은 통과인데 커맨드가 안 잡힘 | 세션을 새로 열었는지. 플러그인 신뢰 확인을 승인했는지 |
