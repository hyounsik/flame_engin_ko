<a id="tap-events"></a>

# 탭 이벤트

**탭 이벤트**는 Flame 게임과 상호작용하는 가장 기본적인 방법 중 하나입니다. 이 이벤트는 사용자가
손가락으로 화면을 터치하거나, 마우스로 클릭하거나, 스타일러스로 탭할 때 발생합니다.
탭은 "길게" 할 수도 있지만, 제스처 도중 손가락이 움직여서는 안 됩니다. 따라서 화면을 터치한 뒤
손가락을 움직였다가 떼는 것은 탭이 아니라 드래그입니다. 마찬가지로, 마우스를 움직이는 동안
마우스 버튼을 클릭하는 것도 드래그로 등록됩니다.

특히 사용자가 여러 손가락을 사용하는 경우, 여러 탭 이벤트가 동시에 발생할 수 있습니다. 이런
경우는 Flame이 올바르게 처리하며, 이벤트의 `pointerId` 속성을 사용해 각 이벤트를 추적할 수도
있습니다.

탭에 반응하게 하려는 컴포넌트에는 `TapCallbacks` 믹스인을 추가합니다.

- 이 믹스인은 컴포넌트에 오버라이드 가능한 메서드 네 개를 추가합니다: `onTapDown`, `onTapUp`,
  `onTapCancel`, `onLongTapDown`. 기본적으로 이 메서드들은 아무 일도 하지 않으므로, 어떤 기능을
  수행하려면 오버라이드해야 합니다.
- 또한 컴포넌트는 `containsLocalPoint()` 메서드를 구현해야 합니다(`PositionComponent`에 이미
  구현되어 있으므로 대부분의 경우 여기서 따로 할 일은 없습니다). 이 메서드를 통해 Flame은
  이벤트가 컴포넌트 안에서 발생했는지 여부를 알 수 있습니다.

```dart
class MyComponent extends PositionComponent with TapCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onTapUp(TapUpEvent event) {
    // 탭 이벤트에 반응하여 무언가를 수행합니다
  }
}
```


<a id="tap-anatomy"></a>

## 탭의 구조


### onTapDown

모든 탭은 "tap down" 이벤트로 시작하며, 이 이벤트는 `void onTapDown(TapDownEvent)` 핸들러를 통해
받습니다. 이벤트는 터치 지점에 위치하면서 `TapCallbacks` 믹스인을 가진 첫 번째 컴포넌트에
전달됩니다. 보통은 그 후 이벤트 전파가 멈춥니다. 하지만 `event.continuePropagation`을 true로
설정하면 아래에 있는 컴포넌트에도 이벤트가 전달되도록 강제할 수 있습니다.

이벤트 핸들러에 전달되는 `TapDownEvent` 객체에는 이벤트에 대해 사용할 수 있는 정보가 담겨
있습니다. 예를 들어 `event.localPosition`에는 현재 컴포넌트의 로컬 좌표계에서의 이벤트 좌표가
담기고, `event.canvasPosition`은 게임 캔버스 전체의 좌표계를 기준으로 합니다.

`onTapDown` 이벤트를 받은 모든 컴포넌트는 결국 같은 `pointerId`를 가진 `onTapUp` 또는
`onTapCancel` 중 하나를 받게 됩니다.


### onLongTapDown

사용자가 손가락을 한동안 누르고 있으면 "long tap"이 발생합니다. 이 이벤트는 앞서 `onTapDown`
이벤트를 받은 컴포넌트들의 `void onLongTapDown(TapDownEvent)` 핸들러를 호출합니다.

기본적으로 `.longTapDelay`는 300밀리초로 설정되어 있으며, 이는 시스템 기본값과 다를 수 있습니다.
`TapConfig.longTapDelay` 값을 설정하여 이 값을 변경할 수 있습니다.
특정한 접근성 요구에도 유용할 수 있습니다.


### onTapUp

이 이벤트는 탭 시퀀스가 성공적으로 완료되었음을 나타냅니다. 이 이벤트는 앞서 같은 포인터 id로
`onTapDown` 이벤트를 받은 컴포넌트에만 전달되는 것이 보장됩니다.

이벤트 핸들러에 전달되는 `TapUpEvent` 객체에는 이벤트에 대한 정보가 담겨 있으며, 여기에는
이벤트의 좌표(즉, 사용자가 손가락을 떼기 직전에 화면을 터치하고 있던 위치)와 이벤트의
`pointerId`가 포함됩니다.

tap-up 이벤트의 기기 좌표는 대응하는 tap-down 이벤트의 기기 좌표와 같거나 매우 가깝습니다.
하지만 로컬 좌표는 그렇다고 할 수 없습니다. 탭하고 있는 컴포넌트가 움직이고 있다면(게임에서는
자주 그렇듯이), 로컬 tap-up 좌표가 로컬 tap-down 좌표와 상당히 다를 수 있습니다.

극단적인 경우, 컴포넌트가 터치 지점에서 벗어나 버리면 `onTapUp` 이벤트는 아예 생성되지 않고
`onTapCancel`로 대체됩니다. 다만 이 경우 `onTapCancel`은 컴포넌트가 터치 지점에서 벗어나는
순간이 아니라, 사용자가 손가락을 떼거나 움직이는 순간에 생성된다는 점에 유의하세요.


### onTapCancel

이 이벤트는 탭이 성립하지 못했을 때 발생합니다. 대부분은 사용자가 손가락을 움직여 제스처가
"탭"에서 "드래그"로 바뀔 때 일어납니다. 그보다 드물게는 탭되고 있던 컴포넌트가 사용자의 손가락
아래에서 벗어날 때 발생할 수 있습니다. 더 드물게는 다른 위젯이 게임 위젯 위로 나타나거나,
기기가 꺼지는 등의 상황에서 `onTapCancel`이 발생합니다.

`TapCancelEvent` 객체에는 지금 취소되고 있는 이전 `TapDownEvent`의 `pointerId`만 담겨 있습니다.
tap-cancel에는 연관된 위치가 없습니다.


<a id="demo"></a>

### 데모

아래 데모를 조작해 보며 탭 이벤트가 동작하는 모습을 확인해 보세요.

가운데의 푸르스름한 사각형이 `TapCallbacks` 믹스인을 가진 컴포넌트입니다. 이 컴포넌트를 탭하면
터치 지점에 원이 생깁니다. 구체적으로는 `onTapDown` 이벤트가 원을 만들기 시작합니다. 원의
두께는 탭 지속 시간에 비례하며, `onTapUp` 이후에는 원의 선 두께가 더 이상 늘어나지 않습니다.
`onLongTapDown`이 발생하는 순간에는 얇은 흰색 줄무늬가 생깁니다. 마지막으로, 손가락을 움직여
`onTapCancel` 이벤트를 일으키면 원이 안쪽으로 줄어들며 사라집니다.

```{flutter-app}
:sources: ../flame/examples
:page: tap_events
:show: widget code
```


<a id="mixins"></a>

## 믹스인

이 섹션에서는 탭 이벤트 처리에 필요한 여러 믹스인을 더 자세히 설명합니다.


### TapCallbacks

`TapCallbacks` 믹스인은 어떤 `Component`에든 추가할 수 있으며, 추가하면 그 컴포넌트가 탭 이벤트를
받기 시작합니다.

이 믹스인은 컴포넌트에 `onTapDown`, `onLongTapDown`, `onTapUp`, `onTapCancel` 메서드를 추가합니다.
이 메서드들은 기본적으로 아무 일도 하지 않지만, 오버라이드하여 실제 기능을 구현할 수 있습니다.
모두 오버라이드할 필요도 없습니다. 예를 들어 "진짜" 탭에만 반응하고 싶다면 `onTapUp`만
오버라이드하면 됩니다.

또 하나 중요한 점은, 컴포넌트는 `containsLocalPoint()` 함수로 판단했을 때 그 컴포넌트 *안에서*
발생한 탭 이벤트만 받는다는 것입니다. 흔히 사용하는 `PositionComponent` 클래스는 `size` 속성을
기반으로 이 구현을 제공합니다. 따라서 컴포넌트가 `PositionComponent`를 상속한다면 크기를
올바르게 설정했는지 확인하세요. 반면 컴포넌트가 기본 `Component`를 상속한다면
`containsLocalPoint()` 메서드를 직접 구현해야 합니다.

컴포넌트가 더 큰 계층 구조의 일부라면, 그 부모가 `containsLocalPoint`를 올바르게 구현한 경우에만
탭 이벤트를 받습니다.

```dart
class MyComponent extends Component with TapCallbacks {
  final _rect = const Rect.fromLTWH(0, 0, 100, 100);
  final _paint = Paint();
  bool _isPressed = false;

  @override
  bool containsLocalPoint(Vector2 point) => _rect.contains(point.toOffset());

  @override
  void onTapDown(TapDownEvent event) => _isPressed = true;

  @override
  void onTapUp(TapUpEvent event) => _isPressed = false;

  @override
  void onTapCancel(TapCancelEvent event) => _isPressed = false;

  @override
  void render(Canvas canvas) {
    _paint.color = _isPressed? Colors.red : Colors.white;
    canvas.drawRect(_rect, _paint);
  }
}
```


### SecondaryTapCallbacks

Flame은 기본 탭 이벤트(데스크톱에서는 마우스 왼쪽 버튼) 외에 보조 탭 이벤트(데스크톱에서는
마우스 오른쪽 버튼)도 지원합니다. 이 이벤트를 받으려면 `PositionComponent`에
`SecondaryTapCallbacks` 믹스인을 추가하세요.

```dart
class MyComponent extends PositionComponent with SecondaryTapCallbacks {
  @override
  void onSecondaryTapUp(SecondaryTapUpEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onSecondaryTapCancel(SecondaryTapCancelEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onSecondaryTapDown(SecondaryTapDownEvent event) {
    /// 무언가를 수행합니다
  }
```

한 컴포넌트에서 `TapCallbacks`와 `SecondaryTapCallbacks`를 함께 사용하여 기본 탭 이벤트와 보조
탭 이벤트를 모두 받을 수 있습니다.


### TertiaryTapCallbacks

Flame은 세 번째 탭 이벤트(데스크톱에서는 마우스 가운데 버튼)도 지원합니다. 이 이벤트를 받으려면
`PositionComponent`에 `TertiaryTapCallbacks` 믹스인을 추가하세요.

```dart
class MyComponent extends PositionComponent with TertiaryTapCallbacks {
  @override
  void onTertiaryTapUp(TertiaryTapUpEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onTertiaryTapCancel(TertiaryTapCancelEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onTertiaryTapDown(TertiaryTapDownEvent event) {
    /// 무언가를 수행합니다
  }
```

한 컴포넌트에서 `TapCallbacks`, `SecondaryTapCallbacks`, `TertiaryTapCallbacks`를 조합하여 기본,
보조, 세 번째 탭 이벤트를 각각 독립적으로 받을 수 있습니다.


### DoubleTapCallbacks

Flame은 컴포넌트에서 더블 탭 이벤트를 받을 수 있도록 `DoubleTapCallbacks`라는 믹스인도
제공합니다. 컴포넌트에서 더블 탭 이벤트를 받기 시작하려면 `PositionComponent`에
`DoubleTapCallbacks` 믹스인을 추가하세요.

```dart
class MyComponent extends PositionComponent with DoubleTapCallbacks {
  @override
  void onDoubleTapUp(DoubleTapEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onDoubleTapCancel(DoubleTapCancelEvent event) {
    /// 무언가를 수행합니다
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    /// 무언가를 수행합니다
  }
```


<a id="migration"></a>

## 마이그레이션

`Tappable`/`Draggable` 믹스인을 사용하는 기존 게임이 있다면, 이 섹션에서 이 문서에 설명된 새 API로
전환하는 방법을 설명합니다. 해야 할 일은 다음과 같습니다.

이 믹스인들을 사용하는 모든 컴포넌트를 찾아 `TapCallbacks`/`DragCallbacks`로 교체하세요.
`onTapDown`, `onTapUp`, `onTapCancel`, `onLongTapDown` 메서드는 새 API에 맞게 조정해야 합니다.

- `(int pointerId, TapDownDetails details)`와 같은 인자 쌍은 단일 이벤트 객체
  `TapDownEvent event`로 대체되었습니다.
- 더 이상 반환값이 없습니다. 컴포넌트가 탭을 아래에 있는 컴포넌트로 통과시키도록 해야 한다면
  `event.continuePropagation`을 true로 설정하세요. 이는 `onTapDown` 이벤트에만 필요하며, 다른
  모든 이벤트는 자동으로 통과됩니다.
- 컴포넌트가 터치 지점의 좌표를 알아야 한다면 직접 계산하는 대신 `event.localPosition`을
  사용하세요. `event.canvasPosition`과 `event.devicePosition` 속성도 사용할 수 있습니다.
- 컴포넌트가 커스텀 조상에 연결되어 있다면, 그 조상도 올바른 크기를 가지고 있거나
  `containsLocalPoint()`를 구현하고 있는지 확인하세요.
