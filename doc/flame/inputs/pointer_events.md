<a id="pointer-events"></a>

# 포인터 이벤트

**포인터 이벤트**는 Flutter에서 일반화된 "마우스 움직임" 유형의 이벤트입니다(데스크톱 또는 웹용).

컴포넌트나 게임에서 마우스 움직임 이벤트와 상호작용하고 싶다면 `MouseMoveCallbacks` 믹스인을
사용할 수 있습니다.

예시:

```dart
class MyComponent extends PositionComponent with MouseMoveCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onMouseMove(MouseMoveEvent event) {
    // 마우스 움직임에 반응하여 무언가를 수행합니다(예: 좌표 갱신)
  }
}
```

이 믹스인은 컴포넌트에 오버라이드 가능한 메서드 두 개를 추가합니다.

- `onMouseMove`: 컴포넌트 안에서 마우스가 움직일 때 호출됩니다
- `onMouseMoveStop`: 컴포넌트 위에 마우스가 올라가 있다가 벗어날 때 한 번 호출됩니다

기본적으로 이 메서드들은 아무 일도 하지 않으므로, 어떤 기능을 수행하려면 오버라이드해야 합니다.

또한 컴포넌트는 `containsLocalPoint()` 메서드를 구현해야 합니다(`PositionComponent`에 이미 구현되어
있으므로 대부분의 경우 여기서 따로 할 일은 없습니다). 이 메서드를 통해 Flame은 이벤트가 컴포넌트
안에서 발생했는지 여부를 알 수 있습니다.

컴포넌트 안에서 발생한 마우스 이벤트만 전달된다는 점에 유의하세요. 다만 `onMouseMoveStop`은
마우스가 컴포넌트를 벗어나는 첫 번째 움직임에서 한 번 호출되므로, 벗어날 때의 처리는 그곳에서
할 수 있습니다.


## HoverCallbacks

컴포넌트 위에 마우스가 올라가 있는지(hover) 여부를 구체적으로 알고 싶거나, hover 진입 및 이탈
이벤트에 연결하고 싶다면 더 전용 믹스인인 `HoverCallbacks`를 사용할 수 있습니다.

예시:

```dart
class MyComponent extends PositionComponent with HoverCallbacks {

  MyComponent() : super(size: Vector2(80, 60));

  @override
  void update(double dt) {
    // `isHovered`를 사용해 컴포넌트 위에 마우스가 올라가 있는지 알 수 있습니다
  }

  @override
  void onHoverEnter() {
    // 마우스가 컴포넌트에 들어올 때 무언가를 수행합니다
  }

  @override
  void onHoverExit() {
    // 마우스가 컴포넌트를 벗어날 때 무언가를 수행합니다
  }
}
```

추가 기능을 위해 여전히 "raw" onMouseMove 메서드를 수신할 수 있습니다. 다만 `HoverCallbacks`
동작이 활성화되도록 `super` 버전을 반드시 호출하세요.


<a id="hover-demo"></a>

### Hover 데모

아래 데모를 조작해 보며 포인터 hover 이벤트가 동작하는 모습을 확인해 보세요.

```{flutter-app}
:sources: ../flame/examples
:page: pointer_events
:show: widget code
```


## ScrollCallbacks

마우스 휠이나 트랙패드 스크롤 이벤트를 처리하려면 `ScrollCallbacks` 믹스인을 사용하세요.

```dart
class ScrollableSquare extends RectangleComponent with ScrollCallbacks {
  @override
  void onScroll(ScrollEvent event) {
    final factor = switch (event.scrollDelta.y.sign) {
      1 => 0.9,
      -1 => 1.1,
      _ => 1.0, // 가로 방향으로만 스크롤하는 경우는 무시합니다
    };
    scale.scale(factor);
    scale.clampScalar(0.3, 5.0);
    event.continuePropagation = false;
  }
}
```

이 믹스인은 오버라이드 가능한 메서드 하나를 추가합니다.

- `onScroll`: 스크롤 이벤트가 컴포넌트에 닿을 때 호출됩니다.

`ScrollEvent`는 다음을 제공합니다.

- `scrollDelta`: 스크롤 오프셋을 담은 `Vector2`(보통 `scrollDelta.y`만 있으면 됩니다).
- `canvasPosition` / `localPosition`: 캔버스 좌표와 로컬 좌표에서의 포인터 위치.
- `continuePropagation`: `false`로 설정하면 이벤트가 히트 테스트 목록에서 더 아래에 있는
  컴포넌트(또는 게임 자체)에 도달하지 않습니다.

스크롤 이벤트는 `continuePropagation = false`로 설정하여 더 이상 전파되지 않게 막지 않는 한,
포인터 아래에 있는 (가장 위쪽 컴포넌트만이 아니라) **모든** 컴포넌트에 전달됩니다.

`ScrollCallbacks`를 `FlameGame`에 직접 믹스인하여 게임 화면 어디에서든 스크롤을 처리할 수도
있습니다.


<a id="scroll-demo"></a>

### 스크롤 데모

```{flutter-app}
:sources: ../flame/examples
:page: scroll
:show: widget code
```


<a id="mouse-cursor"></a>

## 마우스 커서

`GameWidget` 영역에 표시되는 현재 마우스 커서를 변경할 수도 있습니다. 이를 위해 `Game` 클래스
안에서 다음 코드를 사용할 수 있습니다.

```dart
mouseCursor.value = SystemMouseCursors.move;
```

`GameWidget`을 처음부터 커스텀 커서로 초기화하려면 `mouseCursor` 속성을 사용할 수 있습니다.

```dart
GameWidget(
  game: MouseCursorGame(),
  mouseCursor: SystemMouseCursors.move,
);
```
