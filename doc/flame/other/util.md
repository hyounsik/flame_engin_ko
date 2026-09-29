<a id="util"></a>

# 유틸리티

이 페이지에서는 몇 가지 유틸리티 클래스와 메서드에 대한 문서를 볼 수 있습니다.


<a id="device-class"></a>

## Device 클래스

```{warning}
이 클래스의 많은 메서드는 모바일 플랫폼(Android와 iOS)에서만 동작합니다.

다른 플랫폼에서 이 메서드들을 사용하면 아무 효과가 없으며, 디버그 모드로 실행 중이라면
콘솔에 경고가 출력됩니다.
```

이 클래스는 `Flame.device`로 접근할 수 있으며, 기기의 상태를 제어하는 데 사용할 수 있는 몇 가지
메서드를 가지고 있습니다. 예를 들어 화면 방향을 바꾸거나 애플리케이션을 전체 화면으로 할지 설정할 수
있습니다.


### `Flame.device.fullScreen()`

호출하면 모든 `SystemUiOverlay`를 비활성화하여 앱을 전체 화면으로 만듭니다.
main 메서드에서 호출하면 앱이 전체 화면(상단 바와 하단 바가 없는 상태)이 됩니다.

**참고:** 웹에서 호출하면 아무 효과가 없습니다.


### `Flame.device.setLandscape()`

이 메서드는 애플리케이션 전체(결과적으로 게임도 포함)의 방향을 가로로 설정합니다. 운영체제와 기기
설정에 따라 왼쪽 가로 방향과 오른쪽 가로 방향을 모두 허용해야 합니다. 앱 방향을 특정 방향의 가로로
설정하려면 `Flame.device.setLandscapeLeftOnly` 또는 `Flame.device.setLandscapeRightOnly`를
사용하세요.

**참고:** 웹에서 호출하면 아무 효과가 없습니다.


### `Flame.device.setPortrait()`

이 메서드는 애플리케이션 전체(결과적으로 게임도 포함)의 방향을 세로로 설정합니다. 운영체제와 기기
설정에 따라 정방향과 역방향 세로를 모두 허용해야 합니다. 앱 방향을 특정 방향의 세로로 설정하려면
`Flame.device.setPortraitUpOnly` 또는 `Flame.device.setPortraitDownOnly`를 사용하세요.

**참고:** 웹에서 호출하면 아무 효과가 없습니다.


<a id="flamedevicesetorientation-and-flamedevicesetorientations"></a>

### `Flame.device.setOrientation()`과 `Flame.device.setOrientations()`

(`SystemChrome`을 직접 다루지 않고) 허용할 방향을 더 세밀하게 제어해야 한다면
`setOrientation`(단일 `DeviceOrientation`을 파라미터로 받음)과 `setOrientations`(가능한 방향의
`List<DeviceOrientation>`을 받음)를 사용할 수 있습니다.

**참고:** 웹에서 호출하면 아무 효과가 없습니다.


## Timer

Flame은 카운트다운과 타이머 상태 변화를 이벤트처럼 다룰 수 있도록 도와주는 간단한 유틸리티 클래스를
제공합니다.

카운트다운 예제:

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends Game {
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );

  final countdown = Timer(2);

  @override
  void update(double dt) {
    countdown.update(dt);
    if (countdown.finished) {
      // 타이머 콜백을 사용하는 편이 좋지만, 경우에 따라서는 이 방식이 더 낫습니다
    }
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(
      canvas,
      "Countdown: ${countdown.current.toString()}",
      Vector2(10, 100),
    );
  }
}

```

인터벌 예제:

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class MyGame extends Game {
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    interval = Timer(
      1,
      onTick: () => elapsedSecs += 1,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(canvas, "Elapsed time: $elapsedSecs", Vector2(10, 150));
  }
}

```

`TimerComponent` 클래스를 사용하면 `FlameGame` 게임 안에서도 `Timer` 인스턴스를 사용할 수 있습니다.

`TimerComponent` 예제:

```dart
import 'package:flame/timer.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MyFlameGame extends FlameGame {
  MyFlameGame() {
    add(
      TimerComponent(
        period: 10,
        repeat: true,
        onTick: () => print('10 seconds elapsed'),
      )
    );
  }
}
```

```{note}
`Timer`나 `TimerComponent`는 `repeat: true` 인자를 주면 무한히 반복할 수 있고,
`repeat: true`와 함께 `tickCount` 인자를 사용하면 정해진 횟수만큼
반복할 수 있습니다.
```


<a id="time-scale"></a>

## 타임 스케일

많은 게임에서는 게임 내 이벤트에 따라 슬로 모션이나 빨리 감기 효과를 만들고 싶을 때가 많습니다.
이런 효과를 내는 매우 일반적인 방법은 게임 내 시간이나 틱 속도를 조작하는 것입니다.

이 조작을 쉽게 할 수 있도록 Flame은 `HasTimeScale` 믹스인을 제공합니다. 이 믹스인은 어떤 Flame
`Component`에든 붙일 수 있으며, `timeScale`에 대한 간단한 get/set API를 제공합니다. `timeScale`의
기본값은 `1`로, 컴포넌트의 게임 내 시간이 실제 시간과 같은 속도로 흐른다는 뜻입니다. `2`로 설정하면
컴포넌트가 실제 시간보다 두 배 빠르게 틱하고, `0.5`로 설정하면 절반의 속도로 틱합니다. 이 믹스인은
`pause`와 `resume` 메서드도 제공하므로, timeScale을 각각 0과 1로 직접 설정하는 대신 사용할 수
있습니다. `timeScale`이 `0`이면 해당 컴포넌트와 그 하위 트리 전체의 업데이트 단계가 멈춥니다. 즉, 타임
스케일이 다시 바뀔 때까지 그중 어느 것에서도 `update`가 호출되지 않습니다. 생명주기 이벤트는 타임
스케일과 독립적으로 처리되므로, 일시 정지된 게임에 추가된 컴포넌트도 여전히 마운트됩니다.

`FlameGame`도 `Component`이므로 이 믹스인을 `FlameGame`에도 붙일 수 있습니다. 그렇게 하면 게임의
모든 컴포넌트의 타임 스케일을 한곳에서 제어할 수 있습니다.

```{note}
HasTimeScale은 flame_forge2d의 BodyComponent 움직임을 개별적으로 제어할 수 없습니다.
Game 전체나 Forge2DWorld 전체의 타임 스케일을 조절할 때만 유용합니다.
```

```{flutter-app}
:sources: ../flame/examples
:page: time_scale
:show: widget code infobox
:width: 180
:height: 160
```

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MyFlameGame extends FlameGame with HasTimeScale {
  void speedUp(){
    timeScale = 2.0;
  }

  void slowDown(){
    timeScale = 1.0;
  }
}
```


<a id="extensions"></a>

## 확장

Flame에는 유틸리티 확장(extension) 모음이 포함되어 있습니다. 이 확장들은 개발자에게 단축 기능과 변환
메서드를 제공하기 위한 것이며, 여기에서 그 요약을 볼 수 있습니다.

모두 `package:flame/extensions.dart`에서 import할 수 있습니다.


### Canvas

메서드:

- `scaleVector`: `canvas scale` 메서드와 같지만, `Vector2`를 인자로 받습니다.
- `translateVector`: `canvas translate` 메서드와 같지만, `Vector2`를 인자로 받습니다.
- `renderPoint`: 캔버스에 점 하나를 렌더링합니다(주로 디버깅 용도).
- `renderAt`과 `renderRotated`: `Canvas`에 직접 렌더링하는 경우, 이 함수들을 사용해 좌표를 쉽게
  조작하여 올바른 위치에 렌더링할 수 있습니다. `Canvas`의 변환 행렬을 변경하지만 이후에 다시
  되돌립니다.


### Color

메서드:

- `darken`: 0에서 1 사이의 값만큼 색을 어둡게 합니다.
- `brighten`: 0에서 1 사이의 값만큼 색을 밝게 합니다.

팩토리:

- `ColorExtension.fromRGBHexString`: 유효한 16진수 문자열(예: #1C1C1C)에서 RGB 색을 파싱합니다.
- `ColorExtension.fromARGBHexString`: 유효한 16진수 문자열(예: #FF1C1C1C)에서 ARGB 색을 파싱합니다.


### Image

메서드:

- `pixelsInUint8`: 이미지의 픽셀 데이터를 `ImageByteFormat.rawRgba` 픽셀 형식의 `Uint8List`로
 가져옵니다.
- `getBoundingRect`: `Image`의 경계 사각형을 `Rect`로 가져옵니다.
- `size`: `Image`의 크기를 `Vector2`로 나타냅니다.
- `darken`: 0에서 1 사이의 값만큼 `Image`의 각 픽셀을 어둡게 합니다.
- `brighten`: 0에서 1 사이의 값만큼 `Image`의 각 픽셀을 밝게 합니다.


### Offset

메서드:

- `toVector2`: `Offset`에서 `Vector2`를 생성합니다.
- `toSize`: `Offset`에서 `Size`를 생성합니다.
- `toPoint`: `Offset`에서 `Point`를 생성합니다.
- `toRect`: (0,0)에서 시작하고 오른쪽 아래 모서리가 [Offset]인 `Rect`를 생성합니다.


### Rect

메서드:

- `toOffset`: `Rect`에서 `Offset`을 생성합니다.
- `toVector2`: (0,0)에서 시작하여 `Rect`의 크기까지 이어지는 `Vector2`를 생성합니다.
- `containsPoint`: 이 `Rect`가 `Vector2` 점을 포함하는지 여부를 반환합니다.
- `intersectsSegment`: 두 `Vector2`로 이루어진 선분이 이 `Rect`와 교차하는지 여부를 반환합니다.
- `intersectsLineSegment`: `LineSegment`가 `Rect`와 교차하는지 여부를 반환합니다.
- `toVertices`: `Rect`의 네 모서리를 `Vector2` 리스트로 변환합니다.
- `toFlameRectangle`: 이 `Rect`를 Flame `Rectangle`로 변환합니다.
- `toMathRectangle`: 이 `Rect`를 `math.Rectangle`로 변환합니다.
- `toGeometryRectangle`: 이 `Rect`를 flame-geom의 `Rectangle`로 변환합니다.
- `transform`: `Matrix4`를 사용해 `Rect`를 변환합니다.

팩토리:

- `RectExtension.getBounds`: `Vector2` 리스트의 경계를 나타내는 `Rect`를 생성합니다.
- `RectExtension.fromCenter`: 중심점(`Vector2` 사용)으로부터 `Rect`를 생성합니다.


### math.Rectangle

메서드:

- `toRect`: 이 math `Rectangle`을 ui `Rect`로 변환합니다.


### Size

메서드:

- `toVector2`: `Size`에서 `Vector2`를 생성합니다.
- `toOffset`: `Size`에서 `Offset`을 생성합니다.
- `toPoint`: `Size`에서 `Point`를 생성합니다.
- `toRect`: (0,0)에서 시작하고 크기가 `Size`인 `Rect`를 생성합니다.


### Vector2

이 클래스는 `vector_math` 패키지에서 제공되며, Flame은 그 패키지가 제공하는 기능 위에 몇 가지 유용한
확장 메서드를 추가했습니다.

메서드:

- `toOffset`: `Vector2`에서 `Offset`을 생성합니다.
- `toPoint`: `Vector2`에서 `Point`를 생성합니다.
- `toRect`: (0,0)에서 시작하고 크기가 `Vector2`인 `Rect`를 생성합니다.
- `toPositionedRect`: `Vector2`의 [x, y]에서 시작하고 크기가 `Vector2` 인자인 `Rect`를
  생성합니다.
- `lerp`: `Vector2`를 다른 Vector2 쪽으로 선형 보간합니다.
- `rotate`: `Vector2`를 라디안으로 지정한 각도만큼 회전합니다. 선택적으로 지정한 `Vector2`를
  중심으로 회전하며, 지정하지 않으면 원점을 중심으로 회전합니다.
- `scaleTo`: 방향은 바꾸지 않고 `Vector2`의 길이를 주어진 길이로 변경합니다.
- `moveToTarget`: Vector2를 목표 방향으로 주어진 거리만큼 부드럽게 이동합니다.

팩토리:

- `Vector2Extension.fromInts`: int 값을 입력으로 받아 `Vector2`를 생성합니다.

연산자:

- `&`: 두 `Vector2`를 결합하여 Rect를 만듭니다. 원점은 왼쪽에, 크기는 오른쪽에 두어야 합니다.
- `%`: 두 `Vector2`의 x와 y 각각에 대한 모듈로/나머지를 구합니다.


### Matrix4

이 클래스는 `vector_math` 패키지에서 제공됩니다. Flame은 `vector_math`가 이미 제공하는 기능 위에 몇
가지 확장 메서드를 추가했습니다.

메서드:

- `translate2`: 주어진 `Vector2`만큼 `Matrix4`를 평행 이동합니다.
- `transform2`: `Matrix4`를 사용해 주어진 `Vector2`를 변환한 새 `Vector2`를 생성합니다.
- `transformed2`: 입력 `Vector2`를 변환하여 출력 `Vector2`에 담습니다.

게터:

- `m11`: 첫 번째 행, 첫 번째 열.
- `m12`: 첫 번째 행, 두 번째 열.
- `m13`: 첫 번째 행, 세 번째 열.
- `m14`: 첫 번째 행, 네 번째 열.
- `m21`: 두 번째 행, 첫 번째 열.
- `m22`: 두 번째 행, 두 번째 열.
- `m23`: 두 번째 행, 세 번째 열.
- `m24`: 두 번째 행, 네 번째 열.
- `m31`: 세 번째 행, 첫 번째 열.
- `m32`: 세 번째 행, 두 번째 열.
- `m33`: 세 번째 행, 세 번째 열.
- `m34`: 세 번째 행, 네 번째 열.
- `m41`: 네 번째 행, 첫 번째 열.
- `m42`: 네 번째 행, 두 번째 열.
- `m43`: 네 번째 행, 세 번째 열.
- `m44`: 네 번째 행, 네 번째 열.

팩토리:

- `Matrix4Extension.scale`: 스케일된 `Matrix4`를 생성합니다. 첫 번째 인자로 `Vector4` 또는
   `Vector2`를 넘기거나, x y z double 값을 넘겨서 생성할 수 있습니다.
