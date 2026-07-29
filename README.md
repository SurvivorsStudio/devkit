# devkit

SurvivorsStudio 팀 공용 Claude Code 플러그인 마켓플레이스.

## 설치 (팀원 1회)

Claude Code 세션에서:

```
/plugin marketplace add SurvivorsStudio/devkit
/plugin install devkit@survivors
/reload-plugins
```

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

`plugin.json` 의 `version` 을 올려야 팀원에게 업데이트가 전달됩니다.

## 관련 레포

| 레포 | 역할 |
|---|---|
| [app-template](https://github.com/SurvivorsStudio/app-template) | 이 커맨드가 복제하는 원본 |
| [core](https://github.com/SurvivorsStudio/core) | 앱 공통 기능 npm 패키지 |
| [devops-docs](https://github.com/SurvivorsStudio/devops-docs) | 설계 근거·결정 기록 |
