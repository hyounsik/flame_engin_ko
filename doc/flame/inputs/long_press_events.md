<a id="long-press-events"></a>

# 롱 프레스 이벤트

**롱 프레스 이벤트**는 사용자가 컴포넌트 위에서 포인터(손가락 또는 마우스)를 일정 시간 동안 누르고
있을 때 발생합니다. 이 제스처는 흔히 컨텍스트 메뉴, 드래그로 이동하는 동작, 또는 의도적으로
오래 터치해야 하는 모든 동작에 사용됩니다.

롱 프레스 이벤트에 반응해야 하는 컴포넌트에는 `LongPressCallbacks` 믹스인을 추가합니다.

- 이 믹스인은 컴포넌트에 오버라이드 가능한 메서드 네 개를 추가합니다: `onLongPressStart`,
  `onLongPressMoveUpdate`, `onLongPressEnd`, `onLongPressCancel`.
- 기본적으로 `isLongPressing`이 자동으로 추적되며, 컴포넌트에서 접근할 수 있습니다.
- 컴포넌트는 `containsLocalPoint()`를 구현해야 합니다(`PositionComponent`에 이미 구현되어 있으므로
  대부분의 경우 여기서 따로 할 일은 없습니다). 이 메서드를 통해 Flame은 이벤트가 컴포넌트 안에서
  발생했는지 여부를 알 수 있습니다. 위치와 관계없이 모든 롱 프레스 이벤트를 받으려면 이 메서드가
  `true`를 반환하도록 오버라이드할 수 있습니다.

```dart
class MyComponent extends PositionComponent with LongPressCallbacks {
  MyComponent() : super(size: Vector2.all(32));

  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event); // isLongPressing의 내부 갱신을 처리합니다
    // 롱 프레스가 인식되었을 때 무언가를 수행합니다
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event); // isLongPressing의 내부 갱신을 처리합니다
    // 롱 프레스가 끝났을 때 무언가를 수행합니다
  }
}
```


<a id="long-press-anatomy"></a>

## 롱 프레스의 구조


### onLongPressStart

롱 프레스 시퀀스의 첫 번째 이벤트입니다. 포인터를 롱 프레스로 인식될 만큼 오래 누르고 있으면
한 번 발생합니다. 기본적으로 Flutter의 `LongPressGestureRecognizer`는 `kLongPressTimeout`(500ms)을
롱 프레스의 기준으로 사용합니다.

`LongPressStartEvent`는 접촉 지점의 위치를 여러 좌표계로 제공합니다: `devicePosition`(기기 좌표),
`canvasPosition`(게임 위젯 좌표), `localPosition`(컴포넌트 로컬 좌표).

`onLongPressStart`를 받은 컴포넌트는 나중에 `onLongPressEnd`(성공 시) 또는
`onLongPressCancel`(취소 시) 중 하나를 받게 됩니다. 그 사이에 이동 업데이트가 전달될 수도 있습니다.

`super.onLongPressStart(event)`를 호출하면 `isLongPressing`이 `true`로 설정됩니다.


### onLongPressMoveUpdate

롱 프레스가 진행 중인 동안 사용자가 손가락을 움직이면 계속해서 발생합니다. 이 이벤트는 처음에
`onLongPressStart`를 받은 컴포넌트에만 전달됩니다.

`LongPressMoveUpdateEvent`는 `DisplacementEvent`이며, `DragUpdateEvent`와 마찬가지로 프레임 간
델타를 제공합니다. 즉 `localDelta`를 사용해 컴포넌트가 포인터를 따라 움직이게 할 수 있습니다(카메라
줌과 컴포넌트 변환이 올바르게 반영됩니다).
이 이벤트에는 제스처가 시작된 이후의 전체 변위를 나타내는 `offsetFromOrigin`도 담겨 있습니다.


### onLongPressEnd

롱 프레스 후 사용자가 포인터를 뗄 때 발생합니다. `LongPressEndEvent`에는 최종 위치와 포인터를
뗀 순간의 `velocity`가 포함됩니다.

`super.onLongPressEnd(event)`를 호출하면 `isLongPressing`이 `false`로 설정됩니다.


### onLongPressCancel

제스처가 완료되기 전에 중단되면(예: 경쟁하는 제스처 인식기에 의해) 발생합니다.

`super.onLongPressCancel(event)`를 호출하면 `isLongPressing`이 `false`로 설정됩니다.


<a id="mixins"></a>

## 믹스인


### LongPressCallbacks

`LongPressCallbacks` 믹스인은 어떤 `Component`에든 추가할 수 있으며, 추가하면 그 컴포넌트가 롱
프레스 이벤트를 받기 시작합니다.

이 믹스인은 컴포넌트에 `onLongPressStart`, `onLongPressMoveUpdate`, `onLongPressEnd`,
`onLongPressCancel` 메서드를 추가합니다. 이 메서드들을 오버라이드하여 동작을 구현하세요.

컴포넌트는 `containsLocalPoint()` 함수로 판단했을 때 그 컴포넌트 *안에서* 시작된 롱 프레스
이벤트만 받습니다. 흔히 사용하는 `PositionComponent` 클래스는 `size` 속성을 기반으로 이 구현을
제공합니다.

이 믹스인은 또한 현재 컴포넌트에서 롱 프레스 제스처가 진행 중인지를 추적하는 `isLongPressing`
속성을 제공합니다. 이 값은 `onLongPressStart`, `onLongPressEnd`, `onLongPressCancel`에서 `super`를
호출하면 자동으로 관리됩니다.

```dart
class LongPressSquare extends RectangleComponent with LongPressCallbacks {
  @override
  void onLongPressStart(LongPressStartEvent event) {
    super.onLongPressStart(event);
    paint.color = Colors.red;
  }

  @override
  void onLongPressMoveUpdate(LongPressMoveUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onLongPressEnd(LongPressEndEvent event) {
    super.onLongPressEnd(event);
    paint.color = Colors.blue;
  }
}
```
