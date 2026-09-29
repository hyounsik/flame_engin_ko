# FlameGame

모든 게임에는 게임 루프를 소유하는 중심 객체가 필요합니다. 게임 루프는 상태를 업데이트하고
프레임을 렌더링하는 연속적인 순환으로, 모든 실시간 게임을 구동합니다. Flame에서는 `FlameGame`이 그 역할을 맡는 동시에
컴포넌트 트리의 루트 역할도 합니다. Flutter에 익숙하다면
`FlameGame`을 `MaterialApp`에 해당하는 것, 즉 다른 모든 것이 매달려 있는 최상위 진입점이라고
생각하면 됩니다.

거의 모든 Flame 게임의 기반은 `FlameGame` 클래스입니다. 이 클래스는 컴포넌트
트리의 루트입니다. 이 컴포넌트 기반 시스템을 Flame Component System(FCS)이라고 부릅니다. 문서
전반에서 FCS는 이 시스템을 가리킵니다.

`FlameGame` 클래스는 `Component` 기반의 `Game`을 구현합니다. 컴포넌트 트리를 가지고 있으며,
게임에 추가된 모든 컴포넌트의 `update`와 `render` 메서드를 호출합니다.

컴포넌트는 생성자에서 이름 있는 인자 `children`으로 `FlameGame`에 직접 추가하거나,
다른 곳 어디에서든 `add`/`addAll` 메서드로 추가할 수 있습니다. 하지만 대부분의 경우에는
자식들을 `World`에 추가하게 됩니다. 기본 월드는 `FlameGame.world`에 있으며, 다른 컴포넌트에
추가할 때와 똑같이 컴포넌트를 추가하면 됩니다.

컴포넌트 두 개를 하나는 `onLoad`에서, 하나는 생성자에서 직접 추가하는 간단한
`FlameGame` 구현은 다음과 같습니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// 16 x 16 크기로 상자 스프라이트를 렌더링하는 컴포넌트입니다.
class MyCrate extends SpriteComponent {
  MyCrate() : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('assets/images/crate.png');
  }
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(MyCrate());
  }
}

void main() {
  final myGame = FlameGame(world: MyWorld());
  runApp(
    GameWidget(game: myGame),
  );
}
```


<a id="custom-world-type"></a>

## 사용자 정의 World 타입

`FlameGame`에는 기본값이 `World`인 제네릭 타입 파라미터 `W`가 있습니다. 사용자 정의 월드
타입을 지정하면, 게임의 `world` getter가 캐스팅할 필요 없이 해당 월드 타입을
바로 반환합니다.

사용자 정의 `World` 서브클래스가 있고 게임 클래스 안에서 그 속성이나 메서드에
접근하고 싶을 때 유용합니다.

```dart
class MyWorld extends World {
  int score = 0;
}

class MyGame extends FlameGame<MyWorld> {
  MyGame() : super(world: MyWorld());

  void incrementScore() {
    // 캐스팅이 필요 없습니다. `world`는 이미 `MyWorld` 타입입니다.
    world.score++;
  }
}
```

이 제네릭 파라미터를 사용할 때는 `super` 생성자에 일치하는 월드 인스턴스를 **반드시**
전달해야 합니다. 제네릭 타입을 지정했는데 월드를 제공하지 않으면 런타임 assertion 에러가
발생합니다.

```{note}
build 메서드 안에서 게임 인스턴스를 생성하면 Flutter 트리가 다시 빌드될 때마다
게임도 다시 빌드되는데, 이는 보통 원하는 것보다 훨씬 자주 일어납니다.
이를 피하려면 먼저 게임 인스턴스를 만들어 두고 위젯 구조 안에서
참조하거나, `GameWidget.managed`
생성자를 사용하세요.
```

`FlameGame`의 리스트에서 컴포넌트를 제거하려면 `remove` 또는 `removeAll` 메서드를 사용할 수 있습니다.
컴포넌트 하나만 제거하려면 전자를, 컴포넌트 리스트를 제거하려면
후자를 사용하면 됩니다. 이 메서드들은 `World`를 포함한 모든 `Component`에 있습니다.

`FlameGame`에는 `world`라는 내장 `World`와 `camera`라는 `CameraComponent` 인스턴스가
있습니다. 이에 대한 자세한 내용은 [카메라 섹션](camera.md)을 참고하세요.


<a id="game-loop"></a>

## 게임 루프

`GameLoop` 모듈은 게임 루프 개념을 간단하게 추상화한 것입니다. 기본적으로 대부분의 게임은
두 가지 메서드를 기반으로 만들어집니다.

- render 메서드는 게임의 현재 상태를 그리기 위한 캔버스를 받습니다.
- update 메서드는 마지막 업데이트 이후의 델타 타임(초 단위)을 받아
  다음 상태로 넘어갈 수 있게 합니다.

`GameLoop`는 Flame의 모든 `Game` 구현에서 사용됩니다.


<a id="resizing"></a>

## 크기 조정

예를 들어 화면 방향이 바뀌는 등 게임의 크기를 조정해야 할 때마다, `FlameGame`은
모든 `Component`의 `onGameResize` 메서드를 호출하며, 이 정보를
카메라와 뷰포트에도 전달합니다.

`FlameGame.camera`는 좌표 공간의 어느 지점이 뷰파인더의 앵커에 위치할지를
제어합니다. 기본적으로 [0,0]은 뷰포트의 중앙(`Anchor.center`)에 있습니다.


<a id="lifecycle"></a>

## 생명주기

`FlameGame`의 생명주기 콜백인 `onLoad`, `render` 등은 다음 순서로 호출됩니다.

```{include} diagrams/flame_game_life_cycle.md
```

`FlameGame`이 처음 `GameWidget`에 추가되면 생명주기 메서드 `onGameResize`, `onLoad`,
`onMount`가 이 순서대로 호출됩니다. 그 후 `GameWidget`은 초기 컴포넌트 트리 전체가
로드되고 마운트될 때까지 기다리므로, `onLoad` 중에 추가된 모든 컴포넌트가 준비될 때까지
게임은 시작되지 않습니다(`loadingBuilder` 위젯이 설정되어 있다면 계속 표시됩니다). 그런 다음
매 게임 틱마다 `update`와 `render`가 순서대로 호출됩니다. `FlameGame`이 `GameWidget`에서
제거되면 `onRemove`가 호출됩니다. `FlameGame`이 새로운 `GameWidget`에 추가되면
`onGameResize`부터 이 순서가 반복됩니다.

```{note}
`onGameResize`와 `onLoad`의 순서는 다른
`Component`와 반대입니다. 이는 리소스를 로드하거나 생성하기 전에
게임 요소의 크기를 계산할 수 있도록 하기 위해서입니다.
```

`onRemove` 콜백을 사용해 자식과 캐시된 데이터를 정리할 수 있습니다.

```dart
  @override
  void onRemove() {
    // 게임의 필요에 따라 선택적으로 사용합니다.
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();
    // 게임이 제거될 때 실행하고 싶은 다른 코드.
  }
```

```{note}
`FlameGame`의 자식과 리소스 정리는 자동으로 이루어지지 않으므로
`onRemove` 호출에 명시적으로 추가해야 합니다.
```


### onHotReload

Flutter의 핫 리로드가 트리거되면(디버그 모드에서만) `GameWidget`은 `FlameGame`의 `onHotReload`를
호출하며, 이 알림은 트리에서 로드 중이거나 로드된 모든 컴포넌트에
자동으로 전파됩니다. 개발 중에 에셋을 다시 로드하거나, 캐시된 값을 갱신하거나,
소스 코드 변경에 반응하려면 어떤 컴포넌트에서든 이 메서드를 오버라이드하세요.

```dart
class MyGame extends FlameGame {
  @override
  void onHotReload() {
    // 코드 변경의 영향을 받는 게임 수준의 상태를 갱신합니다.
    super.onHotReload();
  }
}
```

```{note}
`onHotReload`는 디버그 모드에서만 호출됩니다. 아직
생명주기 큐에 있는(로드 중이지만 아직 마운트되지 않은) 컴포넌트도 알림을 받습니다.
이벤트가 자식들에게 계속 전파되도록 항상 `super.onHotReload()`를
호출하세요.
```


### dispose()

편의를 위해 `FlameGame`은 일반적인 정리 작업을 한 번의 호출로 모두 처리하는
`dispose()` 메서드를 제공합니다.

```dart
  game.dispose();
```

이 메서드는 게임에서 모든 자식을 제거하고(트리의 모든 컴포넌트에서 `onRemove`가 호출됩니다),
대기 중인 모든 생명주기 이벤트를 처리하며, `images`와 `assets` 캐시를 비웁니다.

`dispose()`와 `onRemove`의 차이점은, `dispose()`는 정리 작업을 수행하기 위해 명시적으로
호출하는 메서드인 반면, `onRemove`는 게임이 `GameWidget`에서 제거될 때 자동으로
호출되는 생명주기 콜백이라는 점입니다. `onRemove` 안에서 `dispose()`를 사용할 수도 있고,
게임 상태를 초기화해야 할 때마다 독립적으로 호출할 수도 있습니다.


<a id="debug-mode"></a>

## 디버그 모드

Flame의 `FlameGame` 클래스는 `debugMode`라는 변수를 제공하며, 기본값은 `false`입니다.
하지만 이 값을 `true`로 설정하면 게임 컴포넌트의 디버그 기능을 활성화할 수 있습니다. 이 변수의 값은
컴포넌트가 게임에 추가될 때 해당 컴포넌트에 전달된다는 점에 **주의하세요**. 따라서 런타임에
`debugMode`를 변경하더라도 기본적으로는 이미 추가된 컴포넌트에 영향을 주지 않습니다.

Flame의 `debugMode`에 대한 자세한 내용은 [디버그 문서](other/debug.md)를 참고하세요.


<a id="change-background-color"></a>

## 배경색 변경하기

`FlameGame`의 배경색을 변경하려면 `backgroundColor()`를 오버라이드해야 합니다.

다음 예제에서는 배경색을 완전히 투명하게 설정해 `GameWidget` 뒤에 있는
위젯들이 보이도록 합니다. 기본값은 불투명한 검은색입니다.

```dart
class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}
```

게임이 실행되는 동안에는 배경색을 동적으로 변경할 수 없다는 점에 유의하세요. 하지만 동적으로
변경하고 싶다면 캔버스 전체를 덮는 배경을 직접 그리면 됩니다.


<a id="singlegameinstance-mixin"></a>

## SingleGameInstance 믹스인

단일 게임 애플리케이션을 만든다면 선택적 믹스인인 `SingleGameInstance`를 게임에 적용할 수
있습니다. 이는 게임을 만들 때 흔한 시나리오입니다. 즉, 하나의 전체 화면
`GameWidget`이 하나의 `Game` 인스턴스를 호스팅하는 경우입니다.

이 믹스인을 추가하면 특정 상황에서 성능상 이점이 있습니다. 특히 컴포넌트의
`onLoad` 메서드는 부모가 아직 마운트되지 않았더라도 해당 컴포넌트가 부모에 추가될 때
시작되는 것이 보장됩니다. 따라서 `parent.add(component)` 이후
`component.loaded`를 기다리면 컴포넌트의 로드가 완료되는 것이 보장됩니다.

이 믹스인의 사용법은 간단합니다.

```dart
class MyGame extends FlameGame with SingleGameInstance {
  // ...
}
```


<a id="low-level-game-api"></a>

## 저수준 Game API

```{include} diagrams/low_level_game_api.md
```

추상 클래스 `Game`은 게임 엔진의 구조를 어떻게 구성할지 그 기능을 직접 구현하고 싶을 때
사용할 수 있는 저수준 API입니다. 예를 들어 `Game`은 `update`나
`render` 함수를 전혀 구현하지 않습니다.

이 클래스에는 생명주기 메서드인 `onLoad`, `onMount`, `onRemove`도 있으며,
게임이 로드되고 마운트될 때, 또는 제거될 때 `GameWidget`(또는 다른 부모)에서 호출됩니다.
`onLoad`는 클래스가 처음 부모에 추가될 때만 호출되지만, `onMount`(`onLoad` 이후에
호출됨)는 새로운 부모에 추가될 때마다 호출됩니다. `onRemove`는
클래스가 부모에서 제거될 때 호출됩니다.

```{note}
`Game` 클래스를 사용하면 구현 방식에서 더 많은 자유를 얻을 수 있지만,
Flame의 모든 내장 기능을 활용하지 못하게 됩니다.
```

`Game` 구현이 어떤 모습일 수 있는지 보여 주는 예시:

```dart
class MyGameSubClass extends Game {
  @override
  void render(Canvas canvas) {
    // ...
  }

  @override
  void update(double dt) {
    // ...
  }
}

void main() {
  final myGame = MyGameSubClass();
  runApp(
    GameWidget(
      game: myGame,
    )
  );
}
```


<a id="pauseresumingstepping-game-execution"></a>

## 게임 실행 일시 정지/재개/단계 실행

Flame의 `Game`은 두 가지 방법으로 일시 정지하고 재개할 수 있습니다.

- `pauseEngine`과 `resumeEngine` 메서드를 사용합니다.
- `isPaused` 속성을 변경합니다.

`Game`을 일시 정지하면 사실상 `GameLoop`가 일시 정지되며, 재개될 때까지 업데이트나 새로운 렌더링이
일어나지 않습니다.

게임이 일시 정지된 동안에는 `stepEngine` 메서드를 사용해 한 프레임씩 진행시킬 수
있습니다. 완성된 게임에서는 별로 유용하지 않을 수 있지만, 개발 과정에서 게임 상태를
단계별로 살펴볼 때 매우 유용할 수 있습니다.


<a id="backgrounding"></a>

### 백그라운드 전환

앱이 백그라운드로 전환되면 게임은 자동으로 일시 정지되고,
다시 포그라운드로 돌아오면 재개됩니다. 이 동작은
`pauseWhenBackgrounded`를 `false`로 설정해 비활성화할 수 있습니다.

```dart
class MyGame extends FlameGame {
  MyGame() {
    pauseWhenBackgrounded = false;
  }
}
```

이 플래그는 현재 Android와 iOS에서만 동작합니다.


<a id="hasperformancetracker-mixin"></a>

## HasPerformanceTracker 믹스인

게임을 최적화할 때, 게임이 각 프레임을 업데이트하고 렌더링하는 데 걸린 시간을 추적하면
유용할 수 있습니다. 이 데이터는 코드에서 부하가 큰 부분을 찾는 데 도움이 됩니다. 또한
게임에서 렌더링에 가장 많은 시간이 걸리는 시각적 영역을
찾는 데도 도움이 됩니다.

업데이트 시간과 렌더링 시간을 얻으려면 게임 클래스에 `HasPerformanceTracker` 믹스인을 추가하기만 하면 됩니다.

```dart
class MyGame extends FlameGame with HasPerformanceTracker {
  // `updateTime`과 `renderTime` getter에 접근합니다.
}
```
