<a id="camera--world"></a>

# 카메라와 월드

대부분의 게임에서 월드는 한 번에 화면에 담을 수 있는 크기보다 큽니다. 카메라는 게임 월드의 어느
부분이 보이는지, 그리고 그것이 플레이어의 디스플레이에 어떻게 투영되는지를 제어하며,
패닝, 줌, 캐릭터 추적 등을 처리합니다. 이는 Flutter의
[`Viewport`](https://api.flutter.dev/flutter/rendering/RenderViewport-class.html)가 스크롤 가능한 영역 중
어느 부분을 보여 줄지 결정하는 방식과 비슷하지만, 게임의 자유로운 2D 좌표 공간에 맞게
조정되어 있습니다.

간단한 게임 구조의 예:

```text
FlameGame
├── World
│   ├── Player
│   └── Enemy
└── CameraComponent
    ├── Viewfinder
    │   ├── HudButton
    │   └── FpsTextComponent
    └── Viewport
```

`CameraComponent`가 어떻게 동작하는지 이해하려면, 게임 월드가 애플리케이션과는
독립적으로 *어딘가에* 존재하는 개체라고 상상해 보세요.
그리고 게임은 그 월드를 들여다볼 수 있는 창문에 불과하다고 상상해 보세요.
언제든 그 창문을 닫을 수 있지만, 게임 월드는
여전히 그곳에 존재합니다. 또는 반대로, 여러 개의 창문을 열어 동시에 같은 월드(또는 서로 다른 월드)를
바라볼 수도 있습니다.

이런 관점을 가지면 이제 `CameraComponent`가 어떻게 동작하는지 이해할 수 있습니다.

먼저 [World](#world) 클래스가 있으며, 게임 월드 안에 있는 모든 컴포넌트를
담고 있습니다. `World` 컴포넌트는 어디에든 마운트할 수 있습니다. 예를 들어
내장 `World`처럼 게임 클래스의 루트에 마운트할 수 있습니다.

그다음으로 [World](#world)를 "바라보는" [CameraComponent](#cameracomponent) 클래스가 있습니다.
`CameraComponent` 안에는 [Viewport](#viewport)와 [Viewfinder](#viewfinder)가
있어, 화면의 어느 위치에든 월드를 렌더링할 수 있는 유연성과
보는 위치 및 각도를 제어하는 기능을 모두 제공합니다.
`CameraComponent`에는 월드 아래에 정적으로 렌더링되는 [backdrop](#backdrop) 컴포넌트도
포함되어 있습니다.


## World

이 컴포넌트는 게임 월드를 구성하는 다른 모든 컴포넌트를 담는 데 사용해야
합니다. `World` 클래스의 주요 특성은 전통적인 방식으로 렌더링되지
않는다는 것입니다. 대신 월드를 "바라보는" 하나 이상의
[CameraComponent](#cameracomponent)에 의해 렌더링됩니다. `FlameGame` 클래스에는
기본적으로 추가되는 `world`라는 `World`가 하나 있으며, 이는
`camera`라는 기본 `CameraComponent`와 짝을 이룹니다.

게임에는 여러 개의 `World` 인스턴스가 있을 수 있으며, 이들은 동시에 렌더링될 수도,
서로 다른 시점에 렌더링될 수도 있습니다. 예를 들어 두 개의 월드 A와 B,
그리고 카메라 하나가 있다면, 카메라의 대상을 A에서 B로 바꾸는 것만으로
A를 언마운트하고 B를 마운트할 필요 없이 즉시 월드 B로 화면이
전환됩니다.

대부분의 `Component`와 마찬가지로, 생성자의 `children` 인자를 사용하거나
`add` 또는 `addAll` 메서드를 사용해 `World`에 자식을
추가할 수 있습니다.

많은 게임에서는 월드를 확장하고 그 안에 로직을 작성하게 됩니다.
그런 게임 구조는 다음과 같을 수 있습니다.

```dart
void main() {
  runApp(GameWidget(FlameGame(world: MyWorld())));
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    // 이 월드에서 필요한 모든 에셋을 로드하고
    // 컴포넌트 등을 추가합니다.
  }
}
```


## CameraComponent

`World`를 렌더링하는 데 사용되는 컴포넌트입니다. 여러 카메라가
동시에 같은 월드를 관찰할 수 있습니다.

`FlameGame` 클래스에는 기본 `world`와 짝을 이루는 `camera`라는 기본 `CameraComponent`가
있으므로, 게임에서 필요하지 않다면 직접 `CameraComponent`를 만들거나
추가할 필요가 없습니다.

`CameraComponent` 안에는 두 개의 다른 컴포넌트, [Viewport](#viewport)와
[Viewfinder](#viewfinder)가 있습니다. 이 컴포넌트들은 항상 카메라의 자식입니다.

`FlameGame` 클래스의 생성자에는 `camera` 필드가 있으므로, 원하는
기본 카메라 유형을 설정할 수 있습니다. 예를 들어 다음은
[고정 해상도](#고정-해상도의-cameracomponent) 카메라를 설정하는 예입니다.

```dart
void main() {
  runApp(
    GameWidget(
      FlameGame(
        camera: CameraComponent.withFixedResolution(
          width: 800,
          height: 600,
        ),
        world: MyWorld(),
      ),
    ),
  );
}
```

또한 정적 속성 `CameraComponent.currentCamera`가 있으며, 이 속성은
현재 렌더링을 수행 중인 카메라 객체를 반환합니다. 이는 컴포넌트의 렌더링이
카메라 설정에 따라 달라지는 일부 고급 사용 사례에서만 필요합니다. 예를 들어 어떤 컴포넌트는
카메라의 뷰포트 밖에 있을 때 자기 자신과 자식들의 렌더링을 건너뛰도록 결정할 수 있습니다.


<a id="cameracomponent-with-fixed-resolution"></a>

### 고정 해상도의 CameraComponent

이 이름 있는 생성자를 사용하면 사용자의 기기가 원하는 고정 해상도를 가진 것처럼
다룰 수 있습니다. 예를 들면 다음과 같습니다.

```dart
final camera = CameraComponent.withFixedResolution(
  world: myWorldComponent,
  width: 800,
  height: 600,
);
```

이렇게 하면 화면 중앙에 뷰포트가 위치한 카메라가 만들어집니다. 뷰포트는 4:3(800x600) 종횡비를
유지하면서 가능한 한 많은 공간을 차지하고, 800 x 600 크기의 게임 월드 영역을
보여 줍니다.

"고정 해상도"는 다루기가 매우 간단하지만, 사용자의 기기가 우연히 선택한 크기와 같은
종횡비를 갖지 않는 한 사용 가능한 화면 공간을 충분히 활용하지 못합니다.


## Viewport

`Viewport`는 `World`를 보는 창문입니다. 이 창문은
화면에서 특정한 크기, 모양, 위치를 가집니다. 여러 종류의
뷰포트가 제공되며, 언제든 직접 구현할 수도 있습니다.

`Viewport`는 컴포넌트이므로 다른 컴포넌트를 추가할 수 있습니다.
이 자식 컴포넌트들은 뷰포트의 위치에는 영향을 받지만,
클립 마스크에는 영향을 받지 않습니다. 따라서 뷰포트가 게임 월드를 들여다보는 "창문"이라면,
그 자식들은 창문 위에 올려놓을 수 있는 것들입니다.

뷰포트에 요소를 추가하는 것은 "HUD" 컴포넌트를 구현하는
편리한 방법입니다.

다음 뷰포트들을 사용할 수 있습니다.

- `MaxViewport`(기본값): 게임이 허용하는 최대 크기까지 확장되는 뷰포트입니다.
    즉, 게임 캔버스의 크기와 같아집니다.
- `FixedResolutionViewport`: 해상도와 종횡비를 고정하며, 종횡비가 맞지 않으면
    양옆에 검은 막대가 표시됩니다.
- `FixedSizeViewport`: 미리 정의된 크기를 가진 단순한 사각형 뷰포트입니다.
- `FixedAspectRatioViewport`: 게임 캔버스에 맞게 확장되지만
    종횡비는 유지하는 사각형 뷰포트입니다.
- `CircularViewport`: 원 모양의 고정 크기 뷰포트입니다.


`Viewport`에 자식을 추가하면 월드 앞에 정적인 HUD로 표시됩니다.


## Viewfinder

카메라의 이 부분은 현재 기반 게임 월드의 어느 위치를 보고 있는지 파악하는
역할을 합니다. `Viewfinder`는 줌 레벨과 뷰의 회전 각도도
제어합니다.

뷰파인더의 `anchor` 속성을 사용하면 뷰포트 안의 어느 지점을
카메라의 "논리적 중심"으로 삼을지 지정할 수 있습니다. 예를 들어
횡스크롤 액션 게임에서는 카메라가 주인공에게 초점을 맞추되, 주인공이
화면 중앙이 아니라 왼쪽 아래 모서리에 더 가깝게 표시되는 경우가 흔합니다. 이렇게 중심에서 벗어난 위치가
카메라의 "논리적 중심"이 되며, 이는 뷰파인더의 `anchor`로 제어합니다.

`Viewfinder`에 자식을 추가하면 월드 앞에, 그러나 뷰포트 뒤에 표시되며,
월드에 적용되는 것과 동일한 변환이 적용되므로 이 컴포넌트들은 정적이지 않습니다.

뷰파인더에 동작(behavior) 컴포넌트를 자식으로 추가할 수도 있습니다. 예를 들어
[이펙트](effects.md)나 다른 컨트롤러를 추가할 수 있습니다. 예를 들어
`ScaleEffect`를 추가하면 게임에서 부드러운 줌을 구현할 수 있습니다.


## Backdrop

월드 뒤에 정적인 컴포넌트를 추가하려면 `backdrop`
컴포넌트에 추가하거나, `backdrop` 컴포넌트를 교체하면 됩니다. 예를 들어
돌아다닐 수 있는 플레이어가 있는 월드 뒤에 정적인 `ParallaxComponent`를 보여 주고 싶을 때
유용합니다.

예시:

```dart
camera.backdrop.add(MyStaticBackground());
```

또는

```dart
camera.backdrop = MyStaticBackground();
```


<a id="camera-controls"></a>

## 카메라 제어

런타임에 카메라 설정을 변경하는 방법은 여러 가지가 있습니다.

1. `follow()`, `moveBy()`, `moveTo()` 같은 카메라 함수를 사용합니다.
   내부적으로 이 방식은 (2)와 같은 이펙트/동작을 사용합니다.

2. 카메라의 `Viewfinder`나 `Viewport`에 이펙트 및/또는 동작을 적용합니다.
   이펙트와 동작은 시간에 따라 컴포넌트의 어떤 속성을 수정하는 것을
   목적으로 하는 특별한 종류의 컴포넌트입니다.

3. 수동으로 처리합니다. 언제든 `CameraComponent.update()`
   메서드(또는 뷰파인더나 뷰포트의 같은 메서드)를 오버라이드하고, 그 안에서
   원하는 대로 뷰파인더의 위치나 줌을 변경할 수 있습니다. 이 방식은
   상황에 따라 쓸 만할 수 있지만, 일반적으로는 권장하지 않습니다.

`CameraComponent`에는 동작을 제어하는 여러 메서드가 있습니다.

- `follow()`는 카메라가 지정된 대상을 따라가도록 합니다.
   선택적으로 카메라의 최대 이동 속도를 제한하거나,
   가로/세로로만 이동하도록 할 수 있습니다.

- `stop()`은 이전 호출의 효과를 취소하고 카메라를
   현재 위치에 멈춥니다.

- `moveBy()`는 카메라를 지정된 오프셋만큼 이동하는 데 사용할 수 있습니다.
   카메라가 이미 다른 컴포넌트를 따라가거나 이동 중이었다면,
   그 동작은 자동으로 취소됩니다.

- `moveTo()`는 카메라를 월드 맵의 지정된 지점으로 이동하는 데
   사용할 수 있습니다. 카메라가 이미 다른 컴포넌트를 따라가거나
   다른 지점으로 이동 중이었다면, 그 동작은 자동으로
   취소됩니다.

- `setBounds()`를 사용하면 카메라가 이동할 수 있는 범위에 제한을 둘 수 있습니다. 이 제한은
   `Shape` 형태이며, 보통은 사각형이지만 다른 어떤 도형이든 될 수 있습니다.


### visibleWorldRect

카메라는 `visibleWorldRect` 속성을 제공합니다. 이 속성은 현재 카메라를 통해 보이는
월드 영역을 나타내는 사각형입니다. 이 영역을 사용하면 화면 밖에 있는 컴포넌트의
렌더링을 피하거나, 플레이어에게서 멀리 떨어진 객체를 덜 자주
업데이트할 수 있습니다.

`visibleWorldRect`는 캐시되는 속성이며, 카메라가
이동하거나 뷰포트의 크기가 바뀔 때마다 자동으로 업데이트됩니다.


### canSee

`CameraComponent`에는 `canSee`라는 메서드가 있으며, 이를 사용해
카메라의 시점에서 컴포넌트가 보이는지 확인할 수 있습니다.
예를 들어 화면에 보이지 않는 컴포넌트를 컬링할 때 유용합니다.

```dart
if (!camera.canSee(component)) {
   component.removeFromParent(); // 컴포넌트를 컬링합니다
}
```


<a id="post-processing"></a>

### 포스트 프로세싱

[포스트 프로세싱](rendering/post_processing.md)은 컴포넌트 트리가 렌더링된 후 시각
효과를 적용하기 위해 게임 개발에서 사용하는 기법입니다. `postProcess` 속성을 통해
카메라에 추가할 수 있습니다.

```dart
camera.postProcess = PostProcessGroup(
  postProcesses: [
    PostProcessSequentialGroup(
      postProcesses: [
        FireflyPostProcess(),
        WaterPostProcess(),
      ],
    ),
    ForegroundFogPostProcess(),
  ],
);
```

자세한 내용은 [포스트 프로세싱](rendering/post_processing.md)을 참고하세요.
