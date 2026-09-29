<a id="contribution-guidelines"></a>

# 기여 가이드라인

**참고:** 이 기여 가이드라인을 따르지 않으면 이슈나 PR이 닫힐 수 있으니 아래 안내를 꼼꼼히
읽어 주세요.


<a id="contribution-types"></a>

## 기여 유형


<a id="bug-reports"></a>

### 버그 제보

- 버그를 발견했다면 먼저 [Github issues]로 제보해 주세요.
  - 먼저 같은 내용의 이슈가 이미 있는지 확인하세요. 중복된 이슈는 닫힙니다.


<a id="bug-fix"></a>

### 버그 수정

- 버그 수정을 제출하고 싶다면 Pull Request를 보내는 방법이 담긴 [기여 방법](#기여-방법)을
   읽어 주세요.
- 열려 있는 이슈에 버그 수정 작업을 하고 있다고 남겨 주시면 이슈가 여러분에게 할당됩니다.
- PR 본문에 `Fixes #xxxx`를 적어 주세요. xxxx는 (이슈가 있다면) 이슈 번호입니다.
- 버그를 격리해서 재현하고 수정되었음을 검증하는 테스트를 포함해 주세요.


<a id="new-features"></a>

### 새 기능

- 라이브러리에 아직 없는 기능을 추가하고 싶다면 새 [GitHub issue]에 기능을 자유롭게
   설명해 주세요.
  - [Discord]에 참여해서 초기 아이디어를 논의할 수도 있습니다.
- 새 기능을 직접 구현하고 싶다면, 코드 작성에 많은 시간을 들이기 전에 프로젝트 메인테이너의
   피드백을 기다려 주세요. 개선 사항이 프로젝트의 향후 개발 방향과 잘 맞지 않는 경우도 있습니다.
- 새 기능의 코드를 구현하고 [기여 방법](#기여-방법)을 읽어 주세요.


<a id="documentation--miscellaneous"></a>

### 문서 및 기타

- 문서, 튜토리얼, 예제(또는 그 밖의 것)에 대한 개선 제안이 있다면 언제든 환영합니다.
- 언제나처럼 먼저 [Github issue]를 등록해 주세요.
- 문서 변경 사항을 구현하고 [기여 방법](#기여-방법)을 읽어 주세요.


<a id="how-to-contribute"></a>

## 기여 방법


<a id="requirements"></a>

### 요구 사항

기여가 받아들여지려면 다음을 지켜야 합니다.

- 코드를 작성할 때 [Style Guide]를 따릅니다.
- `dart format .`으로 코드를 포맷합니다.
- `melos analyze`로 코드를 린트합니다.
- 모든 테스트가 통과하는지 확인합니다: `melos test`
- 문서는 (해당되는 경우) 항상 업데이트하거나 추가해야 합니다.
- 예제는 (해당되는 경우) 항상 업데이트하거나 추가해야 합니다.
- 테스트는 (해당되는 경우) 항상 업데이트하거나 추가해야 합니다. 자세한 내용은
  [Test writing guide]를 확인하세요.
- PR 제목은 [conventional commit] 접두사(`feat:`, `fix:` 등)로 시작해야 합니다.

기여가 이 기준을 충족하지 못하면 메인테이너가 이슈나 PR에서 여러분과 논의합니다. Pull Request를
보낸 브랜치에 커밋을 계속 추가할 수 있으며, 추가한 커밋은 PR에 자동으로 반영됩니다.


<a id="open-an-issue-and-fork-the-repository"></a>

## 이슈 열기와 저장소 포크

- 큰 변경이나 새 기능이라면 먼저
   [버그 또는 기능 제안을 등록][GitHub issue]해서 어떤 방향으로 갈지 논의할 수 있게 해 주세요.
- GitHub에서 [프로젝트를 포크][fork guide]합니다.
- 포크한 저장소를 로컬 개발 머신에 클론합니다
   (예: `git clone git@github.com:<YOUR_GITHUB_USER>/flame.git`).


<a id="environment-setup"></a>

### 환경 설정

Flame은 Flutter의 최신 `stable` 버전에서 동작하도록 설정되어 있으니, 사용 중인 버전이 이와
맞는지 확인하세요.

```shell
flutter channel stable
```

또한 Flame은 프로젝트와 의존성 관리에 [Melos]를 사용합니다.

Melos를 설치하려면 터미널에서 다음 명령을 실행하세요.

```shell
flutter pub global activate melos
```

다음으로, 로컬에 클론한 저장소의 루트에서 프로젝트 의존성을 bootstrap합니다.

```shell
melos bootstrap
```

bootstrap 명령은 [`dependency_overrides`][pubspec doc]를 직접 지정하지 않아도 프로젝트 내의 모든
의존성을 로컬로 연결합니다. 덕분에 모든 플러그인, 예제, 테스트를 로컬 클론 프로젝트에서 빌드할 수
있습니다. 이 명령은 한 번만 실행하면 됩니다.

> bootstrap이 완료된 후에는 `flutter pub get`을 실행할 필요가 없습니다.


#### CSpell

맞춤법 검사기를 로컬에서 실행하려면
[cspell](https://github.com/streetsidesoftware/cspell/tree/main/packages/cspell)을 설치해야 합니다.
npm이나 yarn으로 설치할 수 있습니다.

```bash
npm install -g cspell
```

그런 다음 제공된 스크립트로 실행할 수 있습니다.

```bash
./scripts/cspell-run.sh
```


#### Markdown Lint

마크다운 파일을 린트하려면
[markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli)를 설치해야 합니다. 설치한
후에는(차이가 있을 수 있으니 CI에 고정된 버전을 확인하세요) `melos markdown-check`를 실행해
마크다운이 규칙을 따르는지 확인할 수 있습니다. 일부 마크다운 린트 오류는 `melos markdown-fix`로
자동 수정할 수 있습니다.

안타깝게도 특히 손이 많이 가는 규칙인 MD013은 [자동 수정 옵션을 제공하지
않습니다](https://github.com/DavidAnson/markdownlint/issues/535). 하지만 다른 도구로 우회할 수
있습니다. 예를 들어 VSCode 확장 [Rewrap](https://stkb.github.io/Rewrap/)을
`rewrap.wrappingColumn=100`으로 [설정하면](https://stkb.github.io/Rewrap/configuration/) 이 작업을
대신해 줍니다.


<a id="performing-changes"></a>

### 변경 작업하기

- `main`에서 새 로컬 브랜치를 만듭니다(예: `git checkout -b my-new-feature`).
- 변경 사항을 만듭니다(기능/수정 하나당 PR 하나로 나누도록 해 주세요).
- 변경 사항을 커밋할 때 각 커밋 메시지가 명확한지 확인하세요
 (예: `git commit -m 'Take in an optional Camera as a parameter to FlameGame'`).
- 새 브랜치를 자신의 포크에 같은 이름의 원격 브랜치로 push합니다
 (예: `git push origin my-username.my-new-feature`, 다른 원격을 쓴다면 `origin`을 바꾸세요).


<a id="breaking-changes"></a>

### 호환성을 깨는 변경

호환성을 깨는 변경(breaking change)을 할 때는 가능하면 deprecation 태그를 추가하고, 지원 중단된
메서드/필드가 어느 버전에서 제거되는지와 대신 어떤 메서드를 사용해야 하는지를 사용자에게 알려 주는
메시지를 담아야 합니다. 지정하는 버전은 현재 버전보다 최소 두 버전 뒤여야 합니다. 그래야 사용자가
deprecation 경고를 볼 수 있는 안정 릴리스가 최소 한 번은 있고, 그다음 버전(또는 이후 버전)에서
지원 중단된 항목을 제거할 수 있습니다.

예시(현재 버전이 v1.3.0인 경우):

```dart
@Deprecated('Will be removed in v1.5.0, use nonDeprecatedFeature() instead')
void deprecatedFeature() {}
```


<a id="open-a-pull-request"></a>

### Pull Request 열기

[Flame의 pull request 페이지][PRs]로 가면 페이지 상단에서 새로 만든 브랜치로 pull request를 열지
물어봅니다.

pull request 제목은 [conventional commit] 타입으로 시작해야 합니다.

허용되는 타입은 다음과 같습니다.

- `fix:` -- 버그를 수정하며 새 기능이 아닌 경우
- `feat:` -- 새 기능을 도입하는 경우
- `docs:` -- 문서나 예제를 업데이트하거나 추가하는 경우
- `test:` -- 테스트를 업데이트하거나 추가하는 경우
- `refactor:` -- 코드를 리팩터링하지만 공개 API에 변경이나 추가가 없는 경우
- `perf:` -- 성능을 개선하는 코드 변경
- `build:` -- 빌드 시스템이나 외부 의존성에 영향을 주는 코드 변경
- `ci:` -- CI 설정 파일과 스크립트 변경
- `chore:` -- 소스나 테스트 파일을 수정하지 않는 기타 변경
- `revert:` -- 이전 커밋을 되돌리는 경우

**호환성을 깨는 변경**을 도입한다면 conventional commit 타입은 반드시 느낌표로 끝나야 합니다
(예: `feat!: Remove the position argument from PositionComponent`).

커밋 문장(`:` 뒤)은 현재 시제의 동사로 시작해야 합니다. 경험적으로는 커밋 메시지가 "This commit
will ..." 문장을 완성한다고 생각하면 됩니다. 예를 들어 "Add support for ..."나 "Fix bug with ..."
처럼 씁니다.

PR 제목 예시:

- feat: Component.childrenFactory can be used to set up a global ComponentSet factory
- fix: Avoid infinite loop in `FlameGame`
- docs: Add a `JoystickComponent` example
- docs: Improve the Mandarin README
- test: Add infinity test for `MoveEffect.to`
- refactor: Optimize the structure of the game loop


<a id="maintainers"></a>

## 메인테이너

이 안내는 Flame 메인테이너를 위한 것입니다.


<a id="merging-a-pull-request"></a>

### Pull Request 병합

pull request를 병합할 때는 병합 커밋의 제목에 올바른 conventional commit 태그와 설명적인 제목이
있는지 확인하세요. PR 제목이 GitHub가 기본으로 넣는 병합 커밋 제목과 다를 때가 있어서(예를 들어
PR이 진행되는 동안 제목이 바뀐 경우) 특히 중요합니다.

커밋 메시지와 PR 설명의 기본 텍스트는 모두 지우고, (PR이 호환성을 깨는 경우) "Migration
instruction"의 안내를 커밋 메시지에 복사해 넣어야 합니다.


<a id="creating-a-release"></a>

### 릴리스 만들기

릴리스할 때 고려할 사항이 몇 가지 있습니다.

- 코드베이스에서 `@Deprecated` 메서드/필드를 찾아, 릴리스하려는 버전에서 제거하기로 표시된 것을
   제거합니다.
- 지원 중단된 항목을 제거하는 변경을 담은 PR을 만듭니다.
- `melos version -V <package1>:<version> -V <package2>:<version>`을 실행해 Melos가
   `CHANGELOG.md` 파일을 생성하게 합니다.
- 호환성을 깨는 변경이 있는 PR들을 살펴보고 changelog에 마이그레이션 문서를 추가합니다.
   커밋 메시지에 복사되지 않았다면 각 PR에 마이그레이션 문서가 있어야 합니다.
- `melos publish`를 실행해 패키지에 문제가 없는지, 모든 버전이 올바른지 확인합니다.
- dry run 결과에 만족하면 `melos publish --no-dry-run`을 실행합니다.
- 업데이트된 changelog와 `pubspec.yaml` 파일을 담은 PR을 만듭니다.


[GitHub issue]: https://github.com/flame-engine/flame/issues
[GitHub issues]: https://github.com/flame-engine/flame/issues
[PRs]: https://github.com/flame-engine/flame/pulls
[fork guide]: https://docs.github.com/en/get-started/quickstart/contributing-to-projects
[Discord]: https://discord.com/invite/pxrBmy4
[Melos]: https://github.com/invertase/melos
[pubspec doc]: https://dart.dev/tools/pub/pubspec
[conventional commit]: https://www.conventionalcommits.org
[style guide]: https://docs.flame-engine.org/main/development/style_guide
[test writing guide]: https://docs.flame-engine.org/main/development/testing_guide
