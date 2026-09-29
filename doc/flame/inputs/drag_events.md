<a id="drag-events"></a>

# 드래그 이벤트

**드래그 이벤트**는 사용자가 기기 화면 위에서 손가락을 움직이거나, 마우스 버튼을 누른 채로
마우스를 움직일 때 발생합니다.

사용자가 여러 손가락을 사용하면 여러 드래그 이벤트가 동시에 발생할 수 있습니다. 이런 경우는
Flame이 올바르게 처리하며, 이벤트의 `pointerId` 속성을 사용해 각 이벤트를 추적할 수도 있습니다.

드래그에 반응하게 하려는 컴포넌트에는 `DragCallbacks` 믹스인을 추가합니다.

- 이 믹스인은 컴포넌트에 오버라이드 가능한 메서드 네 개를 추가합니다: `onDragStart`,
  `onDragUpdate`, `onDragEnd`, `onDragCancel`. 기본적으로 이 메서드들은 아무 일도 하지 않으므로,
  어떤 기능을 수행하려면 오버라이드해야 합니다.
- 또한 컴포넌트는 `containsLocalPoint()` 메서드를 구현해야 합니다(`PositionComponent`에 이미
  구현되어 있으므로 대부분의 경우 여기서 따로 할 일은 없습니다). 이 메서드를 통해 Flame은
  이벤트가 컴포넌트 안에서 발생했는지 여부를 알 수 있습니다.

```dart
class MyComponent extends PositionComponent with DragCallbacks {
  MyComponent() : super(size: Vector2(180, 120));

   @override
   void onDragStart(DragStartEvent event) {
     // 드래그 이벤트에 반응하여 무언가를 수행합니다
   }
}
```


<a id="demo"></a>

## 데모

이 예제에서는 드래그 제스처를 사용해 별 모양 도형을 화면 위에서 끌어 옮기거나, 자홍색 사각형
안에 곡선을 그릴 수 있습니다.

```{flutter-app}
:sources: ../flame/examples
:page: drag_events
:show: widget code
```


<a id="drag-anatomy"></a>

## 드래그의 구조


### onDragStart

드래그 시퀀스에서 가장 먼저 발생하는 이벤트입니다. 보통 이 이벤트는 터치 지점에 있으면서
`DragCallbacks` 믹스인을 가진 가장 위쪽 컴포넌트에 전달됩니다. 하지만
`event.continuePropagation` 플래그를 true로 설정하면 이벤트가 아래에 있는 컴포넌트로 전파되도록
할 수 있습니다.

이 이벤트와 연관된 `DragStartEvent` 객체에는 이벤트가 시작된 지점의 좌표가 담겨 있습니다. 이
지점은 여러 좌표계로 제공됩니다:
`devicePosition`은 기기 전체의 좌표계, `canvasPosition`은 게임 위젯의 좌표계,
`localPosition`은 컴포넌트의 로컬 좌표계에서의 위치를 제공합니다.

`onDragStart`를 받은 컴포넌트는 이후 `onDragUpdate`와 `onDragEnd` 이벤트도 받게 됩니다.

드래그는 포인터가 눌린 지점에서 플랫폼의 touch slop보다 멀리 움직인 뒤에야 시작됩니다. 따라서
손가락이 살짝 흔들린 탭은 드래그가 아닌 탭으로 전달됩니다. 드래그가 시작되면 그 시점까지 누적된
움직임은 첫 번째 `onDragUpdate`에서 전달됩니다.


### onDragUpdate

이 이벤트는 사용자가 화면 위에서 손가락을 드래그하는 동안 계속 발생합니다. 사용자가 손가락을
움직이지 않고 있으면 발생하지 않습니다.

기본 구현은 이 이벤트를 이전에 같은 포인터 id로 `onDragStart`를 받은 모든 컴포넌트에 전달합니다.
손가락이 컴포넌트 밖으로 벗어나도 드래그는 멈추지 **않으며**, 로컬 좌표는 계속 계산됩니다(컴포넌트
경계 밖일 수도 있습니다).

예외는 컴포넌트가 아직 드래그를 가지고 있는 동안 히트 테스트가 해당 컴포넌트에 아예 도달하지
않게 되는 경우입니다. 예를 들어 제스처 도중 조상이 `IgnoreEvents`를 켜는 경우입니다. 이때
컴포넌트는 여전히 이벤트를 받지만 `event.renderingTrace`가 비어 있으므로, `localStartPosition`,
`localEndPosition`, `localDelta`를 읽으면 예외가 발생합니다. `canvasStartPosition`,
`canvasEndPosition`, `deviceStartPosition`, `deviceEndPosition`은 trace에 의존하지 않으므로 계속
유효합니다.

또한 `DragUpdateEvent`에는 `delta`가 담겨 있습니다. 이는 이전 `onDragUpdate` 이후, 또는
drag-start 후 첫 번째 drag-update라면 `onDragStart` 이후 손가락이 이동한 양입니다.

`event.timestamp` 속성은 드래그가 시작된 이후 경과한 시간을 측정합니다. 예를 들어 움직임의 속도를
계산하는 데 사용할 수 있습니다.


### onDragEnd

이 이벤트는 사용자가 손가락을 떼어 드래그 제스처를 멈출 때 발생합니다. 이 이벤트에는 연관된
위치가 없습니다.


### onDragCancel

이 이벤트는 드래그 제스처가 자연스럽게 끝나기 전에 중단될 때 발생합니다. 예를 들어 다른 제스처
인식기가 gesture arena에서 이기거나, 두 번째 포인터가 스케일로 전환을 일으키는 경우입니다.
`onDragEnd`와 달리 속도 정보는 담고 있지 않습니다. 기본 구현은 단순히 드래그 상태를 초기화합니다.
취소를 자연스러운 드래그 종료와 똑같이 처리하고 싶다면, 이 메서드를 오버라이드하고 직접
`onDragEnd(event.toDragEnd())`를 호출하세요.


<a id="mixins"></a>

## 믹스인


### DragCallbacks

`DragCallbacks` 믹스인은 어떤 `Component`에든 추가할 수 있으며, 추가하면 그 컴포넌트가 드래그
이벤트를 받기 시작합니다.

이 믹스인은 컴포넌트에 `onDragStart`, `onDragUpdate`, `onDragEnd`, `onDragCancel` 메서드를
추가합니다. 이 메서드들은 기본적으로 아무 일도 하지 않지만, 오버라이드하여 실제 기능을 구현할 수
있습니다.

또 하나 중요한 점은, 컴포넌트는 `containsLocalPoint()` 함수로 판단했을 때 그 컴포넌트 *안에서*
시작된 드래그 이벤트만 받는다는 것입니다. 흔히 사용하는 `PositionComponent` 클래스는 `size`
속성을 기반으로 이 구현을 제공합니다. 따라서 컴포넌트가 `PositionComponent`를 상속한다면 크기를
올바르게 설정했는지 확인하세요. 반면 컴포넌트가 기본 `Component`를 상속한다면
`containsLocalPoint()` 메서드를 직접 구현해야 합니다.

컴포넌트가 더 큰 계층 구조의 일부라면, 그 조상들이 모두 `containsLocalPoint`를 올바르게 구현한
경우에만 드래그 이벤트를 받습니다.


### isDragged

`DragCallbacks` 믹스인은 컴포넌트가 드래그되고 있는 동안 `true`를 반환하는 `isDragged` getter를
제공합니다. 이 값은 `onDragStart`에서 `true`로 설정되고 `onDragEnd`에서 다시 `false`로 돌아갑니다.
예를 들어 드래그 중에 컴포넌트의 외형을 바꾸는 데 사용할 수 있습니다.


### allowsMultiPointerDrag

드래그는 포인터별로 추적되므로, 이미 드래그되고 있는 컴포넌트를 다른 손가락이 터치하면 두 번째의
독립적인 드래그가 시작됩니다. 각 드래그가 각자의 대상을 조작할 때는 이것이 원하는 동작이지만,
모든 드래그가 하나의 상태(카메라나 드래그 가능한 객체 등)를 조작할 때는 두 번째 손가락이 첫 번째
손가락과 충돌할 뿐입니다.

한 번에 하나의 드래그만 받으려면 `allowsMultiPointerDrag`를 `false`로 오버라이드하세요.

```dart
class MagnifyingGlass extends PositionComponent with DragCallbacks {
  @override
  bool get allowsMultiPointerDrag => false;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position = event.canvasEndPosition;
  }
}
```

드래그가 진행 중인 동안에는 다른 포인터가 이 컴포넌트에서 `onDragStart`를 받지 않으며, 그 포인터에
대한 `onDragUpdate`, `onDragEnd`, `onDragCancel`도 뒤따르지 않습니다. 대신 이벤트는 아래에 있는
컴포넌트들에 제공됩니다. 받아들인 드래그가 끝나거나 취소되면 컴포넌트는 다시 새 드래그를 받을 수
있습니다.

제어권은 넘겨지지 않습니다. 받아들인 포인터를 뗐을 때 다른 포인터가 아직 눌려 있더라도, 드래그는
남은 손가락으로 이어지지 않고 끝납니다.

이 설정은 드래그에만 적용됩니다. `ScaleCallbacks`도 사용하는 컴포넌트는 계속 스케일 이벤트를
정상적으로 받으므로, 한 손가락 드래그와 두 손가락 핀치는 여전히 동작합니다.


<a id="combining-with-scalecallbacks"></a>

## ScaleCallbacks와 함께 사용하기

`DragCallbacks`와 `ScaleCallbacks`는 동시에 사용할 수 있습니다. 한 손가락 제스처는 드래그 이벤트를,
두 손가락 제스처는 드래그 이벤트와 스케일 이벤트를 모두 생성합니다. 컴포넌트에서, 그리고 카메라
이동과 줌에서 둘을 함께 동작하게 하는 방법은
[DragCallbacks와 함께 사용하기](scale_events.md#combining-with-dragcallbacks)를 참고하세요.
