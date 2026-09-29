# CommandStorage

**CommandStorage**는 모든 [사용자 정의 명령][user-defined commands]을 저장하는 역할을 하는 [YarnProject]의
일부입니다. `YarnProject.commands` 속성으로 접근할 수 있습니다.

명령 저장소를 사용하면 커스텀 명령을 몇 개든 등록하여 yarn 스크립트에서 사용할 수 있게 만들 수 있습니다.
이런 명령은 yarn 스크립트를 파싱하기 전에 등록해야 하며, 그렇지 않으면 컴파일러가 명령을 인식할 수
없다는 오류를 발생시킵니다.

함수를 yarn 명령으로 등록하려면 함수가 다음 요구 사항을 충족해야 합니다.

- 함수의 반환값은 `void` 또는 `Future<void>`여야 합니다. 함수가 future를 반환하면 대화의 다음 단계로
  넘어가기 전에 그 future를 await 합니다. 이를 통해 `<<walk>>`, `<<moveCamera>>`, `<<prompt>>`처럼
  게임에서 펼쳐지는 데 일정 시간이 걸리는 명령을 만들 수 있습니다.
- 함수의 인자는 Yarn이 알고 있는 타입(`String`, `num`, `int`, `double`, `bool`)이어야 합니다.
  모든 인자는 위치 인자여야 하고, null을 허용하지 않아야 하며, 기본값을 가질 수 없습니다.
- 함수를 등록하려면 함수 인자의 개수에 따라 `addCommand0()` ... `addCommand5()` 메서드를 사용합니다.
- 함수 시그니처의 끝에 불리언이 1개 이상 있으면, 그 인자들은 선택 사항으로 간주되며 기본값은
  `false`가 됩니다.


<a id="methods"></a>

## 메서드

**hasCommand**(`String name`) → `bool`
: 명령 `name`이 저장소에 추가되었는지 여부를 반환합니다.

**addCommand0**(`String name`, `FutureOr<void> Function() fn`)
: 인자가 없는 함수 `fn`을 명령 `name`으로 등록합니다.

**addCommand1**(`String name`, `FutureOr<void> Function(T1) fn`)
: 인자가 하나인 함수 `fn`을 명령 `name`으로 등록합니다.

**addCommand2**(`String name`, `FutureOr<void> Function(T1, T2) fn`)
: 인자가 두 개인 함수 `fn`을 명령 `name`으로 등록합니다.

**addCommand3**(`String name`, `FutureOr<void> Function(T1, T2, T3) fn`)
: 인자가 세 개인 함수 `fn`을 명령 `name`으로 등록합니다.

**addCommand4**(`String name`, `FutureOr<void> Function(T1, T2, T3, T4) fn`)
: 인자가 네 개인 함수 `fn`을 명령 `name`으로 등록합니다.

**addCommand5**(`String name`, `FutureOr<void> Function(T1, T2, T3, T4, T5) fn`)
: 인자가 다섯 개인 함수 `fn`을 명령 `name`으로 등록합니다.

**addOrphanedCommand**(`name`)
: 어떤 Dart 함수에도 연결되지 않은 명령 `name`을 등록합니다. 이런 명령도 `onCommand()` 콜백을 통해
  [DialogueView]에 전달되지만, 인자는 파싱되지 않습니다.

**clear**
: 모든 사용자 정의 명령을 제거합니다.

**remove**(`String name`)
: 지정한 `name`의 사용자 정의 명령을 제거합니다.


<a id="properties"></a>

## 속성

**length** → `int`
: 지금까지 등록된 사용자 정의 명령의 개수입니다.

**isEmpty** → `bool`
: 등록된 사용자 정의 명령이 없으면 `true`를 반환합니다.

**isNotEmpty** → `bool`
: 등록된 명령이 하나라도 있으면 `true`를 반환합니다.


<a id="examples"></a>

## 예제


### `<<StartQuest>>`

퀘스트를 시작하는 yarn 명령 `<<StartQuest>>`를 만들고 싶다고 해 보겠습니다. 이 명령은 퀘스트 이름과
퀘스트 ID를 인자로 받습니다. 기술적으로는 ID만으로 충분하지만, 그러면 yarn 스크립트를 읽고 어떤 퀘스트가
시작되는지 이해하기가 정말 어려워집니다. 그래서 ID와 이름을 모두 전달하고, 런타임에 퀘스트의 ID가
이름과 일치하는지 확인하겠습니다.

이 명령의 일반적인 호출은 다음과 같은 모양입니다(퀘스트 이름이 따옴표 안에 있다는 점에 유의하세요.
그렇지 않으면 `"Get"`, `"rid"`, `"of"`, `"bandits"`라는 네 개의 인자로 파싱됩니다).
```yarn
<<StartQuest Q037 "Get rid of bandits">>
```

이 명령을 구현하기 위해 문자열 인자 두 개를 받는 Dart 함수 `startQuest()`를 만듭니다. 이 함수는 짧은
"퀘스트 X 시작" 애니메이션 메시지를 표시하지만, 게임 대화가 그 메시지를 기다리게 하고 싶지는 않으므로
함수가 future가 아닌 `void`를 반환하게 합니다. 마지막으로 `commands.addCommand2()`로 명령을 등록합니다.

```dart
class MyGame {
  late YarnProject yarnProject;

  void startQuest(String questId, String questName) {
    assert(quests.containsKey(questId));
    assert(quests[questId]!.name == questName);
    // ...
  }
  @override
  void onLoad() {
    yarnProject = YarnProject()
      ..commands.addCommand2('StartQuest', startQuest);
  }
}
```

Dart 함수의 이름이 명령의 이름과 다르다는 점에 주목하세요. 자신의 프로그래밍 스타일에 가장 잘 맞는
이름을 자유롭게 고를 수 있습니다.


### `<<prompt>>`

`<<prompt>>` 함수는 모달 대화 상자를 열어 사용자에게 응답을 입력하도록 요청합니다. 이 명령은 사용자의
입력을 기다려야 하므로 future를 반환해야 합니다. 또한 프롬프트의 결과를 대화로 돌려주고 싶지만,
안타깝게도 명령은 표현식이 아니며 값을 반환하도록 만들어지지 않았습니다. 그래서 대신 결과를 전역 변수
`$prompt`에 기록하고, 대화에서 그 변수에 접근해 프롬프트의 결과를 읽을 수 있게 하겠습니다.

```dart
class MyGame {
  final YarnProject yarnProject = YarnProject();

  Future<void> prompt(String message) async {
    // 모달 대화 상자가 라우터 스택에서 pop 될 때까지 기다립니다
    final name = await router.pushAndWait(KeyboardDialog(message));
    yarnProject.variables.setVariable(r'$prompt', name);
  }

  @override
  void onLoad() {
    yarnProject
      ..variables.setVariable(r'$prompt', '')
      ..commands.addCommand1('prompt', prompt);
  }
}
```

그러면 yarn 스크립트에서 이 명령을 다음과 같이 사용할 수 있습니다.
```yarn
<<declare $name as String>>

title: Greeting
---
Guide: Hello, my name is Jenny, and you?
<<prompt "Enter your name:">>
<<set $player = $prompt>>  // Store the name for later
Guide: Nice to meet you, {$player}
===
```


### `<<give>>`

플레이어에게 특정 아이템 하나 또는 여러 개를 주는 명령을 만들고 싶다고 해 보겠습니다. 이 명령은 아이템을
주는 사람, 아이템 이름, 수량의 3개 인자를 받습니다. 예를 들면 다음과 같습니다.
```yarn
<<give {$quest_reward} TraderJoe>>
```

퀘스트 보상 변수에는 보상 아이템과 그 수량이 모두 들어 있다는 점에 유의하세요. 예를 들어 `"100 gold"`,
`"5 potion_of_healing"`, `'1 "Sword of Darkness"'` 같은 값일 수 있습니다. 런타임에 이런 변수가 명령에
대입되면 명령은 다음과 같아집니다.
```yarn
<<give 100 gold TraderJoe>>
<<give 5 potion_of_healing TraderJoe>>
<<give 1 "Sword of Darkness" TraderJoe>>
```

그러면 이 명령은 다음 Dart 함수에 대응하는 일반적인 3개 인자 명령으로 파싱됩니다.

```dart
/// [source]에게서 [item]을 [amount]개 가져와 플레이어에게 줍니다.
void give(int amount, String item, String source) {
  // ...
}
```


<a id="see-also"></a>

## 함께 보기

- YarnSpinner 언어의 [사용자 정의 명령][user-defined commands]에 대한 설명.
- 커스텀 명령이 실행되고 있음을 [DialogueView]에 알리는 데 사용되는 [UserDefinedCommand] 클래스.


[DialogueView]: dialogue_view.md
[UserDefinedCommand]: user_defined_command.md
[YarnProject]: yarn_project.md
[user-defined commands]: ../language/commands/user_defined_commands.md
