# devkit

SurvivorsStudio 팀 공용 Claude Code 플러그인 마켓플레이스.

## 설치

### 방법 A — `devops-docs` 를 클론한다 (권장, 설정 불필요)

[devops-docs](https://github.com/SurvivorsStudio/devops-docs) 에 `.claude/settings.json` 이 커밋돼
있습니다. 그 폴더에서 Claude Code 세션을 열면 `/devkit:new-app` 이 **그냥 있습니다.**

```bash
git clone https://github.com/SurvivorsStudio/devops-docs
cd devops-docs
claude
```

### 방법 B — 직접 설치 (어느 폴더에서든 쓰고 싶을 때)

```
/plugin marketplace add SurvivorsStudio/devkit
/plugin install devkit@survivors
/reload-plugins
```

> ⚠️ `/plugin` 은 대화형 패널을 여는 커맨드라 **환경에 따라 막혀 있습니다**
> ("`/plugin` isn't available in this environment"). 그럴 때는 터미널에서 `claude` 를 직접 띄워
> 실행하거나, 방법 A 를 쓰십시오.
>
> 설치 결과는 `~/.claude/settings.json` 에 저장되고 터미널과 앱이 같은 파일을 읽습니다.
> 즉 **터미널에서 한 번 설치하면 앱에서도 쓸 수 있습니다** — 단, 설치 전에 시작된 세션은
> 플러그인을 이미 로드한 뒤라 `/reload-plugins` 를 하거나 새 세션을 열어야 잡힙니다.

## 쓰는 법

```
/devkit:new-app
```

앱 이름·레포 이름·번들 ID·설명을 물어본 뒤, `app-template` 에서 레포를 만들고
토큰 치환 → `npm install` → `cap add ios/android` → 첫 커밋까지 진행합니다.

> 플러그인 스킬은 `/플러그인명:스킬명` 형태로 호출됩니다. `/new-app` 이 아니라
> `/devkit:new-app` 입니다.

인자 없이 실행하면 필요한 것을 되묻습니다. 한 번에 주고 싶으면:

```
/devkit:new-app 한손점프
```

## 구조

```
.claude-plugin/marketplace.json     ← 마켓플레이스 레지스트리 (name: survivors)
plugins/devkit/
├── .claude-plugin/plugin.json      ← 매니페스트만
└── skills/new-app/SKILL.md         ← /devkit:new-app
```

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

즉시 받고 싶은 팀원은:

```
/plugin marketplace update
```

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
| [devops-docs](https://github.com/SurvivorsStudio/devops-docs) | 설계 근거·결정 기록 |
