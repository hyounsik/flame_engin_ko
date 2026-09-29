<a id="adding-bullets"></a>

# 총알 추가

이번 단계에서는 모든 슈팅 게임에서 아주 중요한 기능인 사격을 추가하겠습니다!

구현 방법은 다음과 같습니다. 이미 마우스/손가락으로 화면을 드래그해 우주선을 조작하고 있으므로,
플레이어가 드래그를 시작하면 우주선이 자동으로 사격하고
제스처/입력이 끝나면 사격을 멈추도록 하겠습니다.

먼저 게임에서 발사체를 나타낼 `Bullet` 컴포넌트를 만들어 봅시다. 이를 위해
총알 스프라이트가 필요합니다. 아래 이미지를 마우스 오른쪽 버튼으로 클릭하고 "다른 이름으로 저장..."을 선택해
`assets/images/` 폴더에 `bullet.png`로 저장합니다.

![bullet](app/assets/images/bullet.png)

```dart
class Bullet extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
          size: Vector2(25, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await gameRef.loadSpriteAnimation(
      'assets/images/bullet.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(8, 16),
      ),
    );
  }
}
```

지금까지는 새로운 개념이 없습니다. 컴포넌트를 하나 만들고
애니메이션 속성을 설정했을 뿐입니다.

`Bullet`의 동작은 간단합니다. 항상 화면 위쪽으로 이동하고, 더 이상 보이지 않으면
게임에서 제거되어야 합니다. 그러니 `update` 메서드를 추가해
이를 구현해 봅시다.

```dart
class Bullet extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
          size: Vector2(25, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // 생략
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * -500;

    if (position.y < -height) {
      removeFromParent();
    }
  }
}
```

위 코드는 이해하기 쉽겠지만, 하나씩 살펴봅시다.

- 총알의 y축 위치에 초당 -500픽셀의 비율로 값을 더합니다. 화면의 왼쪽 위 모서리가 `0, 0`이므로
y축에서 위로 간다는 것은 `0`에 가까워진다는 뜻임을 기억하세요.
- y가 총알 높이의 음수 값보다 작다면, 컴포넌트가
화면 밖으로 완전히 나갔다는 뜻이므로 제거할 수 있습니다.

좋습니다. 이제 `Bullet` 클래스가 준비되었으니 사격 동작을 구현해 봅시다.
먼저 `Player` 클래스에 `startShooting()`과
`stopShooting()`이라는 빈 메서드 두 개를 만듭니다.

```dart
class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {

  // 나머지 구현은 생략

  void startShooting() {
    // TODO
  }

  void stopShooting() {
    // TODO
  }
}
```

그리고 우주선 이동에 이미 사용하고 있는 `DragCallbacks` 믹스인의 `onDragStart()`와
`onDragEnd()` 메서드를 사용해 게임 클래스에서 이 메서드들을 호출하도록
연결합니다.

```dart
class SpaceShooterGame extends FlameGame with DragCallbacks {
  late Player player;

  // 나머지 구현은 생략

  @override
  void onDragUpdate(DragUpdateEvent event) {
    player.move(event.localDelta);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    player.startShooting();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    player.stopShooting();
  }
}
```

`onDragStart`와 `onDragEnd`는 드래그 상태를 대신 추적해 주므로, 오버라이드한 메서드에서는
자신의 작업을 하기 전에 `super`를 호출해야 합니다.

이제 모든 준비가 끝났으니 플레이어 클래스에 사격 루틴을 작성해 봅시다.

사격 동작은 플레이어가 우주선을 드래그하는 동안 일정한 시간 간격으로 총알을
추가하는 것이라는 점을 기억하세요.

시간 간격 코드와 생성(spawn)을 직접 구현할 수도 있지만, Flame은
이를 위한 컴포넌트인 `SpawnComponent`를 기본으로 제공하므로 이를 활용해 봅시다.


```dart
class Player extends SpriteAnimationComponent
    with HasGameRef<SpaceShooterGame> {
  late final SpawnComponent _bulletSpawner;

  @override
  Future<void> onLoad() async {
    // 애니메이션 로드는 생략

    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) {
        return Bullet(position: position + Vector2(0, -height / 2));
      },
      autoStart: false,
    );

    gameRef.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }
}
```

위 코드는 따로 설명하지 않아도 이해할 수 있기를 바라지만, 좀 더 자세히 살펴봅시다.

- 먼저 게임 클래스에 `_bulletSpawner`라는 `SpawnComponent`를 선언했습니다.
`startShooting`과 `stopShooting` 메서드에서 접근할 것이므로 컴포넌트 전체에서
접근 가능한 변수여야 했습니다.
- `onLoad` 메서드에서 `_bulletSpawner`를 초기화합니다. 첫 번째 인자인 `period`에는
호출 사이에 걸리는 시간을 초 단위로 설정하며, 지금은 `.2`초로 정했습니다.
- 총알이 우주선에서 나오도록 위치를 직접 처리하고 싶으므로, 생성 컴포넌트가 만들어진 컴포넌트의 위치를
지정하지 않도록 `selfPositioning: true`를 설정합니다.
- `factory` 속성은 `period`에 도달할 때마다 호출되어 생성된 컴포넌트를
반환하는 함수를 받습니다.
- 기본적으로 시작되지 않도록 `autoStart: false`를 설정합니다.
- 마지막으로 게임 루프에서 처리될 수 있도록 `_bulletSpawner`를 컴포넌트에 추가합니다.
- 총알은 플레이어 자체가 아니라 게임 전체의 일부이므로, `_bulletSpawner`를 플레이어가 아닌
게임에 추가한다는 점에 주목하세요.

`_bulletSpawner`를 모두 설정했으니, 이제 남은 것은 `startShooting()`에서
`_bulletSpawner.timer`를 시작하고 `stopShooting()`에서 멈추는 것뿐입니다!

이것으로 이 단계를 마치며, 진짜 게임에 한층 가까워졌습니다!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step4
:show: popup code
```

[다음 단계: 적 추가](./step_5.md)
