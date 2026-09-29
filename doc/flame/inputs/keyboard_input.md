<a id="keyboard-input"></a>

# 키보드 입력

이 문서는 키보드 입력에 대해 설명합니다.


<a id="intro"></a>

## 소개

Flame의 키보드 API는
[Flutter의 Focus 위젯](https://api.flutter.dev/flutter/widgets/Focus-class.html)을 기반으로 합니다.

포커스 동작을 커스터마이즈하려면 [포커스 제어하기](#포커스-제어하기)를 참고하세요.

게임이 키 입력에 반응하는 방법은 두 가지로, 게임 수준과 컴포넌트 수준이 있습니다.
각각에 대해 `Game` 또는 `Component` 클래스에 추가할 수 있는 믹스인이 있습니다.


<a id="receive-keyboard-events-in-a-game-level"></a>

### 게임 수준에서 키보드 이벤트 받기

`Game` 서브클래스가 키 입력에 반응하게 하려면 `KeyboardEvents`를 믹스인하세요.

그러면 `onKeyEvent` 메서드를 오버라이드할 수 있게 됩니다.

이 메서드는 두 개의 파라미터를 받습니다. 첫 번째는 애초에 콜백을 발생시킨
[`KeyEvent`](https://api.flutter.dev/flutter/services/KeyEvent-class.html)입니다. 두 번째는 현재
눌려 있는
[`LogicalKeyboardKey`](https://api.flutter.dev/flutter/services/LogicalKeyboardKey-class.html)의
집합입니다.

반환값은
[`KeyEventResult`](https://api.flutter.dev/flutter/widgets/KeyEventResult.html)입니다.

`KeyEventResult.handled`는 프레임워크에 키 입력이 Flame 안에서 처리되었음을 알리고,
`GameWidget` 외의 다른 키보드 핸들러 위젯을 모두 건너뛰게 합니다.

`KeyEventResult.ignored`는 프레임워크에 `GameWidget` 외의 다른 키보드 핸들러 위젯에서 이 이벤트를
계속 검사하도록 알립니다. 어떤 핸들러도 이벤트를 처리하지 않으면 프레임워크는
`SystemSoundType.alert`를 발생시킵니다.

`KeyEventResult.skipRemainingHandlers`는 `.ignored`와 매우 비슷하지만, 다른 핸들러 위젯을 모두
건너뛰고 곧바로 알림음을 재생한다는 점이 다릅니다.

최소 예제:

```dart
class MyGame extends FlameGame with KeyboardEvents {
  // ...
  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isKeyDown = event is KeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      if (keysPressed.contains(LogicalKeyboardKey.altLeft) ||
          keysPressed.contains(LogicalKeyboardKey.altRight)) {
        this.shootHarder();
      } else {
        this.shoot();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
```


<a id="receive-keyboard-events-in-a-component-level"></a>

### 컴포넌트 수준에서 키보드 이벤트 받기

컴포넌트에서 직접 키보드 이벤트를 받으려면 `KeyboardHandler` 믹스인을 사용합니다.

`TapCallbacks`나 `DragCallbacks`와 마찬가지로, `KeyboardHandler`는 `Component`의 어떤 서브클래스에든
믹스인할 수 있습니다.

KeyboardHandler는 `HasKeyboardHandlerComponents`가 믹스인된 게임에만 추가해야 합니다.

> ⚠️ 참고: `HasKeyboardHandlerComponents`를 사용한다면, 충돌을 피하기 위해 게임의 믹스인 목록에서
> `KeyboardEvents`를 제거해야 합니다.

`KeyboardHandler`를 적용하면 `onKeyEvent` 메서드를 오버라이드할 수 있게 됩니다.

이 메서드는 두 개의 파라미터를 받습니다. 첫 번째는 애초에 콜백을 발생시킨
[`KeyEvent`](https://api.flutter.dev/flutter/services/KeyEvent-class.html)입니다. 두 번째는 현재
눌려 있는
[`LogicalKeyboardKey`](https://api.flutter.dev/flutter/services/LogicalKeyboardKey-class.html)들의
집합입니다.

키 이벤트가 다른 컴포넌트들 사이에서 계속 전파되도록 하려면 `true`를 반환해야 합니다. 다른
컴포넌트가 이벤트를 받지 못하게 하려면 `false`를 반환하세요.

Flame은 키보드 이벤트를 처리하는 데 사용할 수 있는 `KeyboardListenerComponent`라는 기본 구현도
제공합니다. 다른 컴포넌트와 마찬가지로 `FlameGame`이나 다른 `Component`에 자식으로 추가할 수
있습니다.

예를 들어 X축과 Y축으로 이동하는 메서드를 가진 `PositionComponent`가 있다고 해 봅시다. 다음
코드를 사용하면 그 메서드들을 키 이벤트에 연결할 수 있습니다.

```dart
add(
  KeyboardListenerComponent(
    keyUp: {
      LogicalKeyboardKey.keyA: (keysPressed) { ... },
      LogicalKeyboardKey.keyD: (keysPressed) { ... },
      LogicalKeyboardKey.keyW: (keysPressed) { ... },
      LogicalKeyboardKey.keyS: (keysPressed) { ... },
    },
    keyDown: {
      LogicalKeyboardKey.keyA: (keysPressed) { ... },
      LogicalKeyboardKey.keyD: (keysPressed) { ... },
      LogicalKeyboardKey.keyW: (keysPressed) { ... },
      LogicalKeyboardKey.keyS: (keysPressed) { ... },
    },
  ),
);
```


<a id="controlling-focus"></a>

### 포커스 제어하기

위젯 수준에서는
[`FocusNode`](https://api.flutter.dev/flutter/widgets/FocusNode-class.html) API를 사용해 게임에
포커스가 있는지 여부를 제어할 수 있습니다.

`GameWidget`에는 선택적인 `focusNode` 파라미터가 있어 외부에서 포커스를 제어할 수 있습니다.

기본적으로 `GameWidget`의 `autofocus`는 true로 설정되어 있어, 마운트되면 포커스를 받습니다. 이
동작을 바꾸려면 `autofocus`를 false로 설정하세요.

더 완전한 예제는
[키보드 입력 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/keyboard_example.dart)를
참고하세요.
