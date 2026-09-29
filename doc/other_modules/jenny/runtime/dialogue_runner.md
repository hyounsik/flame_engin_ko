# DialogueRunner
```{dartdoc}
:file: src/dialogue_runner.dart
:symbol: DialogueRunner
:package: jenny
```


<a id="execution-model"></a>

## 실행 모델

`DialogueRunner`는 대화 진행 타이밍을 제어하는 주요 메커니즘으로 future를 사용합니다. 각 이벤트마다
대화 러너는 모든 [DialogueView]의 해당 콜백을 호출하며, 각 콜백은 future를 반환할 수 있습니다. 그런 다음
대화 러너는 다음 이벤트로 넘어가기 전에 이 모든 future를 (병렬로) await 합니다.

다음과 같은 간단한 `.yarn` 스크립트가 있다면
```yarn
title: main
---
Hello
-> Hi
-> Go away
   <<jump Away>>
===

title: Away
---
<<OhNo>>
===
```

발생하는 이벤트의 순서는 다음과 같습니다(두 번째 옵션을 선택했다고 가정합니다).

- `onDialogueStart()`
- `onNodeStart(Node("main"))`
- `onLineStart(Line("Hello"))`
- `onLineFinish(Line("Hello"))`
- `onChoiceStart(Choice(["Hi", "Go away"]))`
- `onChoiceFinish(Option("Go away"))`
- `onNodeFinish(Node("main"))`
- `onNodeStart(Node("Away"))`
- `onCommand(Command("OhNo"))`
- `onNodeFinish(Node("Away"))`
- `onDialogueFinish()`

:::{note}
대화를 실행하는 도중 `DialogueError`가 발생하면 대화는 즉시 종료되며, `*Finish` 콜백은 하나도 실행되지
않는다는 점을 기억하세요.
:::


[DialogueView]: dialogue_view.md
