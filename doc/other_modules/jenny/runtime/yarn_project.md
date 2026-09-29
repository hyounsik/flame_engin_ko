<a id="yarn-project"></a>

# Yarn 프로젝트

**YarnProject**는 모든 yarn 스크립트와 그에 딸린 정보의 중앙 허브입니다. 일반적으로 게임에는
`YarnProject`가 하나 있지만, 내용이 완전히 독립적이라면 yarn 프로젝트를 여러 개 만들 수도 있습니다.

`YarnProject`를 초기화하는 표준 순서는 다음과 같습니다.

- 사용자 정의 함수 연결하기
- 사용자 정의 명령 연결하기
- 로케일 설정하기(`en`과 다른 경우)
- 전역 변수와 캐릭터 선언이 담긴 `.yarn` 스크립트 파싱하기
- 나머지 모든 `.yarn` 스크립트 파싱하기
- 세이브 게임 저장소에서 변수 복원하기

예를 들면 다음과 같습니다.

```dart
final yarn = YarnProject()
  ..functions.addFunction0('money', player.getMoney)
  ..commands.addCommand1('achievement', player.earnAchievement)
  ..parse(readFile('project.yarn'))
  ..parse(readFile('chapter1.yarn'))
  ..parse(readFile('chapter2.yarn'));
```


<a id="properties"></a>

## 속성

**locale** `String`
: 이 `YarnProject`에서 사용하는 언어입니다(기본값은 `'en'`). 다른 언어를 선택하면 내장 `plural()` 함수가
  바뀝니다.

**random** `Random`
: 난수 생성기입니다. 예를 들어 시드를 제어해야 하는 경우 다른 생성기로 교체할 수 있습니다.

**nodes** `Map<String, Node>`
: 프로젝트에 로드된 모든 [Node]이며, title을 키로 합니다.

**variables** `VariableStorage`
: 이 yarn 프로젝트에서 사용하는 모든 전역 변수의 컨테이너입니다. 이 저장소에 접근해야 하는 이유는 여러
  가지가 있을 수 있습니다.

  <!-- markdownlint-disable MD006 MD007 -->
  - 게임에서 yarn 변수의 값을 바꾸기 위해. 이를 통해 게임의 정보를 대화로 전달할 수 있습니다. 예를 들어
    대화에 `$gold` 변수가 있고, 게임에서 플레이어의 돈이 바뀔 때마다 이 변수를 갱신하고 싶을 수 있습니다.
  - 게임을 저장할 때 모든 yarn 변수의 값을 저장하고, 게임을 불러올 때 복원하기 위해.
  <!-- markdownlint-enable MD006 MD007 -->

**functions** `FunctionStorage`
: 프로젝트에 연결된 모든 사용자 정의 함수의 [컨테이너][FunctionStorage]입니다. 이 속성에 접근하는 주된
  이유는 런타임에 사용할 수 있도록 새 커스텀 함수를 등록하기 위해서입니다.

  모든 커스텀 함수는 대화 스크립트에서 사용하기 전에 `YarnProject`에 추가되어야 합니다. 그렇지 않으면
  알 수 없는 함수를 만났을 때 컴파일 오류가 발생합니다.

**commands** `CommandStorage`
: 프로젝트에 연결된 모든 사용자 정의 명령의 [컨테이너][CommandStorage]입니다. 이 컨테이너에 접근하는
  주된 이유는 새 커스텀 명령을 등록하기 위해서입니다.

  모든 커스텀 명령은 대화 스크립트에서 사용하기 전에 추가되어야 합니다.

**characters** `CharacterStorage`
: yarn 스크립트에서 선언된 모든 [Character] 객체의 [컨테이너][CharacterStorage]입니다.

**strictCharacterNames** `bool`
: `true`(기본값)이면 캐릭터 이름의 유효성이 엄격하게 강제됩니다. 즉, 모든 캐릭터는 사용하기 전에
  [\<\<character\>\>] 명령으로 선언되어야 합니다. 이 속성을 false로 설정하면 스크립트에서 새 캐릭터를
  만날 때마다 [Character] 객체가 자동으로 만들어집니다.

**trueValues**, **falseValues** `Set<String>`
: 각각 `true`/`false` 값으로 인식될 수 있는 문자열입니다.

**variables** `VariableStorage`
: yarn 스크립트에서 선언되고 조작되는 모든 변수의 [컨테이너][VariableStorage]입니다. 사용자가 방문한
  노드의 방문 횟수를 관리하는 데에도 사용됩니다. '게임 저장' 기능을 구현하려면
  `VariableStorage.variables`의 변수를 저장해 두었다가 나중에 다시 복원하면 됩니다.


<a id="methods"></a>

## 메서드

**parse**(`String text`)
: yarn 스크립트의 `text`를 파싱하고 컴파일합니다. 이 명령 이후에는 스크립트에 포함된 노드를 실행할 수
  있습니다.

  이 메서드는 여러 번 실행할 수 있으며, 실행할 때마다 새 노드가 기존 노드에 추가됩니다.


[\<\<character\>\>]: ../language/commands/character.md
[Character]: character.md
[CharacterStorage]: character_storage.md
[CommandStorage]: command_storage.md
[FunctionStorage]: function_storage.md
[Node]: node.md
[VariableStorage]: variable_storage.md
