---
name: new-app
description: SurvivorsStudio 새 앱 레포를 app-template 에서 만듭니다. 앱 이름·번들 ID·설명을 확인한 뒤 레포 생성, 토큰 치환, 네이티브 플랫폼 추가, 첫 커밋까지 진행합니다. 사용자가 "새 앱 만들자", "앱 하나 추가", "/devkit:new-app" 이라고 할 때 사용합니다.
---

# 새 앱 만들기

`SurvivorsStudio/app-template` 에서 새 앱 레포를 만들고 개발 시작 지점까지 세팅합니다.

이 절차는 `app-hansonjump` 를 만들며 실제로 한 번 통과한 것입니다. 새로 발명하지 말고 그대로 따르십시오.

---

## 1단계 — 입력 확인

사용자가 인자로 준 것이 있으면 쓰고, 없으면 **묻습니다.** 추측해서 진행하지 마십시오.

| 물어볼 것 | 토큰 | 기본값 제안 | 규칙 |
|---|---|---|---|
| 앱 이름 | `{{APP_NAME}}` | — | 한글 가능. 화면과 문서에 그대로 노출됨 |
| 레포 이름 | `{{APP_SLUG}}` | `app-<영문소문자>` | 소문자·숫자·하이픈만 |
| 번들 ID | `{{APP_ID}}` | `com.survivorsstudio.<슬러그에서 app- 제거, 하이픈 제거>` | 아래 주의 참조 |
| 한 줄 설명 | `{{APP_DESCRIPTION}}` | — | `package.json` 과 README 에 들어감 |
| 플랫폼 | — | iOS + Android 둘 다 | 하나만 원하면 확인 |

**번들 ID 주의 — 두 가지를 반드시 확인시키십시오:**

1. **하이픈이 들어가면 Android 빌드가 깨집니다.** `applicationId` 의 각 마디는 Java 식별자여야 합니다.
   `app-hansonjump` → `com.survivorsstudio.hansonjump` (하이픈 제거)
2. **전 세계에서 고유해야 하고, 스토어 등록 후에는 변경할 수 없습니다.** 제안값을 그대로 쓰더라도
   사용자에게 한 번 눈으로 확인받으십시오.

**화면 방향은 묻지 않습니다.** 각 앱이 알아서 정하기로 한 사항입니다 (2026-07-29 결정).

---

## 2단계 — 사전 확인

레포를 만들기 전에 확인합니다. 중간에 실패하면 반쯤 만들어진 레포가 남습니다.

```bash
gh auth status
gh repo view SurvivorsStudio/<슬러그> 2>&1 | head -3   # 이미 있으면 중단하고 사용자에게 알림
```

---

## 3단계 — 생성

### 어디에 만드는가 — 묻지 말고 계산하십시오

앱 레포는 **`devops-docs` 와 같은 부모 폴더**에 형제로 둡니다. 그 폴더의 **이름은 사람마다
다릅니다** (`~/Project`, `~/Personal`, `D:\work` …). **경로를 하드코딩하지 마십시오.**

```bash
git rev-parse --show-toplevel        # 지금 어느 레포 안인가
```

| 지금 위치 | 만들 곳 |
|---|---|
| `devops-docs` 안 (보통) | **그 부모 폴더.** `cd "$(git rev-parse --show-toplevel)/.."` |
| 다른 레포 안 (`app-*`·`core`) | 같은 규칙 — 그 레포의 부모 폴더 |
| git 레포가 아님 | 현재 폴더. 단 형제에 `devops-docs` 가 보이는지 확인하고, 아니면 **물어보십시오** |

만들기 직전에 **그 자리가 git 레포 바깥인지** 확인합니다. 여기서 한 번 막으면 되돌릴 일이 없습니다.

```bash
git rev-parse --show-toplevel 2>/dev/null && echo "중단 — 레포 안입니다" || echo "OK"
```

> ⚠️ **`devops-docs` 안에 만들지 마십시오.** 문서 레포 안에 앱 레포가 중첩되면 바깥 `git status`
> 가 앱 폴더를 미추적으로 물고, 문서 커밋에 앱이 딸려 들어갈 수 있습니다. `devops-docs` 는
> **코드가 없는 레포**라는 것이 그 레포의 절대 규칙입니다.

`gh repo create --clone` 은 **현재 폴더 밑에** 클론합니다. 그러니 `cd` 가 먼저입니다.

```bash
cd "$(git rev-parse --show-toplevel)/.."
gh repo create SurvivorsStudio/<슬러그> \
  --template SurvivorsStudio/app-template --private --clone
cd <슬러그>
```

**어디에 만들었는지 절대경로로 보고하십시오.** 팀원은 다음 명령을 그 폴더에서 실행해야 합니다.

### 토큰 치환

`TEMPLATE.md` 는 **반드시 제외**합니다. 그 안의 토큰 표가 자기 자신을 치환해 문서가 깨집니다.

```bash
node -e '
const fs=require("fs"), path=require("path");
const map={
  "{{APP_NAME}}":        process.argv[1],
  "{{APP_ID}}":          process.argv[2],
  "{{APP_SLUG}}":        process.argv[3],
  "{{APP_DESCRIPTION}}": process.argv[4],
};
const skipDir=new Set(["node_modules",".git","dist","ios","android"]);
const skipFile=new Set(["TEMPLATE.md"]);
(function walk(d){
  for (const e of fs.readdirSync(d,{withFileTypes:true})) {
    if (skipDir.has(e.name)) continue;
    const p=path.join(d,e.name);
    if (e.isDirectory()) { walk(p); continue; }
    if (skipFile.has(e.name) || !/\.(ts|json|html|md|css|yml)$/.test(e.name)) continue;
    let t=fs.readFileSync(p,"utf8"); const o=t;
    for (const [k,v] of Object.entries(map)) t=t.split(k).join(v);
    if (t!==o) { fs.writeFileSync(p,t); console.log("  "+path.relative(".",p)); }
  }
})(".");
' "<앱이름>" "<번들ID>" "<슬러그>" "<설명>"
```

잔여 토큰이 0인지 확인합니다. 하나라도 남으면 멈추고 원인을 찾으십시오.

```bash
grep -rn "{{APP_" --include="*.ts" --include="*.json" --include="*.html" --include="*.md" . | grep -v node_modules
```

### 설치와 빌드

```bash
npm install
npm run build          # cap add 가 dist/ 를 복사하므로 빌드가 먼저입니다
npx cap add ios
npx cap add android
```

> ⚠️ **`TEMPLATE.md` 를 여기서 지우지 마십시오.** 4단계(로그인 · Firebase 콘솔 설정)가 아직
> 남아 있고, 그건 사람이 콘솔에서 직접 해야 합니다. 삭제는 그 문서의 5단계("정리")에 이미
> 사람이 할 일로 적혀 있습니다 — 이 커맨드가 대신 지우면 그 안내를 못 보고 지나칩니다.

### 세션 기록 폴더

```bash
mkdir -p .done
```

`/done` 이 세션 요약을 여기에 씁니다. **gitignore 되므로 커밋되지 않습니다** — 템플릿에 담아
전달할 수 없어 앱을 만들 때 로컬에 생성합니다. `app-template` 의 `.gitignore` 에 `.done/` 이
들어 있는지 확인하십시오.

Xcode 나 Java 가 없어도 `cap add` 는 동작합니다. 실제 빌드에만 필요합니다.

### 앱 레포용으로 문서 손보기

템플릿 문구가 그대로 남아 어색한 곳을 고칩니다.

- `README.md` — "이 템플릿으로 새 앱 만들기" 잔재가 있으면 지우고, 남은 자리표시자
  (`resources/` 아이콘, `src/main.ts` 스모크 테스트) 안내로 대체
- `CLAUDE.md` — 첫 인용문의 "공용 앱 템플릿" 표현을 앱 레포에 맞게

### 커밋 · 푸시

```bash
git add -A
git commit -m "chore: 템플릿 토큰 치환 및 네이티브 플랫폼 추가"
git push origin main
```

---

## 4단계 — 검증

여기까지 하고 **직접 확인한 뒤** 보고하십시오. 확인 없이 "완료"라고 하지 마십시오.

- [ ] 잔여 토큰 0
- [ ] `npm run typecheck` · `npm run build` 통과
- [ ] 번들 ID 가 `ios/App/App.xcodeproj/project.pbxproj` 와 `android/app/build.gradle` 에 박혔는지
- [ ] `git status` 가 깨끗하고 origin 과 동기화됨
- [ ] `gh run list --limit 1` 이 success
- [ ] `npm run dev` 로 로그인 화면이 뜨는지 (구글·게스트 버튼 보임, Apple 은 비활성) —
      Firebase 를 아직 설정 안 했으니 눌러보면 `auth/api-key-not-valid` 에러가 뜨는 것이
      **정상입니다.** 크래시만 없으면 배선은 살아 있는 것입니다

---

## 5단계 — 보고

- 레포 URL
- 다음 할 일: `npm run dev` → 탭 카운터가 새로고침 후에도 남으면 `@survivorsstudio/core` 배선이
  살아 있는 것. 확인했으면 `src/main.ts` 의 스모크 테스트 블록을 지우고 앱을 만들기 시작
- **로그인이 아직 동작하지 않는다는 것을 명시적으로 알리십시오.** `TEMPLATE.md` 의
  "4. 로그인(Firebase Auth) 설정" 체크리스트를 완료해야 구글·게스트 로그인이 실제로 됩니다.
  Apple 로그인은 유료 Developer Program 등록 전까지 의도적으로 비활성입니다
- 남은 자리표시자: `resources/icon.png`, `resources/splash.png`

---

## 하지 말 것

이 커맨드의 범위는 **레포 생성과 배선 확인까지**입니다.

- **`devops-docs`(또는 다른 레포) 안에 앱을 만들지 마십시오.** 3단계에서 부모 폴더로 나갑니다
- **작업 폴더 경로를 하드코딩하지 마십시오.** `~/Project` 같은 이름은 사람마다 다릅니다 —
  `git rev-parse --show-toplevel` 에서 계산합니다
- **앱 기능을 만들지 마십시오.** 게임 로직·화면·에셋은 사용자가 만듭니다
- **화면 방향을 고정하지 마십시오.** 각 앱이 정합니다
- **CI·릴리스·서명 워크플로를 추가하지 마십시오.** 템플릿에 든 `ci.yml`(ubuntu, typecheck + build)이
  전부입니다. macOS 잡은 절대 넣지 마십시오 — Actions 쿼터를 10배로 소진합니다
- **`@survivorsstudio/core` 를 앱 안에서 고치지 마십시오.** core 버그는 core 레포에 PR 을 올립니다
- **Capacitor 플러그인을 미리 깔지 마십시오.** 필요해질 때 그 앱에서 추가합니다

## 실패했을 때

| 증상 | 확인 |
|---|---|
| `gh repo create` 권한 오류 | `gh auth status` · 조직 멤버 권한 |
| 앱이 `devops-docs` 안에 생겼음 | `cd ..` 를 빠뜨렸습니다. **바깥으로 옮기고**(`mv`) 문서 레포의 `git status` 가 깨끗한지 확인 |
| 잔여 토큰이 남음 | 치환 대상 확장자 목록에 그 파일이 있는지 |
| Android 빌드에서 패키지명 오류 | 번들 ID 에 하이픈이 들어갔는지 |
| CI 빨강 | 로컬에서 `npm ci && npm run typecheck && npm run build` 재현 |
