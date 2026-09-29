<a id="layers-and-snapshots"></a>

# 레이어와 스냅샷

레이어와 스냅샷은 성능 향상을 위해 객체를 미리 렌더링하고 캐시하는 기능 등 몇 가지 공통점이
있습니다. 하지만 각각 고유한 기능도 있어서 서로 다른 용도에
더 적합합니다.

`Snapshot`은 어떤 `PositionComponent`에든 추가할 수 있는 믹스인입니다. 다음과 같은 경우에 사용하세요.

- 기존 게임 객체(`PositionComponent`인 것)에 믹스인으로 추가할 때
- 렌더링이 복잡한 스프라이트 같은 게임 객체를 캐시할 때
- 같은 객체를 매번 렌더링하지 않고 여러 번 그릴 때
- (예를 들어) 스크린샷으로 저장하기 위해 이미지 스냅샷을 캡처할 때

`Layer`는 클래스입니다. 다음과 같은 경우에 이 클래스를 사용하거나 확장하세요.

- 논리적인 레이어(예: UI, 전경, 메인, 배경)로 게임을 구조화할 때
- 객체들을 묶어 복잡한 장면을 만들고, 이를 캐시할 때(예: 배경 레이어)
- 프로세서 지원이 필요할 때. 레이어를 사용하면 사용자 정의 프로세서를 렌더링 전후에 실행할 수 있습니다.


<a id="layers"></a>

## 레이어

레이어를 사용하면 컨텍스트별로 렌더링을 묶을 수 있고, 미리 렌더링해 둘 수도 있습니다.
예를 들어 배경처럼 자주 바뀌지 않는 게임의 일부분을 메모리에 렌더링해 둘 수 있습니다.
이렇게 하면 매 게임 틱마다 렌더링해야 하는 보다 동적인 콘텐츠에 처리 능력을
더 쓸 수 있습니다.

Flame에는 두 가지 유형의 레이어가 있습니다.

- `DynamicLayer`: 움직이거나 변하는 것들을 위한 레이어입니다.
- `PreRenderedLayer`: 정적인 것들을 위한 레이어입니다.


### DynamicLayer

동적 레이어는 캔버스에 그려질 때마다 렌더링되는 레이어입니다. 이름에서
알 수 있듯이 동적인 콘텐츠를 위한 것이며, 같은 컨텍스트를 가진 객체들의 렌더링을 묶을 때
가장 유용합니다.

사용 예:

```dart
class GameLayer extends DynamicLayer {
  final MyGame game;

  GameLayer(this.game);

  @override
  void drawLayer() {
    game.playerSprite.render(
      canvas,
      position: game.playerPosition,
    );
    game.enemySprite.render(
      canvas,
      position: game.enemyPosition,
    );
  }
}

class MyGame extends Game {
  // 다른 메서드는 생략...

  @override
  void render(Canvas canvas) {
    gameLayer.render(canvas); // x와 y를 선택적 위치 인자로 전달할 수 있습니다
  }
}
```


### PreRenderedLayer

미리 렌더링된 레이어는 한 번만 렌더링되어 메모리에 캐시되고, 그 이후에는 게임 캔버스에
그대로 복제됩니다. 예를 들어 배경처럼 게임 도중 변하지 않는 콘텐츠를 캐시할 때
유용합니다.

사용 예:

```dart
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite);

  @override
  void drawLayer() {
    sprite.render(
      canvas,
      position: Vector2(50, 200),
    );
  }
}

class MyGame extends Game {
  // 다른 메서드는 생략...

  @override
  void render(Canvas canvas) {
    // x와 y를 선택적 위치 인자로 전달할 수 있습니다.
    backgroundLayer.render(canvas);
  }
}
```


<a id="layer-processors"></a>

### 레이어 프로세서

Flame은 레이어에 프로세서를 추가하는 방법도 제공합니다. 프로세서는 레이어 전체에 효과를
추가하는 수단입니다. 현재 기본으로 제공되는 것은 `ShadowProcessor`뿐이며, 이 프로세서는
레이어 뒤에 드롭 섀도를 렌더링합니다.

레이어에 프로세서를 추가하려면 다음과 같이 레이어의 `preProcessors` 또는 `postProcessors`
리스트에 추가하기만 하면 됩니다.

```dart
// DynamicLayer와 PreRenderedLayer 모두 동일하게 동작합니다
class BackgroundLayer extends PreRenderedLayer {
  final Sprite sprite;

  BackgroundLayer(this.sprite) {
    preProcessors.add(ShadowProcessor());
  }

  @override
  void drawLayer() { /* 생략 */ }

  // ...
```

`LayerProcessor` 클래스를 확장해 사용자 정의 프로세서를 만들 수 있습니다.

[레이어의 동작 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/layers_example.dart)를 참고하세요.


<a id="snapshots"></a>

## 스냅샷

스냅샷은 레이어의 대안입니다. `Snapshot` 믹스인은 어떤 `PositionComponent`에든 적용할 수 있습니다.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;

  @override
  Future<void> onLoad() async {
    // 스냅샷 컴포넌트를 추가합니다.
    root = SnapshotComponent();
    add(root);
  }
}
```


<a id="render-as-a-snapshot"></a>

### 스냅샷으로 렌더링하기

스냅샷이 활성화된 컴포넌트에서 `renderSnapshot`을 `true`(기본값)로 설정하면
`PreRenderedLayer`와 비슷하게 동작합니다. 컴포넌트는 한 번만 렌더링되어 메모리에 캐시되고, 그 이후에는
게임 캔버스에 그대로 복제됩니다. 배경처럼 게임 도중 변하지 않는 콘텐츠를
캐시할 때 유용합니다.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;
  late final SpriteComponent background1;
  late final SpriteComponent background2;

  @override
  Future<void> onLoad() async {
    // 스냅샷 컴포넌트를 추가합니다.
    root = SnapshotComponent();
    add(root);

    // 자식 몇 개를 추가합니다.
    final background1Sprite = Sprite(await images.load('assets/images/background1.png'));
    background1 = SpriteComponent(sprite: background1Sprite);
    root.add(background1);

    final background2Sprite = Sprite(await images.load('assets/images/background2.png'));
    background2 = SpriteComponent(sprite: background2Sprite);
    root.add(background2);

    // 이제 root는 (자기 자신과 모든 자식을) 한 번 렌더링한 뒤 그 결과를
    // 캐시합니다. 이후의 render 호출에서는 root 자신도, 그 자식들도
    // 렌더링되지 않습니다. 대신 성능 향상을 위해 스냅샷이
    // 사용됩니다.
  }
}
```


<a id="regenerating-a-snapshot"></a>

#### 스냅샷 다시 생성하기

스냅샷이 활성화된 컴포넌트는 자식들을 포함한 트리 전체의 스냅샷을 생성합니다.
자식 중 하나라도 변경되면(예를 들어 위치가 바뀌거나 애니메이션되는 경우)
`takeSnapshot`을 호출해 캐시된 스냅샷을 업데이트하세요. 자식들이 매우 자주 변한다면 성능상 이점이 없으므로
`Snapshot`을 사용하지 않는 것이 좋습니다.

스냅샷을 렌더링하는 컴포넌트는 성능 비용 없이 여전히 변환할 수 있습니다.
스냅샷을 찍은 후에도 컴포넌트의 스케일을 조정하고, 이동하고, 회전할 수 있습니다. 하지만
컴포넌트의 내용(무엇을 렌더링하는지)이 바뀌면 `takeSnapshot`을 호출해
스냅샷을 다시 생성해야 합니다.


<a id="taking-a-snapshot"></a>

### 스냅샷 찍기

스냅샷이 활성화된 컴포넌트는 `renderSnapshot`이 false로 설정되어 있더라도 언제든지
스냅샷을 생성하는 데 사용할 수 있습니다. 화면 캡처를 하거나, 게임 전체 또는 일부의 정적 스냅샷이
필요한 그 밖의 용도에 유용합니다.

스냅샷은 항상 변환이 적용되지 않은 상태로 생성됩니다. 즉, 스냅샷이 활성화된
컴포넌트가 위치 (0,0)에 있고 스케일이나 회전이 적용되지 않은 것처럼 생성됩니다.

스냅샷은 `Picture`로 저장되지만, `snapshotToImage`를 사용해 `Image`로 변환할 수 있습니다.

```dart
class SnapshotComponent extends PositionComponent with Snapshot {}

class MyGame extends FlameGame {
  late final SnapshotComponent root;

  @override
  Future<void> onLoad() async {
    // 스냅샷 컴포넌트를 추가하되, 렌더링 모드는 사용하지 않습니다.
    root = SnapshotComponent()..renderSnapshot = false;
    add(root);

    // 다른 코드는 생략.
  }

  // 언제든 이와 같은 코드를 호출해 이미지 스냅샷을 찍을 수 있습니다.
  void takeSnapshot() {
    root.takeSnapshot();
    final image = root.snapshotToImage(200, 200);
  }
}
```


<a id="snapshots-that-are-cropped-or-off-center"></a>

### 잘리거나 중심에서 벗어난 스냅샷

스냅샷 `Image`가 잘려 보이거나 예상한 위치에 있지 않을 때가 있습니다.

이는 `Picture`의 내용은 원점을 기준으로 어디에든 위치할 수 있지만,
`Image`로 변환될 때 이미지는 항상 `0,0`에서 시작하기 때문입니다. 즉,
음수 위치에 있는 것은 모두 잘립니다.

이 문제를 해결하는 가장 좋은 방법은 `Snapshot` 컴포넌트가 게임을 기준으로 항상 위치
`0,0`에 있도록 하고 절대 움직이지 않는 것입니다. 그러면 이미지에는 대개
예상한 내용이 담기게 됩니다.

하지만 항상 이렇게 할 수 있는 것은 아닙니다. 이미지로 변환하기 전에 스냅샷을 이동(또는 회전, 스케일 조정 등)하려면
다음과 같이 `snapshotToImage`에 변환 행렬을 전달하세요.

```dart
// 언제든 이와 같은 코드를 호출해 이미지 스냅샷을 찍을 수 있습니다.
void takeSnapshot() {
  // 스냅샷을 200,50만큼 이동하는 행렬을 준비합니다.
  final matrix = Matrix4.identity()..translate(200.0,50.0);

  root.takeSnapshot();
  final image = root.snapshotToImage(200, 200, transform: matrix);
}
```
