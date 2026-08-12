---
name: pr-merge
description: PR 을 squash 머지합니다. CI 통과를 기다린 뒤 요약을 보여주고 곧바로 머지, 이후 브랜치를 정리하고 로컬 main 을 갱신합니다. 사용자가 "/pr-merge #12", "PR 머지해" 라고 할 때 사용합니다.
disable-model-invocation: true
---

# PR 머지

**항상 squash 머지입니다.** 다른 방식은 쓰지 않습니다.

---

## 1단계 — 대상 PR 확정

인자에서 번호를 뽑습니다. `#12` · `12` · PR URL 전부 받습니다.

**번호가 없으면 현재 브랜치의 PR 을 찾습니다:**

```bash
gh pr view --json number,title,url -q '.number'
```

없으면 여기서 멈추고 사용자에게 알립니다. 짐작해서 다른 PR 을 고르지 마십시오.

```bash
gh pr view <번호> --json number,title,body,state,isDraft,mergeable,mergeStateStatus,\
headRefName,baseRefName,author,changedFiles,additions,deletions,url,commits
```

## 2단계 — 머지 가능한지 확인

아래 중 하나라도 걸리면 **중단하고 이유를 보고**합니다. 우회하지 마십시오.

| 상태 | 처리 |
|---|---|
| `state` 가 `MERGED` | 이미 머지됨. 그대로 알림 |
| `state` 가 `CLOSED` | 닫힌 PR. 열지 말고 알림 |
| `isDraft` 가 `true` | 초안입니다. 사용자가 `gh pr ready` 를 할지 물어봅니다 |
| `mergeable` 이 `CONFLICTING` | **충돌.** 아래 참조 |
| `mergeStateStatus` 가 `BLOCKED` | 보호 규칙에 막힘. 무엇이 부족한지 보고 |

### 충돌이 있으면

**자동으로 해결하지 마십시오.** 어느 쪽을 살릴지는 작성자만 압니다.

충돌 파일을 보여주고 중단합니다:

```bash
gh pr view <번호> --json mergeable,mergeStateStatus
git fetch origin && git diff --name-only origin/<base>...origin/<head>
```

작성자가 브랜치에서 `git merge origin/main` 으로 해결한 뒤 다시 부르면 됩니다.

## 3단계 — CI 통과를 기다림

```bash
gh pr checks <번호> --watch
```

- **통과하면** 다음 단계로
- **실패하면 머지하지 않습니다.** 어떤 잡이 왜 실패했는지 보고합니다:

```bash
gh pr checks <번호>
gh run view <run-id> --log-failed | tail -40
```

체크가 아예 없는 레포라면 그 사실만 알리고 진행합니다.

> ⚠️ CI 가 오래 걸리면 `--watch` 가 세션을 붙잡습니다. 몇 분 넘게 걸리면 사용자에게
> 기다릴지 나중에 다시 부를지 물어봅니다.

## 4단계 — squash 커밋 메시지 준비

머지하면 개별 커밋이 하나로 합쳐집니다. **이 메시지가 `main` 이력에 영구히 남는 것**입니다.

**제목** — PR 제목을 씁니다. 단 Conventional Commits 형식이어야 합니다:

```
<type>[scope][!]: <설명>
```

PR 제목이 형식에서 벗어났다면 **고친 제목을 제안**하고 확인받습니다. 조용히 바꾸지 마십시오.

**본문** — 개별 커밋 목록을 남깁니다. 상세 과정이 사라지지 않게 하는 장치입니다.

```bash
gh pr view <번호> --json commits -q '.commits[] | "* " + .messageHeadline'
```

```
* feat: storage 모듈 추가
* docs: storage 사용법 추가
* fix: 키 접두사 오타

PR: #12
```

## 5단계 — 요약 보여주기

**`/devkit:pr-merge` 를 부른 것 자체가 머지 승인입니다.** 여기서 다시 `AskUserQuestion` 으로
되묻지 마십시오. 이 커맨드의 존재 목적이 머지이고, 사용자가 번호(또는 "머지해")를 명시해서
호출한 시점에 의도는 이미 표명된 것입니다.

다만 **무엇을 머지하는지는 텍스트로 보여줍니다.** 번호를 잘못 읽어 다른 PR 을 머지하는 사고를
사용자가 바로 알아챌 수 있게 하는 안전장치입니다 — 질문으로 막지 않을 뿐, 정보는 그대로 보여줘야
합니다.

```
#12 를 squash 머지할게:

  제목    feat(storage): Preferences 래퍼 추가
  브랜치  feat/core-storage → main
  작성자  babysean
  변경    4개 파일 +120 −8
  CI      ✓ 통과
  커밋    3개 → 1개로 합쳐짐

머지 후: 원격·로컬 브랜치 삭제, main 으로 이동해 pull
```

보여준 뒤 **곧바로 6단계로 진행**합니다. 응답을 기다리지 않습니다.

> ⚠️ 이 예외는 **이 커맨드 한정**입니다. 충돌·CI 실패·`isDraft` 처럼 2~3단계에서 이미 중단
> 대상으로 분류된 상태는 이 단계로 오지 않습니다 — 그 경우는 여전히 멈추고 사용자에게
> 알립니다. "되묻지 않는다" 는 것이 "무엇이든 진행한다" 는 뜻은 아닙니다.

## 6단계 — 머지

```bash
gh pr merge <번호> --squash --delete-branch \
  --subject "<제목>" --body "<본문>"
```

`--squash` 는 **고정**입니다. `--merge` · `--rebase` 를 쓰지 마십시오.
`--admin` 도 쓰지 마십시오 — 보호 규칙을 우회하는 플래그입니다.

성공했는지 확인합니다:

```bash
gh pr view <번호> --json state,mergeCommit -q '{state, sha: .mergeCommit.oid}'
```

`state` 가 `MERGED` 가 아니면 다음 단계로 넘어가지 말고 보고합니다.

## 7단계 — 로컬 정리

`--delete-branch` 가 원격과 로컬을 모두 지우지만, 로컬은 실패할 수 있습니다. 확인하고 마무리합니다.

```bash
git checkout <base>          # 보통 main
git pull origin <base>
git branch --list <head>     # 로컬 브랜치가 남았는지
```

> ⚠️ **squash 머지 후에는 `git branch -d` 가 거부됩니다.**
> squash 는 브랜치 커밋을 `main` 의 조상으로 만들지 않으므로 git 이 "머지되지 않았다"고 봅니다.
> **6단계에서 `state == MERGED` 를 확인한 뒤에만** 강제 삭제하십시오 — 그 시점엔 작업이 이미
> squash 커밋으로 `main` 에 들어가 있습니다.
>
> ```bash
> git branch -D <head>
> ```
>
> 머지 확인 전에는 절대 `-D` 를 쓰지 마십시오. 확인 안 된 상태의 강제 삭제는 작업 유실입니다.

`git checkout` 전에 워킹 트리가 깨끗한지 확인합니다. 커밋되지 않은 변경이 있으면 브랜치 이동이
실패하므로, 그 사실을 알리고 정리는 건너뜁니다.

## 8단계 — 보고

- 머지된 squash 커밋 SHA 와 제목
- 로컬 상태 (`main` 최신, 브랜치 삭제됨)
- `core` 레포였다면: release-please 가 릴리스 PR 을 만들 것이고, **그 PR 을 머지해야 npm 배포**가
  됩니다. 이 커맨드는 거기까지 하지 않습니다

---

## 하지 말 것

- **squash 외의 머지 방식을 쓰지 마십시오.** `--merge` · `--rebase` 금지
- **`--admin` 을 쓰지 마십시오.** 보호 규칙은 우회하려고 있는 것이 아닙니다
- **충돌을 자동으로 해결하지 마십시오.** 중단하고 작성자에게 넘깁니다
- **CI 실패를 무시하지 마십시오.** 사용자가 명시적으로 요청할 때만 예외
- **5단계의 요약 표시를 생략하지 마십시오.** 되묻지는 않지만 무엇을 머지하는지는 보여줘야
  합니다. 되묻지 않는 것과 2~3단계의 중단 대상(충돌·CI 실패·초안)을 그냥 진행하는 것은
  다릅니다 — 그 경우는 여전히 멈춥니다
- **머지 확인 전에 `git branch -D` 를 쓰지 마십시오**
- `git push --force` · `git reset --hard` 를 쓰지 마십시오
- **릴리스 태그를 만들거나 배포하지 마십시오.** 이 커맨드의 범위는 머지까지입니다

## 실패했을 때

| 증상 | 확인 |
|---|---|
| `gh pr merge` 권한 오류 | 레포 쓰기 권한 / `gh auth status` |
| `not fully merged` 로 브랜치 삭제 실패 | squash 머지의 정상 동작입니다. 7단계의 `-D` 참조 |
| `mergeStateStatus` 가 `UNKNOWN` | GitHub 이 계산 중입니다. 잠시 후 재조회 |
| `checkout` 실패 | 커밋되지 않은 변경이 있습니다. 정리를 건너뛰고 알립니다 |
| CI 가 계속 대기 상태 | 워크플로가 트리거되지 않았을 수 있습니다. `gh run list` 확인 |
