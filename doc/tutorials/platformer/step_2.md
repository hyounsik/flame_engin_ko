<a id="2-start-coding"></a>

# 2. 코딩 시작


<a id="the-plan"></a>

## 계획

이제 에셋을 준비했고 어떤 클래스가 필요할지 대략적인 아이디어도 생겼으니, 이 게임을 어떻게 구현할지와
우리의 목표에 대해 생각해 봐야 합니다. 이를 위해 게임이 무엇을 해야 하는지
나누어 봅시다.

- Ember를 조종해 왼쪽, 오른쪽으로 움직이고 점프할 수 있어야 합니다.
- 레벨은 무한하므로 레벨의 구간을 무작위로 로드하는 방법이 필요합니다.
- 목표는 적을 피하면서 별을 모으는 것입니다.
- 적은 죽일 수 없으므로 플랫폼을 이용해 피해야 합니다.
- Ember가 적에게 맞으면 Ember의 체력이 1 줄어야 합니다.
- Ember는 잃을 수 있는 목숨이 3개 있어야 합니다.
- Ember가 빠지면 자동으로 게임 오버가 되는 구덩이가 있어야 합니다.
- 메인 메뉴와 플레이어가 다시 시작할 수 있는 게임 오버 화면이 있어야 합니다.

이렇게 계획을 세웠으니, 여러분도 저만큼 빨리 시작하고 싶을 것입니다. 저는 일단 화면에서 Ember를
보고 싶습니다. 그러니 그것부터 해 봅시다.

```{note}
왜 이 게임을 무한 횡스크롤 플랫포머로 만들기로 했을까요?

무작위 레벨 로딩을 보여 주고 싶었기 때문입니다. 같은 플레이는 두 번 다시
나오지 않습니다. 이 설정은 전통적인 레벨 방식의 게임으로도 쉽게 바꿀 수
있습니다. 튜토리얼을 진행하다 보면 레벨 코드를 수정해 끝이 있도록 만드는
방법을 보게 될 것입니다. 해당 섹션에 적절한 방법을 설명하는 참고를
추가해 두겠습니다.
```


<a id="loading-assets"></a>

## 에셋 로드

Ember를 표시하려면 에셋을 로드해야 합니다. 이 작업은 `main.dart`에서 할 수도 있지만, 그렇게 하면
파일이 금방 지저분해집니다. 게임을 체계적으로 유지하려면 하나의 역할에 집중하는 파일을 만들어야 합니다.
그러니 `lib` 폴더에 `ember_quest.dart`라는 파일을 만들어 봅시다. 그 파일에
다음을 추가합니다.

```dart
import 'package:flame/game.dart';

class EmberQuestGame extends FlameGame {
  EmberQuestGame();

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'assets/images/block.png',
      'assets/images/ember.png',
      'assets/images/ground.png',
      'assets/images/heart_half.png',
      'assets/images/heart.png',
      'assets/images/star.png',
      'assets/images/water_enemy.png',
    ]);

  }
}
```

[에셋](step_1.md#assets) 섹션에서 언급했듯이 우리는 여러 개의 개별 이미지
파일을 사용하므로, 성능을 위해 Flame에 내장된 캐싱 시스템을 활용해야 합니다. 이 시스템은
파일을 한 번만 로드하지만, 게임에 영향을 주지 않고 필요한 만큼 여러 번 접근할 수 있게 해 줍니다.
`await images.loadAll()`은 전체 에셋 경로 목록을 받아 캐시에 로드하며,
같은 경로를 키로 사용합니다.


<a id="scaffolding"></a>

## 뼈대 만들기

이제 게임 파일이 생겼으니, 새로 만든 `FlameGame`을 받을 수 있도록 `main.dart` 파일을
준비해 봅시다. `main.dart` 파일 전체를 다음과 같이 바꿉니다.

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'ember_quest.dart';

void main() {
  runApp(
    const GameWidget<EmberQuestGame>.managed(
      gameFactory: EmberQuestGame.new,
    ),
  );
}
```

이 파일을 실행하면 지금은 빈 화면만 보일 것입니다. 이제 Ember를 로드해 봅시다!


<a id="cameracomponent-and-world"></a>

## CameraComponent와 World

월드 안에서 이동하기 위해 `FlameGame` 클래스에 존재하는 내장 `CameraComponent`와 `World`를
사용하겠습니다.
모든 컴포넌트를 `world`에 추가하고, `camera`로 플레이어를 따라가겠습니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class EmberQuestGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'assets/images/block.png',
      'assets/images/ember.png',
      'assets/images/ground.png',
      'assets/images/heart_half.png',
      'assets/images/heart.png',
      'assets/images/star.png',
      'assets/images/water_enemy.png',
    ]);

    // 이 튜토리얼의 모든 내용은 `CameraComponent`의 뷰파인더(카메라가
    // 바라보는 곳)의 위치가 왼쪽 위 모서리에 있다고 가정하므로,
    // 여기서 앵커를 설정합니다.
    camera.viewfinder.anchor = Anchor.topLeft;
  }
}
```


<a id="ember-time"></a>

## Ember 등장

게임 파일을 체계적으로 정리하는 것은 언제나 어려운 일입니다. 저는 게임에서 어떻게 쓰이는지에 따라
논리적으로 정리하는 것을 좋아합니다. 그러니 Ember를 위해 `lib/actors` 폴더를 만들고,
그 폴더 안에 `ember.dart`를 만듭니다. 그 파일에 다음 코드를 추가합니다.

```dart
import 'package:flame/components.dart';

import '../ember_quest.dart';

class EmberPlayer extends SpriteAnimationComponent
    with HasGameRef<EmberQuestGame> {
  EmberPlayer({
    required super.position,
  }) : super(size: Vector2.all(64), anchor: Anchor.center);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      gameRef.images.fromCache('assets/images/ember.png'),
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
  }
}
```

이 파일은 `HasGameRef` 믹스인을 사용합니다. 이 믹스인을 사용하면 `ember_quest.dart`에 접근해
게임 클래스에 정의된 변수나 메서드를 활용할 수 있습니다. `gameRef.images.fromCache('assets/images/ember.png')`
줄에서 이것이 사용되는 것을 볼 수 있습니다. 앞에서 모든
파일을 캐시에 로드했으므로, 이제 그 파일을 사용하려면 `fromCache`를 호출해
`SpriteAnimation`에서 활용할 수 있게 합니다.
`EmberPlayer` 클래스는 `SpriteAnimationComponent`를 상속합니다. 이를 통해
애니메이션을 정의하고 게임 월드에서 적절히 위치를 지정할 수 있습니다. 이 클래스를 생성할 때
게임 월드에서 Ember의 크기가 64x64여야 하므로 기본 크기를 `Vector2.all(64)`로 정의합니다.
애니메이션 `SpriteAnimationData`에서 `textureSize`가 `Vector2.all(16)`, 즉 16x16으로 정의된 것을
보셨을 것입니다. 이는 `ember.png`의 개별 프레임이 16x16이고
총 4개의 프레임이 있기 때문입니다. 애니메이션 속도를 정의하기 위해 `stepTime`을 사용하며,
프레임당 `0.12`초로 설정했습니다. `stepTime`은 여러분이 구상한 게임에 맞게 애니메이션이 자연스러워 보이는
어떤 길이로든 바꿀 수 있습니다.

이제 서둘러 게임을 다시 실행하기 전에, Ember를 게임 월드에 추가해야 합니다. 이를 위해
`ember_quest.dart`로 돌아가 다음을 추가합니다.

```dart
import 'package:flame/game.dart';

import 'actors/ember.dart';

class EmberQuestGame extends FlameGame {
  late EmberPlayer _ember;
  
  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'assets/images/block.png',
      'assets/images/ember.png',
      'assets/images/ground.png',
      'assets/images/heart_half.png',
      'assets/images/heart.png',
      'assets/images/star.png',
      'assets/images/water_enemy.png',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;
    
    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 70),
    );
    world.add(_ember);
  }
}
```

이제 게임을 실행하면 왼쪽 아래 모서리에서 깜빡이는 Ember를 볼 수 있습니다.


<a id="building-blocks"></a>

## 블록 쌓기

이제 화면에 Ember가 보이고 기본 환경이 모두 올바르게 동작한다는 것을 알았으니,
Ember Quest를 위한 월드를 만들 차례입니다! [](step_3.md)로 넘어갑시다!
