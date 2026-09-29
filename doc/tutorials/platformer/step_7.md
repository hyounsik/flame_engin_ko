<a id="7-adding-menus"></a>

# 7. 메뉴 추가

게임에 메뉴를 추가하기 위해 Flame에 내장된
[오버레이](../../flame/overlays.md) 시스템을 활용하겠습니다.


<a id="main-menu"></a>

## 메인 메뉴

`lib/overlays` 폴더에 `main_menu.dart`를 만들고 다음 코드를 추가합니다.

```dart
import 'package:flutter/material.dart';

import '../ember_quest.dart';

class MainMenu extends StatelessWidget {
  // 부모 게임에 대한 참조입니다.
  final EmberQuestGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 250,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ember Quest',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 40.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
'''Use WASD or Arrow Keys for movement.
Space bar to jump.
Collect as many stars as you can and avoid enemies!''',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

```

이 파일은 표준 Flutter 위젯만 사용해 정보를 표시하고 `Play` 버튼을 제공하므로
따로 설명할 필요가 거의 없습니다. Flame과 관련된 유일한 줄은
`game.overlays.remove('MainMenu');`로, 사용자가 게임을 플레이할 수 있도록 오버레이를 제거하기만
합니다. 참고로 이 메뉴가 표시되는 동안에도 기술적으로는 사용자가 Ember를 움직일 수 있지만,
입력을 가로채는 방법은 여러 가지가 있으므로 이 튜토리얼의 범위를
벗어납니다.


<a id="game-over-menu"></a>

## 게임 오버 메뉴

다음으로 `lib/overlays/game_over.dart`라는 파일을 만들고 다음 코드를 추가합니다.

```dart
import 'package:flutter/material.dart';

import '../ember_quest.dart';

class GameOver extends StatelessWidget {
  // 부모 게임에 대한 참조입니다.
  final EmberQuestGame game;
  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 200,
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    game.reset();
                    game.overlays.remove('GameOver');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

메인 메뉴와 마찬가지로, 오버레이를 제거하는 호출과 지금 만들 `game.reset()` 호출을
제외하면 모두 표준 Flutter 위젯입니다.

`lib/ember_quest.dart`를 열고 다음 코드를 추가하거나 수정합니다.

```dart
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
  initializeGame(true);
}

void initializeGame(bool loadHud) {
  // size.x < 3200이라고 가정합니다
  final segmentsToLoad = (size.x / 640).ceil();
  segmentsToLoad.clamp(0, segments.length);

  for (var i = 0; i <= segmentsToLoad; i++) {
    loadGameSegments(i, (640 * i).toDouble());
  }

  _ember = EmberPlayer(
    position: Vector2(128, canvasSize.y - 128),
  );
  add(_ember);
  if (loadHud) {
    add(Hud());
  }
}

void reset() {
  starsCollected = 0;
  health = 3;
  initializeGame(false);
}
```

`initializeGame` 메서드에 파라미터를 추가해 게임에 HUD를 추가하는 것을
건너뛸 수 있게 한 것을 눈치챘을 것입니다. 이어지는 섹션에서 Ember의 체력이 0으로 떨어지면
게임을 초기화할 텐데, 이때 HUD는 제거할 필요 없이 `reset()`으로 값만
재설정하면 되기 때문입니다.


<a id="displaying-the-menus"></a>

## 메뉴 표시하기

메뉴를 표시하려면 `lib/main.dart`에 다음 코드를 추가합니다.

```dart
void main() {
  runApp(
    GameWidget<EmberQuestGame>.managed(
      gameFactory: EmberQuestGame.new,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'GameOver': (_, game) => GameOver(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
```

메뉴가 자동으로 import되지 않았다면 다음을 추가합니다.

```dart
import 'overlays/game_over.dart';
import 'overlays/main_menu.dart';
```

이제 게임을 실행하면 메인 메뉴 오버레이가 반겨 줄 것입니다. Play를 누르면
메뉴가 제거되고 게임을 시작할 수 있습니다.


<a id="health-check-for-game-over"></a>

### 게임 오버를 위한 체력 확인

Ember Quest를 완성하기 위한 마지막 단계는 게임 오버 메커니즘을 추가하는 것입니다. 꽤 간단하지만
모든 컴포넌트에 비슷한 코드를 넣어야 합니다. 그럼 시작해 봅시다!

`lib/actors/ember.dart`의 `update` 메서드에 다음을 추가합니다.

```dart
// ember가 구덩이에 빠지면 게임 오버입니다.
if (position.y > gameRef.size.y + size.y) {
  gameRef.health = 0;
}

if (gameRef.health <= 0) {
  removeFromParent();
}
```

`lib/actors/water_enemy.dart`의 `update` 메서드에서 다음 코드를 수정합니다.

```dart
if (position.x < -size.x || gameRef.health <= 0) {
  removeFromParent();
}
```

`lib/objects/ground_block.dart`의 `update` 메서드에서 다음 코드를 수정합니다.

```dart
if (gameRef.health <= 0) {
  removeFromParent();
}
```

`lib/objects/platform_block.dart`의 `update` 메서드에서 다음 코드를 수정합니다.

```dart
if (position.x < -size.x || gameRef.health <= 0) {
  removeFromParent();
}
```

`lib/objects/star.dart`의 `update` 메서드에서 다음 코드를 수정합니다.

```dart
if (position.x < -size.x || gameRef.health <= 0) {
  removeFromParent();
}
```

마지막으로 `lib/ember_quest.dart`에 다음 `update` 메서드를 추가합니다.

```dart
@override
void update(double dt) {
  if (health <= 0) {
    overlays.add('GameOver');
  }
  super.update(dt);
}
```


<a id="congratulations"></a>

## 축하합니다

해냈습니다! 이제 동작하는 Ember Quest가 완성되었습니다. 아래 버튼을 눌러 완성된 코드가
어떤 모습인지 보거나 직접 플레이해 보세요.

```{flutter-app}
:sources: ../tutorials/platformer/app
:show: popup code
```
