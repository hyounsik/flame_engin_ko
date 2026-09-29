<a id="migration-guides"></a>

# 마이그레이션 가이드

이 섹션에서는 Flame의 메이저 버전 간에 업그레이드할 때 알아야 할 호환성을 깨는 변경 사항(breaking
change)과, 코드를 마이그레이션하는 데 필요한 단계를 설명합니다.


<a id="migrating-from-v1380-to-v200"></a>

## v1.38.0에서 v2.0.0으로 마이그레이션


<a id="games-are-opaque-to-hit-tests-by-default"></a>

### 게임은 기본적으로 히트 테스트에 대해 불투명합니다

예전에 `FlameGame`은 컴포넌트 트리를 순회하면서 `PointerInputCallbacks`를 구현한 컴포넌트가 있는
위치에서만 히트를 보고하는 방식으로 `containsEventHandlerAt`에 응답했습니다. 이제는 기본 `Game` 클래스처럼
모든 위치에서 히트를 보고하며, 트리 순회는 옵트인(opt-in) 방식입니다.

```dart
// 이전: 암묵적으로 동작하며, deferToChild에서 히트 테스트마다 비용이 발생
class MyGame extends FlameGame {}

// 이후
class MyGame extends FlameGame with DeferHitTestToComponents {}
```

이 변경은 `HitTestBehavior.deferToChild`로 만든 게임에만 영향을 줍니다. `opaque`(기본값)와
`translucent`는 게임에 묻지 않기 때문입니다. `GameWidget` 뒤에 있는 위젯까지 이벤트가 전달되도록
`deferToChild`를 사용하고 있다면, 믹스인을 추가하거나 더 저렴한 자체 규칙으로
`containsEventHandlerAt`을 오버라이드하세요.

이와 별개로, 이제 `translucent`도 더 이상 게임에 묻지 않습니다. Flutter에서 이 값의 의미는 "나도
히트되고, 내 뒤에 있는 것도 히트된다"이므로, 이제 게임은 항상 히트되고 통과 처리는 Flutter에
맡겨집니다. 이전에는 translucent 게임이 상호작용 가능한 컴포넌트가 없는 위치에서는 전혀 히트될 수
없었습니다.

전체 내용은 [Hit Test Behavior](game_widget.md#hit-test-behavior)를 참고하세요.


<a id="the-gesture-listener-interfaces-removed"></a>

### 제스처 리스너 인터페이스 제거

`MultiTapListener`, `MultiDragListener`, `ScaleListener`가 대체 없이 제거되었습니다.

이 인터페이스들은 하나의 어댑터가 두 가지 구현, 즉 컴포넌트 수준의 믹스인이나 그에 대응하는 게임
수준의 디텍터 중 어느 쪽과도 동작할 수 있도록 하기 위해 존재했습니다. 그 디텍터들은 v2 재작성
과정에서 먼저 제거되었고, 결국 각 인터페이스에는 구현이 하나씩만 남고 인터페이스로서 사용하는 곳은
하나도 남지 않았습니다.

이 인터페이스 중 하나를 직접 구현했다면, 대신 컴포넌트나 게임에 `TapCallbacks`, `DragCallbacks`
또는 `ScaleCallbacks` 믹스인을 사용하세요. 이 인터페이스들이 이미 안내하던 대상이기도 합니다.

`FlameDragAdapter`도 사라졌으며, `MultiDragScaleDispatcher` 안의 private 클래스로 합쳐졌습니다. 이미
`@internal`이었기 때문에 Flame 외부에서는 생성할 수 없었습니다.


<a id="hasgamereference-removed-in-favour-of-hasgameref"></a>

### `HasGameReference`가 제거되고 `HasGameRef`로 대체

`HasGameReference`가 제거되었습니다. 대신 `HasGameRef`를 사용하세요. `HasGameRef`는 더 이상 지원
중단(deprecated) 상태가 아니며, 이제 컴포넌트에서 게임 인스턴스에 접근하는 데 사용하는 유일한
믹스인입니다. 접근자의 이름은 `gameRef`이며, `game` getter와 setter는 사라졌습니다.

```dart
// 이전
class MyComponent extends Component with HasGameReference<MyGame> {
  void doSomething() => game.score++;
}

// 이후
class MyComponent extends Component with HasGameRef<MyGame> {
  void doSomething() => gameRef.score++;
}
```

이미 `HasGameRef`를 사용하고 있었다면 변경할 것이 없습니다. 접근자는 여전히 `gameRef`입니다.

게임 인스턴스를 명시적으로 설정하는 것(테스트에서 모킹할 때 유용)도 `gameRef`를 통해 하며,
`findGame()` 오버라이드는 이전과 똑같이 동작합니다.


<a id="hasworldreference-renamed-to-hasworldref"></a>

### `HasWorldReference`의 이름이 `HasWorldRef`로 변경

`HasWorldReference`의 이름이 `HasWorldRef`로 바뀌었고, 접근자 `world`의 이름도 `worldRef`로
바뀌어서 `HasGameRef`/`gameRef`와 정확히 대응됩니다. 이전 이름은 사라졌으며, 지원 중단(deprecated)
별칭도 없습니다.

```dart
// 이전
class MyComponent extends Component with HasWorldReference<MyWorld> {
  void doSomething() => world.add(AnotherComponent());
}

// 이후
class MyComponent extends Component with HasWorldRef<MyWorld> {
  void doSomething() => worldRef.add(AnotherComponent());
}
```

이 변경은 믹스인의 접근자에만 영향을 준다는 점에 유의하세요. `FlameGame.world`와
`CameraComponent.world`는 바뀌지 않았습니다. 월드 인스턴스를 명시적으로 설정하는 것(테스트에서
모킹할 때 유용)은 이제 `worldRef`를 통해 하며, `findWorld()`는 이전과 똑같이 동작합니다.

믹스인을 간접적으로 얻는 컴포넌트도 영향을 받습니다. `flame_3d`의 `Component3D`는
`HasWorldRef<World3D>`를 믹스인하므로, 자신을 감싸는 월드에 접근하는 하위 클래스는 `worldRef`를
사용해야 합니다.


<a id="asset-prefix-removed"></a>

### 에셋 prefix 제거

`Images`와 `AssetsCache`는 더 이상 전달받은 경로 앞에 아무것도 붙이지 않습니다. 이전에 `Images`는
`assets/images/`를, `AssetsCache`는 `assets/`를 앞에 붙였으며, 둘 다 `prefix` 속성으로 설정할 수
있었습니다. 이 속성은 `prefix` 생성자 인자와 함께 사라졌습니다.

이제 모든 에셋은 `pubspec.yaml`에 선언한 그대로의 전체 경로로 지정합니다.

```dart
// 이전
await Flame.images.load('player.png');
final level = await Flame.assets.readJson('levels/level1.json');

// 이후
await Flame.images.load('assets/images/player.png');
final level = await Flame.assets.readJson('assets/levels/level1.json');
```

이는 해당 캐시를 통해 로드하는 모든 것에 적용됩니다. `Sprite.load`, `SpriteAnimation.load`,
`SpriteBatch.load`, `Game.loadSprite`, `Game.loadSpriteAnimation`, `Parallax` 로더와
`ParallaxImageData`/`ParallaxAnimationData`, 그리고 `SpriteWidget`, `SpriteAnimationWidget`,
`NineTileBoxWidget`, `SpriteButton`의 `.asset` 생성자가 포함됩니다.

사용자 정의 prefix에 의존하고 있었다면, 이를 대체할 것도 설정할 것도 없습니다. 실제로 원하는 경로를
그대로 쓰면 됩니다.

```dart
// 이전
Flame.images.prefix = 'gfx/';
await Flame.images.load('player.png');

// 이후
await Flame.images.load('gfx/player.png');
```


<a id="cache-keys-are-now-the-full-path"></a>

#### 이제 캐시 키는 전체 경로입니다

경로는 에셋이 캐시되는 키이기도 하므로, 키로 캐시를 읽는 모든 곳에서도 같은 전체 경로가 필요합니다.

```dart
// 이전
await Flame.images.load('player.png');
final image = Flame.images.fromCache('player.png');

// 이후
await Flame.images.load('assets/images/player.png');
final image = Flame.images.fromCache('assets/images/player.png');
```

이는 `Images.fromCache`, `Images.containsKey`, `Images.clear`, `Images.keys`,
`AssetsCache.fromCache`, `AssetsCache.clear`에 영향을 줍니다. 로드할 때 사용한 경로로부터 내부
`imageKey`를 만드는 `SpriteBatch`도 영향을 받습니다.

그 결과 버그 하나가 수정되었습니다. 이제 `Images.load`는 `AssetsCache`가 이미 하던 것처럼 캐시 키에
패키지를 포함합니다. 이전에는 서로 다른 두 패키지에서 같은 파일 이름을 로드하면 하나의 키에서
충돌이 일어났고, 두 번째 로드는 아무 경고 없이 첫 번째 패키지의 이미지를 반환했습니다.


<a id="loadallimages-and-loadallfrompattern-require-a-directory"></a>

#### `loadAllImages`와 `loadAllFromPattern`에 디렉터리 필요

이 두 메서드는 prefix를 사용해 에셋 매니페스트를 필터링하고, 결과 키에서 다시 prefix를 떼어 냈습니다.
이제는 대신 필수 인자인 `directory`를 받으며, 매니페스트의 전체 경로로 캐시 항목을 저장합니다. 번들
전체를 탐색하려면 빈 문자열을 전달하세요.

```dart
// 이전
await Flame.images.loadAllImages();

// 이후
await Flame.images.loadAllImages(directory: 'assets/images/');
```


#### `flame_audio`

전역 `AudioCache`가 이제 빈 prefix로 생성되므로, 오디오 경로도 전체 경로입니다.
더 이상 업데이트할 prefix가 없으므로 `FlameAudio.updatePrefix()`는 제거되었습니다.

```dart
// 이전
FlameAudio.play('explosion.mp3');
FlameAudio.bgm.play('music/theme.mp3');

// 이후
FlameAudio.play('assets/audio/explosion.mp3');
FlameAudio.bgm.play('assets/audio/music/theme.mp3');
```


#### `flame_tiled`

`TiledComponent.load`, `RenderableTiledMap.fromFile`, `RenderableTiledMap.fromString`,
`FlameTsxProvider.parse`에서 `prefix` 인자가 사라졌습니다. 이제 맵의 파일 이름은 전체 경로이며,
파일 이름에 경로 구분자가 포함되면 안 된다는 assertion은 제거되었습니다.

외부 `.tsx` 타일셋은 그 경로에서 얻은 맵 자체의 디렉터리를 기준으로 한 상대 경로로 해석됩니다.
`RenderableTiledMap.fromString`에는 디렉터리를 얻을 경로가 없으므로, 이 메서드의 `prefix` 인자는
`tsxDirectory`가 되었습니다.

다음 두 가지는 컴파일 오류 없이 동작만 바뀌므로 주의하세요.
`RenderableTiledMap.fromString`의 `tsxDirectory`와 `FlameTsxProvider.parse`의 세 번째 인자는 이제
둘 다 기본값이 `''`입니다. 이전 `prefix`의 기본값은 `assets/tiles/`였습니다. 둘 중 하나를 직접
호출하면서 그 기본값에 의존하고 있었다면, 디렉터리를 명시적으로 전달하세요.

타일셋과 이미지 레이어의 소스는 새 `imagesDirectory` 인자를 기준으로 해석됩니다. 이 인자의 기본값은
`assets/images/`이므로 이전 동작이 유지됩니다.

```dart
// 이전
await TiledComponent.load('map.tmx', Vector2.all(16));
await TiledComponent.load(
  'map.tmx',
  Vector2.all(16),
  prefix: 'assets/maps/',
);

// 이후
await TiledComponent.load('assets/tiles/map.tmx', Vector2.all(16));
await TiledComponent.load('assets/maps/map.tmx', Vector2.all(16));
```

`TiledAtlas` 캐시 키는 이제 `imagesDirectory` 범위로 지정되므로, `tiles.png`였던 키는 이제
`assets/images/tiles.png`가 된다는 점에 유의하세요.


#### `flame_texturepacker`

`atlasFromAssets`, `TexturePackerAtlas.load`, `TexturePackerAtlas.loadAtlas`에서 `assetsPrefix`
인자가 사라졌습니다. 아틀라스 경로는 전체 경로이며, 아틀라스 안에 나열된 페이지 텍스처는 아틀라스
자체의 디렉터리를 기준으로 한 상대 경로로 해석됩니다.

```dart
// 이전
final atlas = await atlasFromAssets('atlas_map.atlas');

// 이후
final atlas = await atlasFromAssets('assets/images/atlas_map.atlas');
```


#### `flame_sprite_fusion`

`SpriteFusionTilemapComponent.load`에서 `tilemapPrefix` 인자가 사라졌습니다. 이제 `mapJsonFile`과
`spriteSheetFile` 모두 전체 경로입니다.

```dart
// 이전
await SpriteFusionTilemapComponent.load(
  mapJsonFile: 'map.json',
  spriteSheetFile: 'spritesheet.png',
);

// 이후
await SpriteFusionTilemapComponent.load(
  mapJsonFile: 'assets/tiles/map.json',
  spriteSheetFile: 'assets/images/spritesheet.png',
);
```


<a id="verticaldragdetector-and-horizontaldragdetector-removed"></a>

### `VerticalDragDetector`와 `HorizontalDragDetector` 제거

두 게임 수준 믹스인이 제거되었으며, Flame에는 직접적인 대체재가 없습니다.

이 믹스인들은 Flutter의 `VerticalDragGestureRecognizer`와 `HorizontalDragGestureRecognizer`를
노출하기 위해서만 존재했습니다. 이 인식기들의 특징은 필터링 자체가 아니라 Flutter의 제스처 아레나에서
동작하는 방식에 있습니다. 축이 제한된 인식기는 다른 축의 경쟁 인식기에게 양보합니다. 이는
`GameWidget`이 스크롤 가능한 위젯 안에 중첩되어 있을 때 중요한데, 이것은 게임이 아니라 위젯 트리의
관심사이며, 컴포넌트 수준의 `DragCallbacks`로는 재현할 수 없습니다.

게임이 모든 축의 드래그를 받는다면, 게임 클래스에 직접 믹스인할 수 있는 `DragCallbacks`를
사용하세요.

```dart
// 이전
class MyGame extends FlameGame with VerticalDragDetector {
  @override
  void onVerticalDragUpdate(DragUpdateInfo info) { /* ... */ }
}

// 이후
class MyGame extends FlameGame with DragCallbacks {
  @override
  void onDragUpdate(DragUpdateEvent event) { /* ... */ }
}
```

아레나 동작이 꼭 필요하다면, `GameWidget`을 Flutter 자체의
[`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)로 감싸고
그 위젯의 `onVerticalDragUpdate` / `onHorizontalDragUpdate` 콜백을 사용하세요.


<a id="forcepressdetector-removed"></a>

### `ForcePressDetector` 제거

`ForcePressDetector` 믹스인과 그 이벤트 클래스인 `ForcePressInfo`가 대체 없이
제거되었습니다.

이것은 일부 구형 Apple 3D Touch 기기에서만 사용할 수 있는 틈새 API였습니다. iPhone XS와 XS Max
(2018)가 이 기능을 탑재한 마지막 모델입니다(Apple의
[3D Touch 지원 모델](https://support.apple.com/guide/iphone/aside/iph945ccc462/14.0/ios/14.0)
목록을 참고하세요. Apple은 iOS 14 가이드 이후로는 이 목록조차 이어서 싣지 않았습니다). XR부터 그 이후의
모든 iPhone은 Haptic Touch를 사용하는데, 이는 얼마나 세게 누르는지가 아니라 얼마나 오래 누르는지에
반응하므로 이 콜백을 전혀 발생시키지 않습니다. 이를 지원한 Android 기기는 극소수였고, 그중 일부(Pixel 2와
3 등)는 어차피 콜백을 한 번도 발생시키지 않는 가짜 압력 센서를 가지고 있었습니다.

게다가 포스 프레스는 컴포넌트 수준 이벤트 시스템에 대응하는 기능이 없는 마지막 제스처였기 때문에,
이를 유지하는 것은 더 이상 API 표면적을 늘릴 만한 가치가 없었습니다.

여전히 3D Touch 기기를 대상으로 한다면, 이 제스처는 Flutter에서 그대로 사용할 수 있습니다.
`GameWidget`을
[`GestureDetector`](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)로 감싸고
그 위젯의 `onForcePressStart`, `onForcePressPeak`, `onForcePressUpdate`, `onForcePressEnd` 콜백을
직접 사용하세요.


<a id="deprecated-tap-and-long-press-game-detectors-removed"></a>

### 지원 중단된 탭 및 롱 프레스 게임 디텍터 제거

v1.38.0에서 지원 중단(deprecated)된 게임 수준 디텍터 믹스인이, 그 믹스인들만 사용하던 이벤트
클래스와 함께 이제 제거되었습니다.

| 제거됨                    | 대신 사용                  |
| ------------------------- | -------------------------- |
| `TapDetector`             | `TapCallbacks`             |
| `SecondaryTapDetector`    | `SecondaryTapCallbacks`    |
| `TertiaryTapDetector`     | `TertiaryTapCallbacks`     |
| `DoubleTapDetector`       | `DoubleTapCallbacks`       |
| `LongPressDetector`       | `LongPressCallbacks`       |
| `LongPressStartInfo`      | `LongPressStartEvent`      |
| `LongPressMoveUpdateInfo` | `LongPressMoveUpdateEvent` |
| `LongPressEndInfo`        | `LongPressEndEvent`        |

대체재는 게임이 아니라 컴포넌트에 믹스인하며, 각 콜백은 이벤트 객체 하나를
받습니다.

```dart
// 이전
class MyGame extends FlameGame with TapDetector {
  @override
  void onTapDown(TapDownInfo info) {
    final position = info.eventPosition.widget;
  }
}

// 이후
class MyComponent extends PositionComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
  }
}
```

컴포넌트는 `containsLocalPoint()`로 판단했을 때 자신 위에서 발생한 이벤트만 받는다는 점에 유의하세요.
반면 이전의 게임 수준 디텍터는 게임 표면에서 발생한 모든 이벤트를 받았습니다. 이전처럼 화면 전체에서
동작하게 하려면 믹스인을 `FlameGame` 하위 클래스에 직접 추가하세요. `FlameGame` 자체도
`Component`입니다.

전체 대체 API는 [탭 이벤트](inputs/tap_events.md)와 [롱 프레스 이벤트](inputs/long_press_events.md)를
참고하세요.


<a id="scaledetector-removed"></a>

### `ScaleDetector` 제거

`ScaleDetector` 게임 믹스인이 그 믹스인만 사용하던 이벤트 클래스와 함께 제거되었습니다.

| 제거됨            | 대신 사용          |
| ----------------- | ------------------ |
| `ScaleDetector`   | `ScaleCallbacks`   |
| `ScaleStartInfo`  | `ScaleStartEvent`  |
| `ScaleUpdateInfo` | `ScaleUpdateEvent` |
| `ScaleEndInfo`    | `ScaleEndEvent`    |

`ScaleUpdateEvent`는 `ScaleUpdateInfo`의 엄격한 상위 집합입니다. `info.scale.global.x`와
`info.scale.global.y`는 `event.horizontalScale`과 `event.verticalScale`이 되고,
`info.delta.global`은 `event.focalPointDelta`가 됩니다.

알아 두어야 할 동작 차이가 하나 있습니다. 이전 디텍터는 Flutter의 `ScaleGestureRecognizer`를 기반으로
했는데, 이 인식기는 *단일* 포인터에 대해서도 스케일 팩터 1.0으로 스케일 이벤트를 발생시킵니다. 게임들은
흔히 이 특이한 동작에 의존하여 `onScaleUpdate` 안에서 카메라를 이동(pan)시켰습니다. 새
`MultiDragScaleGestureRecognizer`는 두 개 이상의 포인터가 눌렸을 때만 스케일 이벤트를 발생시키므로,
이제 이동은 `DragCallbacks`로 처리해야 합니다. `DragCallbacks`는 `ScaleCallbacks`와 자유롭게 함께 사용할
수 있습니다.

```dart
// 이전
class MyGame extends FlameGame with ScaleDetector {
  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final scale = info.scale.global;
    if (!scale.isIdentity()) {
      camera.viewfinder.zoom = startZoom * scale.y;
    } else {
      camera.moveBy((info.delta.global..negate()) / camera.viewfinder.zoom);
    }
  }
}

// 이후
class MyGame extends FlameGame with ScaleCallbacks, DragCallbacks {
  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = startZoom * event.verticalScale;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // 두 손가락 핀치는 드래그와 스케일을 모두 발생시키므로, 줌 중에는 이동을 건너뜁니다
    if (isScaling) {
      return;
    }
    camera.moveBy((event.localDelta..negate()) / camera.viewfinder.zoom);
  }
}
```

현재 새 시스템에서는 트랙패드 핀치 제스처를 인식하지 못한다는 점에 유의하세요.
`MultiDragScaleGestureRecognizer`는 아직 Flutter의 `PointerPanZoom` 이벤트를 처리하지 않는데, 트랙패드
핀치는 이 이벤트를 통해 스케일 인식기에 전달됩니다. 터치스크린 핀치는 영향을 받지 않습니다.

전체 대체 API는 [스케일 이벤트](inputs/scale_events.md)를 참고하세요.


<a id="multitouchtapdetector-and-multitouchdragdetector-removed"></a>

### `MultiTouchTapDetector`와 `MultiTouchDragDetector` 제거

두 게임 수준 믹스인이 제거되었습니다.

| 제거됨                   | 대신 사용       |
| ------------------------ | --------------- |
| `MultiTouchTapDetector`  | `TapCallbacks`  |
| `MultiTouchDragDetector` | `DragCallbacks` |

이전에 별도의 첫 번째 인자로 전달되던 `pointerId`는 이제 이벤트 자체에 담겨 있으므로, 동시에 일어나는
터치를 여전히 구별할 수 있습니다.

```dart
// 이전
class MyGame extends FlameGame with MultiTouchTapDetector {
  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    taps[pointerId] = info.eventPosition.widget;
  }
}

// 이후
class MyGame extends FlameGame with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    taps[event.pointerId] = event.canvasPosition;
  }
}
```

`TapCallbacks`에는 `MultiTouchTapDetector.onTap`에 해당하는 것이 없습니다. 이 콜백은
`MultiTapGestureRecognizer`의 "탭 완료" 콜백을 그대로 전달하는 것이었습니다. 대신 제스처의 같은
시점에 발생하는 `onTapUp`을 사용하세요.

새 믹스인은 `MultiDragScaleDispatcher`를 통해 라우팅되므로, 제스처 아레나에서
`MultiTouchDragDetector`와 `PanDetector`를 함께 사용하지 못하도록 막던 assertion은 사라졌습니다
(`PanDetector` 자체도 사라졌습니다. 아래를 참고하세요).

전체 대체 API는 [탭 이벤트](inputs/tap_events.md)와 [드래그 이벤트](inputs/drag_events.md)를
참고하세요.


<a id="scrolldetector-removed"></a>

### `ScrollDetector` 제거

`ScrollDetector` 게임 믹스인이 그 믹스인만 사용하던 이벤트 클래스와 함께 제거되었습니다.

| 제거됨              | 대신 사용         |
| ------------------- | ----------------- |
| `ScrollDetector`    | `ScrollCallbacks` |
| `PointerScrollInfo` | `ScrollEvent`     |

이제 스크롤 델타는 중첩된 래퍼를 거치지 않고 이벤트에서 직접 읽으며, 이벤트에는 일반적인
`PositionEvent` 필드가 담겨 있으므로 스크롤이 발생한 위치를 `devicePosition` / `canvasPosition` /
`localPosition`으로 얻을 수 있습니다.

```dart
// 이전
class MyGame extends FlameGame with ScrollDetector {
  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom += info.scrollDelta.global.y.sign * 0.02;
  }
}

// 이후
class MyGame extends FlameGame with ScrollCallbacks {
  @override
  void onScroll(ScrollEvent event) {
    camera.viewfinder.zoom += event.scrollDelta.y.sign * 0.02;
  }
}
```

게임 표면 어디에서든 발생한 모든 스크롤 이벤트를 받던 이전 디텍터와 달리, `ScrollCallbacks`는 다른
컴포넌트 콜백처럼 위치에 따라 라우팅됩니다. 컴포넌트는 `containsLocalPoint()`로 판단했을 때 자신
위에서 발생한 스크롤만 받습니다. 위 예시처럼 `FlameGame` 하위 클래스에 직접 믹스인하면 이전처럼 표면
전체에서 동작합니다.

전체 대체 API는 [포인터 이벤트](inputs/pointer_events.md)를 참고하세요.


<a id="mousemovementdetector-removed-and-pointermove-renamed-to-mousemove"></a>

### `MouseMovementDetector` 제거 및 `PointerMove*`의 이름이 `MouseMove*`로 변경

`MouseMovementDetector` 게임 믹스인이 그 믹스인만 사용하던 이벤트 클래스와 함께 제거되었습니다.
동시에, 이를 대체하는 컴포넌트 수준 API의 이름이 `PointerMove`에서 `MouseMove`로
바뀌었습니다.

| 제거됨 / 이름 변경      | 대신 사용             |
| ----------------------- | --------------------- |
| `MouseMovementDetector` | `MouseMoveCallbacks`  |
| `PointerHoverInfo`      | `MouseMoveEvent`      |
| `PointerMoveCallbacks`  | `MouseMoveCallbacks`  |
| `PointerMoveEvent`      | `MouseMoveEvent`      |
| `PointerMoveDispatcher` | `MouseMoveDispatcher` |
| `onPointerMove`         | `onMouseMove`         |
| `onPointerMoveStop`     | `onMouseMoveStop`     |

이름을 바꾼 이유는 두 가지입니다. Flame의 `PointerMoveEvent`는 Flutter의 같은 이름의 클래스와
충돌하여, `package:flame/events.dart`와 `package:flutter/material.dart`를 모두 import하는 파일에서는
`hide`를 써야 했습니다. 그리고 "mouse move"가 단순히 더 정확합니다. 이 이벤트는 Flutter의
`PointerHoverEvent`를 감싸며 `MouseRegion`에서 전달되므로, 일반적인 포인터 이동이 아니라 구체적으로
마우스 이동입니다. `MouseMoveDispatcherKey`는 이미 이런 방식으로 이름이 지어져 있었습니다.

디텍터에서 마이그레이션할 때 콜백의 이름은 `onMouseMove` 그대로이고 파라미터만 바뀝니다. 위치는
중첩된 `eventPosition` 래퍼를 거치지 않고 이벤트에서 직접
읽습니다.

```dart
// 이전
class MyGame extends FlameGame with MouseMovementDetector {
  @override
  void onMouseMove(PointerHoverInfo info) {
    target = info.eventPosition.widget;
  }
}

// 이후
class MyGame extends FlameGame with MouseMoveCallbacks {
  @override
  void onMouseMove(MouseMoveEvent event) {
    target = event.canvasPosition;
  }
}
```

게임 표면 어디에서든 발생한 모든 마우스 이동을 받던 이전 디텍터와 달리, `MouseMoveCallbacks`는 다른
컴포넌트 콜백처럼 위치에 따라 라우팅됩니다. 컴포넌트는 `containsLocalPoint()`로 판단했을 때 자신
위에서 발생한 이동만 받습니다. 위 예시처럼 `FlameGame` 하위 클래스에 직접 믹스인하면 이전처럼 표면
전체에서 동작합니다.
`MouseMoveCallbacks`는 추가로 `onMouseMoveStop`을 제공하는데, 이는 이전 디텍터에는 없던
기능입니다.

`flame_test`의 `createMouseMoveEvent` 헬퍼는 이제 `MouseMoveEvent`를 반환합니다. 또한
`flame_behaviors`를 사용하고 있었다면, 이 패키지가 더 이상 레거시 `*Info` 이벤트 클래스를 다시
export하지 않는다는 점에 유의하세요.

전체 대체 API는 [포인터 이벤트](inputs/pointer_events.md)를 참고하세요.


<a id="pandetector-removed-and-with-it-the-whole-info-event-hierarchy"></a>

### `PanDetector` 제거 및 이에 따른 `*Info` 이벤트 계층 전체 제거

`PanDetector`는 마지막으로 남은 게임 수준 제스처 디텍터였으므로, 이를 제거하면서 디텍터들을 위해
존재하던 모든 이벤트 클래스도 제거되었습니다.

| 제거됨           | 대신 사용         |
| ---------------- | ----------------- |
| `PanDetector`    | `DragCallbacks`   |
| `DragStartInfo`  | `DragStartEvent`  |
| `DragUpdateInfo` | `DragUpdateEvent` |
| `DragEndInfo`    | `DragEndEvent`    |
| `DragDownInfo`   | —                 |
| `TapDownInfo`    | `TapDownEvent`    |
| `TapUpInfo`      | `TapUpEvent`      |
| `PositionInfo`   | `PositionEvent`   |

```dart
// 이전
class MyGame extends FlameGame with PanDetector {
  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }
}

// 이후
class MyGame extends FlameGame with DragCallbacks {
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    player.startShooting();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    player.move(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    player.stopShooting();
  }
}
```

알아 두어야 할 몇 가지 차이점이 있습니다.

- `onDragStart`, `onDragEnd`, `onDragCancel`은 `isDragged` 플래그를 관리하므로 `@mustCallSuper`입니다.
  오버라이드할 때는 먼저 `super`를 호출해야 합니다.
- `onPanDown`에 해당하는 것은 없습니다. 대신 `onDragStart`를 사용하세요. 이 콜백은 `onPanStart`와
  똑같이 터치 슬롭(touch slop)을 넘어섰을 때 발생합니다.
- 중첩된 위치 및 델타 래퍼가 사라졌습니다. `info.eventPosition.widget`은 `event.canvasPosition`이
  되고, `info.delta.global`은 `event.localDelta`가 됩니다(카메라 변환이 적용되기 전의 델타가 필요하다면
  `event.canvasDelta`).
- `DragEndEvent`는 `velocity`를 제공하지만, `DragEndInfo.primaryVelocity`에 대한 대체는 없습니다.
  축이 제한된 인식기만 이 값을 설정했으므로 어차피 항상 `null`이었습니다.
- 모든 드래그 이벤트에는 `pointerId`가 담겨 있으므로, 동시에 일어나는 드래그를 구별할 수 있습니다.
  `PanDetector`는 하나만 추적할 수 있었습니다.
- 다른 컴포넌트 콜백처럼 드래그도 위치에 따라 라우팅됩니다. 컴포넌트는 `containsLocalPoint()`로
  판단했을 때 자신 위에서 시작된 드래그만 받습니다. 위 예시처럼 `DragCallbacks`를 `FlameGame` 하위
  클래스에 직접 믹스인하면 이전처럼 표면 전체에서 동작합니다.

이로써 `package:flame/events.dart`와 `package:flame/input.dart`는 더 이상 어떤 `*Detector` 믹스인이나
`*Info` 클래스도 export하지 않으며, 그 디텍터들을 연결하기 위해서만 존재하던
`GestureDetectorBuilder.initializeGestures`도 제거되었습니다.

전체 대체 API는 [드래그 이벤트](inputs/drag_events.md)를 참고하세요.


<a id="ondragcancel-no-longer-delegates-to-ondragend"></a>

### `onDragCancel`이 더 이상 `onDragEnd`에 위임하지 않음

예전에 `DragCallbacks.onDragCancel`은 기본적으로 취소를 `onDragEnd` 이벤트로 변환했기 때문에, 취소된
드래그가 완료된 드래그와 똑같아 보였습니다. 취소는 제스처가 중단되었다는 뜻이며(다른 인식기가 제스처
아레나에서 이겼거나, 두 번째 포인터가 스케일 전환을 일으켰거나, 시스템 이벤트가 발생한 경우 등) 속도
정보도 없습니다. 그래서 드래그로 닫기(drag-to-dismiss) 같은 컴포넌트는 드래그가 끝나지 않았는데도
동작을 수행하곤 했습니다. 이는 드문 일도 아닙니다. `MultiDragScaleDispatcher`에서는 두 손가락 핀치를
할 때마다 개별 포인터 드래그가 취소되기 때문입니다.

이제 기본 구현은 `isDragged`만 초기화합니다. 즉, 드래그가 취소되면 더 이상 `onDragEnd`가 호출되지
않습니다. 이전 동작에 의존하고 있었다면 `onDragCancel`을 오버라이드하고
`DragCancelEvent.toDragEnd`로 이벤트를 직접 전달하세요.

```dart
// 이전
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    // 드래그가 취소되었을 때도 실행되었습니다.
    dismiss();
  }
}

// 이후
class MyComponent extends PositionComponent with DragCallbacks {
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    dismiss();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    onDragEnd(event.toDragEnd());
  }
}
```

취소된 드래그를 대신 되돌려야 한다면, `onDragEnd`를 호출하지 않고 그 로직을 `onDragCancel`에
넣으세요.


<a id="multidragdispatcher-removed"></a>

### `MultiDragDispatcher` 제거

지원 중단(deprecated)된 `MultiDragDispatcher`와 `MultiDragDispatcherKey` 별칭이 제거되었습니다. 이를
직접 사용하고 있었다면 대신 `MultiDragScaleDispatcher`와 `MultiDragScaleDispatcherKey`를 사용하세요
(보통은 믹스인만 사용하면 됩니다).

```dart
// 이전
game.findByKey(const MultiDragDispatcherKey())
    as MultiDragDispatcher?;

// 이후
game.findByKey(const MultiDragScaleDispatcherKey())
    as MultiDragScaleDispatcher?;
```


<a id="eventhandled-removed-in-favour-of-continuepropagation"></a>

### `Event.handled`가 제거되고 `continuePropagation`으로 대체

예전에는 이벤트에 서로 독립적인 두 개의 boolean이 있었습니다. Flame이 설정하지도 읽지도 않던
`handled`와, 이벤트가 컴포넌트 트리 아래로 계속 전달될지를 실제로 제어하는 `continuePropagation`입니다.
전자는 제거되었고, 이제 `continuePropagation`이 모든 이벤트의 유일한 전파 플래그입니다.

기본적으로 이벤트는 처리할 수 있는 첫 번째 컴포넌트에서 멈추므로, 이벤트를 "소비"하는 컴포넌트는 아무
것도 할 필요가 없습니다. 그 아래에 있는 컴포넌트는 이벤트를 보지 못합니다.

```dart
// 이전
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    if (!event.handled) {
      add(Square(event.localPosition));
    }
  }
}

// 이후
class Square extends RectangleComponent with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
  }
}

class MyWorld extends World with TapCallbacks {
  @override
  void onTapDown(TapDownEvent event) {
    add(Square(event.localPosition));
  }
}
```

`handled`를 사용해 이벤트가 여러 컴포넌트에 도달하도록 했다면, 대신 이벤트를 넘겨주어야 하는
컴포넌트에서 `event.continuePropagation = true`를 설정하세요.

지원 중단된 `*Info` 이벤트 클래스의 해당 필드(`TapDownInfo.handled` 등)도 함께
제거되었습니다.


<a id="add-addall-and-addtoparent-are-now-synchronous"></a>

### `add`, `addAll`, `addToParent`가 이제 동기 방식

예전에 `Component.add`, `Component.addAll`, `Component.addToParent`는 future를 반환했기 때문에, 추가
작업을 await할 수 있는 것처럼 보였습니다. 그 future는 자식의 로딩만 다룰 뿐 마운트는 다루지 않았으므로
await하는 것은 오해의 소지가 있었고, await하지 않거나 `unawaited`로 감싸지 않으면 많은 게임에서
`discarded_futures` 린트에 걸렸습니다. 이제 세 메서드 모두 `void`를 반환합니다.

`await`를 제거하세요.

```dart
// 이전
await add(MyComponent());
await addAll([MyComponent(), MyOtherComponent()]);

// 이후
add(MyComponent());
addAll([MyComponent(), MyOtherComponent()]);
```

반환된 future로 자식이 로드된 시점을 알고 있었다면, 대신 자식의 `loaded` future를
await하세요.

```dart
// 이전
await add(crate);

// 이후
add(crate);
await crate.loaded;
```

여러 자식을 한꺼번에 다룰 때는 모든 `Iterable<Component>`에서도 `loaded`, `mounted`, `removed`를
사용할 수 있습니다.

```dart
// 이전
await addAll(crates);

// 이후
addAll(crates);
await crates.loaded;
```

또는 단순히 로드되는 것이 아니라 `children`에 실제로 존재해야 한다면, 추가한 뒤
`game.lifecycleEventsProcessed`를 한 번 await하세요.


<a id="load-errors-are-no-longer-reported-by-gamewidgeterrorbuilder"></a>

#### 로드 오류가 더 이상 `GameWidget.errorBuilder`로 보고되지 않음

`GameWidget.errorBuilder`는 *게임의* 로딩이 실패했을 때 위젯을 보여 줍니다. 예전에는
`await add(child)`가 자식의 오류를 게임 자신의 `onLoad` future에 연결했기 때문에, 자식의 `onLoad`
실패도 잡아냈습니다. 이제 `add`가 future를 반환하지 않으므로 그 연결은 사라졌습니다. `onLoad`에서
예외를 던지는 자식은 더 이상 `errorBuilder`에 도달하지 않습니다.

해당 컴포넌트 자체는 트리에 추가되지 않으며, 게임의 나머지 부분은 계속 실행됩니다. 오류는 자식의
`loaded` future를 통해 보고되며, 아무것도 이를 await하고 있지 않으면 처리되지 않은 오류로 현재
`Zone`에 전달됩니다.

특정 자식에 대해 이전 동작을 원한다면, 부모의 `onLoad` 안에서 그 자식의 `loaded` future를
await하세요. 그러면 `errorBuilder`가 지켜보는 future에 오류가 다시 연결됩니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final level = Level();
    world.add(level);
    // Level.onLoad가 실패하면 여기서 예외가 발생하므로 errorBuilder가 표시됩니다.
    await level.loaded;
  }
}
```


<a id="gamewidgetcontrolled-renamed-to-gamewidgetmanaged"></a>

### `GameWidget.controlled`의 이름이 `GameWidget.managed`로 변경

`GameWidget.controlled` 생성자의 이름이 `GameWidget.managed`로 바뀌었습니다. 동작은 그대로이며 이름만
다릅니다.

`GameWidget.controlled`를 사용하는 모든 곳을 `GameWidget.managed`로 바꾸세요.

```dart
// 이전
GameWidget.controlled(
  gameFactory: MyGame.new,
);

// 이후
GameWidget.managed(
  gameFactory: MyGame.new,
);
```


<a id="gamepaused-renamed-to-gameispaused"></a>

### `Game.paused`의 이름이 `Game.isPaused`로 변경

Flame의 다른 boolean 속성과 일관되도록 `Game`의 `paused` getter와 setter 이름이 `isPaused`로
바뀌었습니다. 동작은 그대로이며 이름만 다릅니다.

`game.paused`를 사용하는 모든 곳을 `game.isPaused`로 바꾸세요.

```dart
// 이전
if (game.paused) {
  game.paused = false;
}

// 이후
if (game.isPaused) {
  game.isPaused = false;
}
```


<a id="children-is-now-a-componentlist-instead-of-an-orderedset"></a>

### `children`이 이제 `OrderedSet` 대신 `ComponentList`

`ordered_set` 패키지는 더 이상 사용되지 않으며, 자식들은 Flame이 소유한 `ComponentList`에 저장됩니다.
iterable 인터페이스, `query<T>()`, `register<T>()`는 바뀌지 않았으므로 대부분의 코드는 그대로
컴파일됩니다. 변수의 타입을 지정하기 위해 `package:ordered_set` 타입을 import했다면, 대신
(`package:flame/components.dart`의) `ComponentList`를 사용하세요.

```dart
// 이전
import 'package:ordered_set/ordered_set.dart';
OrderedSet<Component> children = component.children;

// 이후
ComponentList children = component.children;
```

알아 두어야 할 다른 변경 사항은 다음과 같습니다.

- `children.reversed()`는 이제 getter인 `children.reversed`입니다.
- `Component.strictQueryMode`가 제거되었습니다. strict 모드는 기본적으로 꺼져 있으며, 컴포넌트에서
  활성화하려면 `createComponentList()`가 `ComponentList(strictMode: true)`를 반환하도록 오버라이드하세요.
- `query<T>()` 결과는 이제 항상 우선순위 순서입니다.
- `children`을 순회하는 동안 컴포넌트를 제거하는 것은 허용됩니다. 순회하는 동안 리스트의 순서를 바꾸면
  `ConcurrentModificationError`가 발생합니다.


<a id="componentchildrenfactory-is-removed"></a>

### `Component.childrenFactory` 제거

전역 자식 컨테이너 팩토리가 사라졌습니다. 대신 컴포넌트에서 `createComponentList()`를
오버라이드하세요. 생성자는 해당 부모의 우선순위 정렬을 대체하는 선택적 `Comparator<Component>`를
받으므로, y-sort 같은 사용자 정의 정렬을 공식적으로 지원되는 방식으로 구현할 수 있습니다.

```dart
// 이전
Component.childrenFactory = () => OrderedSet.mapping<num, Component>((c) => c.priority);

// 이후
class YSortedWorld extends World {
  @override
  ComponentList createComponentList() {
    return ComponentList(
      comparator: (a, b) => (a as PositionComponent)
          .position.y
          .compareTo((b as PositionComponent).position.y),
    );
  }
}
```


<a id="componentupdatetree-is-non-virtual"></a>

### `Component.updateTree`는 이제 non-virtual

업데이트 단계는 게임이 소유한 평탄화된 순회 리스트를 따라 실행되므로, 더 이상 `updateTree`를
오버라이드할 수 없습니다. 이를 오버라이드하고 있었다면, 대신 `CustomTraversal`을 믹스인하고
`updateSubtree`를 오버라이드하세요. 표준 순회를 실행하려면 `super.updateSubtree(dt)`를 호출합니다.

```dart
// 이전
class SlowMotionArea extends Component {
  @override
  void updateTree(double dt) => super.updateTree(dt / 2);
}

// 이후
class SlowMotionArea extends Component with CustomTraversal {
  @override
  void updateSubtree(double dt) => super.updateSubtree(dt / 2);
}
```

`HasTimeScale`은 이제 `on CustomTraversal`로 선언되므로, `FlameGame`(이미 이를 믹스인하고 있음)이 아닌
컴포넌트는 그보다 먼저 `CustomTraversal`을 믹스인해야 합니다.

```dart
// 이전
class SlowWorld extends World with HasTimeScale {}

// 이후
class SlowWorld extends World with CustomTraversal, HasTimeScale {}
```

`HasTimeScale`의 타임 스케일이 `0`이면(또는 `pause()`를 호출하면) 이제 하위 트리 전체의 업데이트
단계가 `dt`를 `0`으로 해서 업데이트되는 대신 아예 멈춥니다. `Route.stopTime()`은 바로 이 동작에
의존합니다.
