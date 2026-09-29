# flame_texturepacker

**flame_texturepacker**
는 [CodeAndWeb's TexturePacker]로 생성한 스프라이트 시트를 Flame 게임에 불러올 수 있게 해 주는
브릿지 패키지입니다.

스프라이트 시트(또는 텍스처 아틀라스)는 여러 개의 작은 스프라이트를 하나로 묶은 큰 이미지입니다.
이렇게 하면 게임이 불러와야 하는 개별 텍스처의 수가 줄어들어 오버헤드가 낮아지고,
로딩 속도와 렌더링 성능이 향상될 수 있습니다.


<a id="installation"></a>

## 설치

프로젝트에 *flame_texturepacker*를 추가합니다.

```shell
flutter pub add flame_texturepacker
```

그런 다음 Dart 코드에서 import합니다.

```dart
import 'package:flame_texturepacker/flame_texturepacker.dart';
```


<a id="usage"></a>

## 사용법


<a id="loading-from-assets"></a>

### 에셋에서 불러오기

먼저 ``.atlas`` 데이터 파일과 스프라이트 시트 이미지를 assets 디렉터리에 추가하고 `pubspec.yaml`에서
참조합니다.

```yaml
flutter:
  assets:
    - assets/images/atlas_map.atlas
    - assets/images/sprite_sheet1.png
    - assets/images/sprite_sheet2.png
    - assets/images/sprite_sheet3.png
```

그런 다음 게임에서 아틀라스를 불러옵니다.

```dart
class MyGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    // 텍스처 아틀라스를 불러옵니다
    final atlas = await atlasFromAssets('assets/images/atlas_map.atlas');
    
    // 아틀라스를 사용해 스프라이트를 가져옵니다
    final sprite = atlas.findSpriteByName('robot_jump')!;
    add(SpriteComponent(sprite: sprite));
  }
}
```


## TexturePackerAtlas

`TexturePackerAtlas` 클래스는 텍스처 아틀라스를 다루기 위한 주요 인터페이스입니다. 스프라이트를 조회하고
가져오기 위한 여러 메서드를 제공합니다.


<a id="finding-sprites"></a>

### 스프라이트 찾기

**이름으로 단일 스프라이트 찾기:**

```dart
final jumpSprite = atlas.findSpriteByName('robot_jump')!;
final fallSprite = atlas.findSpriteByName('robot_fall')!;
```

**이름과 인덱스로 스프라이트 찾기:**

```dart
final sprite = atlas.findSpriteByNameIndex('robot_walk', 0);
```

**같은 이름을 가진 모든 스프라이트 찾기:**

인덱스가 붙은 스프라이트로 애니메이션을 만들 때 특히 유용합니다.

```dart
// 이름이 'robot_walk'인 모든 스프라이트를 가져옵니다
// (예: robot_walk_0, robot_walk_1 등)
final walkingSprites = atlas.findSpritesByName('robot_walk');

// 스프라이트 목록으로 애니메이션을 만듭니다
final walkingAnimation = SpriteAnimation.spriteList(
  walkingSprites,
  stepTime: 0.1,
  loop: true,
);

add(SpriteAnimationComponent(animation: walkingAnimation));
```


<a id="advanced-options"></a>

## 고급 옵션


<a id="whitelist-filtering"></a>

### 화이트리스트 필터링

메모리 사용량을 최적화하기 위해 불러올 스프라이트 이름의 화이트리스트를 지정할 수 있습니다. 이름에
화이트리스트 문자열 중 하나라도 포함된 스프라이트만 불러옵니다.

```dart
final atlas = await TexturePackerAtlas.load(
  'assets/images/atlas_map.atlas',
  whiteList: [ 'robot_walk' ]
);
```

스프라이트 중 일부만 필요한 큰 아틀라스에서 특히 유용합니다.


<a id="original-size-vs-packed-size"></a>

### 원본 크기와 패킹된 크기

TexturePacker는 공간을 절약하기 위해 스프라이트의 투명 픽셀을 잘라낼 수 있습니다. 기본적으로
`flame_texturepacker`는 원본(잘라내지 않은) 크기를 사용합니다. 이 동작은 다음과 같이 바꿀 수 있습니다.

```dart
final atlas = await TexturePackerAtlas.load(
  'assets/images/atlas_map.atlas',
  useOriginalSize: false, // 대신 잘라낸/패킹된 크기를 사용합니다
);
```


<a id="atlas-location"></a>

### 아틀라스 위치

``.atlas`` 경로는 전체 에셋 경로이므로 파일을 어디에나 둘 수 있습니다. 아틀라스 안에 나열된 페이지 텍스처는
아틀라스 파일이 있는 디렉터리를 기준으로 한 상대 경로로 해석됩니다.

```dart
final atlas = await atlasFromAssets('assets/atlases/atlas_map.atlas');
```


<a id="full-example"></a>

## 전체 예제

완전히 동작하는 예제는 [flame_texturepacker example]이나
[tutorial from CodeAndWeb]에서 찾을 수 있습니다.


[flame_texturepacker example]: https://github.com/flame-engine/flame/tree/main/packages/flame_texturepacker/example
[tutorial from CodeAndWeb]: https://www.codeandweb.com/texturepacker/tutorials/how-to-create-sprite-sheets-and-animations-with-flame-engine
[CodeAndWeb's TexturePacker]: https://www.codeandweb.com/texturepacker
