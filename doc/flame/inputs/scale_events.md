<a id="scale-events"></a>

# 스케일 이벤트

**스케일 이벤트**는 사용자가 두 손가락을 오므리거나(pinch in) 벌리는(pinch out) 동작을 할 때
발생합니다. 한 번에 하나의 스케일 제스처만 발생할 수 있습니다.

스케일 이벤트에 반응하게 하려는 컴포넌트에는 `ScaleCallbacks` 믹스인을 추가합니다.

- 이 믹스인은 컴포넌트에 오버라이드 가능한 메서드 세 개를 추가합니다: `onScaleStart`,
  `onScaleUpdate`, `onScaleEnd`. 기본적으로 이 메서드들은 아무 일도 하지 않으므로, 어떤 기능을
  수행하려면 오버라이드해야 합니다.
- 또한 컴포넌트는 `containsLocalPoint()` 메서드를 구현해야 합니다(`PositionComponent`에 이미
  구현되어 있으므로 대부분의 경우 여기서 따로 할 일은 없습니다). 이 메서드를 통해 Flame은
  이벤트가 컴포넌트 안에서 발생했는지 여부를 알 수 있습니다.

```dart
class MyComponent extends PositionComponent with ScaleCallbacks {
  MyComponent() : super(size: Vector2(180, 120));

   @override
   void onScaleStart(ScaleStartEvent event) {
     // 스케일 이벤트에 반응하여 무언가를 수행합니다
   }
}
```


<a id="scale-anatomy"></a>

## 스케일의 구조


### onScaleStart

스케일 시퀀스에서 가장 먼저 발생하는 이벤트입니다. 보통 이 이벤트는 초점(두 손가락이 이루는 선의
중심점)에 있으면서 `ScaleCallbacks` 믹스인을 가진 가장 위쪽 컴포넌트에 전달됩니다. 하지만
`event.continuePropagation` 플래그를 true로 설정하면 이벤트가 아래에 있는 컴포넌트로 전파되도록
할 수 있습니다.

이 이벤트와 연관된 `ScaleStartEvent` 객체에는 스케일 제스처 인식기가 인식한 첫 번째 초점의
좌표가 담겨 있습니다. 이 지점은 여러 좌표계로 제공됩니다:
`devicePosition`은 기기 전체의 좌표계, `canvasPosition`은 게임 위젯의 좌표계,
`localPosition`은 컴포넌트의 로컬 좌표계에서의 위치를 제공합니다.

`onScaleStart`를 받은 컴포넌트는 이후 `onScaleUpdate`와 `onScaleEnd` 이벤트도 받게 됩니다.


### onScaleUpdate

이 이벤트는 사용자가 화면 위에서 손가락을 드래그하는 동안 계속 발생합니다. 사용자가 손가락을
움직이지 않고 있으면 발생하지 않습니다.

기본 구현은 이 이벤트를 이전에 `onScaleStart`를 받은 모든 컴포넌트에 전달합니다. 초점이
컴포넌트 밖으로 벗어나도 스케일 제스처는 멈추지 **않으며**, 로컬 좌표는 계속 계산됩니다(컴포넌트
경계 밖일 수도 있습니다).

예외는 컴포넌트가 아직 제스처를 가지고 있는 동안 히트 테스트가 해당 컴포넌트에 아예 도달하지
않게 되는 경우입니다. 예를 들어 제스처 도중 조상이 `IgnoreEvents`를 켜는 경우입니다. 이때
컴포넌트는 여전히 이벤트를 받지만 `event.renderingTrace`가 비어 있으므로,
`localStartPosition`, `localEndPosition`, `localDelta`를 읽으면 예외가 발생합니다.
`canvasStartPosition`, `canvasEndPosition`, `deviceStartPosition`, `deviceEndPosition`은 trace에
의존하지 않으므로 계속 유효합니다.

또한 `ScaleUpdateEvent`에는 `focalPointDelta`가 담겨 있습니다. 이는 이전 `onScaleUpdate` 이후,
또는 scale-start 후 첫 번째 scale-update라면 `onScaleStart` 이후 초점이 이동한 양입니다.

`event.timestamp` 속성은 스케일이 시작된 이후 경과한 시간을 측정합니다. 예를 들어 움직임의 속도를
계산하는 데 사용할 수 있습니다.

`event.rotation` 속성은 시작 시점에 두 손가락이 이루던 선과 이 이벤트가 호출될 때 이루는 선
사이의 회전 각도를 라디안 단위로 측정합니다.

`event.scale` 속성은 시작 시점에 두 손가락이 이루던 선과 이 이벤트가 호출될 때 이루는 선 사이의
길이 비율을 측정합니다.


### onScaleEnd

이 이벤트는 사용자가 손가락을 떼어 스케일 제스처를 멈출 때 발생합니다. 이 이벤트에는 연관된
위치가 없습니다.


<a id="mixins"></a>

## 믹스인


### ScaleCallbacks

`ScaleCallbacks` 믹스인은 어떤 `Component`에든 추가할 수 있으며, 추가하면 그 컴포넌트가 스케일
이벤트를 받기 시작합니다.

이 믹스인은 컴포넌트에 `onScaleStart`, `onScaleUpdate`, `onScaleEnd` 메서드를 추가합니다. 이
메서드들은 기본적으로 아무 일도 하지 않지만, 오버라이드하여 실제 기능을 구현할 수 있습니다.

또 하나 중요한 점은, 컴포넌트는 `containsLocalPoint()` 함수로 판단했을 때 그 컴포넌트 *안에서*
시작된 스케일 이벤트만 받는다는 것입니다. 흔히 사용하는 `PositionComponent` 클래스는 `size`
속성을 기반으로 이 구현을 제공합니다. 따라서 컴포넌트가 `PositionComponent`를 상속한다면 크기를
올바르게 설정했는지 확인하세요. 반면 컴포넌트가 기본 `Component`를 상속한다면
`containsLocalPoint()` 메서드를 직접 구현해야 합니다.

컴포넌트가 더 큰 계층 구조의 일부라면, 그 조상들이 모두 `containsLocalPoint`를 올바르게 구현한
경우에만 스케일 이벤트를 받습니다.


### isScaling

`ScaleCallbacks` 믹스인은 컴포넌트가 스케일되고 있는 동안 `true`를 반환하는 `isScaling` getter를
제공합니다. 이 값은 `onScaleStart`가 시작될 때 `true`로 설정되고 `onScaleEnd`에서 다시 `false`로
돌아갑니다. 예를 들어 스케일 제스처 중에 컴포넌트의 외형을 바꾸는 데 사용할 수 있습니다.


### scaleThreshold

스케일 이벤트는 두 손가락이 화면에 닿자마자 발생하지 않습니다. 대신 먼저 작은 이동 임계값을
넘어야 합니다. 기본적으로 `onScaleStart`가 호출되려면 손가락을 최소 5%(스케일 계수 1.05) 이상
벌리거나 오므려야 합니다. 이는 사용자가 스케일할 의도 없이 두 손가락을 올려놓기만 했을 때 의도치
않은 스케일 제스처가 발생하는 것을 막아줍니다.

임계값은 게임에서 `MultiDragScaleDispatcher`에 접근하여, `ScaleCallbacks` 컴포넌트가 마운트되기
전에 `scaleThreshold`를 설정하는 방식으로 변경할 수 있습니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final dispatcher = MultiDragScaleDispatcher()..scaleThreshold = 1.02;
    registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
    add(dispatcher);
  }
}
```

값을 낮추면 인식기가 더 민감해지고(더 작은 핀치 동작에도 반응), 값을 높이면 스케일 이벤트가
발생하기 전에 더 의도적인 제스처가 필요해집니다.


<a id="combining-with-dragcallbacks"></a>

## DragCallbacks와 함께 사용하기

`ScaleCallbacks`와 `DragCallbacks`는 동시에 사용할 수 있습니다. 둘 다 같은 인식기로 구동되므로
자유롭게 조합됩니다. 한 손가락 제스처는 드래그 이벤트를, 두 손가락 제스처는 스케일 이벤트와
드래그 이벤트를 모두 생성합니다. 이는 한 손가락으로 드래그하고 두 손가락으로 핀치 줌이나 회전을
해야 하는 컴포넌트에 유용합니다.

```dart
class InteractiveRectangle extends RectangleComponent
    with ScaleCallbacks, DragCallbacks {

  double _initialAngle = 0;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _initialAngle = angle;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    angle = _initialAngle + event.rotation;
  }
}
```

같은 조합을 `FlameGame`에 믹스인하면 흔히 쓰는 "드래그로 이동, 핀치로 줌" 카메라 조작을 구현할
수 있습니다. 두 손가락 핀치는 드래그 이벤트도 함께 발생시키므로, 스케일이 진행 중일 때는 드래그
핸들러가 빠져나와야 합니다. 그렇지 않으면 카메라가 이동과 줌을 동시에 하게 됩니다.

```dart
class MyGame extends FlameGame with DragCallbacks, ScaleCallbacks {
  late double startZoom;

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 3.0);
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = startZoom * event.scale;
    clampZoom();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // 두 손가락 핀치는 드래그와 스케일을 모두 발생시키므로, 줌 중에는 이동을 건너뜁니다
    if (isScaling) {
      return;
    }
    final zoom = camera.viewfinder.zoom;
    camera.moveBy((event.localDelta..negate()) / zoom);
  }
}
```

이는 [zoom 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/zoom_example.dart)에서도
확인할 수 있습니다.
