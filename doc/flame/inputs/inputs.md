<a id="inputs"></a>

# 입력

게임은 본질적으로 상호작용하는 것이므로 플레이어 입력 처리는 필수입니다. Flame은 Flutter가 지원하는
모든 플랫폼에서 동작하는 입력 처리를 제공합니다. 모바일에서는 터치, 데스크톱에서는 마우스와 키보드,
웹에서는 포인터 이벤트를 다룹니다. 이 API들은 컴포넌트에 추가하는 믹스인으로 설계되어 있어서,
각 컴포넌트가 어떤 입력 이벤트에 관심을 가질지 독립적으로 결정할 수 있습니다. 이는
Flutter의 [GestureDetector](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)가
동작하는 방식과 비슷하지만, Flame의 컴포넌트 트리에 맞게 조정되어 있습니다.

`FlameGame` 자체도 `Component`이므로, 이 믹스인 중 하나를 게임 클래스에 추가하는 것은 컴포넌트에
추가하는 것과 똑같이 동작합니다. 래퍼 컴포넌트는 필요하지 않습니다.

- [탭 이벤트](tap_events.md): `TapCallbacks`, `SecondaryTapCallbacks`, `TertiaryTapCallbacks`,
  `DoubleTapCallbacks`
- [드래그 이벤트](drag_events.md): `DragCallbacks`
- [스케일 이벤트](scale_events.md): `ScaleCallbacks`
- [롱 프레스 이벤트](long_press_events.md): `LongPressCallbacks`
- [포인터 이벤트](pointer_events.md): `MouseMoveCallbacks`, `HoverCallbacks`, `ScrollCallbacks`
- [키보드 입력](keyboard_input.md): 키 입력용
- [Hardware Keyboard Detector](hardware_keyboard_detector.md)
- [기타 입력과 헬퍼](other_inputs.md): 조이스틱, 게임패드 등

내부적으로 이들은 모두 Flutter 자체의 제스처 위젯을 기반으로 만들어져 있습니다. 여기에는
[GestureDetector 위젯](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector 위젯](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html),
[MouseRegion 위젯](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html)이 포함됩니다.
[Flutter의 제스처 시스템](https://api.flutter.dev/flutter/gestures/gestures-library.html)에 대해서도
더 읽어볼 수 있습니다.


<a id="event-coordinate-system"></a>

## 이벤트 좌표계

위치를 담고 있는 모든 이벤트는 그 위치를 세 가지 좌표계로 알려줍니다.

- `devicePosition`: 전체 화면을 기준으로 하며, Flutter 네이티브 이벤트의 `globalPosition`과
  같습니다.
- `canvasPosition`: `GameWidget`의 위치와 크기를 기준으로 하며, Flutter 네이티브 이벤트의
  `localPosition`과 같습니다. 이것이 Flame의 "전역" 위치입니다.
- `localPosition`: 현재 이벤트를 받고 있는 컴포넌트를 기준으로 하며, 부모 변환 체인 전체(카메라
  포함)가 이미 적용되어 있습니다.

`DragUpdateEvent`처럼 움직임을 나타내는 이벤트는 추가로 시작 위치와 끝 위치
(`canvasStartPosition` / `canvasEndPosition` 등)와 그에 대응하는 델타인
`deviceDelta`, `canvasDelta`, `localDelta`를 제공합니다.

`localPosition`과 `localDelta`는 현재 이벤트를 받고 있는 컴포넌트를 기준으로 하므로, 콜백 안에서만
읽어야 합니다. 이벤트를 보관해 두었다가 나중에 읽지 마세요. 전달이 끝나면 더 이상 값이 유지되지
않으며, 이벤트에 따라 남아 있던 값을 얻거나 오류가 발생합니다. 나중에 위치가 필요하다면 콜백 중에
`event.localPosition.clone()`으로 복사해 두세요.

콜백을 `FlameGame`에 직접 믹스인하면 게임이 곧 그 컴포넌트가 됩니다. 게임에는 자체 변환이 없으므로,
그곳에서의 로컬 값은 캔버스 좌표와 같습니다.


## GestureHitboxes

위치를 담은 이벤트를 다루는 모든 믹스인은 `PointerInputCallbacks`를 구현하며(탭, 드래그, 스케일,
롱 프레스, 포인터 이벤트 - 키보드 관련은 제외), 이들은 모두 컴포넌트의 `containsLocalPoint()`에
물어서 이벤트가 그 컴포넌트에 속하는지 결정합니다. `PositionComponent`의 경우 이는 직사각형
경계입니다.

`GestureHitboxes` 믹스인은 `Component` 위의 입력을 더 정확하게 인식하는 데 사용됩니다.
예를 들어 둥근 바위를 `SpriteComponent`로 가지고 있다면, 바위가 표시되지 않는 이미지 모서리의
입력은 등록하고 싶지 않을 것입니다. 이럴 때 `GestureHitboxes` 믹스인을 사용하면 이벤트가
컴포넌트로 전파될 때 확인할 더 정확한 경계(원, 다각형, 어떤 도형이든)를 정의할 수 있습니다.

`GestureHitboxes` 믹스인을 가진 컴포넌트에는 `Collidable` 예제에서 추가하는 것과 똑같은 방식으로
새 히트박스를 추가할 수 있습니다.

히트박스를 정의하는 방법에 대한 자세한 내용은
[충돌 감지](../collision_detection.md#shapehitbox) 문서의 히트박스 섹션에서 확인할 수 있습니다.

사용 예시는
[gesture hitboxes 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/gesture_hitboxes_example.dart)에서
볼 수 있습니다.

```{toctree}
:hidden:

탭 이벤트                <tap_events.md>
드래그 이벤트               <drag_events.md>
스케일 이벤트              <scale_events.md>
롱 프레스 이벤트         <long_press_events.md>
포인터 이벤트            <pointer_events.md>
키보드 입력            <keyboard_input.md>
HardwareKeyboardDetector  <hardware_keyboard_detector.md>
기타 입력              <other_inputs.md>
```
