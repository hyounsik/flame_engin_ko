<a id="sprite-components"></a>

# 스프라이트 컴포넌트

스프라이트는 게임 객체의 시각적 모습을 나타내는 2D 이미지(또는 이미지의 일부 영역)입니다. 2D 게임에서
캐릭터, 아이템, 배경 등 여러 시각 요소를 표시하는 가장 일반적인 방법입니다. Flame은 이미지를 로드하고,
애니메이션을 재생하고, 시각적 상태를 전환하는 작업을 쉽게 해 주는 여러 스프라이트 기반 컴포넌트를
제공하며, 이 컴포넌트들은 모두 `PositionComponent`에서 물려받은 변환 속성의 이점을 누립니다.


## SpriteComponent

가장 흔히 사용되는 `PositionComponent` 구현은 `SpriteComponent`이며, `Sprite`로 만들 수 있습니다:

```dart
import 'package:flame/components/component.dart';

class MyGame extends FlameGame {
  late final SpriteComponent player;

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('assets/images/player.png');
    final size = Vector2.all(128.0);
    final player = SpriteComponent(size: size, sprite: sprite);

    // 기본값은 Vector2(0.0, 0.0)이며, 생성자에서 설정할 수도 있습니다
    player.position = Vector2(10, 20);

    // 기본값은 0이며, 생성자에서 설정할 수도 있습니다
    player.angle = 0;

    // 컴포넌트를 추가합니다
    add(player);
  }
}
```


## SpriteAnimationComponent

이 클래스는 하나의 순환 애니메이션으로 재생되는 스프라이트들을 가진 컴포넌트를 나타내는 데 사용됩니다.

다음 코드는 서로 다른 이미지 3개를 사용해 간단한 3프레임 애니메이션을 만듭니다:

```dart
@override
Future<void> onLoad() async {
  final sprites = [0, 1, 2]
      .map((i) => Sprite.load('assets/images/player_$i.png'));
  final animation = SpriteAnimation.spriteList(
    await Future.wait(sprites),
    stepTime: 0.01,
  );
  this.player = SpriteAnimationComponent(
    animation: animation,
    size: Vector2.all(64.0),
  );
}
```

스프라이트 시트가 있다면 `SpriteAnimationData` 클래스의 `sequenced` 생성자를 사용할 수 있습니다
(자세한 내용은 [Images > Animation](../rendering/images.md#animation)을 참고하세요):

```dart
@override
Future<void> onLoad() async {
  final size = Vector2.all(64.0);
  final data = SpriteAnimationData.sequenced(
    textureSize: size,
    amount: 2,
    stepTime: 0.1,
  );
  this.player = SpriteAnimationComponent.fromFrameData(
    await images.load('assets/images/player.png'),
    data,
  );
}
```

모든 애니메이션 컴포넌트는 내부적으로 `SpriteAnimation`을 진행시키는 `SpriteAnimationTicker`를
유지합니다. 덕분에 여러 컴포넌트가 같은 애니메이션 객체를 공유할 수 있습니다.

예:

```dart
final sprites = [/*여기에 스프라이트 목록*/];
final animation = SpriteAnimation.spriteList(sprites, stepTime: 0.01);

final animationTicker = SpriteAnimationTicker(animation);

// 또는 애니메이션 객체에 ticker를 만들어 달라고 요청할 수도 있습니다.

final animationTicker = animation.createTicker(); // 새 ticker를 만듭니다

animationTicker.update(dt);
```

애니메이션이 끝났을 때(반복하지 않는 애니메이션이 마지막 프레임에 도달했을 때)를 감지하려면
`animationTicker.completed`를 사용할 수 있습니다.

예:

```dart
await animationTicker.completed;

doSomething();

// 또는

animationTicker.completed.whenComplete(doSomething);
```

또한 `SpriteAnimationTicker`에는 선택적 이벤트 콜백인 `onStart`, `onFrame`, `onComplete`도 있습니다.
이 이벤트를 수신하려면 다음과 같이 합니다:

```dart
final animationTicker = SpriteAnimationTicker(animation)
  ..onStart = () {
    // 시작할 때 무언가를 합니다.
  };

final animationTicker = SpriteAnimationTicker(animation)
  ..onComplete = () {
    // 완료될 때 무언가를 합니다.
  };

final animationTicker = SpriteAnimationTicker(animation)
  ..onFrame = (index) {
    if (index == 1) {
      // 두 번째 프레임에서 무언가를 합니다.
    }
  };
```

컴포넌트가 제거될 때 애니메이션을 첫 프레임으로 되돌리려면 `resetOnRemove`를 `true`로 설정합니다:

```dart
SpriteAnimationComponent(
  animation: animation,
  size: Vector2.all(64.0),
  resetOnRemove: true,
);
```


## SpriteAnimationGroupComponent

`SpriteAnimationGroupComponent`는 `SpriteAnimationComponent`를 감싼 간단한 래퍼로, 컴포넌트가 여러
애니메이션을 가지고 런타임에 현재 재생 중인 애니메이션을 바꿀 수 있게 해 줍니다. 이 컴포넌트는
래퍼일 뿐이므로 이벤트 리스너는 [SpriteAnimationComponent](#spriteanimationcomponent)에서 설명한
방식대로 구현할 수 있습니다.

사용법은 `SpriteAnimationComponent`와 매우 비슷하지만, 하나의 애니메이션으로 초기화하는 대신 제네릭
타입 `T`를 키로, `SpriteAnimation`을 값으로 하는 Map과 현재 애니메이션을 받습니다.

예:

```dart
enum RobotState {
  idle,
  running,
}

final running = await loadSpriteAnimation(/* 생략 */);
final idle = await loadSpriteAnimation(/* 생략 */);

final robot = SpriteAnimationGroupComponent<RobotState>(
  animations: {
    RobotState.running: running,
    RobotState.idle: idle,
  },
  current: RobotState.idle,
);

// 현재 애니메이션을 "running"으로 바꿉니다
robot.current = RobotState.running;
```

이 컴포넌트는 여러 `SpriteAnimation`을 다루므로, 당연히 그 모든 애니메이션을 진행시키려면 같은 수의
애니메이션 ticker가 필요합니다. `animationsTickers` getter를 사용하면 각 애니메이션 상태에 대한
ticker를 담은 맵에 접근할 수 있습니다. `onStart`, `onComplete`, `onFrame` 콜백을 등록하고 싶을 때
유용합니다.

예:

```dart
enum RobotState { idle, running, jump }

final running = await loadSpriteAnimation(/* 생략 */);
final idle = await loadSpriteAnimation(/* 생략 */);

final robot = SpriteAnimationGroupComponent<RobotState>(
  animations: {
    RobotState.running: running,
    RobotState.idle: idle,
  },
  current: RobotState.idle,
);

robot.animationTickers?[RobotState.running]?.onStart = () {
  // running 애니메이션이 시작될 때 무언가를 합니다.
};

robot.animationTickers?[RobotState.jump]?.onStart = () {
  // jump 애니메이션이 시작될 때 무언가를 합니다.
};

robot.animationTickers?[RobotState.jump]?.onComplete = () {
  // jump 애니메이션이 완료될 때 무언가를 합니다.
};

robot.animationTickers?[RobotState.idle]?.onFrame = (currentIndex) {
  // idle 애니메이션의 현재 프레임 인덱스에 따라 무언가를 합니다.
};
```


## SpriteGroupComponent

`SpriteGroupComponent`는 애니메이션 버전과 매우 비슷하지만, 스프라이트 전용입니다.

예:

```dart
class PlayerComponent extends SpriteGroupComponent<ButtonState>
    with HasGameRef<SpriteGroupExample>, TapCallbacks {
  @override
  Future<void> onLoad() async {
    final pressedSprite = await gameRef.loadSprite(/* 생략 */);
    final unpressedSprite = await gameRef.loadSprite(/* 생략 */);

    sprites = {
      ButtonState.pressed: pressedSprite,
      ButtonState.unpressed: unpressedSprite,
    };

    current = ButtonState.unpressed;
  }

  // 탭 메서드 핸들러는 생략...
}
```


## IconComponent

`IconComponent`는 Flutter의 `IconData`(예: `Icons.star`)를 Flame 컴포넌트로 렌더링합니다. 아이콘은
`onLoad()` 중에 한 번 이미지로 래스터화된 뒤, 매 프레임 컴포넌트의 `Paint`와 함께
`canvas.drawImageRect()`로 그려집니다. 아이콘이 텍스트가 아니라 캐시된 이미지로 렌더링되므로
`tint()`, `setOpacity()`, `ColorEffect`, `OpacityEffect`, `GlowEffect`, 커스텀 `ColorFilter` 등
paint 기반 효과가 모두 별도 설정 없이 동작합니다.


<a id="basic-usage"></a>

### 기본 사용법

```dart
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final star = IconComponent(
      icon: Icons.star,
      iconSize: 64,
      position: Vector2(100, 100),
    );
    add(star);
  }
}
```


<a id="tinting-and-effects"></a>

### 틴트와 이펙트

아이콘은 흰색으로 래스터화되므로 `HasPaint` 메서드를 사용해 원하는 색으로 틴트할 수 있습니다:

```dart
// 아이콘을 금색으로 틴트합니다
final star = IconComponent(
  icon: Icons.star,
  iconSize: 64,
  position: Vector2(100, 100),
)..tint(const Color(0xFFFFD700));

// 불투명도를 설정합니다
star.setOpacity(0.5);

// 또는 커스텀 paint를 사용합니다
final icon = IconComponent(
  icon: Icons.favorite,
  iconSize: 48,
  paint: Paint()..colorFilter = const ColorFilter.mode(
    Color(0xFFFF0000),
    BlendMode.srcATop,
  ),
);
```


<a id="constructor-parameters"></a>

### 생성자 파라미터

- `icon`: 렌더링할 `IconData`(예: `Icons.star`, `Icons.favorite`).
- `iconSize`: 아이콘을 래스터화할 해상도(기본값 `64`). 컴포넌트의 표시 크기인 `size`와는 독립적입니다.
- `size`: 컴포넌트의 표시 크기. 지정하지 않으면 기본값은 `Vector2.all(iconSize)`입니다.
- `paint`: 렌더링 효과를 위한 선택적 `Paint`.
- 모든 표준 `PositionComponent` 파라미터(`position`, `scale`, `angle`, `anchor` 등).


<a id="changing-the-icon-at-runtime"></a>

### 런타임에 아이콘 바꾸기

`icon`과 `iconSize` 속성은 모두 생성 후에 바꿀 수 있습니다. 컴포넌트는 다음 프레임에 자동으로
아이콘을 다시 래스터화합니다:

```dart
final iconComponent = IconComponent(
  icon: Icons.play_arrow,
  iconSize: 64,
);

// 나중에 아이콘을 교체합니다
iconComponent.icon = Icons.pause;

// 또는 래스터화 해상도를 바꿉니다
iconComponent.iconSize = 128;
```
