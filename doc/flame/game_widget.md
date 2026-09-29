<a id="game-widget"></a>

# Game 위젯

`GameWidget`은 Flutter와 Flame을 잇는 다리입니다. Flame 게임은 그 자체로는 Flutter 위젯이 아니므로,
`GameWidget`이 `Game` 인스턴스를 감싸서 다른 [위젯](https://docs.flutter.dev/get-started/fundamentals/widgets)과
똑같이 Flutter 위젯 트리에 배치합니다. 덕분에 전체 화면 게임을 Flutter UI 요소(내비게이션 바, 오버레이,
다이얼로그)와 함께 쓰거나, 게임을 앱 레이아웃의 일부로만 임베드할 수 있습니다.

```{dartdoc}
:package: flame
:symbol: GameWidget
:file: src/game/game_widget/game_widget.dart

[ClipRect]: https://api.flutter.dev/flutter/widgets/ClipRect-class.html
[FocusNode]: https://api.flutter.dev/flutter/widgets/FocusNode-class.html
[RepaintBoundary]: https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html
```


<a id="hit-test-behavior"></a>

## 히트 테스트 동작

`behavior` 인자는 `GameWidget`이 Flutter의 히트 테스트에 어떻게 참여할지를 제어합니다. 이를 통해
포인터 이벤트(탭, 드래그 등)를 게임이 흡수할지, 아니면 위젯 트리에서 게임 아래에 있는 위젯으로
통과시킬지가 결정됩니다.

Flutter의 `HitTestBehavior`에는 세 가지 값이 있습니다:

- **`HitTestBehavior.opaque`** (기본값): 게임이 자신의 전체 영역에서 모든 포인터 이벤트를 흡수하여,
  뒤에 있는 위젯이 이벤트를 받지 못하게 합니다. 게임이 불투명한 레이어처럼 동작하는 전통적인
  방식입니다.

- **`HitTestBehavior.deferToChild`**: `containsEventHandlerAt`을 호출해 위치마다 해당 이벤트가 게임의
  것인지를 게임에 묻습니다. 게임이 거절한 이벤트는 `GameWidget` 뒤의 위젯으로 전달됩니다. Flutter UI
  위에 게임을 겹쳐 놓고, 게임이 처리할 필요가 없는 영역에서는 아래 위젯이 계속 상호작용할 수 있게
  하고 싶을 때 유용합니다. 기본 응답은 "전부"이므로 아래의
  [게임이 흡수할 이벤트 결정하기](#게임이-흡수할-이벤트-결정하기)를 참고하세요.

- **`HitTestBehavior.translucent`**: 게임이 전체 영역에서 이벤트를 흡수하면서, 뒤에 있는 위젯도
  히트 테스트를 받으므로 둘 다 같은 이벤트를 받을 수 있습니다.


<a id="allowing-taps-to-pass-through"></a>

### 탭 통과시키기

흔한 사용 사례는 `Stack` 안에서 다른 Flutter 위젯 위에 `GameWidget`을 올려놓는 것입니다. 기본적으로
게임은 아래에 있는 위젯과의 모든 상호작용을 막습니다. 탭이 그 위젯들에 전달되게 하려면 `behavior`를
`HitTestBehavior.deferToChild`로 설정합니다:

```dart
Widget build(BuildContext context) {
  return Stack(
    children: [
      // 아래에 놓인 Flutter 위젯
      Center(
        child: ElevatedButton(
          onPressed: () => print('Button tapped!'),
          child: const Text('Tap me'),
        ),
      ),
      // 위에 놓인 게임, 탭을 통과시킴
      Positioned.fill(
        child: GameWidget(
          game: MyGame(),
          behavior: HitTestBehavior.deferToChild,
        ),
      ),
    ],
  );
}
```

이것만으로는 충분하지 않습니다. `deferToChild`는 어떤 위치가 게임의 것인지 게임에 묻는데, 게임은
따로 지정하지 않으면 "전부"라고 답합니다. 컴포넌트를 기준으로 답하도록 `DeferHitTestToComponents`
믹스인을 추가합니다:

```dart
class MyGame extends FlameGame with DeferHitTestToComponents {}
```

두 가지를 모두 적용하면, 상호작용하는 게임 컴포넌트가 없는 영역을 탭했을 때는 게임 뒤의
`ElevatedButton`에 전달되고, `TapCallbacks`를 사용하는 컴포넌트를 탭했을 때는 게임이 처리합니다.


<a id="deciding-what-the-game-absorbs"></a>

### 게임이 흡수할 이벤트 결정하기

`containsEventHandlerAt`은 하나의 위치에 대해 게임이 그 이벤트를 원하는지를 답합니다. 이 메서드는
`deferToChild`일 때만 참조되며, `opaque`와 `translucent`는 묻지 않고 결정합니다.

기본적으로 모든 곳에서 `true`를 반환하므로, 직접 해제하기 전까지 게임은 불투명합니다. 이를 바꾸는
방법은 두 가지입니다:

- `DeferHitTestToComponents` 믹스인을 추가합니다. 이 믹스인은 해당 지점의 컴포넌트들을 순회하여
  그중 하나라도 `PointerInputCallbacks`를 구현하면(모든 위치 기반 콜백 믹스인이 구현합니다)
  히트로 보고합니다.
- 또는 `containsEventHandlerAt`을 오버라이드하여 고정된 사각형 같은 자신만의 규칙을 적용합니다.
  이렇게 하면 믹스인이 이벤트마다 치르는 트리 순회 비용을 피할 수 있습니다.

`TapCallbacks` 같은 믹스인을 직접 섞어 포인터 이벤트를 스스로 처리하는 `FlameGame`은 전체 영역에서
상호작용한다는 점에 유의하세요. 이 경우 믹스인이 위임할 대상이 없으므로 assert가 발생합니다.
