<a id="images"></a>

# 이미지

먼저 적절한 폴더 구조를 갖추고 다음과 같이 `pubspec.yaml`
파일에 파일들을 추가해야 합니다.

```yaml
flutter:
  assets:
    - assets/images/player.png
    - assets/images/enemy.png
```

이미지는 Flutter가 지원하는 모든 형식을 사용할 수 있습니다. JPEG, WebP, PNG, GIF, 애니메이션 GIF,
애니메이션 WebP, BMP, WBMP가 여기에 포함됩니다. 다른 형식은 추가 라이브러리가 필요합니다. 예를 들어 SVG
이미지는 `flame_svg` 라이브러리를 통해 로드할 수 있습니다.


<a id="loading-images"></a>

## 이미지 로드하기

Flame에는 `Images`라는 유틸리티 클래스가 포함되어 있어, 에셋 디렉터리의 이미지를 메모리로 쉽게 로드하고
캐시할 수 있습니다.

Flutter에는 이미지와 관련된 타입이 여러 가지 있으며, 로컬 에셋을 캔버스에 그릴 수 있는 `Image`로
올바르게 변환하는 과정은 다소 복잡합니다. 이 클래스를 사용하면 `drawImageRect` 메서드로
`Canvas`에 그릴 수 있는 `Image`를 얻을 수 있습니다.

이미지는 `pubspec.yaml`에 선언된 그대로의 전체 에셋 경로로 지정합니다. 예를 들면
`assets/images/player.png`와 같습니다. 앞에 아무것도 자동으로 붙지 않으며, 이 경로가 그대로
이미지가 캐시되는 키가 되므로 `load`를 여러 번 호출해도 안전합니다.

로드와 캐시 정리를 위한 메서드는 `load`, `loadAll`, `loadAllImages`,
`loadAllFromPattern`, `clear`, `clearCache`입니다. 두 `loadAll*` 메서드는 에셋 매니페스트를 스캔하며,
검색 범위를 지정하기 위한 `directory`를 필수로 받습니다. 예를 들면
`loadAllImages(directory: 'assets/images/')`와 같습니다.
이 메서드들은 이미지를 로드하는 `Future`를 반환합니다. 이미지를 어떤 식으로든 사용하려면 먼저 이 Future를
기다려야(await) 합니다. 이 Future를 바로 기다리고 싶지 않다면, 여러 개의 `load()` 작업을 시작한 다음
`Images.ready()` 메서드로 모두 한꺼번에 기다릴 수 있습니다.

이전에 캐시된 이미지를 동기적으로 가져오려면 `fromCache` 메서드를 사용할 수 있으며, 로드할 때 사용한 것과
같은 전체 경로를 전달합니다. 해당 키로 이전에 로드된 이미지가 없으면
예외가 발생합니다.

이미 로드된 이미지를 캐시에 추가하려면 `add` 메서드를 사용할 수 있으며, 캐시에서 이미지가 가질 키를
지정할 수 있습니다. 캐시에 있는 모든 키는 `keys`
getter로 가져올 수 있습니다.

게임 도중에 동적으로 이미지를 만들려면 `ImageExtension.fromPixels()`를 사용할 수도 있습니다.

`clear`와 `clearCache`의 경우, 캐시에서 제거되는 각 이미지에 대해 `dispose`가 호출된다는 점에
유의하세요. 따라서 이후에 해당 이미지를 사용하지 않도록 주의해야 합니다.


<a id="standalone-usage"></a>

### 단독 사용

직접 인스턴스를 생성해 수동으로 사용할 수 있습니다.

```dart
import 'package:flame/cache.dart';
final imagesLoader = Images();
Image image = await imagesLoader.load('assets/images/yourImage.png');
```

하지만 Flame은 직접 인스턴스를 생성하지 않고도 이 클래스를 사용할 수 있는 두 가지 방법을 제공합니다.


### Flame.images

`Flame` 클래스가 제공하는 싱글턴이 있으며, 이를 전역 이미지 캐시로 사용할 수 있습니다.

예시:

```dart
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

// 비동기 컨텍스트 내부에서
Image image = await Flame.images.load('assets/images/player.png');

final playerSprite = Sprite(image);
```


### Game.images

`Game` 클래스도 이미지 로드를 다루기 위한 몇 가지 유틸리티 메서드를 제공합니다. `Game`에는
`Images` 클래스의 인스턴스가 포함되어 있어, 게임에서 사용할 이미지 에셋을 로드하는 데 사용할 수 있습니다.
게임 위젯이 위젯 트리에서 제거되면 게임이 자동으로 캐시를 해제합니다.

`Game` 클래스의 `onLoad` 메서드는 초기 에셋을 로드하기에 아주 좋은 곳입니다.

예시:

```dart
class MyGame extends Game {

  Sprite player;

  @override
  Future<void> onLoad() async {
    // 이 작업에는 Sprite.load를 사용할 수도 있습니다.
    final playerImage = await images.load('assets/images/player.png');
    player = Sprite(playerImage);
  }
}
```

로드된 에셋은 게임 실행 중에 `images.fromCache`로 가져올 수도 있습니다. 예를 들면 다음과 같습니다.

```dart
class MyGame extends Game {

  // 속성 생략

  @override
  Future<void> onLoad() async {
    // 다른 로드 작업 생략
    await images.load('assets/images/bullet.png');
  }

  void shoot() {
    // 이것은 예시일 뿐이며, 실제 게임에서는 발사할 때마다 새로운 [Sprite] 객체를
    // 인스턴스화하지 않는 것이 좋습니다.
    final bulletSprite = Sprite(images.fromCache('assets/images/bullet.png'));
    _bullets.add(bulletSprite);
  }
}
```


<a id="loading-images-over-the-network"></a>

## 네트워크에서 이미지 로드하기

Flame 코어 패키지는 네트워크에서 이미지를 로드하는 내장 메서드를 제공하지 않습니다.

그 이유는 Flutter/Dart에 내장 http 클라이언트가 없어 별도의 패키지를 사용해야 하는데,
사용할 수 있는 패키지가 여러 개 있으므로 사용자에게 특정 패키지를 강제하지
않기 위해서입니다.

그렇긴 하지만, 사용자가 http 클라이언트 패키지를 선택하고 나면 네트워크에서 이미지를 로드하는 것은
매우 간단합니다. 다음 코드는 [http](https://pub.dev/packages/http) 패키지를 사용해 웹에서
`Image`를 가져오는 방법을 보여 줍니다.

```dart
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';

final response = await http.get('https://url.com/image.png');
final image = await decodeImageFromList(response.bytes);
```

```{note}
내장 캐시를 제공하는 바로 사용 가능한 네트워크 에셋 솔루션이 필요하다면
[`flame_network_assets`](https://pub.dev/packages/flame_network_assets)를 확인하세요.
```


## Sprite

Flame은 이미지 또는 이미지의 한 영역을 나타내는 `Sprite` 클래스를 제공합니다.

`Image`와, 스프라이트가 나타내는 이미지 조각을 정의하는 좌표를 전달해
`Sprite`를 만들 수 있습니다.

예를 들어 다음 코드는 전달된 파일의 전체 이미지를 나타내는 스프라이트를 만듭니다.

```dart
final image = await images.load('assets/images/player.png');
Sprite player = Sprite(image);
```

원본 이미지에서 스프라이트가 위치한 좌표를 지정할 수도 있습니다. 이를 통해
스프라이트 시트를 사용하고 메모리에 올라가는 이미지 수를 줄일 수 있습니다. 예를 들면 다음과 같습니다.

```dart
final image = await images.load('assets/images/player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);
```

기본값은 `srcPosition`이 `(0.0, 0.0)`, `srcSize`가 `null`입니다(`null`은 원본 이미지의
전체 너비/높이를 사용한다는 의미입니다).

`Sprite` 클래스에는 스프라이트를 `Canvas`에 렌더링할 수 있는 render 메서드가 있습니다.

```dart
final image = await images.load('assets/images/block.png');
Sprite block = Sprite(image);

// render 메서드 안에서
block.render(canvas, 16.0, 16.0); //canvas, width, height
```

render 메서드에는 크기를 전달해야 하며, 이미지는 그 크기에 맞게 조정됩니다.

`Sprite` 클래스의 모든 render 메서드는 선택적 이름 있는 파라미터 `overridePaint`로
`Paint` 인스턴스를 받을 수 있으며, 이 파라미터는 해당 render 호출에서 현재 `Sprite`의 paint 인스턴스를
대체합니다.

`Sprite`는 위젯으로도 사용할 수 있으며, 그러려면 `SpriteWidget` 클래스를 사용하면 됩니다.
다음은 전체
[스프라이트를 위젯으로 사용하는 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_widget_example.dart)입니다.


<a id="sprite-bleeding"></a>

### 스프라이트 블리딩

스프라이트를 서로 붙여서 렌더링할 때, 스프라이트의 가장자리가 맞닿아 있는 경우
그 사이에 "고스트 라인"이라고 부르는 렌더링 결함이 보일 수 있습니다.

이 현상은 특히 스프라이트가 정수가 아닌 좌표에 배치되었거나,
캔버스에 스케일이 적용되었을 때 발생합니다.

이 선들이 나타나는 이유는 컴퓨터 과학에서 부동소수점 수가 100% 정확하지 않기 때문입니다.
반올림 오차 때문에 스프라이트들이 맞닿아 있어야 함에도 실제로는 그렇게
렌더링되지 않습니다.

이를 피하는 한 가지 방법은 "블리딩(bleeding)"이라는 기법을 사용하는 것입니다. 스프라이트의 가장자리에
아주 작은 여백을 추가해, 렌더링할 때 스프라이트들이 약간 겹치도록 해서
고스트 라인이 렌더링되지 않게 하는 기법입니다.

Flame은 `Sprite`의 render 메서드에 `bleed` 파라미터를 사용해 이를 적용하는 방법을 제공합니다. 이
값은 스프라이트 가장자리에 적용할 블리딩의 양을 나타내는 double 값입니다.

예를 들어 다음과 같이 하면,

```dart
final image = await images.load('assets/images/player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);
playerFrame.render(canvas, 16.0, 16.0, bleed: 1.0);
```

스프라이트가 1.0의 블리드 값으로 렌더링됩니다. 즉, 스프라이트의 각 가장자리에
1픽셀씩 추가됩니다.

`SpriteComponent`를 사용하는 경우에도 블리딩 기능을 사용하는 방법은 아주 간단합니다.
컴포넌트 생성자의 `bleed` 속성에 값을 전달하기만 하면 됩니다.

```dart
final sprite = Sprite(...);

final spriteComponent = SpriteComponent(
  sprite: sprite,
  size: Vector2.all(16.0),
  bleed: 1.0, // 블리드 값
);
```

블리드 값의 크기는 스프라이트의 크기에 따라 달라진다는 점에 유의하세요. 따라서 100x100 크기의
스프라이트에서는 블리드 값 1.0이 큰 차이를 만들지 않을 수 있습니다.


<a id="sprite-rasterization"></a>

### 스프라이트 래스터화

스프라이트를 래스터화한다는 것은 해당 스프라이트에서 이미지의 선택된 영역을 추출해
메모리에 저장하고, 그 래스터화된 이미지를 담은 새로운 Sprite를 반환하는 과정입니다.

이는 여러 용도로 사용할 수 있으며, 가장 유용한 것 중 하나는 스프라이트 시트를 사용할 때
텍스처 누출(texture leaking)을 피하는 것입니다.

텍스처 누출은 위에서 설명한 문제와 같은 이유(부동소수점
반올림 오차)로 발생할 수 있으며, 스프라이트 선택 영역 바깥 부분까지 렌더링되게 만듭니다.

렌더링 전에 스프라이트 선택 영역을 추출해 래스터화하면 선택된 영역만 담은 이미지를
렌더링하게 되므로 이 문제를 피할 수 있습니다.

`RasterSpriteComponent`를 사용하는 예:

```dart
final sprite = await Sprite.load('assets/images/flame.png');
final rasterSpriteComponent = RasterSpriteComponent(
  sprite: sprite,
  size: Vector2.all(16.0),
);
```

`RasterSpriteComponent`를 사용하면 로드될 때 자동으로 스프라이트를
래스터화합니다.

스프라이트를 수동으로 래스터화해야 한다면 `Sprite.rasterize` 메서드를 사용할 수 있습니다.

```dart
final image = await images.load('assets/images/player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);

final rasterizedSprite = await playerFrame.rasterize();
```

기본적으로 `rasterize` 메서드는 래스터화된 이미지를 캐시하기 위해 `Flame.images`를 사용하며,
스프라이트의 원본 위치와 크기를 기반으로 키를 자동 생성합니다. 래스터화된 이미지에 사용자 정의
키를 사용하거나 다른 캐시 객체를 사용하고 싶다면 선택적
파라미터로 전달할 수 있습니다.

```dart
final rasterizedSprite = await playerFrame.rasterize(
  cacheKey: 'custom_key_for_rasterized_image',
  images: Images(),
);
```


## SpriteBatch

스프라이트 시트(이미지 아틀라스라고도 하며, 내부에 더 작은 이미지들을 담고 있는 이미지)를 가지고 있고
이를 효율적으로 렌더링하고 싶다면 `SpriteBatch`가 그 일을 대신 처리해 줍니다.

이미지의 파일 이름을 전달한 다음, 변환(위치, 스케일, 회전)과 선택적인 색상과 함께
이미지의 여러 부분을 설명하는 사각형들을 추가하세요.

렌더링할 때는 `Canvas`와 선택적인 `Paint`, `BlendMode`, `CullRect`를 사용합니다.

편의를 위해 `SpriteBatchComponent`도 제공됩니다.

사용 방법은
[SpriteBatch 예제](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprites/sprite_batch_example.dart)를 참고하세요.


## ImageComposition

여러 이미지를 하나의 이미지로 합치고 싶을 때가 있습니다. 이를
[합성(Compositing)](https://en.wikipedia.org/wiki/Compositing)이라고 합니다. 예를 들어
[SpriteBatch](#spritebatch) API로 그리기 호출을 최적화할 때 유용합니다.

이런 경우를 위해 Flame은 `ImageComposition` 클래스를 제공합니다. 이 클래스를 사용하면 여러
이미지를 각자의 위치에 배치해 새로운 이미지에 추가할 수 있습니다.

```dart
final composition = ImageComposition()
  ..add(image1, Vector2(0, 0))
  ..add(image2, Vector2(64, 0));
  ..add(image3,
    Vector2(128, 0),
    source: Rect.fromLTWH(32, 32, 64, 64),
  );
  
Image image = await composition.compose();
Image imageSync = composition.composeSync();
```

보시다시피 이미지를 합성하는 두 가지 버전이 있습니다. 비동기 방식에는 `ImageComposition.compose()`를
사용하세요. 또는 새로운 `ImageComposition.composeSync()` 함수를 사용하면 `Picture.toImageSync` 함수의
이점을 활용해 이미지를 GPU 컨텍스트로 래스터화할 수 있습니다.

**참고:** 이미지 합성은 비용이 큽니다. 성능에 큰 영향을 주므로 매 틱마다 실행하는 것은
권장하지 않습니다. 대신 합성 결과를 미리 렌더링해 두고 출력 이미지를 재사용하는 것을
권장합니다.


<a id="animation"></a>

## 애니메이션

Animation 클래스는 스프라이트의 순환 애니메이션을 만드는 데 도움을 줍니다.

같은 크기의 스프라이트 리스트와 stepTime(다음 프레임으로 넘어가는 데 걸리는
시간(초))을 전달해 만들 수 있습니다.

```dart
final a = SpriteAnimationTicker(SpriteAnimation.spriteList(sprites, stepTime: 0.02));
```

애니메이션을 만든 후에는 `update` 메서드를 호출하고, 게임 인스턴스에서 현재 프레임의
스프라이트를 렌더링해야 합니다.

예시:

```dart
class MyGame extends Game {
  SpriteAnimationTicker a;

  MyGame() {
    a = SpriteAnimationTicker(SpriteAnimation(...));
  }

  void update(double dt) {
    a.update(dt);
  }

  void render(Canvas c) {
    a.getSprite().render(c);
  }
}
```

스프라이트 리스트를 생성하는 더 나은 대안은 `fromFrameData` 생성자를 사용하는 것입니다.

```dart
const amountOfFrames = 8;
final a = SpriteAnimation.fromFrameData(
    imageInstance,
    SpriteAnimationFrame.sequenced(
      amount: amountOfFrames,
      textureSize: Vector2(16.0, 16.0),
      stepTime: 0.1,
    ),
);
```

이 생성자를 사용하면 스프라이트 시트로 `Animation`을 아주 쉽게 만들 수 있습니다.

생성자에는 이미지 인스턴스와, 애니메이션을 설명하는 데 사용할 수 있는 몇 가지 파라미터를 담은
프레임 데이터를 전달합니다. 모든 파라미터를 확인하려면 `SpriteAnimationFrameData` 클래스에서 사용할 수 있는
생성자에 대한 문서를 참고하세요.

애니메이션 제작에 Aseprite를 사용한다면, Flame은 Aseprite 애니메이션의
JSON 데이터를 어느 정도 지원합니다. 이 기능을 사용하려면 스프라이트 시트의 JSON 데이터를 내보낸 다음,
다음과 같은 코드를 사용하면 됩니다.

```dart
final image = await images.load('assets/images/chopper.png');
final jsonData = await assets.readJson('assets/chopper.json');
final animation = SpriteAnimation.fromAsepriteData(image, jsonData);
```

**참고:** Flame은 트리밍된 스프라이트 시트를 지원하지 않습니다. 따라서 스프라이트 시트를 이런 방식으로
내보내면 스프라이트의 원래 크기가 아닌 트리밍된 크기를 갖게 됩니다.

애니메이션은 생성된 후 update 메서드와 render 메서드를 가집니다. 후자는 현재 프레임을 렌더링하고,
전자는 내부 시계를 진행시켜 프레임을 업데이트합니다.

애니메이션은 보통 `SpriteAnimationComponent` 안에서 사용하지만, 여러
애니메이션을 가진 사용자 정의 컴포넌트를 만들 수도 있습니다.

더 자세히 알아보려면
[애니메이션을 위젯으로 사용하기](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_animation_widget_example.dart)의 전체 예제 코드를 확인하세요.


## SpriteSheet

스프라이트 시트는 같은 스프라이트의 여러 프레임을 담은 큰 이미지로, 애니메이션을 정리하고
저장하는 아주 좋은 방법입니다. Flame은 스프라이트 시트를 다루기 위한 매우 간단한 유틸리티 클래스를
제공하며, 이를 사용해 스프라이트 시트 이미지를 로드하고 그로부터 애니메이션을 추출할 수도
있습니다. 다음은 사용 방법을 보여 주는 간단한 예제입니다.

```dart
import 'package:flame/sprite.dart';

final spriteSheet = SpriteSheet(
  image: imageInstance,
  srcSize: Vector2.all(16.0),
);

final animation = spriteSheet.createAnimation(0, stepTime: 0.1);
```

이제 애니메이션을 직접 사용하거나 애니메이션 컴포넌트에서 사용할 수 있습니다.

`SpriteSheet.createFrameData` 또는 `SpriteSheet.createFrameDataFromId`를 사용해 개별
`SpriteAnimationFrameData`를 가져와 사용자 정의 애니메이션을 만들 수도 있습니다.

```dart
final animation = SpriteAnimation.fromFrameData(
  imageInstance, 
  SpriteAnimationData([
    spriteSheet.createFrameDataFromId(1, stepTime: 0.1), // id로
    spriteSheet.createFrameData(2, 3, stepTime: 0.3), // 행, 열
    spriteSheet.createFrameDataFromId(4, stepTime: 0.1), // id로
  ]),
);
```

애니메이션이 필요 없고 `SpriteSheet`의 `Sprite` 인스턴스만 필요하다면
`getSprite` 또는 `getSpriteById` 메서드를 사용할 수 있습니다.

```dart
spriteSheet.getSpriteById(2); // id로
spriteSheet.getSprite(0, 0); // 행, 열
```

사용 방법에 대한 자세한 내용은 [`SpriteSheet` 클래스](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprites/sprite_sheet_example.dart)의
전체 예제를 참고하세요.


## HasAutoBatchedChildren

Flame은 `HasAutoBatchedChildren` 믹스인을 통해 렌더링 성능 향상을 위한 자동 스프라이트 배칭을
도입했습니다. 이 믹스인을 사용하면 스프라이트 컴포넌트 그룹을 아틀라스당 한 번의
그리기 호출로 렌더링할 수 있어, 특히 비슷한 스프라이트를 많이 다룰 때 렌더링 오버헤드가 크게 줄고
성능이 향상됩니다.


<a id="purpose"></a>

### 목적

`HasAutoBatchedChildren` 믹스인은 같은 아틀라스 이미지를 공유하는 스프라이트 또는
애니메이션 컴포넌트 그룹(적, 총알, 파티클 등)이 있는 상황을 위해 설계되었습니다. 이들의 렌더링을
배치 처리함으로써 Flame은 그래픽 애플리케이션의 주요 성능 병목인 그리기 호출 횟수를
최소화합니다.


<a id="when-to-use"></a>

### 사용 시점

다음 조건을 만족하는 `SpriteComponent` 또는 `SpriteAnimationComponent` 자식이 많을 때 이 믹스인을 사용하세요.

- 같은 아틀라스 이미지를 사용함
- 스케일이 균일함
- 사용자 정의 데코레이터나 스냅샷 캐싱이 필요 없음
- 복잡한 paint 효과가 없음

적 웨이브나 파티클 시스템처럼 비슷한 객체들의 그룹에 이상적입니다.


<a id="how-to-use"></a>

### 사용 방법

배칭을 활성화하려면 그룹 컴포넌트에 믹스인을 추가하기만 하면 됩니다.

```dart
import 'package:flame/components.dart';
import 'package:flame/src/components/mixins/has_auto_batched_children.dart';

class EnemyGroup extends PositionComponent with HasAutoBatchedChildren {
  // SpriteComponent 또는 SpriteAnimationComponent 자식을 추가합니다
}
```

런타임에 배칭을 켜고 끌 수 있습니다.

```dart
final group = EnemyGroup();
group.batchingEnabled = false; // 개별 렌더링으로 돌아갑니다
```

이 믹스인은 자식별 렌더링(`renderChild`)과 자식 렌더링 이후
훅(`afterChildrenRendered`)을 가로채는 방식으로 동작합니다. 배치 렌더링이 가능한 자식들을 모아 두었다가,
올바른 렌더링 순서를 유지하기 위해 우선순위 경계에서 배치를 플러시합니다.


<a id="example"></a>

### 예제

```dart
class BulletGroup extends PositionComponent with HasAutoBatchedChildren {
  // 총알을 나타내는 SpriteComponent 자식을 추가합니다
}

// 그룹에 총알을 추가합니다
bulletGroup.add(BulletSpriteComponent(...));
```


<a id="rogue-shooter-example"></a>

#### Rogue Shooter 예제

이 믹스인의 실제 사용 사례는 [Rogue Shooter 게임 예제](https://examples.flame-engine.org/#/Sample_Games_Rogue_Shooter)를
참고하세요.
