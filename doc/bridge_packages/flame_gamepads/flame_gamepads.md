# flame_gamepads

**flame_gamepads**는 Flame 게임에서 `gamepads` 패키지를 사용하기 위한 브릿지 기능을
제공합니다.


<a id="gamepadcallbacks-mixin"></a>

## GamepadCallbacks 믹스인

`with` 키워드로 컴포넌트에 `GamepadCallbacks` 믹스인을 추가하고 `onGamepadEvent` 메서드를
오버라이드하면 게임패드 이벤트가 발생할 때 콜백을 받을 수 있습니다.

```dart
class PlayerComponent extends PositionComponent with GamepadCallbacks {
  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.button == GamepadButton.a && event.value != 0) {
        // 'a' 버튼이 눌렸습니다.
    }
  }
}
```

API 사용 예제는
[여기](https://github.com/flame-engine/flame/tree/main/packages/flame_gamepads/example)에서 찾을 수 있습니다.

NormalizedGamepadEvent 데이터를 처리하는 방법에 대한 자세한 내용은
[gamepads](https://github.com/flame-engine/gamepads.dart) 라이브러리를 참고하세요.
