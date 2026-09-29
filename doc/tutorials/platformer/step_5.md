<a id="5-controlling-movement"></a>

# 5. 이동 제어

본격적인 코딩을 기다리고 있었다면, 바로 이 챕터입니다. 뛰어들 준비를 하세요!


<a id="keyboard-controls"></a>

## 키보드 조작

첫 번째 단계는 키보드로 Ember를 조작할 수 있게 하는 것입니다. 먼저 게임 클래스와 Ember에
적절한 믹스인을 추가해야 합니다. 다음을 추가합니다.

`lib/ember_quest.dart`

```dart
import 'package:flame/events.dart';

class EmberQuestGame extends FlameGame with HasKeyboardHandlerComponents {
```

`lib/actors/ember.dart`

```dart
class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, HasGameRef<EmberQuestGame> {
```

이제 새 메서드를 추가할 수 있습니다.

```dart
  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return true;
  }
```

앞에서처럼 자동 import가 되지 않았다면 다음이 필요합니다.

```dart
import 'package:flutter/services.dart';
```

Ember의 이동을 제어하려면, 이동 방향을 정규화된 벡터처럼 생각하는 변수를 두는 것이 가장 쉽습니다.
즉, 값은 -1, 0, 1로 제한됩니다. 그러니 클래스 맨 위에
변수를 하나 둡시다.

```dart
  int horizontalDirection = 0;
```

이제 `onKeyEvent` 메서드에 다음을 추가해 눌린 키를 등록할 수 있습니다.

```dart
@override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    return true;
  }
```

코드 몇 줄을 추가하고 `update` 메서드를 만들어 Ember를 움직여 봅시다. 먼저
Ember를 위한 속도 변수를 정의해야 합니다. `EmberPlayer` 클래스 맨 위에
다음을 추가합니다.

```dart
final Vector2 velocity = Vector2.zero();
final double moveSpeed = 200;
```

이렇게 하면 기본 속도가 0으로 정해지고 `moveSpeed`가 저장되므로, 게임플레이에 맞게 필요에 따라
조정할 수 있습니다. 다음으로 `update` 메서드를 다음과 같이 추가합니다.


```dart
  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    position += velocity * dt;
    super.update(dt);
  }
```

이제 게임을 실행하면 화살표 키나 `A`, `D` 키로 Ember가 좌우로 움직입니다.
왼쪽으로 갈 때 Ember가 뒤돌아보지 않는다는 것을 눈치챘을 수 있습니다. 이를 고치려면
`update` 메서드 끝에 다음 코드를 추가합니다.

```dart
if (horizontalDirection < 0 && scale.x > 0) {
  flipHorizontally();
} else if (horizontalDirection > 0 && scale.x < 0) {
  flipHorizontally();
}
```

이제 Ember가 이동하는 방향을 바라봅니다.


<a id="collisions"></a>

## 충돌

이제 충돌이라는 본론으로 들어갈 차례입니다. Flame에서 충돌이 어떻게 동작하는지 이해하려면
[문서](../../flame/collision_detection.md)를 읽어 보기를 강력히 권합니다.
가장 먼저 해야 할 일은 `HasCollisionDetection` 믹스인을 사용해 게임이 충돌이 일어난다는 것을
알게 하는 것입니다. `lib/ember_quest.dart`에 다음과 같이 추가합니다.

```dart
class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
```

다음으로 `lib/actors/ember.dart`에 `CollisionCallbacks` 믹스인을 다음과 같이 추가합니다.

```dart
class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<EmberQuestGame> {
```

자동 import가 되지 않았다면 다음이 필요합니다.

```dart
import 'package:flame/collisions.dart';
```

이제 다음 `onCollision` 메서드를 추가합니다.

```dart
@override
void onCollision(List<Vector2> intersectionPoints, PositionComponent other) {
  if (other is GroundBlock || other is PlatformBlock) {
    if (intersectionPoints.length == 2) {
      // 충돌 법선과 분리 거리를 계산합니다.
      final mid = (intersectionPoints.elementAt(0) +
        intersectionPoints.elementAt(1)) / 2;

      final collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.x / 2) - collisionNormal.length;
      collisionNormal.normalize();

      // 충돌 법선이 거의 위쪽을 향한다면
      // ember는 땅 위에 있는 것입니다.
      if (fromAbove.dot(collisionNormal) > 0.9) {
        isOnGround = true;
      }

      // 충돌 법선 방향으로 분리 거리만큼 ember를
      // 이동시켜 충돌을 해소합니다.
      position += collisionNormal.scaled(separationDistance);
      }
    }

  super.onCollision(intersectionPoints, other);
}
```

다음을 import해야 합니다.

```dart
import '../objects/ground_block.dart';
import '../objects/platform_block.dart';
```

또한 다음 클래스 변수도 만들어야 합니다.

```dart
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;
```

Ember의 충돌이 활성화되려면 `CircleHitbox`를 추가해야 합니다. `onLoad`
메서드에 다음을 추가합니다.

```dart
add(CircleHitbox());
```

기본적인 충돌을 만들었으니, 이제 중력을 추가해 Ember가 아주 기본적인 물리가 있는 게임 월드에
존재하도록 할 수 있습니다. 이를 위해 변수를 몇 개 더 만들어야 합니다.

```dart
  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  bool hasJumped = false;
```

이제 `onKeyEvent` 메서드에 다음을 추가해 Ember가 점프할 수 있게 합니다.

```dart
hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
```

마지막으로 `update` 메서드에서 다음과 같이 이 모든 것을 하나로 묶습니다.

```dart
// 기본 중력을 적용합니다
velocity.y += gravity;

// ember가 점프했는지 판단합니다
if (hasJumped) {
  if (isOnGround) {
    velocity.y = -jumpSpeed;
    isOnGround = false;
  }
  hasJumped = false;
}

// ember가 너무 빠르게 점프하거나, 너무 빠르게 떨어져서
// 땅이나 플랫폼을 뚫고 지나가는 것을 막습니다.
velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
```

앞에서 Ember가 잔디 한가운데에 있다고 했습니다. 이를 해결하고 Ember에서 충돌과
중력이 어떻게 동작하는지 보여 주기 위해, 게임을 시작할 때 살짝 떨어지며 등장하도록 해 보겠습니다.
`lib/ember_quest.dart`의 `initializeGame` 메서드에서 다음을 변경합니다.

```dart
_ember = EmberPlayer(
  position: Vector2(128, canvasSize.y - 128),
);
```

이제 게임을 실행하면 Ember가 생성되어 땅으로 떨어집니다. 그런 다음 여기저기 점프할 수 있습니다!


<a id="collisions-with-objects"></a>

### 오브젝트와의 충돌

다른 오브젝트와의 충돌을 추가하는 것은 꽤 간단합니다.
`onCollision` 메서드 맨 아래에 다음을 추가하기만 하면 됩니다.

```dart
if (other is Star) {
  other.removeFromParent();
}

if (other is WaterEnemy) {
  hit();
}
```

Ember가 별과 충돌하면 게임은 별을 제거합니다. 그리고 Ember가 적과 충돌했을 때를 위한
`hit` 메서드를 구현하려면 다음을 해야 합니다.

`EmberPlayer` 클래스 맨 위에 다음 변수를 추가합니다.

```dart
bool hitByEnemy = false;
```

또한 `EmberPlayer` 클래스에 이 메서드를 추가합니다.

```dart
// 이 메서드는 ember에 불투명도 이펙트를 실행해
// 깜빡이게 합니다.
void hit() {
  if (!hitByEnemy) {
    hitByEnemy = true;
  }
  add(
    OpacityEffect.fadeOut(
    EffectController(
      alternate: true,
      duration: 0.1,
      repeatCount: 6,
    ),
    )..onComplete = () {
      hitByEnemy = false;
    },
  );
}
```

자동 import가 되지 않았다면 파일에 다음 import를 추가해야 합니다.

```dart
import 'package:flame/effects.dart';

import '../objects/star.dart';
import 'water_enemy.dart';
```

이제 게임을 실행하면 이리저리 움직이고, 별을 사라지게 할 수 있으며, 적과
충돌하면 Ember가 깜빡일 것입니다.


<a id="adding-the-scrolling"></a>

## 스크롤 추가

이것이 Ember와 관련된 마지막 작업입니다. 지금은 Ember가 화면 밖으로 나갈 수 있고
맵은 전혀 움직이지 않으므로 Ember의 이동을 제한해야 합니다. 이 기능을 구현하려면
`update` 메서드 끝에 다음을 추가하기만 하면 됩니다.

```dart
gameRef.objectSpeed = 0;
// 화면 가장자리에서 ember가 뒤로 가지 못하게 합니다.
if (position.x - 36 <= 0 && horizontalDirection < 0) {
  velocity.x = 0;
}
// ember가 화면 절반을 넘어가지 못하게 합니다.
if (position.x + 64 >= gameRef.size.x / 2 && horizontalDirection > 0) {
  velocity.x = 0;
  gameRef.objectSpeed = -moveSpeed;
}

position += velocity * dt;
super.update(dt);
```

이제 게임을 실행하면 Ember는 왼쪽 화면 밖으로 나갈 수 없고, 오른쪽으로 이동하다가
화면 가운데에 도달하면 나머지 오브젝트들이 스크롤됩니다. 이는 시리즈 초반에 만든
`gameRef.objectSpeed`를 이제 업데이트하고 있기 때문입니다. 또한
땅 블록에서 한 작업 덕분에 다음 무작위 세그먼트가 생성되어 레벨에 추가되는 것을 볼 수 있습니다.

```{note}
앞에서 이 게임을 전통적인 레벨 방식의 게임으로 바꾸는 방법에 대한 섹션을
추가하겠다고 했습니다. [](step_3.md)에서 세그먼트를 만들 때처럼, 문이나 특별한
블록이 있는 세그먼트를 추가할 수 있습니다. 세그먼트가 `X`개 로드될 때마다
그 특별한 세그먼트를 추가하면 됩니다. Ember가 그 오브젝트에 도달하면
모은 별과 체력을 유지한 채 레벨을 다시 로드해 처음부터 시작할 수 있습니다.
```

거의 다 왔습니다! [](step_6.md)에서는 체력 시스템을 추가하고, 점수를 기록하며,
그 정보를 플레이어에게 전달하는 HUD를 제공하겠습니다.
